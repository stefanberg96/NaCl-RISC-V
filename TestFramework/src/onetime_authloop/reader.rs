

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
pub struct AuthLoopResult {
    pub cycle_counts: Vec<f64>,
}


impl fmt::Display for AuthLoopResult {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        writeln!(f, "Cycle counts:{:?}", self.cycle_counts).expect("write failed");

        Ok(())
    }
}

struct Reader {
    reader: BufReader<File>,
    outputlen: usize,
}

impl Reader {
    pub fn new_authloop() -> Reader {
        let path = Path::new("/dev/ttyACM1");
        let file = match File::open(&path) {
            Err(e) => panic!("Couldn't open /dev/ttyACM1: {}", e.description()),
            Ok(file) => file,
        };



        Reader { reader: BufReader::new(file), outputlen: 32}
    }
}

impl Iterator for Reader {
    type Item = AuthLoopResult;

    fn next(&mut self) -> Option<AuthLoopResult> {
        let cycle_regex = Regex::new("(?:([0-9]+), )").expect("Cycle regex is invalid");

        let mut result = AuthLoopResult {  cycle_counts: Vec::new() };
        for line in self.reader.by_ref().lines() {
            let line = line.unwrap_or_default();
            if cycle_regex.is_match(line.as_str()) {
                let z: Vec<f64> = cycle_regex.captures_iter(line.as_str())
                    .map(|c| c[1].parse::<f64>())
                    .filter_map(Result::ok)
                    .collect();
                result.cycle_counts = z;
                return Some(result);
            }
        }
        return None;
    }
}


pub fn start_reader_thread(tx: Sender<AuthLoopResult>) {
    thread::spawn(move || {
        let reader = Reader::new_authloop();

        for result in reader {
            let _ = tx.send(result);
        }
    });
}

