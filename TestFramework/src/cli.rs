use crate::Function;
use structopt::StructOpt;

#[derive(StructOpt)]
#[structopt(name = "test framework", about = "Testframework to fuzz test the NaCl implementation. It is required to provide either -a or --function.")]
pub struct Opt {
    #[structopt(long, help = "Put result in /tmp/{test name}")]
    pub no_output: bool,

    #[structopt(short, long, help = "Test for all available functions")]
    pub all: bool,

    ///Provide which functions to check
    ///
    /// The acceptable values are:
    ///     poly1305
    ///     scalarmult
    #[structopt(short, long, help = "Which of the functions to check")]
    pub functions: Vec<Function>,

    #[structopt(short, long, help = "The amount of tests function", default_value = "500")]
    pub tests: u64,

    #[structopt(long, help = "The number of attempts before a test is skipped", default_value = "4")]
    pub attempts: u64,

    #[structopt(short, long, help = "The amount of runs per test function", default_value = "21")]
    pub runs: u64,

}