CC		:= clang
OBJCPY		:= llvm-objcopy
LD		:= ld.lld

BUILD_DIR = build
SRC_DIR = src

GENERAL_OPTIONS = 

CLANGOPS = -Wall -nostdlib -ffreestanding -mgeneral-regs-only -Iinclude -mcpu=cortex-a72+nosimd --target=aarch64-elf
ASMOPS = $(CLANGOPS)
COPS = $(CLANGOPS)

C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

ifndef VERBOSE
    VERB := @
endif

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	$(VERB) echo Compiling $<
	$(VERB) mkdir -p $(@D)
	$(VERB) $(CC) $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	$(VERB) echo Compiling $<
	$(VERB) mkdir -p $(@D)
	$(VERB) $(CC) $(ASMOPS) -MMD -c $< -o $@

$(BUILD_DIR)/kernel8.elf: $(SRC_DIR)/linker.ld $(OBJ_FILES)
	$(VERB) echo Linking kernel8.elf
	$(VERB) $(LD) -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel8.elf  $(OBJ_FILES)
	
$(BUILD_DIR)/kernel8.img: $(BUILD_DIR)/kernel8.elf
	$(VERB) echo Building kernel8.img
	$(VERB) $(OBJCPY) $(BUILD_DIR)/kernel8.elf -O binary $(BUILD_DIR)/kernel8.img

.PHONY: image kernel real_hardware

flat: $(BUILD_DIR)/kernel8.img

kernel: $(BUILD_DIR)/kernel8.elf

$(BUILD_DIR)/r4.img: $(BUILD_DIR)/kernel8.img src/config.txt third-party/raspi-firmware/boot/*
	$(VERB) echo Building the image
	
	$(VERB) echo -- Making the image file \($(BUILD_DIR)/r4.img \)
	$(VERB) dd if=/dev/zero of=$(BUILD_DIR)/tmp.img count=64 bs=1M
	$(VERB) echo -e "unit: sectors\n/dev/hdc1 : Id=0c" | sfdisk $(BUILD_DIR)/tmp.img > /dev/null
	$(VERB) mkfs.vfat -F 32 $(BUILD_DIR)/tmp.img > /dev/null
	
	$(VERB) echo -- Copying files to $(BUILD_DIR)/staging
	$(VERB) mkdir -p $(BUILD_DIR)/staging
	$(VERB) cp third-party/raspi-firmware/boot/bcm2710-rpi-3-b.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2710-rpi-3-b-plus.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2710-rpi-cm3.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-4-b.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-400.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-cm4.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-cm4s.dtb $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/*.dat $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/*.elf $(BUILD_DIR)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bootcode.bin $(BUILD_DIR)/staging/
	$(VERB) cp src/config.txt $(BUILD_DIR)/staging/
	$(VERB) cp $(BUILD_DIR)/kernel8.img $(BUILD_DIR)/staging/kernel8.img
	
	$(VERB) echo -- Gzipping the kernel
	$(VERB) gzip $(BUILD_DIR)/staging/kernel8.img
	$(VERB) mv $(BUILD_DIR)/staging/kernel8.img.gz $(BUILD_DIR)/staging/kernel8.img
	
	$(VERB) echo -- Copying files into the image
	$(VERB) mcopy -i $(BUILD_DIR)/tmp.img $(BUILD_DIR)/staging/* ::/	

	$(VERB) mv $(BUILD_DIR)/tmp.img $(BUILD_DIR)/r4.img
	$(VERB) echo Done!

real_hardware: $(BUILD_DIR)/r4.img
	
clean:
	rm -rf $(BUILD_DIR) *.img
