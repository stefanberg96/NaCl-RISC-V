#[macro_use]
extern crate log;

use std::sync::mpsc;
use std::time::Duration;
use crate::karatsuba::reader::{start_reader_thread, TIMEOUT};
use crate::karatsuba::generator;
use simple_error::SimpleError;
use env_logger::{Builder, WriteStyle};
use log::{error, info, LevelFilter};
use crate::make::run_make;
use plotlib::boxplot::BoxPlot;
use plotlib::view::CategoricalView;
use plotlib::page::Page;
use std::fs::{create_dir, OpenOptions};
use std::path::Path;
use chrono::Local;
use std::io::Write;
use crate::karatsuba::generator::{generate_testcase, generator_name};
use core::fmt;
use std::process::exit;


mod make;
mod poly1305;
mod securemul;
mod onetime_authloop;
mod mulmod;
mod karatsuba;
mod scalarmult;

fn main() -> Result<(), SimpleError> {
    let mut builder = Builder::new();

    builder.filter(None, LevelFilter::Info)
        .write_style(WriteStyle::Always)
        .init();
    let dt = Local::now();
    let x = format!("results/{}_{}", generator_name(),dt.format("%Y-%m-%d %H:%M"));
    let dir = Path::new(&x);
    let _ = create_dir(dir);

    let mut output = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(dir.join(Path::new("results.txt"))).expect("Couldn't create output file");
    let mut raw_output = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(dir.join(Path::new("raw_output.txt"))).expect("Couldn't create output file");

    // create a thread that reads the output from the board
    let (tx, rx) = mpsc::channel();
    start_reader_thread(tx);

    let messagelen = 135;
    //main loop that runs the tests
    let mut cycles_times = vec![];
    for _i in 0..500 {
        let testcase = generate_testcase();
        for _attempt in 0..4 {
            if _attempt == 3 {
                error!("Too many failed attempt on this input:\n {:?}", testcase);
                return Err(SimpleError::new("Too many failed commands please do a manual check"));
            }

            if run_make().is_err() {
                error!("run make failed");
                continue;
            }

            match rx.recv_timeout(Duration::from_secs(TIMEOUT)) {
                Ok(result) => {
                    info!("Calculation took {} instructions ", result.cycle_counts[8]);
                    cycles_times.push(result.cycle_counts.clone());

                    let _ = writeln!(output, "{:?}\n {}", testcase.variables, result);
                    for line in result.raw_output{
                        let _ = writeln!(raw_output, "{}", line);
                    }
                    let _ = writeln!(raw_output, "Expected result: {}", &testcase.expected_result);
                    if result.result != testcase.expected_result{
                        error!("multiplication not correct \n
                        Result: {}\n
                        Expected: {}", &result.result, &testcase.expected_result);
                        exit(1);
                    }
                    break;
                }
                Err(_) => {
                    error!("Did not get the result within {} seconds rerunning make", TIMEOUT);
                    error!("Expected: {}", &testcase.expected_result);
                    continue;
                }
            }
        }
    }

    Ok(())
}


struct HexSlice<'a>(&'a [u8]);

impl<'a> HexSlice<'a> {
    fn new<T>(data: &'a T) -> HexSlice<'a>
        where T: ?Sized + AsRef<[u8]> + 'a
    {
        HexSlice(data.as_ref())
    }
}

// You can even choose to implement multiple traits, like Lower and UpperHex
impl<'a> fmt::Display for HexSlice<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for byte in self.0 {
            // Decide if you want to pad out the value here
            write!(f, "{:02x}", byte)?;
        }
        Ok(())
    }
}
