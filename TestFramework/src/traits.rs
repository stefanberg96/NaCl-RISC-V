use std::fmt::Display;
use std::sync::mpsc::Sender;
use crate::ReadResultObj;


pub trait Testcase: Display{
    type ExpectedItem:Display;
    fn print_raw_output(&self, file: &mut impl std::io::Write);
    fn print_result(&self, file: &mut impl std::io::Write);
    fn is_correct(&self) -> bool;
    fn get_expected(&self) ->  Self::ExpectedItem;
    fn copy_result_variables(&mut self, read_result: impl ReadResult);
}

pub trait ReadResult {
    fn get_raw_output(&self) -> &Vec<String>;
    fn get_result(&self) -> &Vec<u8>;
    fn get_cycle_count(&self) -> &Vec<f64>;
}

pub trait Reader {
    fn start_reader_thread(&self, channel: Sender<ReadResultObj>);
}

pub trait Generator {
    type Item:Testcase;
    fn get_generator_name(&self) -> String;
    fn generate_testcase(&self) -> Self::Item;
    fn get_timeout(&self) -> u64;
    fn get_outputlen(&self) -> usize;
}

