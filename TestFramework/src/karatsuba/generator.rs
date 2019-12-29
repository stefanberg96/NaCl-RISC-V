use rand::Rng;
use sodiumoxide::crypto::onetimeauth;
use std::fs::{remove_file, OpenOptions};
use std::path::{Path};
use std::env;
use std::io::Write;
use log::{info};
use std::str::FromStr;
use num_bigint::BigUint;
use std::ops::{MulAssign,Rem,BitAndAssign};
use num_traits::One;


#[derive(Debug)]
pub struct KaratsubaTestcase {
    pub variables: Vec<String>,
    pub expected_result: BigUint,
}

pub fn generator_name() -> String {
    String::from_str("karatsuba").unwrap()
}

pub fn generate_testcase() -> KaratsubaTestcase {
    let mut rng = rand::thread_rng();

    let mut a: [u8; 18] = [0; 18];
    rng.fill(&mut a);
    let mut b: [u8; 18] = [0; 18];
    rng.fill(&mut b);
    a[17] &= 0x3;
    b[17] &= 0x3;


    //print variables
    let mut variables = Vec::new();

    let mut var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char a_bytes[18] = {{").as_str());

    for i in 0.. 17 {
        var.push_str(format!("0x{:x}, ", a[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", a[17]).as_str());
    variables.push(var);

    var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char b_bytes[18] = {{").as_str());
    for i in 0..17 {
        var.push_str(format!("0x{:x}, ", b[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", b[17]).as_str());
    variables.push(var);


    generate_testcasefile(variables.clone());

    let mut a_bigInt = BigUint::from_bytes_le(&a);
    let mut b_bigInt = BigUint::from_bytes_le(&b);

    a_bigInt.mul_assign(b_bigInt);

    let mut p: BigUint = One::one();
    p = p<<130;
    p= p-(5 as u32);

    let expected_result = a_bigInt.rem(p);
    KaratsubaTestcase {variables, expected_result}
}


fn generate_testcasefile(variables: Vec<String>){
    let buf_path = env::current_dir().expect("Failed to get current path");
    let current_path = buf_path.as_path();
    let benchmark_path = current_path.join(Path::new("benchmark.c"));
    remove_file(benchmark_path.clone()).expect("Can not remove benchmark.c");

    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(benchmark_path).expect("Couldn't create benchmark.c file");
    //print header stuff
    writeln!(file, "#include \"benchmark.h\"

    void convert_to_radix226(unsigned int* r, unsigned char *k){{
        r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
        r[1] = ((k[3] >> 2) & 3) + ((k[4] & 252) << 6) + (k[5] << 14) +
            ((k[6] & 15) << 22);
        r[2] = (k[6] >> 4) + ((k[7] & 15) << 4) + ((k[8] & 252) << 12) +
            ((k[9] & 63) << 20);
        r[3] =
            (k[9] >> 6) + (k[10] << 2) + ((k[11] ) << 10) + ((k[12] & 252) << 18);
        r[4] = k[13] + (k[14] << 8) + (k[15]  << 16 )+ (k[16]<<24);
    }}

    void dobenchmark() {{

        unsigned int a[17];
        unsigned int b[5];
    ").expect("write failed");

    for var in variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "

        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);


        uint32_t timings[21];
        unsigned int out[17];
        for(int i =0;i<21;i++){{
            timings[i]=getcycles();
            karatsuba226asm(out, a,b);
        }}

        for(int i=1;i<21;i++){{
            printf(\"%d, \",timings[i]-timings[i-1]);
        }}
        printf(\"\\n\");
        toradix28(a);
        printarray(a,17);
        printf(\"\\n\");
    }}").expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");

}