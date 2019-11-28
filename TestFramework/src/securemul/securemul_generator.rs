use rand::Rng;
use sodiumoxide::crypto::onetimeauth;
use std::fs::{remove_file, OpenOptions};
use std::path::Path;
use std::env;
use std::io::Write;
use log::info;

#[derive(Debug)]
pub struct TestcaseSecuremul {
    pub variables: Vec<String>,
    pub expected_result: u64,
}

pub fn generate_testcase() -> TestcaseSecuremul {
    let mut rng = rand::thread_rng();
    let a: u64 = rng.gen_range(0,2^26-1);
    let b: u64 = rng.gen_range(0, 2^26-1);


    //print variables
    let mut variables = Vec::new();

    let var = format!("static unsigned int a = {};", a);
    variables.push(var);
    let var = format!("static unsigned int b = {};", b);
    variables.push(var);

    generate_testcasefile(variables.clone());
    TestcaseSecuremul { variables, expected_result:a*b }
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

    void dobenchmark() {{").expect("write failed");

    for var in variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "
        uint32_t timings[21];
        for(int i =0;i<21;i++){{
            timings[i]=getcycles();
            securemul226(a,b);
        }}

        for(int i=1;i<21;i++){{
            printf(\"%d, \",timings[i]-timings[i-1]);
        }}
        printf(\"\\n\");
        uint64_t output = securemul226(a,b);
        printf(\"0x%llx\\n\", output);
    }}").expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");
}