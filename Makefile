all:
	avr-gcc -c -pipe -gdwarf-2 -g2 -mmcu=atmega32u4 -fshort-enums -fno-inline-small-functions -fpack-struct -Wall -fno-strict-aliasing -funsigned-char -funsigned-bitfields -ffunction-sections -I. -DF_CPU=16000000UL -mrelax -fno-jump-tables -x c -Os -std=gnu99 -Wstrict-prototypes usb.c -o usb.o
	avr-gcc usb.o -o usb.elf -lm -Wl,-Map=usb.map,--cref -Wl,--gc-sections -Wl,--relax -mmcu=atmega32u4
	avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature usb.elf usb.hex

flash:
	avrdude -c usbasp -p m32u4 -U flash:w:usb.hex

.PHONY: $(wildcard *.eps)

baud-rate-calculation.eps: baud-rate-calculation.jpg
	@convert $< $@
	@imgsize $@ 16 -

#----------------

avrtel: _avrtel all
_avrtel:
	ctie -c tmp.ch usb.w micro.ch avrtel.ch
	ctangle usb tmp
