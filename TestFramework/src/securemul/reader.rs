use std::io::{BufReader, BufRead, Read, Cursor};
use std::fs::File;
use std::path::Path;
use std::error::Error;
use regex::Regex;
use core::fmt;
use std::fmt::Formatter;
use std::sync::mpsc::Sender;
use std::thread;
use std::str::FromStr;
use byteorder::{ReadBytesExt, BigEndian};

#[derive(Clone)]
pub struct SecuremulResult {
    pub result: u64,
    pub cycle_counts: Vec<f64>,
    pub raw_output: Vec<String>,
}

pub const TIMEOUT: u64 = 10;

impl fmt::Display for SecuremulResult {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        writeln!(f, "Cycle counts:{:?}", self.cycle_counts).expect("write failed");
        writeln!(f, "Result:{}", self.result).expect("write failed");
        Ok(())
    }
}

struct Reader {
    reader: BufReader<File>,
}

impl Reader {
    pub fn new_securemul() -> Reader {
        let path = Path::new("/dev/ttyACM1");
        let file = match File::open(&path) {
            Err(e) => panic!("Couldn't open /dev/ttyACM1: {}", e.description()),
            Ok(file) => file,
        };


        Reader { reader: BufReader::new(file) }
    }
}

impl Iterator for Reader {
    type Item = SecuremulResult;

    fn next(&mut self) -> Option<SecuremulResult> {
        let output_regex_str = format!("0x([0-9a-f]+)");
        let cycle_regex = Regex::new("(?:([0-9]+), )").expect("Cycle regex is invalid");
        let output_regex = Regex::new(output_regex_str.as_str()).expect("Output regex is invalid");


        let mut result = SecuremulResult { result: 0, cycle_counts: Vec::new(), raw_output: Vec::new() };
        for line in self.reader.by_ref().lines() {
            let line = line.unwrap_or_default();
            add_to_raw(&mut result, line.clone());
            if cycle_regex.is_match(line.as_str()) {
                let z: Vec<f64> = cycle_regex.captures_iter(line.as_str())
                    .map(|c| c[1].parse::<f64>())
                    .filter_map(Result::ok)
                    .collect();
                result.cycle_counts = z;
            } else if output_regex.is_match(line.as_str()) {
                println!("{}", line.as_str());
                let mut hexstr = &output_regex.captures(line.as_str()).unwrap()[1];
                let z = String::from("0") + hexstr;
                if hexstr.len() % 2 != 0 {
                    hexstr = z.as_str();
                }
                let mut hex = hex::decode(hexstr).unwrap_or_default();

                let mut cursor = Cursor::new(hex);
                result.result = cursor.read_u64::<BigEndian>().expect("couldn't parse array");

                return Some(result);
            }
        }
        return None;
    }
}


fn add_to_raw(result: &mut SecuremulResult, line: String) {
    if line.trim().len() == 0 {
        return;
    }

    let ignore_list = vec!("ATE0-->ATE0", "AT+BLEINIT=0-->OK", "AT+CWMODE=0-->OK", "OK", "Bench Clock Reset Complete", "Send Flag Timed Out Busy. Giving Up.",
                           "Receive Length Timed Out Busy", "AT+BLEINIT=0-->Send Flag Timed Out Busy. Giving Up.");
    if !ignore_list.contains(&line.trim()) {
        result.raw_output.push(line);
    }
}

pub fn start_reader_thread(tx: Sender<SecuremulResult>) {
    thread::spawn(move || {
        let reader = Reader::new_securemul();

        for result in reader {
            let _ = tx.send(result);
        }
    });
}


