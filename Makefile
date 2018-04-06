all:
	avr-gcc -w -c -pipe -gdwarf-2 -g2 -mmcu=atmega32u4 -fshort-enums -fno-inline-small-functions -fpack-struct -Wall -fno-strict-aliasing -funsigned-char -funsigned-bitfields -ffunction-sections -I. -DARCH=ARCH_AVR8 -DF_CPU=16000000UL -mrelax -fno-jump-tables -x c -Os -std=gnu99 -Wstrict-prototypes -DUSE_LUFA_CONFIG_HEADER -IConfig/ -I. -ILUFA/.. -DARCH=ARCH_AVR8 -DBOARD=BOARD_USBKEY -DF_USB=16000000UL usb.c -o usb.o
	avr-gcc usb.o -o usb.elf -lm -Wl,-Map=usb.map,--cref -Wl,--gc-sections -Wl,--relax -mmcu=atmega32u4
	avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature usb.elf usb.hex

flash:
	avrdude -c usbasp -p m32u4 -U flash:w:usb.hex
