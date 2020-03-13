use std::fmt::Display;
use std::sync::mpsc::Sender;
use crate::ReadResultObj;
use crate::TestcaseEnum;


pub trait Testcase: Display{

    fn print_raw_output(&self, file: &mut impl std::io::Write ) where Self: Sized;
    fn print_result(&self, file: &mut impl std::io::Write )  where Self: Sized;
    fn is_correct(&self) -> bool;
    fn get_expected(&self) -> String;
    fn copy_result_variables(&mut self, read_result: impl ReadResult)  where Self: Sized;
}

pub trait ReadResult {
    fn get_raw_output(&self) -> &Vec<String> ;
    fn get_result(&self) -> &Vec<u8>;
    fn get_cycle_count(&self) -> &Vec<f64>;
}

pub trait Reader {
    fn start_reader_thread(&self, channel: Sender<ReadResultObj>);
}

pub trait Generator {
    fn get_generator_name(&self) -> String;
    fn generate_testcase(&self) -> TestcaseEnum;
    fn get_timeout(&self) -> u64;
    fn get_outputlen(&self) -> usize;
}

