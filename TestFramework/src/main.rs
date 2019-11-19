use std::process::{Stdio, Child};
use std::process::Command;
use std::path::{Path, PathBuf};
use std::fs::{OpenOptions, remove_file};
use std::io::{Write, Error};
use std::{env, thread};
use std::sync::mpsc;
use std::sync::mpsc::Receiver;
use std::time::Duration;
use crate::poly1305::poly1305_reader::Poly1305Reader;
use crate::poly1305::poly1305_generator;
use crate::poly1305::poly1305_generator::TestcasePoly1305;
use std::thread::sleep;
use std::any::Any;


mod poly1305;

fn main() {
    let path = get_benchmark_path();

    //create a thread that reuploads the program in case it hangs
    let (tx, rx) = mpsc::channel();
    thread::spawn(move || {
        heartbeat(rx);
    });

    // kick off the reaction
    let initial_variables = generate_testcasefile();
    tx.send(initial_variables).expect("Send failed");
    let mut child = run_make();
    println!("Created child id:{}", child.id());
    // main loop that runs the tests
    let reader = Poly1305Reader::new();
    for val in reader {
        if child.try_wait().expect("Somethign happened") == None {
            println!("Killed child id: {}", child.id());
            child.kill().expect("Killing the process to prevent the second reset failed");
            sleep(Duration::from_millis(100));
        }
        let testcase = generate_testcasefile();

        tx.send(testcase).expect("Send failed");
        child = run_make();
        println!("Created child id:{}", child.id());
        //TODO handle result
        println!("{}", val);
    }
}

fn generate_testcasefile() -> TestcasePoly1305 {
    remove_file(get_benchmark_path()).expect("Can not remove benchmark.c");

    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(get_benchmark_path()).expect("Couldn't create benchmark.c file");
    //print header stuff
    writeln!(file, "#include \"benchmark.h\"

    void dobenchmark(uint64_t *timings, unsigned char a[16]) {{").expect("write failed");
    let testcase = poly1305_generator::generate_testcase();

    for var in &testcase.variables {
        writeln!(file, "{}", var).expect("write failed");
    }

    //print rest of the code
    writeln!(file, "
        uint32_t oldcount, newcount;
        unsigned char x = 5, y = 10;
        oldcount = getcycles();
        crypto_onetimeauth(a, c, 131, rs);
        newcount = getcycles();
        timings[0] = newcount - oldcount;
    }}").expect("write failed");
    file.flush().expect("Couldn't flush benchmark file");

    testcase
}


fn run_make() -> Child {
    let dir_path = env::current_dir().expect("Couldn't get current path");
    let _ = Command::new("rm")
        .arg("benchmark.o")
        .current_dir(dir_path.as_path())
        .spawn().expect("Couldn't rm benchmark.o")
        .wait();
    //Run make in the program remove current dir to run in the dir from which it is called
    //has a custom command since it needs to reset again after 7 seconds of not getting a result
    let mut command = Command::new("make");
    command
        .current_dir(dir_path.as_path())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .arg("upload")
        .spawn().expect("Could not run make upload_testcase")
}

fn heartbeat(result_receiver: Receiver<TestcasePoly1305>) {
    let timeout = Duration::from_secs(17);
    let mut last_input = TestcasePoly1305 { variables: vec![], expected_result: [0; 16] };
    let mut consecutive_fails = 0;
    loop {
        //TODO get message from make on success with timeout, so that make upload can be run again
        //restart the loop from the top then

        //start the timeout for the reset text from the reader


        //start timeout receive from the reader on the output
        let r = result_receiver.recv_timeout(timeout);
        match r {
            Ok(val) =>{
                last_input = val;
                consecutive_fails = 0;
            }
            Err(_) => {
                println!("Timedout");
                if consecutive_fails >= 2 {
                    last_input = generate_testcasefile();
                    run_make();
                    //TODO log last input
                    consecutive_fails = 0;
                }else{
                    run_reset();
                }
                consecutive_fails+=1;
            }
        }

    }
}

fn run_reset(){
    let dir_path = env::current_dir().expect("Couldn't get current path");
    let _ = Command::new("make")
        .arg("reset")
        .current_dir(dir_path.as_path())
        .stdout(Stdio::null())
        .spawn().expect("Couldn't run reset");
}


fn get_benchmark_path() -> PathBuf {
    let buf_path = env::current_dir().expect("Failed to get current path");
    let current_path = buf_path.as_path();
    current_path.join(Path::new("benchmark.c"))
}