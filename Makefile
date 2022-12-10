CC		:= $(PREFIX)gcc
AS		:= $(PREFIX)as
OBJCPY		:= $(PREFIX)objcopy
boot.o: src/boot.S
	$(AS) -c src/boot.S -o boot.o

kernel.o: src/kernel.c
	$(CC) -ffreestanding -c src/kernel.c -o kernel.o -O2 -Wall -Wextra

os.elf: boot.o kernel.o src/linker.ld
	$(CC) -T src/linker.ld -o os.elf -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

kernel8.img: os.elf
	$(OBJCPY) os.elf -O binary kernel8.img

.PHONY: image kernel

image: kernel8.img

kernel: os.elf

real_hardware: kernel8.img
	mkdir -p staging
	cp -v raspi_fw/boot/bcm2710-rpi-3-b.dtb staging
	cp -v raspi_fw/boot/bcm2710-rpi-3-b-plus.dtb staging
	cp -v raspi_fw/boot/bcm2710-rpi-cm3.dtb staging
	cp -v raspi_fw/boot/bcm2711-rpi-4-b.dtb staging
	cp -v raspi_fw/boot/bcm2711-rpi-400.dtb staging
	cp -v raspi_fw/boot/bcm2711-rpi-cm4.dtb staging
	cp -v raspi_fw/boot/bcm2711-rpi-cm4s.dtb staging
	cp -v raspi_fw/boot/*.dat staging
	cp -v raspi_fw/boot/*.elf staging
	cp -v raspi_fw/boot/bootcode.bin staging
	cp -v kernel8.img staging

clean:
	rm boot.o kernel.o os.elf kernel8.img
	rm -rf staging
