use std::process::{Command, Stdio};
use simple_error::SimpleError;
use std::error::Error;
use std::env;
use std::io::{BufReader, BufRead};


pub fn run_make() -> Result<(), SimpleError> {
    let dir_path = env::current_dir().expect("Couldn't get current path");
    let _ = Command::new("rm")
        .arg("benchmark.o")
        .current_dir(dir_path.as_path())
        .spawn().expect("Couldn't rm benchmark.o")
        .wait();

    run_make_hex()?;
    run_make_upload_only()?;
    run_make_reset()?;
    Ok(())
}

fn run_make_hex() -> Result<(), SimpleError> {
    let dir_path = env::current_dir().expect("Couldn't get current path");
    let mut command = Command::new("make");
    let child = command
        .current_dir(dir_path.as_path())
        .stderr(Stdio::piped())
        .stdout(Stdio::piped())
        .arg("hex")
        .spawn().expect("Could not run make hex");

    let x = child.wait_with_output().expect("Could not run make hex");

    let keyword = "riscv64-unknown-elf-objcopy -O ihex program.elf program.hex";
    let error_message = "Make hex did not finish successfull";
    match check_for_keyword(x.stdout, keyword, error_message) {
        Ok(_) => {
            info!("make hex successfull");
            Ok(())
        }
        Err(e) => Err(e),
    }
}

fn run_make_reset() -> Result<(), SimpleError> {
    let dir_path = env::current_dir().expect("Couldn't get current path");
    let mut command_wo_args = Command::new("make");
    let command = command_wo_args
        .arg("reset")
        .current_dir(dir_path.as_path())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());

    let child = command.spawn().expect("Couldn't run reset");

    let keyword = "Reset type NORMAL: Resets core & peripherals using RESET pin.";
    let output = child.wait_with_output().expect("make reset didn't timeout");
    if check_for_keyword(output.stdout.clone(), keyword, "Failed to run the reset command").is_err() {
        warn!("run make reset failed");
        return check_for_keyword(output.stdout, keyword, "Failed to run the reset command");
    }
    info!("Reset successful");
    Ok(())
}

fn check_for_keyword(val: Vec<u8>, keyword: &str, error_message: &str) -> Result<(), SimpleError> {
    let strings = vecu8_to_string(val)?;
    if !strings.contains(keyword) {
        error!("{}", error_message);
        return Err(SimpleError::new("Keyword was not found in the string"));
    }
    Ok(())
}

fn vecu8_to_string(val: Vec<u8>) -> Result<String, SimpleError> {
    let val = match String::from_utf8(val) {
        Ok(val) => val,
        Err(e) => {
            error!("Failed transform\n {}\n", e.description());
            let error_message = format!("Failed to transform vecu8 to string\n {}", e.description());
            Err(SimpleError::new(error_message))?
        }
    };
    Ok(val)
}

fn run_make_upload_only() -> Result<(), SimpleError> {
    let dir_path = env::current_dir().expect("Couldn't get current path");
    let mut command = Command::new("make");
    let child = command
        .current_dir(dir_path.as_path())
        .stderr(Stdio::piped())
        .stdout(Stdio::piped())
        .arg("upload_only")
        .spawn().expect("Could not run make hex");


    let output = child.stdout.unwrap();

    for line in BufReader::new(output).lines(){
        let line = line.unwrap();

        //as soon as the upload is ok return
        if line.as_str() == "O.K."{
            info!("make upload successfull");
            return Ok(());
        }
    }

    return Err(SimpleError::new("Did not find the O.K. keyword for the upload_only"));
}
