use std::io::{BufReader, BufRead, Read};
use std::fs::{File};
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



        Reader { reader: BufReader::new(file), outputlen: 32}
    }
}

impl Iterator for Reader {
    type Item = Poly1305Result;

    fn next(&mut self) -> Option<Poly1305Result> {
        let output_regex_str = format!("([a-f0-9]{{ {} }})", self.outputlen);
        let cycle_regex = Regex::new("(?:([0-9]+), )").expect("Cycle regex is invalid");
        let output_regex = Regex::new(output_regex_str.as_str()).expect("Output regex is invalid");


        let mut result = Poly1305Result { result: [0; 16], cycle_counts: Vec::new() };
        for line in self.reader.by_ref().lines() {
            let line = line.unwrap_or_default();
            if cycle_regex.is_match(line.as_str()) {
                let z: Vec<f64> = cycle_regex.captures_iter(line.as_str())
                    .map(|c| c[1].parse::<f64>())
                    .filter_map(Result::ok)
                    .collect();
                result.cycle_counts = z;
            } else if output_regex.is_match(line.as_str()) {
                let bytes = hex::decode(line.as_str()).expect("Failed to decode output result from hex to bytes");
                for i in 0..16 {
                    result.result[i] = bytes[i];
                }
                return Some(result);
            }
        }
        return None;
    }
}


pub fn start_reader_thread(tx: Sender<Poly1305Result>) {
    thread::spawn(move || {
        let reader = Reader::new_poly1305();

        for result in reader {
            let _ = tx.send(result);
        }
    });
}

