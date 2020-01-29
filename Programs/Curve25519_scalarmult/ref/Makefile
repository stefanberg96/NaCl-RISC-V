riscv64-unknown-elf-gcc=/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc
freedom-e-sdk=/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk
riscv-gnu-toolchain=/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv-gnu-toolchain

SRCS=$(wildcard *.c)
ASM=$(wildcard *.S)

OBJS=$(SRCS:.c=.o) $(ASM:.S=.o)
BENCHMARK=main.o benchmark.o

upload: hex
	timeout 10s $(freedom-e-sdk)/scripts/upload --hex ./program.hex --jlink JLinkExe

upload_only: hex
	echo -e "\nloadfile program.hex\nexit" | timeout 15 JLinkExe -device FE310 -if JTAG -speed 4000 -jtagconf -1,-1 -autoconnect 1

reset:
	echo -e "\nr\nexit" | timeout 10 JLinkExe -device FE310 -if JTAG -speed 4000 -jtagconf -1,-1 -autoconnect 1


hex: $(OBJS)
	 $(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc  -march=rv32imac -mabi=ilp32 -mcmodel=medlow -ffunction-sections -fdata-sections -I$(freedom-e-sdk)/bsp/sifive-hifive1-revb/install/include -Os -g  -Wl,--gc-sections -Wl,-Map,program.map -nostartfiles -nostdlib -L$(freedom-e-sdk)/bsp/sifive-hifive1-revb/install/lib/debug/ -T$(freedom-e-sdk)/bsp/sifive-hifive1-revb/metal.default.lds $(OBJS) -Wl,--start-group -lc -lgcc -lmetal -lmetal-gloss -Wl,--end-group -Wl,--print-memory-usage -o program.elf
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-objcopy -O ihex program.elf program.hex

lib: $(filter-out $(BENCHMARK), $(OBJS))
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc-ar -target=elf32-elf32-littleriscv  lib.a $(OBJS) 

main.o: main.c
	clang -O3 -c $< --target=riscv32 -march=rv32ia -I$(freedom-e-sdk)/freedom-metal

%.o: %.c
	clang -O3 -c $< --target=riscv32 -march=rv32ia -I$(freedom-e-sdk)/freedom-metal

%.o: %.S
	clang -O3 -c $< --target=riscv32 -march=rv32ia

objdump:
	$(riscv-gnu-toolchain)/build-binutils-newlib/binutils/objdump -D $(file) > $(file).objdump 

clean:
	rm $(OBJS) $(wildcard *.hex) $(wildcard *.map) $(wildcard *.elf)

qemu: $(OBJS)
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 $(OBJS) -o qemu

