
SRCS=$(wildcard *.c)
ASM=$(wildcard *.S)

OBJS=$(SRCS:.c=.o) $(ASM:.S=.o)


test: $(OBJS)
	/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc/bin/riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medlow -ffunction-sections -fdata-sections -I/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk/bsp/sifive-hifive1-revb/install/include -O0 -g  -Wl,--gc-sections -Wl,-Map,program.map -nostartfiles -nostdlib -L/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk/bsp/sifive-hifive1-revb/install/lib/debug/ -T/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk/bsp/sifive-hifive1-revb/metal.default.lds $(OBJS) -Wl,--start-group -lc -lgcc -lmetal -lmetal-gloss -Wl,--end-group -o program.elf
	/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc/bin/riscv64-unknown-elf-objcopy -O ihex program.elf program.hex

%.o: %.c
	clang -O -c $< --target=riscv32




 