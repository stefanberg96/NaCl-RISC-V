use std::fmt::{Display, Error, Formatter};
use std::io::Write;
use std::str::FromStr;
use sodiumoxide::crypto::stream::salsa20::{stream, gen_key, gen_nonce};

use crate::traits::{Generator, ReadResult, Testcase};
use crate::utils::{generate_testcasefile, u8_to_string_variable, u8_to_string};
use crate::{StreamGenerator, TestcaseEnum};

const CLEN: usize = 1024;

pub struct TestcaseStream {
    key: [u8; 32],
    nonce: [u8;8],
    expected_result: Vec<u8>,
    result: Vec<u8>,
    cycle_counts: Vec<f64>,
    raw_output: Vec<String>,
}

impl Display for TestcaseStream {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        writeln!(f, "Key: {}", u8_to_string(&self.key))?;
        writeln!(f, "Nonce: {}", u8_to_string(&self.nonce))?;
        writeln!(f, "Expected result: {}", u8_to_string(&self.expected_result))?;
        writeln!(f, "Result: {}", u8_to_string(&self.result))?;
        writeln!(f, "Cycle counts: {:?}", &self.cycle_counts)?;

        Ok(())
    }
}

impl Default for TestcaseStream {
    fn default() -> Self {
        TestcaseStream {
            key: [0; 32],
            nonce: [0; 8],
            expected_result: vec!(),
            result: vec!(),
            cycle_counts: Vec::new(),
            raw_output: Vec::new(),
        }
    }
}


impl Testcase for TestcaseStream {
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
        for i in 0..CLEN{
            if self.result[i] != self.expected_result[i]{
                return false;
            }
        }
        return true
    }

    fn get_expected(&self) -> String {
        format!("{}", u8_to_string(&self.expected_result))
    }

    fn copy_result_variables(&mut self, read_result: impl ReadResult) {
        self.cycle_counts = read_result.get_cycle_count().clone();
        self.result = read_result.get_result().clone();
        self.raw_output = read_result.get_raw_output().clone();
    }
}

impl Generator for StreamGenerator {
    fn get_generator_name(&self) -> String {
        String::from_str("stream_xsalsa20").unwrap()
    }

    fn generate_testcase(&self) -> TestcaseEnum {

        let key = gen_key();
        let nonce = gen_nonce();

        //print variables
        let mut variables: Vec<String> = Vec::new();
        variables.push(format!("unsigned char c[{}];", CLEN));

        let nonce_string = u8_to_string_variable(&nonce.0, "n");
        variables.push(nonce_string);

        let key_string = u8_to_string_variable(&key.0, "k");
        variables.push(key_string);

        let expected_result = stream(CLEN, &nonce, &key);
        let functioncall = format!("crypto_stream_salsa20(c,{}, n, k);",CLEN);
        let resultprint = format!("printresult(c, {});", CLEN);

        generate_testcasefile(variables.clone(), functioncall.as_str(), resultprint.as_str());
        TestcaseEnum::salsa20(TestcaseStream { nonce: nonce.0, key: key.0, expected_result, ..Default::default() })
    }

    fn get_timeout(&self) -> u64 {
        60
    }

    fn get_outputlen(&self) -> usize {
        CLEN
    }
}



