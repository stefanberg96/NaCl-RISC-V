riscv64-unknown-elf-gcc=/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv64-unknown-elf-gcc
freedom-e-sdk=/home/stefan/Documents/Graduation/RISC-V-toolchain/freedom-e-sdk
riscv-gnu-toolchain=/home/stefan/Documents/Graduation/RISC-V-toolchain/riscv-gnu-toolchain

LIB_MODULES=crypto_core/hsalsa20/ref crypto_core/salsa20/ref crypto_core/salsa208/opt crypto_core/salsa2012/opt crypto_box/curve25519xsalsa20poly1305 crypto_onetimeauth/poly1305/Radix2.26 crypto_onetimeauth/poly1305/Verify crypto_scalarmult/curve25519/Radix2.26 crypto_secretbox/xsalsa20poly1305 crypto_stream/salsa20 crypto_stream/salsa208 crypto_stream/salsa2012 crypto_stream/xsalsa20 crypto_verify/16 crypto_verify/32

LIB_SRCS_S=$(foreach subdir, $(LIB_MODULES), $(wildcard $(subdir)/*.S))
LIB_SRCS_C=$(foreach subdir, $(LIB_MODULES), $(wildcard $(subdir)/*.c)) 
LIB_SRCS= $(LIB_SRCS_C) $(LIB_SRCS_S)
LIB_OBJS=$(patsubst %.S, build/%.o,$(LIB_SRCS_S)) $(patsubst %.c, build/%.o, $(LIB_SRCS_C))
BUILD_DIR=$(addprefix build/, $(LIB_MODULES))

SRCS=$(wildcard *.c)
ASM=$(wildcard *.S)

OBJS_lose=$(SRCS:.c=.o) $(ASM:.S=.o)
OBJS=$(addprefix build/, $(OBJS_lose))

vpath %.c %.S $(LIB_SRCS)

upload: hex
	timeout 10s $(freedom-e-sdk)/scripts/upload --hex build/program.hex --jlink JLinkExe

upload_only: hex
	echo -e "\nloadfile build/program.hex\nexit" | timeout 15 JLinkExe -device FE310 -if JTAG -speed 4000 -jtagconf -1,-1 -autoconnect 1

reset:
	echo -e "\nr\nexit" | timeout 10 JLinkExe -device FE310 -if JTAG -speed 4000 -jtagconf -1,-1 -autoconnect 1

hex: lib $(OBJS)
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc  -march=rv32imac -mabi=ilp32 -mcmodel=medlow -ffunction-sections -fdata-sections -I$(freedom-e-sdk)/bsp/sifive-hifive1-revb/install/include -Os -g  -Wl,--gc-sections -Wl,-Map,program.map -nostartfiles -nostdlib -L$(freedom-e-sdk)/bsp/sifive-hifive1-revb/install/lib/debug/ -T$(freedom-e-sdk)/bsp/sifive-hifive1-revb/metal.default.lds $(OBJS) build/lib.a -Wl,--start-group -lc -lgcc -lmetal -lmetal-gloss -Wl,--end-group -Wl,--print-memory-usage -o build/program.elf
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-objcopy -O ihex build/program.elf build/program.hex

lib: checkdirs $(LIB_OBJS) 
	rm -f build/lib.a
	$(riscv64-unknown-elf-gcc)/bin/riscv64-unknown-elf-gcc-ar --target=elf32-littleriscv -q build/lib.a $(LIB_OBJS) 

build/%.o: %.c
	clang -O3 -c $< --target=riscv32 -march=rv32ia -I$(freedom-e-sdk)/freedom-metal -o $@ 

build/%.o: %.S
	clang -O0 -c $< --target=riscv32 -march=rv32ia -o $@

objdump:
	$(riscv-gnu-toolchain)/build-binutils-newlib/binutils/objdump -D $(file) > $(file).objdump 

clean:
	rm -rf build/

checkdirs: $(BUILD_DIR)


$(BUILD_DIR):
	@mkdir -p $@


