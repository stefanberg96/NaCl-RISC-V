use std::path::Path;
use std::fs::{OpenOptions, remove_file};
use std::io::Write;
use std::env;
use structopt::StructOpt;
use crate::cli::Opt;

pub fn u8_to_string_variable(input: &[u8], varname: &str) -> String {
    let mut var = String::with_capacity((input.len() * 8) as usize);
    var.push_str(format!("        static unsigned char {}[{}] = {{", varname, input.len()).as_str());

    for i in 0..input.len() - 1 {
        var.push_str(format!("0x{:02x}, ", input[i as usize]).as_str());
    }

    var.push_str(format!("0x{:02x}}};", input[(input.len() - 1) as usize]).as_str());

    var.clone()
}

pub fn u8_to_string(input: &[u8]) -> String {
    let mut var = String::with_capacity((input.len() * 8) as usize);

    for i in 0..input.len() - 1 {
        var.push_str(format!("0x{:02x}, ", input[i as usize]).as_str());
    }

    var.push_str(format!("0x{:02x}", input[(input.len() - 1) as usize]).as_str());

    var.clone()
}

pub fn generate_testcasefile(variables: Vec<String>, functioncall: &str, resultprint: &str) {
    let buf_path = env::current_dir().expect("Failed to get current path");
    let current_path = buf_path.as_path();
    let benchmark_path = current_path.join(Path::new("benchmark.c"));
    remove_file(benchmark_path.clone()).expect("Can not remove benchmark.c");

    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(benchmark_path).expect("Couldn't create benchmark.c file");

    let args: Opt = Opt::from_args();


    //print header stuff
    writeln!(file, "#include \"benchmark.h\"
    extern void icachemisses();
    static int runs={};

    void printresult(unsigned char *in, int inlen){{
        for(int i =0;i<inlen;i++){{
            printf(\"%02x\", in[i]);
        }}
        printf(\"\\n\");
    }}

    void printresultreverse(unsigned char *in, int inlen){{
        for(int i =inlen-1;i>=0;i--){{
            printf(\"%02x\", in[i]);
        }}
        printf(\"\\n\");
    }}


    void printintarray(unsigned int *in, int inlen){{
        for(int i =0;i<inlen;i++){{
            printf(\"0x%02x, \", in[i]);
        }}
        printf(\"\\n\");
    }}

    void printchararray(unsigned char *in, int inlen){{
        for(int i =0;i<inlen;i++){{
            printf(\"0x%02x, \", in[i]);
        }}
        printf(\"\\n\");
    }}

    void printcounters(unsigned int *a, int initialoffset){{

           for(int i = initialoffset+3; i < runs*3;i+=3){{
               printf(\"%6u, \", a[i]-a[i-3]);
        }}
        printf(\"\\n\");
    }}

    void dobenchmark() {{

    ", args.runs+1).expect("write failed");

    //print the variables
    for var in variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "

        unsigned int counters[3*runs];
        icachemisses();

        uint32_t timings[21];
        for(int i =0;i<runs;i++){{
            getcycles(&counters[i*3]);
            {}
        }}

        printf(\"Cycle counts:          \");
        printcounters(counters, 0);

        printf(\"Branch mispredictions:        \");
        printcounters(counters, 1);

        printf(\"ICache misses:    \");
        printcounters(counters, 2);

        printf(\"Result: \");
        {}
        printf(\"\\n\\n\");

    }}", functioncall, resultprint).expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");
    info!("written benchmark.c");
}



