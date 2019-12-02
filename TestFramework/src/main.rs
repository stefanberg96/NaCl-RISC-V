#[macro_use]
extern crate log;

use std::sync::mpsc;
use std::time::Duration;
use crate::mulmod::reader::start_reader_thread;
use crate::poly1305::generator;
use simple_error::SimpleError;
use env_logger::{Builder, WriteStyle};
use log::{error, info, LevelFilter};
use crate::make::run_make;
use plotlib::boxplot::BoxPlot;
use plotlib::view::CategoricalView;
use plotlib::page::Page;
use std::fs::{create_dir, OpenOptions};
use std::path::Path;
use chrono::Local;
use std::io::Write;
use crate::mulmod::generator::{generate_testcase, generator_name};


mod make;
mod poly1305;
mod securemul;
mod onetime_authloop;
mod mulmod;

fn main() -> Result<(), SimpleError> {
    let mut builder = Builder::new();

    builder.filter(None, LevelFilter::Info)
        .write_style(WriteStyle::Always)
        .init();
    let dt = Local::now();
    let x = format!("results/{}_{}", generator_name(),dt.format("%Y-%m-%d %H:%M"));
    let dir = Path::new(&x);
    let _ = create_dir(dir);

    let mut output = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(dir.join(Path::new("results.txt"))).expect("Couldn't create output file");

    // create a thread that reads the output from the board
    let (tx, rx) = mpsc::channel();
    start_reader_thread(tx);

    //main loop that runs the tests
    let mut cycles_times = vec![];
    for _i in 0..100 {
        let testcase = generate_testcase();
        for _attempt in 0..4 {
            if _attempt == 3 {
                error!("Too many failed attempt on this input:\n {:?}", testcase);
                return Err(SimpleError::new("Too many failed commands please do a manual check"));
            }

            if run_make().is_err() {
                error!("run make failed");
                continue;
            }

            match rx.recv_timeout(Duration::from_secs(10)) {
                Ok(result) => {
                    info!("Calculation took {} cycles ", result.cycle_counts[8]);
                    cycles_times.push(result.cycle_counts.clone());

                    let _ = writeln!(output, "{:?}\n {}", testcase.variables, result);

                    break;
                }
                Err(_) => {
                    error!("Did not get the result within 10 seconds rerunning make");
                    continue;
                }
            }
        }
    }


    let skipped_first_run: Vec<f64> = cycles_times.iter().map(|v| v.iter().skip(1)).flatten().cloned().collect();
    let filtered: Vec<f64> = cycles_times.iter().map(|v| v.iter().skip(5)).flatten().cloned().collect();

    let boxplot_all = BoxPlot::from_vec(cycles_times.iter().flatten().cloned().collect());
    let boxplot_skipped_first = BoxPlot::from_vec(skipped_first_run);
    let boxplot_filtered = BoxPlot::from_vec(filtered);

    let v_all = CategoricalView::new().add(&boxplot_all);
    let v_skipped_first = CategoricalView::new().add(&boxplot_skipped_first);
    let v_filtered = CategoricalView::new().add(&boxplot_filtered);


    let _ = Page::single(&v_all).save(dir.join("boxplot_all.svg"));
    let _ = Page::single(&v_skipped_first).save(dir.join("boxplot_first_skipped.svg"));
    let _ = Page::single(&v_filtered).save(dir.join("boxplot_filtered.svg"));
    let _ = Page::single(&v_all).save(dir.join("boxplot_all.svg"));

    Ok(())
}





