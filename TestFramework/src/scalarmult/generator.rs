use rand::Rng;
use std::fs::{remove_file, OpenOptions};
use std::path::Path;
use std::env;
use std::io::Write;
use log::info;
use std::str::FromStr;
use num_bigint::BigUint;
use std::ops::{MulAssign, Rem, BitAndAssign, Mul};
use num_traits::One;
use sodiumoxide::crypto::scalarmult::*;

#[derive(Debug)]
pub struct ScalarMultTestCase {
    pub variables: Vec<String>,
    pub expected_result: GroupElement,
    pub n: Scalar,
    pub G: GroupElement,
}

pub fn generator_name() -> String {
    String::from_str("scalarmult").unwrap()
}

pub fn generate_testcase() -> ScalarMultTestCase {
    let mut rng = rand::thread_rng();
    // 32 byte scalar
    let mut n_bytes: [u8; 32] = rng.gen();
    n_bytes[0] &=248;
    n_bytes[31] &= 127;
    n_bytes[31] |= 64;
    let n = Scalar::from_slice(&n_bytes).unwrap();
    n_bytes = n.0;
    // 32 byte groupelement
    let mut g_bytes: [u8; 32] = rng.gen();
    g_bytes[0] &=248;
    g_bytes[31] &= 127;
    g_bytes[31] |= 64;
    let G = GroupElement::from_slice(&g_bytes).unwrap();
    g_bytes = G.0;


    //print variables
    let mut variables = Vec::new();

    let mut var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char g_bytes[32] = {{").as_str());

    for i in 0..31 {
        var.push_str(format!("0x{:x}, ", g_bytes[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", g_bytes[31]).as_str());
    variables.push(var);

    var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char n_bytes[32] = {{").as_str());
    for i in 0..31 {
        var.push_str(format!("0x{:x}, ", n_bytes[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", n_bytes[31]).as_str());
    variables.push(var);


    generate_testcasefile(variables.clone());

    let expected_result = scalarmult(&n, &G).expect("couldn't do scalar multiplication");

    ScalarMultTestCase{variables, expected_result, n, G}
}


fn generate_testcasefile(variables: Vec<String>) {
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

    void printarray(unsigned char *in, int inlen){{
        for(int i =0;i<inlen;i++){{
            printf(\"%02x\", in[i]);
        }}
        printf(\"\\n\");
    }}

    void printcounters(unsigned int *a, int initialoffset){{

           for(int i = initialoffset+3; i < 21*3;i+=3){{
               printf(\"%6u, \", a[i]-a[i-3]);
        }}
        printf(\"\\n\");
    }}

    void convert_to_radix226(unsigned int* r, unsigned char *k){{
        r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3]&3)  << 24);
        r[1] = (k[3] >> 2)  + (k[4]  << 6) + (k[5] << 14) +
            ((k[6] & 15) << 22);
        r[2] = (k[6] >> 4) + (k[7] << 4) + (k[8] << 12) +
            ((k[9] & 63) << 20);
        r[3] =
            (k[9] >> 6) + (k[10] << 2) + ((k[11] ) << 10) + (k[12] << 18);
        r[4] = k[13] + (k[14] << 8) + (k[15]  << 16 )+ (k[16]<<24);
    }}

    void dobenchmark() {{

    ").expect("write failed");

    for var in variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "

        unsigned int counters[3*21];
        icachemisses();

        unsigned char q[32];
        for(int i =0;i<2;i++){{
            getcycles(&counters[i*3]);
            crypto_scalarmult(q, n_bytes, g_bytes);
        }}

        printf(\"Cycle counts:          \");
        printcounters(counters, 0);

        printf(\"Branch dir mis:        \");
        printcounters(counters, 1);

        printf(\"Branch target mis:    \");
        printcounters(counters, 2);

        printf(\"Result: \");
        printarray(q, 32);
        printf(\"\\n\\n\");
    }}").expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");
}