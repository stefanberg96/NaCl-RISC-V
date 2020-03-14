use std::fmt::{Display, Error, Formatter};
use std::io::Write;
use std::str::FromStr;

use rand::prelude::*;
use sodiumoxide::crypto::onetimeauth;

use crate::traits::{Generator, ReadResult, Testcase};
use crate::utils::{generate_testcasefile, u8_to_string_variable, u8_to_string};
use crate::{Poly1305Generator, TestcaseEnum};

const MESSAGELEN: usize = 132;

pub struct TestcasePoly1305 {
    message: [u8; MESSAGELEN],
    key: [u8; 32],
    expected_result: [u8; 16],
    result: [u8; 16],
    cycle_counts: Vec<f64>,
    raw_output: Vec<String>,
}

impl Display for TestcasePoly1305 {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        writeln!(f, "Message: {}", u8_to_string(&self.message))?;
        writeln!(f, "Key: {}", u8_to_string(&self.key))?;
        writeln!(f, "Expected result: {}", u8_to_string(&self.expected_result))?;
        writeln!(f, "Result: {}", u8_to_string(&self.result))?;
        writeln!(f, "Cycle counts: {:?}", &self.cycle_counts)?;

        Ok(())
    }
}

impl Default for TestcasePoly1305 {
    fn default() -> Self {
        TestcasePoly1305 {
            message: [0; MESSAGELEN],
            key: [0; 32],
            expected_result: [0; 16],
            result: [0; 16],
            cycle_counts: Vec::new(),
            raw_output: Vec::new(),
        }
    }
}


impl Testcase for TestcasePoly1305 {
    fn print_raw_output(&self, file: &mut (impl Write + std::io::Write)) {
        for line in &self.raw_output {
            let _ = writeln!(file, "{}", line);
        }
        let _ = writeln!(file, "Expected result: {}", self.get_expected());
    }


    fn print_result(&self, file: &mut impl Write) {
        let _ = writeln!(file, "{}", &self);
    }

    fn is_correct(&self) -> bool {
        self.result == self.expected_result
    }

    fn get_expected(&self) -> String {
        format!("{}", u8_to_string(&self.expected_result))
    }

    fn copy_result_variables(&mut self, read_result: impl ReadResult) {
        self.cycle_counts = read_result.get_cycle_count().clone();
        self.result.copy_from_slice(&read_result.get_result());
        self.raw_output = read_result.get_raw_output().clone();
    }
}

impl Generator for Poly1305Generator {
    fn get_generator_name(&self) -> String {
        String::from_str("poly1305").unwrap()
    }

    fn generate_testcase(&self) -> TestcaseEnum {
        let mut rng = rand::thread_rng();
        let mut message: [u8; MESSAGELEN] = [0; MESSAGELEN];
        rng.fill_bytes(&mut message);

        let poly1305_key = onetimeauth::gen_key();
        let key = poly1305_key.0;

        //print variables
        let mut variables: Vec<String> = Vec::new();
        variables.push(String::from_str("unsigned char a[16];").unwrap());

        let message_string = u8_to_string_variable(&message, "c");
        variables.push(message_string);

        let rc_string = u8_to_string_variable(&key, "rs");
        variables.push(rc_string);

        let expected_result = onetimeauth::authenticate(&message, &poly1305_key).0;
        generate_testcasefile(variables.clone(), "crypto_onetimeauth(a,c,132,rs);", "printresult(a, 16);");
        TestcaseEnum::poly130(TestcasePoly1305 { message, key, expected_result, ..Default::default() })
    }

    fn get_timeout(&self) -> u64 {
        15
    }

    fn get_outputlen(&self) -> usize {
        16
    }
}


