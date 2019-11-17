use std::io::{BufReader, BufRead, Read};
use std::fs::File;
use std::path::Path;
use std::error::Error;
use regex::Regex;

#[derive(Debug)]
pub struct Poly1305Result {
    result: [u8; 16],
    cycle_count: i64,
}

pub struct Poly1305Reader {
    reader: BufReader<File>,
    finished: bool,
}

impl Poly1305Reader {
    pub fn new() -> Poly1305Reader {
        let path = Path::new("/dev/ttyACM1");
        let file = match File::open(&path) {
            Err(e) => panic!("Couldn't open /dev/ttyACM1: {}", e.description()),
            Ok(file) => file,
        };

        Poly1305Reader { reader: BufReader::new(file), finished: false }
    }
}

impl Iterator for Poly1305Reader {
    type Item = Poly1305Result;

    fn next(&mut self) -> Option<Poly1305Result> {
        match self.finished {
            true => None,
            false => {
                let mut result = Poly1305Result{result: [0;16], cycle_count:0};
                for line in self.reader.by_ref().lines() {
                    let line = line.unwrap_or_default();
                    println!("{}",line);
                    let cycle_regex = Regex::new("This took ([0-9]+) cycles").expect("Cycle regex is invalid");
                    let output_regex = Regex::new("([a-f0-9]{32})").expect("Output regex is invalid");
                    if cycle_regex.is_match(line.as_str()) {
                        let captures = cycle_regex.captures(line.as_str()).expect("Cannot get captures from cycle regex");
                        result.cycle_count = captures[1].parse::<i64>().unwrap_or_default();
                    } else if output_regex.is_match(line.as_str()) {
                        let bytes = hex::decode(line.as_str()).expect("Failed to decode output result from hex to bytes");
                        for i in 0..16 {
                            result.result[15 - i] = bytes[i];
                        }
                        return Some(result);
                    }
                }
                return None;
            }
        }
    }
}
