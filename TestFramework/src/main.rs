#[macro_use]
extern crate log;

use std::fs::{create_dir, OpenOptions};
use std::path::Path;
use std::process::exit;
use std::sync::mpsc;
use std::time::Duration;

use chrono::Local;
use log::{error, info};
use simple_error::SimpleError;

use reader::ReaderObj;
use traits::{Generator, Reader, Testcase};

use crate::make::run_make;
use crate::reader::ReadResultObj;
use flexi_logger::{Logger, opt_format};
use indicatif::{ProgressBar, ProgressStyle};
use structopt::StructOpt;
use cli::Opt;
use crate::generators::poly1305::generator::TestcasePoly1305;
use crate::generators::scalarmult::generator::ScalarMultTestcase;
use crate::generators::crypto_box::generator::CryptoBoxTestcase;
use crate::generators::crypto_stream::generator::TestcaseStream;
use crate::generators::crypto_secretbox::generator::SecretboxTestcase;
use std::sync::mpsc::Receiver;

mod cli;
mod make;
mod generators;
mod traits;
mod utils;
mod reader;
mod functions_and_testcases;

pub struct Poly1305Generator {}
pub struct ScalarmultGenerator {}
pub struct CryptoboxGenerator {}
pub struct StreamGenerator {}
pub struct SecretBoxGenerator {}


#[allow(non_camel_case_types)]
pub enum Function {
    poly1305(Poly1305Generator),
    scalarmult(ScalarmultGenerator),
    cryptobox(CryptoboxGenerator),
    salsa20(StreamGenerator),
    secretbox(SecretBoxGenerator),
}

#[allow(non_camel_case_types)]
pub enum TestcaseEnum {
    poly130(TestcasePoly1305),
    scalarmult(ScalarMultTestcase),
    cryptobox(CryptoBoxTestcase),
    salsa20(TestcaseStream),
    secretbox(SecretboxTestcase),
}

fn main() -> Result<(), SimpleError> {
    Logger::with_env_or_str("info")
        .log_to_file()
        .directory("log_files")
        .format(opt_format)
        .start().unwrap();

    let args: Opt = Opt::from_args();

    if !args.all && args.functions.is_empty() {
        println!("Either all flag must be set or a function must be given to test");
        exit(1);
    }

    let functions;
    if args.all {
        functions = Function::iterator();
    } else {
        functions = args.functions.iter();
    }

    let (tx, rx) = mpsc::channel::<ReadResultObj>();
    ReaderObj::start_reader_thread( tx);

    for function in functions {
        let generator = function;

        let bar = ProgressBar::new(args.tests);
        bar.set_message(format!("Testing {}", generator.get_generator_name()).as_str());

        bar.set_style(ProgressStyle::default_bar()
            .template("{msg} {wide_bar:.cyan/blue} {pos}/{len} {elapsed_precise}")
        );

        run_test(generator, args.attempts, args.tests, &bar, &rx)?;

        bar.finish();
    }


    Ok(())
}


fn run_test( generator: &impl Generator, attempts: i64, tests: u64, bar: &ProgressBar, rx: &Receiver<ReadResultObj>) -> Result<(), SimpleError> {
    let dt = Local::now();
    let opt = Opt::from_args();
    let x;
    if opt.no_output {
        x = format!("/tmp/{}_{}", generator.get_generator_name(), dt.format("%Y-%m-%d %H:%M"));
    } else {
        x = format!("results/{}_{}", generator.get_generator_name(), dt.format("%Y-%m-%d %H:%M"));
    }

    let dir = Path::new(&x);
    if create_dir(dir).is_err(){
        error!("Could not create directory for the output")
    }
    info!("{}", dir.display());


    let mut output = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(dir.join(Path::new("results.txt"))).expect("Couldn't create output file");
    let mut raw_output = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(dir.join(Path::new("raw_output.txt"))).expect("Couldn't create raw_output file");



    let timeout = generator.get_timeout();

    for _testcase_run in 0..tests {
        let mut testcase = generator.generate_testcase();
        for _attempt in 0..attempts {
            if _attempt == attempts - 1 {
                //error!("Too many failed attempt on this input:\n {}", testcase);
                return Err(SimpleError::new("Too many failed make commands please do a manual check"));
            }

            if run_make().is_err() {
                error!("run  make failed");
                continue;
            }

            match rx.recv_timeout(Duration::from_secs(timeout)) {
                Ok(result) => {
                    testcase.copy_result_variables(result);
                    testcase.print_raw_output(&mut raw_output);
                    testcase.print_result(&mut output);

                    if !testcase.is_correct() {
                        error!("Result is incorrect for testcase:\n {}", testcase);
                        exit(1);
                    } else {
                        info!("Result was correct");
                        bar.inc(1);
                    }
                    break;
                }
                Err(_) => {
                    error!("Did not get the result within {} seconds rerunning make", timeout);
                    error!("Expected: {}", testcase.get_expected());
                    continue;
                }
            }
        }
    }
    Ok(())
}


