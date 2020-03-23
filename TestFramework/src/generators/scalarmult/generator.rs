use rand::Rng;
use std::io::Write;
use std::str::FromStr;
use sodiumoxide::crypto::scalarmult::*;
use std::fmt::{Display, Formatter, Error};
use crate::utils::*;
use crate::traits::*;
use crate::{ScalarmultGenerator, TestcaseEnum};

#[allow(non_snake_case)]
pub struct ScalarMultTestcase {
    n: Scalar,
    G: GroupElement,
    expected_result: GroupElement,
    result: GroupElement,
    cycle_counts: Vec<f64>,
    raw_output: Vec<String>,
}

impl Default for ScalarMultTestcase {
    fn default() -> Self {
        let zero_byte = [0; 32];
        ScalarMultTestcase {
            n: Scalar::from_slice(&zero_byte).unwrap(),
            G: GroupElement::from_slice(&zero_byte).unwrap(),
            expected_result: GroupElement::from_slice(&zero_byte).unwrap(),
            result: GroupElement::from_slice(&zero_byte).unwrap(),
            cycle_counts: vec!(),
            raw_output: vec!(),
        }
    }
}

impl Display for ScalarMultTestcase {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        writeln!(f, "n: {}", u8_to_string(&self.n.0))?;
        writeln!(f, "G: {}", u8_to_string(&self.G.0))?;
        writeln!(f, "Expected result: {}", u8_to_string(&self.expected_result.0))?;
        writeln!(f, "Result: {}", u8_to_string(&self.result.0))?;
        writeln!(f, "Cycle counts: {:?}", &self.cycle_counts)?;
        Ok(())
    }
}

impl Testcase for ScalarMultTestcase {
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
        &self.result == &self.expected_result
    }

    fn get_expected(&self) -> String {
        format!("{}", u8_to_string(&self.expected_result.0))
    }

    fn copy_result_variables(&mut self, read_result: impl ReadResult) {
        self.cycle_counts = read_result.get_cycle_count().clone();
        self.raw_output = read_result.get_raw_output().clone();
        let result = GroupElement::from_slice(&read_result.get_result()).unwrap();
        self.result = result;
    }
}

impl Generator for ScalarmultGenerator {
    fn get_generator_name(&self) -> String {
        String::from_str("scalarmult").unwrap()
    }

    fn generate_testcase(&self) -> TestcaseEnum {
        let mut rng = rand::thread_rng();
        // 32 byte scalar
        let mut n_bytes: [u8; 32] = rng.gen();
        n_bytes[0] &= 248;
        n_bytes[31] &= 127;
        n_bytes[31] |= 64;
        let n = Scalar::from_slice(&n_bytes).unwrap();
        n_bytes = n.0;
        // 32 byte groupelement
        let mut g_bytes: [u8; 32] = rng.gen();
        g_bytes[0] &= 248;
        g_bytes[31] &= 127;
        g_bytes[31] |= 64;
        let g = GroupElement::from_slice(&g_bytes).unwrap();
        g_bytes = g.0;


        let mut variables = Vec::new();
        let n_bytes_string = u8_to_string_variable(&n_bytes, "n_bytes");
        variables.push(n_bytes_string);
        let g_bytes_string = u8_to_string_variable(&g_bytes, "g_bytes");
        variables.push(g_bytes_string);
        variables.push(String::from("unsigned char q[32];"));


        generate_testcasefile(variables.clone(), "crypto_scalarmult_asm(q, n_bytes, g_bytes);", "printresult(q, 32);");

        let expected_result = scalarmult(&n, &g).expect("couldn't do scalar multiplication");

        TestcaseEnum::scalarmult(ScalarMultTestcase { expected_result, n, G:g, ..Default::default() })
    }

    fn get_timeout(&self) -> u64 {
        210
    }

    fn get_outputlen(&self) -> usize {
        32
    }
}

