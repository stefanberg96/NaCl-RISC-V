# NaCl in RISC-V

In this project the [NaCl](https://nacl.cr.yp.to/), created by Daniel J. Bernstein, Tanja Lange and Peter Schwabe,  is/has been implemented in RISC-V.  For this project the decision is made to go for the 32-bit base instruction set. The project provides code without any extensions, and one using the multiplication extension. The development board used during the project is the [Sifive Hifive1 rev-B](https://www.sifive.com/boards/hifive1-rev-b). 

## Folder structure

The RISC-V programs and code can be found in the Programs folder, in which subfolders exists for each implementation. In the folder of the implementation subfolder exist for each component of the NaCl library. A component can have different implementations. The fastest implementation is in the sub-folder opt or Radix2.26. To build the library make lib is used. This creates the library in the build directory. The include file can be found in the includes folder with all functions provided by the library. 

The parsing, testframework and rstudio folder are all used for testing and analysis which is further explained in correctness.

## Progress

Below the list of implemented components can be found.

**Without multiplication extension**

- Poly1305
- Salsa20
- HSalsa20
- Curve25519 scalar multiplication

**With multiplication extension**

- Poly1305
- Salsa20 (same as without multiplication)
- HSalsa20 (same as without multiplication)
- Curve25519 scalar multiplication 

## Correctness

To check that the functions behaves correctly a testframework has been created. 

The testframework will create a testcase and calculate the expected result. Afterwards it will write the benchmark file in the folder of which it is called. It will make the hex file and upload the file to the board. The board will be reset and start executing. The computer is at this time waiting for the result of the board on /dev/ttyACM1, so make sure that no other processes are accessing that file. The board will report back with the timing results, the branch mispredictions and the result. The result is checked and the other information is logged. The results of a test are in the subfolder results of the component. 

At the end of a testcase the parsing tool can be used to extract the cycle counts, branch mispredictions, the result and expected result. It will parse each testcase and give it an id. This id in combination with the run id, which is a counter per testcase, will be a single run of the testcase with that id. Each run will become a line in the csv with the corresponding values. The csv is used in RStudio to analyze whether or not the cycle counts deviate a lot. The results of this can be found in the RStudio folder.

After analysis it did appear to deviate quite a bit so it could be possible that a timing attack was possible in the code. To check this a tool called [SMArTCAT](https://essay.utwente.nl/72321/1/Krak_MA_EEMCS.pdf) (created by Roeland Krak) was used after modifying it to the Sifive Hifive1 rev B board. Next to that a lifter was created from the binary to PyVex IR, which is used by [angr](https://angr.io/)(dependency of SMArTCAT). Using this tool it was determined that there are no branches on data that should remain secret. It also showed that there were no loads from memory depending on secret data. This shows that timing attacks are very unlikely to exists in this program. The source code of [the modified SMArTCAT](https://github.com/stefanberg96/SMArTCAT) is also publicly available.
