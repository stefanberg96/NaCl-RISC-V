use std::io::{BufReader, BufRead, Read};
use std::fs::File;
use std::path::Path;
use std::error::Error;
use regex::Regex;
use std::sync::mpsc::Sender;
use std::thread;
use crate::traits::{Reader, ReadResult};

pub struct ReadResultObj {
    result: Vec<u8>,
    cycle_counts: Vec<f64>,
    raw_output: Vec<String>,
}

impl ReadResultObj {
    fn add_to_raw(&mut self, line: String) {
        if line.trim().len() == 0 {
            return;
        }

//    let ignore_list = vec!("ATE0-->ATE0", "ATE0-->OK", "AT+BLEINIT=0-->OK", "AT+CWMODE=0-->OK", "OK", "Bench Clock Reset Complete", "Send Flag Timed Out Busy. Giving Up.",
//                           "Receive Length Timed Out Busy", "AT+BLEINIT=0-->Send Flag Timed Out Busy. Giving Up.", "ATE0--> Send Flag error: #0 #0 #0 #0 AT+BLEINIT=0-->AT+BLEINIT=0", "AT+CWMODE=0-->AT+CWMODE=0");
//    if ignore_list.contains(&line.trim()) || line.contains("Bench Clock Reset Complete") {
//        return;
//    }

        self.raw_output.push(line);
    }
}

impl ReadResult for ReadResultObj{
    fn get_raw_output(&self) -> &Vec<String> {
        &self.raw_output
    }

    fn get_result(&self) -> &Vec<u8> {
        &self.result
    }

    fn get_cycle_count(&self) -> &Vec<f64> {
        &self.cycle_counts
    }
}

pub struct ReaderObj {
    reader: BufReader<File>,
    outputlen: usize,
}

impl ReaderObj {
    pub fn new(outputlen: usize) -> ReaderObj {
        let path = Path::new("/dev/ttyACM1");
        let file = match File::open(&path) {
            Err(e) => panic!("Couldn't open /dev/ttyACM1: {}", e.description()),
            Ok(file) => file,
        };

        ReaderObj { reader: BufReader::new(file), outputlen }
    }
}

impl Reader for ReaderObj {
    fn start_reader_thread(&self, tx: Sender<ReadResultObj>) {
        let outputlen = self.outputlen;

        thread::spawn(move || {
            let reader = ReaderObj::new(outputlen);

            for result in reader {
                let _ = tx.send(result);
            }
        });
    }
}

impl Iterator for ReaderObj {
    type Item = ReadResultObj;

    fn next(&mut self) -> Option<ReadResultObj> {
        let output_regex_str = format!("([a-f0-9]{{ {} }})", 2*self.outputlen);
        let cycle_regex = Regex::new("(?:([0-9]+), )").expect("Cycle regex is invalid");
        let output_regex = Regex::new(output_regex_str.as_str()).expect("Output regex is invalid");

        let mut result = ReadResultObj { result: vec!(), cycle_counts: vec!(), raw_output: vec!()};
        for line in self.reader.by_ref().lines() {

            let line = line.unwrap_or_default();
            result.add_to_raw(line.clone());

            if line.starts_with("Cycle counts:") {
                let z: Vec<f64> = cycle_regex.captures_iter(line.as_str())
                    .map(|c| c[1].parse::<f64>())
                    .filter_map(Result::ok)
                    .collect();
                result.cycle_counts = z;
            } else if line.starts_with("Result:") {
                let hex = output_regex.captures(line.as_str()).unwrap();
                let bytes = hex::decode(&hex[0]).expect("Failed to decode output result from hex to bytes");
                result.result = bytes;

                return Some(result);
            }
        }
        return None;
    }
}


