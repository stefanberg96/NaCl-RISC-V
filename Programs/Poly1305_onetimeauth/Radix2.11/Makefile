riscv64-unknown-elf-gcc=/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc
freedom-e-sdk=/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk
riscv-gnu-toolchain=/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv-gnu-toolchain

SRCS=$(wildcard *.c)
ASM=$(wildcard *.S)

OBJS=$(SRCS:.c=.o) $(ASM:.S=.o)

upload: hex
	timeout 30s $(freedom-e-sdk)/scripts/upload --hex ./program.hex --jlink JLinkExe

hex: $(OBJS)
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc  -march=rv32imac -mabi=ilp32 -mcmodel=medlow -ffunction-sections -fdata-sections -I$(freedom-e-sdk)/bsp/sifive-hifive1-revb/install/include -O0 -g  -Wl,--gc-sections -Wl,-Map,program.map -nostartfiles -nostdlib -L$(freedom-e-sdk)/bsp/sifive-hifive1-revb/install/lib/debug/ -T$(freedom-e-sdk)/bsp/sifive-hifive1-revb/metal.default.lds $(OBJS) -Wl,--start-group -lc -lgcc -lmetal -lmetal-gloss -Wl,--end-group -o program.elf
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-objcopy -O ihex program.elf program.hex

%.o: %.c
	clang -Os -c $< --target=riscv32 -march=rv32ima
%.o: %.S
	clang -O0 -c $< --target=riscv32 -march=rv32ima

objdump:
	$(riscv-gnu-toolchain)/build-binutils-linux/binutils/objdump -D $(file) > $(file).objdump 

clean:
	rm $(OBJS) $(wildcard *.hex) $(wildcard *.map) $(wildcard *.elf)

qemu: $(OBJS)
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 $(OBJS) -o qemu


