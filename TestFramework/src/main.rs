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
use crate::poly1305::generator::Poly1305Generator;
use crate::reader::ReadResultObj;
use flexi_logger::{Logger, opt_format};
use indicatif::{ProgressBar, ProgressStyle};
use structopt::StructOpt;
use std::str::FromStr;
use std::slice::Iter;


mod make;
mod poly1305;
//mod securemul;
//mod onetime_authloop;
//mod mulmod;
//mod karatsuba;
//mod scalarmult;
mod traits;
mod utils;
mod reader;

#[allow(non_camel_case_types)]
enum Function {
    poly1305
}

impl FromStr for Function {
    type Err = SimpleError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "poly1305" => Ok(Function::poly1305),
            _ => Err(SimpleError::new("Could not parse the function")),
        }
    }
}
impl Function {

    fn iterator() -> Iter<'static, Function> {
        static FUNCTIONS: [Function;1] = [Function::poly1305];
        FUNCTIONS.iter()
    }
}

#[derive(StructOpt)]
#[structopt(name="test framework", about="Testframework to fuzz test the NaCl implementation")]
struct Opt{
    #[structopt(long, help= "Put result in /tmp/{test name}")]
    no_output: bool,

    #[structopt(short, long, help = "Test for all available functions")]
    all: bool,

    #[structopt(short, long, help="Which of the functions to check")]
    functions: Vec<Function>,

    #[structopt(short,  long, help="The amount of test to run per function", default_value="500")]
    runs: u64,

    #[structopt(long, help="The number of attempts before a test is skipped", default_value ="4")]
    attempts: u64,

}



fn main() -> Result<(), SimpleError> {
    Logger::with_env_or_str("info")
        .log_to_file()
        .directory("log_files")
        .format(opt_format)
        .start().unwrap();

    let args:Opt  = Opt::from_args();

    if !args.all && args.functions.is_empty(){
        println!("Either all flag must be set or a function must be given to test");
        exit(1);
    }

    let functions;
    if args.all{
        functions = Function::iterator();
    }else{
        functions = args.functions.iter();
    }

    for function in functions {

        let generator = create_generator(function);
        let reader = ReaderObj::new(generator.get_outputlen());
        let bar = ProgressBar::new(args.runs);
        bar.set_message("Testing Poly1305");

        bar.set_style(ProgressStyle::default_bar()
            .template("{msg} {wide_bar:.cyan/blue} {pos}/{len} {elapsed}")
        );

        run_test(reader, generator, args.attempts, args.runs, &bar)?;

        bar.finish();
    }


    Ok(())
}

fn create_generator(function: &Function) -> impl Generator{
    match function {
        _poly1305 => Poly1305Generator{}
    }
}

fn run_test(reader: impl Reader, generator: impl Generator, attempts: u64, runs: u64, bar: &ProgressBar) -> Result<(), SimpleError> {
    let dt = Local::now();
    let opt = Opt::from_args();
    let x;
    if opt.no_output{
        x = format!("/tmp/{}_{}", generator.get_generator_name(), dt.format("%Y-%m-%d %H:%M"));
    }else{
        x = format!("results/{}_{}", generator.get_generator_name(), dt.format("%Y-%m-%d %H:%M"));
    }

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

    let (tx, rx) = mpsc::channel::<ReadResultObj>();
    reader.start_reader_thread(tx);
    let timeout = generator.get_timeout();

    for _testcase_run in 0..runs {
        let mut testcase = generator.generate_testcase();
        for _attempt in 0..attempts {
            if _attempt == attempts - 1 {
                error!("Too many failed attempt on this input:\n {}", testcase);
                return Err(SimpleError::new("Too many failed commands please do a manual check"));
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


