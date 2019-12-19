use clap::{App, Arg};
use std::path::Path;
use std::fs::OpenOptions;
use std::io::{BufReader, BufRead, BufWriter};
use std::str::FromStr;
use std::fmt::{Display, Formatter, Error};
use std::io::Write;

#[derive(Debug)]
struct Testcase {
    cycles: Vec<i32>,
    branch_dir_mis: Vec<i32>,
    branch_tar_mis: Vec<i32>,
    correct: bool,
    result: String,
    expected_result: String,
    run: i32,
}

impl Testcase {
    fn new() -> Testcase {
        Testcase { cycles: Vec::new(), branch_dir_mis: Vec::new(), branch_tar_mis: Vec::new(), correct: false, run: 0, result: String::new(), expected_result: String::new() }
    }
}

struct Trial {
    cycle: i32,
    branch_dir_mis: i32,
    branch_tar_mis: i32,
    correct: bool,
    run: i32,
    id: i32,
}


impl Display for Trial{
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        let _ = write!(f, "{}, {}, {}, {}, {}, ", self.run, self.id, self.cycle, self.branch_dir_mis, self.branch_tar_mis);
        match self.correct{
            true => writeln!(f,"TRUE"),
            false => writeln!(f, "FALSE")
        }


    }
}


fn main() {
    let matches = App::new("parser")
        .version("0.1")
        .about("Parses the output from the test run on the Hifive1 to a csv file")
        .arg(Arg::with_name("INPUT")
            .required(true)
            .help("The file to parse"))
        .arg(Arg::with_name("OUTPUT")
            .short("o")
            .long("output")
            .help("The output file path")
        ).get_matches();

    let input_str = matches.value_of("INPUT").unwrap();
    let input_path = Path::new(input_str);
    let output_path = match matches.value_of("OUTPUT") {
        Some(val) => Path::new(val).to_path_buf(),
        None => {
            Path::new(input_str).with_extension("csv")
        }
    };

    let input_file = OpenOptions::new()
        .read(true)
        .write(false)
        .create(false)
        .open(input_path).expect("Can not open input file");

    let output_file = OpenOptions::new()
        .write(true)
        .create(true)
        .append(false)
        .truncate(true)
        .open(output_path).expect("Can not create or open output file");
    let mut writer = BufWriter::new(output_file);
    let _ = writeln!(&mut writer, "run, id, cycles, Branch direction mis, Branch target mis, Correct");
    let mut run_counter = 0;
    let mut testcase = Testcase::new();
    for line in BufReader::new(input_file).lines() {
        let line = line.expect("Could not read line");
        parse_line(&mut testcase, line.clone());
        if line.starts_with("Expected result:") {
            testcase.run = run_counter;

            let trials = testcase_to_trial(testcase);
            for trial in trials{
               let _ =  writeln!(&mut writer, "{}", trial);
            }
            run_counter += 1;
            testcase = Testcase::new();
        }
    }
}

fn parse_line(testcase: &mut Testcase, line: String) {

    if line.starts_with("Cycle counts:") {
        let csline = line.replace("Cycle counts:", "");
        testcase.cycles = line_to_vec(csline);
    } else if line.starts_with("Branch dir mis:") {
        let csline = line.replace("Branch dir mis:", "");
        testcase.branch_dir_mis = line_to_vec(csline);
    } else if line.starts_with("Branch target mis:") {
        let csline = line.replace("Branch target mis:", "");
        testcase.branch_tar_mis = line_to_vec(csline);
    } else if line.starts_with("Result:") {
        let result = line.replace("Result:", "");
        testcase.result = result.trim().to_string();
    } else if line.starts_with("Expected result:") {
        let eresult = line.replace("Expected result:", "");
        testcase.expected_result = eresult.trim().to_string();
        testcase.correct = testcase.result == testcase.expected_result;
        if ! testcase.correct{
            println!("Result not correct expected: {}\n got:{}", testcase.expected_result, testcase.result);
        }
    }
}

fn line_to_vec(line: String) -> Vec<i32> {
    line.split(',').map(|v| {
        let z = v.trim();
        i32::from_str(z)
    }).filter_map(Result::ok).collect()
}

fn testcase_to_trial(testcase: Testcase) -> Vec<Trial>{
    let mut trials = Vec::with_capacity(testcase.cycles.len());
    for i in 0..testcase.cycles.len(){
        let cycle = testcase.cycles[i];
        let branch_dir_mis = testcase.branch_dir_mis[i];
        let branch_tar_mis = testcase.branch_tar_mis[i];
        trials.push(Trial{cycle, branch_dir_mis, branch_tar_mis, run:testcase.run
        , id: i as i32, correct: testcase.correct});
    }
    trials
}