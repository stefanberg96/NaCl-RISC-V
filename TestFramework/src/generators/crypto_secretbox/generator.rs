use std::fmt::{Display, Error, Formatter};
use std::io::Write;
use std::str::FromStr;

use rand::prelude::*;
use crate::traits::{Generator, ReadResult, Testcase};
use crate::utils::{generate_testcasefile, u8_to_string_variable, u8_to_string};
use crate::{SecretBoxGenerator, TestcaseEnum};
use microsalt::secretbox::xsalsa20poly1305::{secretbox, SecretboxKey, SecretboxNonce};

const MESSAGELEN: usize = 1024;

pub struct SecretboxTestcase {
    message: [u8;MESSAGELEN],
    key: [u8; 32],
    nonce: [u8;24],
    expected_result:  [u8;MESSAGELEN],
    result:  [u8;MESSAGELEN],
    cycle_counts: Vec<f64>,
    raw_output: Vec<String>,
}

impl Display for SecretboxTestcase {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        writeln!(f, "Message: {}", u8_to_string(&self.message))?;
        writeln!(f, "Key: {}", u8_to_string(&self.key))?;
        writeln!(f, "Nonce: {}", u8_to_string(&self.nonce))?;
        writeln!(f, "Expected result: {}", u8_to_string(&self.expected_result))?;
        writeln!(f, "Result: {}", u8_to_string(&self.result))?;
        writeln!(f, "Cycle counts: {:?}", &self.cycle_counts)?;

        Ok(())
    }
}

impl Default for SecretboxTestcase {
    fn default() -> Self {
        SecretboxTestcase {
            message: [0;MESSAGELEN],
            key: [0; 32],
            nonce: [0; 24],
            expected_result: [0;MESSAGELEN],
            result: [0;MESSAGELEN],
            cycle_counts: Vec::new(),
            raw_output: Vec::new(),
        }
    }
}


impl Testcase for SecretboxTestcase {
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
        for i in 0..MESSAGELEN{
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
        self.result.copy_from_slice(read_result.get_result());
        self.raw_output = read_result.get_raw_output().clone();
    }
}

impl Generator for SecretBoxGenerator {
    fn get_generator_name(&self) -> String {
        String::from_str("secretbox").unwrap()
    }

    fn generate_testcase(&self) -> TestcaseEnum {
        let mut rng = rand::thread_rng();
        let mut message: [u8; MESSAGELEN] = [0; MESSAGELEN];
        let mut key: [u8; 32] = [0;32];
        let mut nonce: [u8;24]= [0;24];
        rng.fill_bytes(&mut message);
        rng.fill(&mut key);
        rng.fill(&mut nonce);
        let mut expected_result = [0;MESSAGELEN];
        for i in 0..32{
            message[i]=0;
        }

        //print variables
        let mut variables: Vec<String> = Vec::new();

        variables.push(format!("unsigned char c[{}];", MESSAGELEN));

        let message_string = u8_to_string_variable(&message, "m");
        variables.push(message_string);

        let nonce_string = u8_to_string_variable(&nonce, "n");
        variables.push(nonce_string);

        let key_string = u8_to_string_variable(&key, "k");
        variables.push(key_string);

        let n: SecretboxNonce = nonce;
        let k: SecretboxKey = key;

        let _ = secretbox(&mut expected_result, &message, &n,&k);
        let resultprint = format!("printresult(c, {});", MESSAGELEN);
        let functioncall = format!("crypto_secretbox(c,m, {}, n, k);", MESSAGELEN);
        generate_testcasefile(variables.clone(), functioncall.as_str(), resultprint.as_str());
        TestcaseEnum::secretbox(SecretboxTestcase { message, key, nonce, expected_result, ..Default::default() })
    }

    fn get_timeout(&self) -> u64 {
        60
    }

    fn get_outputlen(&self) -> usize {
        MESSAGELEN
    }
}


