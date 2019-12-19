use std::io::{BufReader, BufRead, Read};
use std::fs::File;
use std::path::Path;
use std::error::Error;
use regex::Regex;
use core::fmt;
use std::fmt::Formatter;
use std::sync::mpsc::Sender;
use std::thread;

#[derive(Clone)]
pub struct Poly1305Result {
    pub result: [u8; 16],
    pub cycle_counts: Vec<f64>,
    pub raw_output: Vec<String>,
}


impl fmt::Display for Poly1305Result {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        writeln!(f, "Cycle counts:{:?}", self.cycle_counts).expect("write failed");
        for i in 0..15 {
            write!(f, "0x{:02x}, ", self.result[i]).expect("write failed");
        }
        writeln!(f, "0x{:02x}", self.result[15]).expect("write failed");
        Ok(())
    }
}

struct Reader {
    reader: BufReader<File>,
    outputlen: usize,
}

impl Reader {
    pub fn new_poly1305() -> Reader {
        let path = Path::new("/dev/ttyACM1");
        let file = match File::open(&path) {
            Err(e) => panic!("Couldn't open /dev/ttyACM1: {}", e.description()),
            Ok(file) => file,
        };


        Reader { reader: BufReader::new(file), outputlen: 32 }
    }
}

impl Iterator for Reader {
    type Item = Poly1305Result;

    fn next(&mut self) -> Option<Poly1305Result> {
        let output_regex_str = format!("([a-f0-9]{{ {} }})", self.outputlen);
        let cycle_regex = Regex::new("(?:([0-9]+), )").expect("Cycle regex is invalid");
        let output_regex = Regex::new(output_regex_str.as_str()).expect("Output regex is invalid");

        let mut result = Poly1305Result { result: [0; 16], cycle_counts: Vec::new(), raw_output: Vec::new() };
        for line in self.reader.by_ref().lines() {
            let line = line.unwrap_or_default();
            add_to_raw(&mut result, line.clone());
            if line.starts_with("Cycle counts:          ") {
                let z: Vec<f64> = cycle_regex.captures_iter(line.as_str())
                    .map(|c| c[1].parse::<f64>())
                    .filter_map(Result::ok)
                    .collect();
                result.cycle_counts = z;
            } else if line.starts_with("Result: ") {
                let hex = output_regex.captures(line.as_str()).unwrap();
                let bytes = hex::decode(&hex[0]).expect("Failed to decode output result from hex to bytes");
                for i in 0..16 {
                    result.result[i] = bytes[i];
                }
                return Some(result);
            }
        }
        return None;
    }
}


fn add_to_raw(result: &mut Poly1305Result, line: String) {
    if line.trim().len() == 0 {
        return;
    }

    let ignore_list = vec!("ATE0-->ATE0", "ATE0-->OK", "AT+BLEINIT=0-->OK", "AT+CWMODE=0-->OK", "OK", "Bench Clock Reset Complete", "Send Flag Timed Out Busy. Giving Up.",
                           "Receive Length Timed Out Busy", "AT+BLEINIT=0-->Send Flag Timed Out Busy. Giving Up.", "ATE0--> Send Flag error: #0 #0 #0 #0 AT+BLEINIT=0-->AT+BLEINIT=0","AT+CWMODE=0-->AT+CWMODE=0");
    if ignore_list.contains(&line.trim()) || line.contains( "Bench Clock Reset Complete"){
       return
    }


    result.raw_output.push(line);
}

pub fn start_reader_thread(tx: Sender<Poly1305Result>) {
    thread::spawn(move || {
        let reader = Reader::new_poly1305();

        for result in reader {
            let _ = tx.send(result);
        }
    });
}

