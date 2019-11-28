use std::io::{BufReader, BufRead, Read};
use std::fs::{File};
use std::path::Path;
use std::error::Error;
use regex::Regex;
use core::fmt;
use std::fmt::Formatter;
use std::sync::mpsc::Sender;
use std::thread;
use std::str::FromStr;

#[derive(Clone)]
pub struct SecuremulResult {
    pub result: u64,
    pub cycle_counts: Vec<f64>,
}


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



        Reader { reader: BufReader::new(file)}
    }
}

impl Iterator for Reader {
    type Item = SecuremulResult;

    fn next(&mut self) -> Option<SecuremulResult> {
        let output_regex_str = format!("0x([0-9a-f]+)");
        let cycle_regex = Regex::new("(?:([0-9]+), )").expect("Cycle regex is invalid");
        let output_regex = Regex::new(output_regex_str.as_str()).expect("Output regex is invalid");


        let mut result = SecuremulResult { result: 0, cycle_counts: Vec::new() };
        for line in self.reader.by_ref().lines() {
            let line = line.unwrap_or_default();
            if cycle_regex.is_match(line.as_str()) {
                let z: Vec<f64> = cycle_regex.captures_iter(line.as_str())
                    .map(|c| c[1].parse::<f64>())
                    .filter_map(Result::ok)
                    .collect();
                result.cycle_counts = z;
            } else if output_regex.is_match(line.as_str()) {
                println!("{}",line.as_str());
                let hexstr = &output_regex.captures(line.as_str()).unwrap()[1];
                let hex = hex::decode(hexstr).unwrap_or_default();
                let mut val = 0;
                for i in 0.. hex.len(){
                    val+= (hex[i]<<((i*8) as u8)) as u64;
                }

                result.result = val;
                return Some(result);
            }
        }
        return None;
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

