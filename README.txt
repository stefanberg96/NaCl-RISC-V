To make a hello world compile make sure that any project has been build with the freedom-e-sdk to ensure that the metal library is build(do not run make clean afterwards that removes the build metal library)
DONT FORGET TO DO THIS IN THE riscv directory:
 export PATH=`pwd`/_install/bin:$PATH

Then run clang -O -c hello.c --target=riscv32 to add the multiplier or atomic instruction add -march=rv32iam

After that the following command is used to link the object files together

/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc/bin/riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medlow -ffunction-sections -fdata-sections -I/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk/bsp/sifive-hifive1-revb/install/include -O0 -g  -Wl,--gc-sections -Wl,-Map,hello.map -nostartfiles -nostdlib -L/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk/bsp/sifive-hifive1-revb/install/lib/debug/ -T/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk/bsp/sifive-hifive1-revb/metal.default.lds  hello.o  -Wl,--start-group -lc -lgcc -lmetal -lmetal-gloss -Wl,--end-group -o hello.elf

Finally the hello.elf that was outputted needs to converted to a hex file for which this command is used

/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc/bin/riscv64-unknown-elf-objcopy -O ihex hello.elf hello.hex

Afterwards just drag and drop into the folder when the board is plugged in.
