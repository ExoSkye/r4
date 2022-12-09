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

clean:
	rm boot.o kernel.o os.elf kernel8.img
