CC	:= $(PREFIX)gcc
AS	:= $(PREFIX)as
OBJCPY	:= $(PREFIX)objcopy

boot.o: boot.S
	$(AS) -c boot.S -o boot.o

kernel.o: kernel.c
	$(CC) -ffreestanding -c kernel.c -o kernel.o -O2 -Wall -Wextra
	
os.elf: boot.o kernel.o linker.ld
	$(CC) -T linker.ld -o os.elf -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
	
kernel8.img: os.elf
	$(OBJCPY) os.elf -O binary kernel8.img

clean:
	rm boot.o kernel.o os.elf kernel8.img
