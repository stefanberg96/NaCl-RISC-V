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
use std::str::FromStr;
use std::slice::Iter;
use std::io::Write;
use crate::traits::ReadResult;
use std::ops::{Deref, DerefMut};
use crate::poly1305::generator::TestcasePoly1305;
use crate::scalarmult::generator::ScalarMultTestcase;
use std::fmt::{Formatter, Error};


mod make;
mod poly1305;
mod scalarmult;
mod traits;
mod utils;
mod reader;

struct Poly1305Generator {}

struct ScalarmultGenerator {}


#[allow(non_camel_case_types)]
enum Function {
    poly1305(Poly1305Generator),
    scalarmult(ScalarmultGenerator),
}

#[allow(non_camel_case_types)]
enum TestcaseEnum {
    poly130(TestcasePoly1305),
    scalarmult(ScalarMultTestcase),
}

impl FromStr for Function {
    type Err = SimpleError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "poly1305" => Ok(Function::poly1305(Poly1305Generator {})),
            "scalarmult" => Ok(Function::scalarmult(ScalarmultGenerator {})),
            _ => Err(SimpleError::new("Could not parse the function")),
        }
    }
}

impl Function {
    fn iterator() -> Iter<'static, Function> {
        static FUNCTIONS: [Function; 2] = [Function::poly1305(Poly1305Generator {}), Function::scalarmult(ScalarmultGenerator {})];
        FUNCTIONS.iter()
    }
}

#[derive(StructOpt)]
#[structopt(name = "test framework", about = "Testframework to fuzz test the NaCl implementation")]
struct Opt {
    #[structopt(long, help = "Put result in /tmp/{test name}")]
    no_output: bool,

    #[structopt(short, long, help = "Test for all available functions")]
    all: bool,

    #[structopt(short, long, help = "Which of the functions to check")]
    functions: Vec<Function>,

    #[structopt(short, long, help = "The amount of tests function", default_value = "500")]
    tests: u64,

    #[structopt(long, help = "The number of attempts before a test is skipped", default_value = "4")]
    attempts: u64,

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

    for function in functions {
        let generator = function;
        let reader = ReaderObj::new(generator.get_outputlen());
        let bar = ProgressBar::new(args.tests);
        bar.set_message("Testing Poly1305");

        bar.set_style(ProgressStyle::default_bar()
            .template("{msg} {wide_bar:.cyan/blue} {pos}/{len} {elapsed}")
        );

        run_test(reader, generator, args.attempts, args.tests, &bar)?;

        bar.finish();
    }


    Ok(())
}


impl Generator for Function {
    fn get_generator_name(&self) -> String {
        match self {
            Function::scalarmult(gen) => gen.get_generator_name(),
            Function::poly1305(gen) => gen.get_generator_name()
        }
    }

    fn generate_testcase(&self) -> TestcaseEnum {
        match self {
            Function::scalarmult(gen) => gen.generate_testcase(),
            Function::poly1305(gen) => gen.generate_testcase()
        }
    }

    fn get_timeout(&self) -> u64 {
        match self {
            Function::scalarmult(gen) => gen.get_timeout(),
            Function::poly1305(gen) => gen.get_timeout()
        }
    }

    fn get_outputlen(&self) -> usize {
        match self {
            Function::scalarmult(gen) => gen.get_outputlen(),
            Function::poly1305(gen) => gen.get_outputlen()
        }
    }
}

impl Testcase for TestcaseEnum {
    fn print_raw_output(&self, file: &mut impl Write) where Self: Sized {
        match self {
            TestcaseEnum::scalarmult(tc) => tc.print_raw_output(file),
            TestcaseEnum::poly130(tc) => tc.print_raw_output(file)
        }
    }

    fn print_result(&self, file: &mut impl Write) where Self: Sized {
        match self {
            TestcaseEnum::scalarmult(tc) => tc.print_result(file),
            TestcaseEnum::poly130(tc) => tc.print_result(file)
        }
    }

    fn is_correct(&self) -> bool {
        match self {
            TestcaseEnum::scalarmult(tc) => tc.is_correct(),
            TestcaseEnum::poly130(tc) => tc.is_correct()
        }
    }

    fn get_expected(&self) -> String {
        match self {
            TestcaseEnum::scalarmult(tc) => tc.get_expected(),
            TestcaseEnum::poly130(tc) => tc.get_expected()
        }
    }

    fn copy_result_variables(&mut self, read_result: impl ReadResult) where Self: Sized {
        match self {
            TestcaseEnum::scalarmult(tc) => tc.copy_result_variables(read_result),
            TestcaseEnum::poly130(tc) => tc.copy_result_variables(read_result)
        }
    }
}

impl std::fmt::Display for TestcaseEnum{
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        match self{
            TestcaseEnum::scalarmult(tc) => tc.fmt(f),
            TestcaseEnum::poly130(tc) => tc.fmt(f)
        }
    }
}

//
//impl Testcase for Box<dyn Testcase>{
//    fn print_raw_output(&self, file: &mut impl Write) where Self: Sized {
//        let z = self.deref();
//
//        self.deref().print_raw_output(file)
//    }
//
//    fn print_result(&self, f: &mut impl Write) where Self: Sized {
//        self.deref().print_result(f)
//    }
//
//    fn is_correct(&self) -> bool {
//        self.deref().is_correct()
//    }
//
//    fn get_expected(&self) -> String {
//        self.deref().get_expected()
//    }
//
//    fn copy_result_variables(&mut self, read_result: impl ReadResult) where Self: Sized {
//        self.deref_mut().copy_result_variables(read_result)
//    }
//}

fn run_test(reader: impl Reader, generator: &impl Generator, attempts: u64, tests: u64, bar: &ProgressBar) -> Result<(), SimpleError> {
    let dt = Local::now();
    let opt = Opt::from_args();
    let x;
    if opt.no_output {
        x = format!("/tmp/{}_{}", generator.get_generator_name(), dt.format("%Y-%m-%d %H:%M"));
    } else {
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

    for _testcase_run in 0..tests {
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


