# this file is named in such a way in order that it will be used before "makefile" when we type "make"

all:
	@make -f makefile

flash: all
	avrdude -c usbasp -p m32u4 -U flash:w:usbttl.hex
