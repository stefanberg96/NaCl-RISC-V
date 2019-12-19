use rand::Rng;
use sodiumoxide::crypto::onetimeauth;
use std::fs::{remove_file, OpenOptions};
use std::path::{Path};
use std::env;
use std::io::Write;
use log::{info};
use std::str::FromStr;

#[derive(Debug)]
pub struct TestcaseAuthLoop {
    pub variables: Vec<String>,
    pub messagelen: usize,
}

pub fn generator_name() -> String {
    String::from_str("authloop").unwrap()
}

pub fn generate_testcase(messagelen : usize) -> TestcaseAuthLoop {
    let mut rng = rand::thread_rng();

    let mut message: [u8; 256] = [0; 256];
    rng.fill(&mut message);

    let poly1305_key = onetimeauth::gen_key();
    let key = poly1305_key.0;

    //print variables
    let mut variables = Vec::new();

    let mut var = String::with_capacity((messagelen*2) as usize);
    var.push_str(format!("        static unsigned char in[{}] = {{", messagelen).as_str());

    for i in 0..messagelen - 1 {
        var.push_str(format!("0x{:x}, ", message[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", message[(messagelen - 1) as usize]).as_str());
    variables.push(var);

    var = String::with_capacity((messagelen*2) as usize);
    var.push_str(format!("        static unsigned char k[16] = {{").as_str());
    for i in 0..16 {
        var.push_str(format!("0x{:x}, ", key[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", key[31 as usize]).as_str());
    variables.push(var);

    let message_slice = &message[0..messagelen];


    generate_testcasefile(variables.clone(), messagelen);
    TestcaseAuthLoop {variables,  messagelen}
}


fn generate_testcasefile(variables: Vec<String>, inlen: usize){
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

    void dobenchmark() {{

    unsigned int c[17];
    unsigned int h[17]={{0}};
    unsigned int r[5];
    ").expect("write failed");

    for var in variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "
  r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
  r[1] = ((k[3] >> 2) & 3) + ((k[4] & 252) << 6) + (k[5] << 14) +
         ((k[6] & 15) << 22);
  r[2] = (k[6] >> 4) + ((k[7] & 15) << 4) + ((k[8] & 252) << 12) +
         ((k[9] & 63) << 20);
  r[3] =
      (k[9] >> 6) + (k[10] << 2) + ((k[11] & 15) << 10) + ((k[12] & 252) << 18);
  r[4] = k[13] + (k[14] << 8) + ((k[15] & 15) << 16);



        uint32_t timings[21];
        for(int i =0;i<21;i++){{
            timings[i]=getcycles();
            onetimeauth_loop(in, {}, h, r, c);
        }}

        for(int i=1;i<21;i++){{
            printf(\"%d, \",timings[i]-timings[i-1]);
        }}
        printf(\"\\n\");
    }}", inlen).expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");

}