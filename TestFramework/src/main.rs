use crate::test_results_reader::poly1305::Poly1305Reader;
use std::process::Stdio;
use std::process::Command;
use std::path::Path;
use rand::Rng;
use std::fs::{File, OpenOptions, remove_file};
use std::io::{Write};
use std::{env, thread};
use std::sync::mpsc;
use std::sync::mpsc::Receiver;
use std::time::Duration;
use std::env::var;


mod test_results_reader;
mod testcase_generators;

fn main() {
    // way too much code to get a path -.-'
    let dir_buf_path = env::current_dir().expect("Couldn't get current directory");
    let path_str = dir_buf_path.to_str().expect("can not unwrap path");
    let filename = Path::new("benchmark.c");
    let path = Path::new("./benchmark.c");

    //create a thread that reuploads the program in case it hangs
    let (tx, rx) = mpsc::channel();
    thread::spawn(move || {
        heartbeat(rx, path);
    });

    // kick off the reaction
    let initial_variables = generate_testcase(path);
    tx.send(initial_variables);
    run_make();

    // main loop that runs the tests
    let reader = Poly1305Reader::new();
    for val in reader {
        println!("{:?}", val);
        let variables = generate_testcase(path);
        tx.send(variables);
        run_make();
    }
}

fn generate_testcase(path: & Path) -> Vec<String> {

    remove_file(path).expect("Can not remove benchmark.c");

    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(path).expect("Couldn't create benchmark.c file");
    //print header stuff
    writeln!(file, "#include \"benchmark.h\"

    void dobenchmark(uint64_t *timings, unsigned char a[16]) {{");
    let variables = testcase_generators::poly1305::generate_testcase();

    for var in &variables{
        writeln!( file, "{}", var);
    }

    //print rest of the code
    writeln!(file, "
        uint32_t oldcount, newcount;
        unsigned char x = 5, y = 10;
        oldcount = getcycles();
        crypto_onetimeauth(a, c, 131, rs);
        newcount = getcycles();
        timings[0] = newcount - oldcount;
    }}");

    variables
}

fn run_make() {
    //Run make in the program remove current dir to run in the dir from which it is called
    Command::new("make")
        .current_dir("/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv/Programs/Poly1305_onetimeauth/Radix2.26")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn().expect("Could not run make");
}

fn heartbeat(rx: Receiver<Vec<String>>, path:&Path){
    let timeout = Duration::from_secs(30);
    let mut last_input = vec![String::new()];
    loop{
        let r= rx.recv_timeout(timeout);
        match r {
            Ok(val) => last_input = val,
            Err(_)=>{
                println!("Timedout");
               // println!("{:?}", last_input);
                last_input = generate_testcase(path);
                run_make();
                //TODO log last input
            }
        }
    }
}