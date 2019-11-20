#[macro_use]
extern crate log;

use std::{thread};
use std::sync::mpsc;
use std::sync::mpsc::Sender;
use std::time::Duration;
use crate::poly1305::poly1305_reader::{Poly1305Reader, Poly1305Result};
use crate::poly1305::poly1305_generator;
use simple_error::SimpleError;
use env_logger::{Builder, WriteStyle};
use log::{error, info, LevelFilter};
use crate::make::run_make;

mod make;
mod poly1305;

fn main() -> Result<(), SimpleError> {
    let mut builder = Builder::new();

    builder.filter(None, LevelFilter::Info)
        .write_style(WriteStyle::Always)
        .init();


    // create a thread that reads the output from the board
    let (tx, rx) = mpsc::channel();
    start_reader_thread(tx);

    //main loop that runs the tests
    loop {
        let testcase = poly1305_generator::generate_testcase();
        for _attempt in 0..3 {
            run_make()?;
            match rx.recv_timeout(Duration::from_secs(10)) {
                Ok(result) => {
                    if testcase.expected_result == result.result {
                        info!("Result was correct and took {} cycles", result.cycle_count);
                    } else {
                        error!("Result was not correct!\n {:?} \n{}", testcase, result);
                    }

                    break;
                }
                Err(_) => continue,
            }
        }
    }
}

fn start_reader_thread(tx: Sender<Poly1305Result>) {
    thread::spawn(move || {
        let reader = Poly1305Reader::new();

        for result in reader {
            let _ = tx.send(result);
        }
    });
}




