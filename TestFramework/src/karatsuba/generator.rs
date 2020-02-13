use rand::Rng;
use sodiumoxide::crypto::onetimeauth;
use std::fs::{remove_file, OpenOptions};
use std::path::{Path};
use std::env;
use std::io::Write;
use log::{info};
use std::str::FromStr;
use num_bigint::BigUint;
use std::ops::{MulAssign,Rem,BitAndAssign, Mul};
use num_traits::One;
use std::fmt::{Display, Formatter, Error};



pub struct KaratsubaTestcase {
    pub variables: Vec<String>,
    pub expected_result: BigUint,
    pub A: BigUint,
    pub B: BigUint,
}

impl Display for KaratsubaTestcase{
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        writeln!(f, "A: {:02x}", self.A)?;
        writeln!(f, "B: {:02x}", self.B)?;
        writeln!(f, "Expected result: {:02x}", self.expected_result)?;
        Ok(())
    }
}

pub fn generator_name() -> String {
    String::from_str("karatsuba").unwrap()
}

pub fn generate_testcase() -> KaratsubaTestcase {
    let mut rng = rand::thread_rng();

    let mut a: [u8; 17] = [0; 17];
    rng.fill(&mut a);
    let mut b: [u8; 17] = [0; 17];
    rng.fill(&mut b);
    a[16] &= 0x3;
    b[16] &= 0x3;


    //print variables
    let mut variables = Vec::new();

    let mut var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char a_bytes[32] = {{").as_str());

    for i in 0.. 16 {
        var.push_str(format!("0x{:x}, ", a[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", a[16]).as_str());
    variables.push(var);

    var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char b_bytes[32] = {{").as_str());
    for i in 0..16 {
        var.push_str(format!("0x{:x}, ", b[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", b[16]).as_str());
    variables.push(var);


    generate_testcasefile(variables.clone());

    let mut a_bigInt = BigUint::from_bytes_le(&a);
    let mut b_bigInt = BigUint::from_bytes_le(&b);

    let mut res = a_bigInt.mul(&b_bigInt);

    let mut p: BigUint = One::one();
    p = p<<130;
    p= p-(5 as u32);

    let expected_result = res.rem(p);
    KaratsubaTestcase {variables, expected_result, A:BigUint::from_bytes_le(&a), B:b_bigInt}
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

    void printarrayinv(unsigned int *in, int inlen){{
        for(int i =inlen-1;i>=0;i--){{
            printf(\"%02x\", in[i]);
        }}
        printf(\"\\n\");
    }}

 void convert_to_radix226(unsigned int* r, unsigned char *k){{
        r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
        r[1] = ((k[3] >> 2) & 3) + ((k[4] & 252) << 6) + (k[5] << 14) +
            ((k[6] & 15) << 22);
        r[2] = (k[6] >> 4) + ((k[7] & 15) << 4) + ((k[8] & 252) << 12) +
            ((k[9] & 63) << 20);
        r[3] =
            (k[9] >> 6) + (k[10] << 2) + ((k[11] & 15) << 10) + ((k[12] & 252) << 18);
        r[4] = k[13] + (k[14] << 8) + ((k[15] & 15) << 16);
    }}

 void convert_to_radix226_kara(unsigned int* r, unsigned char *k){{
        r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
        r[1] = ((k[3] >> 2)) + ((k[4] ) << 6) + (k[5] << 14) +
            ((k[6] & 15) << 22);
        r[2] = (k[6] >> 4) + ((k[7]) << 4) + ((k[8]) << 12) +
            ((k[9] & 63) << 20);
        r[3] =
            (k[9] >> 6) + (k[10] << 2) + ((k[11] ) << 10) + ((k[12]) << 18);
        r[4] = k[13] + (k[14] << 8) + ((k[15] ) << 16)+(k[16]<<24);
    }}

    void printcounters(unsigned int *a, int initialoffset){{

           for(int i = initialoffset+3; i < 21*3;i+=3){{
               printf(\"%6u, \", a[i]-a[i-3]);
        }}
        printf(\"\\n\");
    }}

    void dobenchmark() {{

        unsigned int a[10];
        unsigned int b[10];
    ").expect("write failed");

    for var in variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "

        convert_to_radix226_kara(a, a_bytes);
        convert_to_radix226_kara(b,b_bytes);

        printf(\"A: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\\n\", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
        printf(\"B: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\\n\", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);


        unsigned int out[32];
        unsigned int counters[3*21];
        icachemisses();

        for(int i =0;i<21;i++){{
            getcycles(&counters[i*3]);
            karatsuba226asm(out, a,b);
        }}

        printf(\"Cycle counts:          \");
        printcounters(counters, 0);

        printf(\"Branch dir mis:        \");
        printcounters(counters, 1);

        printf(\"Branch target mis:    \");
        printcounters(counters, 2);

        toradix28(out);
        printf(\"Result: \");
        printarrayinv(out,17);
        printf(\"\\n\");
    }}").expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");

}