
use std::io::Write;
use std::str::FromStr;
use std::fmt::{Display, Formatter, Error};
use crate::utils::*;
use crate::traits::*;
use crate::{CryptoboxGenerator, TestcaseEnum};
use microsalt::boxy::*;
use rand::prelude::*;
use crate::generators::crypto_box::curve25519xsalsa20poly1305::*;

#[allow(non_snake_case)]
pub struct CryptoBoxTestcase {
    pk: [u8;32],
    sk: [u8;32],
    nonce: [u8;24],
    message: [u8;MESSAGELEN],
    expected_result: [u8;MESSAGELEN],
    result:[u8;MESSAGELEN],
    cycle_counts: Vec<f64>,
    raw_output: Vec<String>,
}

const MESSAGELEN:usize = 132;

impl Default for CryptoBoxTestcase {
    fn default() -> Self {
        let zero_byte = [0; 32];
        CryptoBoxTestcase {
            pk: zero_byte,
            sk: zero_byte,
            nonce: [0;24],
            message: [0;MESSAGELEN],
            expected_result: [0;MESSAGELEN],
            result: [0;MESSAGELEN],
            cycle_counts: vec!(),
            raw_output: vec!(),
        }
    }
}

impl Display for CryptoBoxTestcase {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        writeln!(f, "sk: {}", u8_to_string(&self.sk))?;
        writeln!(f, "pk: {}", u8_to_string(&self.pk))?;
        writeln!(f, "n: {}", u8_to_string(&self.nonce))?;
        writeln!(f, "m: {}", u8_to_string(&self.message))?;
        writeln!(f, "Expected result: {}", u8_to_string(&self.expected_result))?;
        writeln!(f, "Result: {}", u8_to_string(&self.result))?;
        writeln!(f, "Cycle counts: {:?}", &self.cycle_counts)?;
        Ok(())
    }
}

impl Testcase for CryptoBoxTestcase {
    fn print_raw_output(&self, file: &mut impl Write) {
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
        format!("{:?}", u8_to_string(&self.expected_result))
    }

    fn copy_result_variables(&mut self, read_result: impl ReadResult) {
        self.cycle_counts = read_result.get_cycle_count().clone();
        self.raw_output = read_result.get_raw_output().clone();
        self.result.copy_from_slice(read_result.get_result());
    }
}

impl Generator for CryptoboxGenerator {
    fn get_generator_name(&self) -> String {
        String::from_str("crypto_box").unwrap()
    }

    fn generate_testcase(&self) -> TestcaseEnum {
        let mut rng = rand::thread_rng();
        let mut receiver_key :BoxPublicKey = [0;32];
        let mut sender_key :BoxSecretKey = [0;32];
        let mut nonce:[u8;24]=[0;24];

        box_keypair(&mut receiver_key, &mut sender_key);

        let sk = sender_key;
        let pk = receiver_key;

        let mut message: [u8; MESSAGELEN] = [0; MESSAGELEN];
        rng.fill_bytes(&mut message);
        rng.fill_bytes(&mut nonce);

        for i in 0..32{
            message[i]=0;
        }

        let mut variables = Vec::new();
        let message_str = u8_to_string_variable(&message, "m");
        variables.push(message_str);
        let nonce_string = u8_to_string_variable(&nonce, "n");
        variables.push(nonce_string);
        let pk_string = u8_to_string_variable(&pk, "pk");
        variables.push(pk_string);
        let sk_string = u8_to_string_variable(&sk, "sk");
        variables.push(sk_string);
        variables.push(format!("unsigned char c[{}];", MESSAGELEN));

        let resultprint = format!("printresult(c,{});", MESSAGELEN);
        let functioncall = format!("crypto_box(c, m, {}, n, pk, sk);", MESSAGELEN);
        generate_testcasefile(variables.clone(), functioncall.as_str(), resultprint.as_str());

        let mut cipher:[u8;MESSAGELEN]=[0;MESSAGELEN];
        let n :BoxNonce = nonce;
        let _ = box_(&mut cipher, &message, &n, &receiver_key, &sender_key);

        TestcaseEnum::cryptobox(CryptoBoxTestcase { expected_result:cipher , message, nonce, pk, sk, ..Default::default() })
    }

    fn get_timeout(&self) -> u64 {
        240
    }

    fn get_outputlen(&self) -> usize {
        MESSAGELEN
    }
}

