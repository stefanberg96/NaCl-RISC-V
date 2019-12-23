use rand::Rng;
use sodiumoxide::crypto::onetimeauth;
use std::fs::{remove_file, OpenOptions};
use std::path::{Path};
use std::env;
use std::io::Write;
use log::{info};
use std::str::FromStr;

#[derive(Debug)]
pub struct MulModTestcase {
    pub variables: Vec<String>,
}

pub fn generator_name() -> String {
    String::from_str("mulmod").unwrap()
}

pub fn generate_testcase() -> MulModTestcase {
    let mut rng = rand::thread_rng();

    let mut message: [u8; 32] = [0; 32];
    rng.fill(&mut message);


    //print variables
    let mut variables = Vec::new();

    let mut var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char a_bytes[16] = {{").as_str());

    for i in 0.. 15 {
        var.push_str(format!("0x{:x}, ", message[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", message[15]).as_str());
    variables.push(var);

    var = String::with_capacity(200);
    var.push_str(format!("        static unsigned char b_bytes[16] = {{").as_str());
    for i in 16..32 {
        var.push_str(format!("0x{:x}, ", message[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", message[31]).as_str());
    variables.push(var);


    generate_testcasefile(variables.clone());
    MulModTestcase {variables}
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
            (k[9] >> 6) + (k[10] << 2) + ((k[11] & 15) << 10) + ((k[12] & 252) << 18);
        r[4] = k[13] + (k[14] << 8) + ((k[15] & 15) << 16);
    }}

    void dobenchmark() {{

        unsigned int a[5];
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
        for(int i =0;i<21;i++){{
            timings[i]=getcycles();
            mulmod226asm(a,b);
        }}

        for(int i=1;i<21;i++){{
            printf(\"%d, \",timings[i]-timings[i-1]);
        }}
        printf(\"\\n\");
    }}").expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");

}