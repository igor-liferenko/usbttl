%TODO: convert all functions to lowercase with _

%NOTE: to test, use avr/check.w + see cweb/SERIAL_TODO

\let\lheader\rheader

\secpagedepth=1 % begin new page only on **

@** Data throughput, latency and handshaking issues.
The Universal Serial Bus may be new to some users and developers. Here are
described the major architecture differences that need to be considered by both software and
hardware designers when changing from a traditional RS232 based solution to one that uses
the USB to serial interface devices.

@* The need for handshaking.
USB data transfer is prone to delays that do not normally appear in systems that have been used
to transferring data using interrupts. The original COM ports of a PC were directly connected
to the
motherboard and were interrupt driven. When a character was transmitted or received (depending
if FIFO's are used) the CPU would be interrupted and go to a routine to handle the data. This
meant that a user could be reasonably certain that, given a particular baud rate and data rate,
the
transfer of data could be achieved without any real need for flow control. The hardware interrupt
ensured that the request would get serviced. Therefore data could be transferred without using
handshaking and still arrive into the PC without data loss.

@* Data transfer comparison.
USB does not transfer data using interrupts. It uses a scheduled system and as a result, there can
be periods when the USB request does not get scheduled and, if handshaking is not used, data
loss will occur. An example of scheduling delays can be seen if an open application is dragged
around using the mouse.

For a USB device, data transfer is done in packets. If data is to be sent from the PC, then a
packet
of data is built up by the device driver and sent to the USB scheduler. This scheduler puts the
request onto the list of tasks for the USB host controller to perform. This will typically take
at least
1 millisecond to execute because it will not pick up the new request until the next 'USB Frame'
(the
frame period is 1 millisecond). Therefore there is a sizable overhead (depending on your required
throughput) associated with moving the data from the application to the USB device. If data were
sent 'a byte at a time' by an application, this would severely limit the overall throughput of the
system as a whole.

@* Continuous data --- smoothing the lumps.
Data is received from USB to the PC by a polling method. The driver will request a certain amount
of data from the USB scheduler. This is done in multiples of 64 bytes. The 'bulk packet size' on
USB is a maximum of 64 bytes. The host controller will read data from the device until either:

a) a packet shorter than 64 bytes is received or
b) the requested data length is reached

The device driver will request packet sizes between 64 Bytes and 4 Kbytes. The size of the packet
will affect the performance and is dependent on the data rate. For very high speed, the largest
packet size is needed. For 'real-time' applications that are transferring audio data at 115200 Baud
for example, the smallest packet possible is desirable, otherwise the device will be holding up
4k of
data at a time. This can give the effect of 'jerky' data transfer if the USB request size is too
large
and the data rate too low (relatively).

@* Small amounts of data or end of buffer conditions.
When transferring data from a USB-Serial or USB-FIFO IC device to the PC, the device will
send the data given one of the following conditions:

1. The buffer is full (64 bytes made up of 2 status bytes and 62 user bytes).

2. One of the RS232 status lines has changed (USB-Serial chips only). A change of level (high
or low) on CTS\# / DSR\# / DCD\# or RI\# will cause it to pass back the current buffer even
though it may be empty or have less than 64 bytes in it.

3. An event character had been enabled and was detected in the incoming data stream.

4. A timer integral to the chip has timed out. There is a timer (latency timer) in some
chips that measures the time since data was last
sent to the PC. The default value of the timer is set to 16 milliseconds.
The value of the timer is adjustable from 1 to 255 milliseconds.
Every time data is
sent back to the PC the timer is reset. If it times-out then the chip will send back the 2 status
bytes and any data that is held in the buffer.

From this it can be seen that small amounts of data (or the end of large amounts of data), will be
subject to a 16 millisecond delay when transferring into the PC. This delay should be taken along
with the delays associated with the USB request size as mentioned in the previous section. The
timer value was chosen so that we could make advantage of 64 byte packets to fill large buffers
when in high speed mode, as well as letting single characters through. Since the value chosen for
the latency timer is 16 milliseconds, this means that it will take 16 milliseconds to receive an
individual character, over and above the transfer time on serial or parallel link.

For large amounts of data, at high data rates, the timer will not be used. It may be used to send
the last packet of a block, if the final packet size works out to be less than 64 bytes. The
first 2
bytes of every packet are used as status bytes for the driver. This status is sent every 16
milliseconds, even when no data is present in the device.

A worst case condition could occur when 62 bytes of data are received in 16 milliseconds. This
would not cause a timeout, but would send the 64 bytes (2 status + 62 user data bytes) back to
USB every 16 milliseconds. When the USB driver receives the 64 bytes it would hold on
to them and request another 'IN' transaction. This would be completed another 16 milliseconds
later and so on until USB driver gets all of the 4K of data required. The overall time would
be (4096 / 64) * 16 milliseconds = 1.024 seconds between data packets being received by the
application. In
order to stop the data arriving in 4K packets, it should be requested in smaller amounts. A short
packet (< 64 bytes) will of course cause the data to pass from USB driver back to the chip
driver for
use by the application.

For application programmers it must be stressed that data should be sent or received using buffers
and not individual characters.

@** Effect of USB buffer size and the latency timer on data throughput.
An effect that is not immediately obvious is the way the size of the USB total packet request
has on
the smoothness of data flow. When a read request is sent to USB, the USB host controller will
continue to read 64 byte packets until one of the following conditions is met:

1. It has read the requested size (default is 4 Kbytes).

2. It has received a packet shorter than 64 bytes from the chip.

3. It has been cancelled.

While the host controller is waiting for one of the above conditions to occur, NO data is
received by
our driver and hence the user's application. The data, if there is any, is only finally
transferred after
one of the above conditions has occurred.

Normally condition 3 will not occur so we will look at cases 1 and 2. If 64 byte packets are
continually sent back to the host, then it will continue to read the data to match the block size
requested before it sends the block back to the driver. If a small amount of data is sent, or the
data is sent slowly, then the latency timer will take over and send a short packet back to the host
which will terminate the read request. The data that has been read so far is then passed on to the
users application via the chip driver. This shows a relationship between the latency timer,
the data
rate and when the data will become available to the user. A condition can occur where if data is
passed into the chip at such a rate as to avoid the latency timer timing out, it can take a long
time between receiving data blocks. This occurs because the host controller will see 64 byte
packets at the point just before the end of the latency period and will therefore continue to
read the
data until it reaches the block size before it is passed back to the user's application.

The rate that causes this will be:

62 / Latency Timer bytes/Second

(2 bytes per 64 byte packet are used for status)

For the default values: -

62 / 0.016 ~= 3875 bytes /second ~= 38.75 KBaud

Therefore if data is received at a rate of 3875 bytes per second (38.75 KBaud) or faster, then the
data will be subject to delays based on the requested USB block length. If data is received at a
slower rate, then there will be less than 62 bytes (64 including our 2 status bytes) available
after 16
milliseconds. Therefore a short packet will occur, thus terminating the USB request and passing
the data back. At the limit condition of 38.75 KBaud it will take approximately 1.06 seconds
between data buffers into the users application (assuming a 4Kbyte USB block request buffer size).

To get around this you can either increase the latency timer or reduce the USB block request.
Reducing the USB block request is the preferred method though a balance between the 2 may be
sought for optimum system response.

USB Transfer (buffer) size can be adjusted in the chip. Transmit buffer and receive buffer
are separate. TODO: read Dimitrov's arduino forum thread about this.
@^TODO@>

The size of the USB block requested can be adjusted in the chip.

@* Event Characters.
If the event character is enabled and it is detected in the data stream, then the contents of the
devices buffer is sent immediately. The event character is not stripped out of the data stream by
the device or by the drivers, it is up to the application to remove it. Event characters may
be turned
on and off depending on whether large amounts of random data or small command sequences are
to be sent. The event character will not work if it is the first character in the buffer. It
needs to be
the second or higher. The reason for this being applications that use the Internet for example,
will
program the event character as `\$7E'. All the data is then sent and received in packets that have
`\$7E' at the start and at the end of the packet. In order to maximise throughput and to avoid a
packet with only the starting `\$7E' in it, the event character does not trigger on the first
position.

@* Flushing the receive buffer using the modem status lines.
Flow control can be used by some chips to flush
the buffer in the chip. Changing one of the modem status lines will do this. The modem status
lines can be controlled by an external device or from the host PC itself. If an unused output line
(DTR) is connected to one of the unused inputs (DSR), then if the DTR line is changed by the
application program from low to high or high to low, this will cause a change on DSR and make it
flush the buffer.

@* Flow Control.
Some chips use their own handshaking as an
integral part of its design, by proper use of the TXE\# line. Such chips can use RTS/CTS,
DTR/DSR hardware or XOn/XOff software handshaking.
It is highly recommended that some form of handshaking be used.

There are 4 methods of flow control that can be programmed for some devices.

1. None - this may result in data loss at high speeds

2. RTS/CTS - 2 wire handshake. The device will transmit if CTS is active and will drop RTS if it
cannot receive any more.

3. DTR/DSR - 2 wire handshake. The device will transmit if DSR is active and will drop DTR if it
cannot receive any more.

4. XON/XOFF - flow control is done by sending or receiving special characters. One is XOn
(transmit on) the other is XOff (transmit off). They are individually programmable to any value.

It is strongly encouraged that flow control is used because it is impossible to ensure that the
chip
driver will always be scheduled. The chip can buffer up to 384 bytes of data. Kernel can 'starve'
the driver program of time if it is doing other things. The most obvious example of this is moving
an application around the screen with the mouse by grabbing its task bar. This will result in a lot
of
graphics activity and data loss will occur if receiving data at 115200 baud (as an example) with no
handshaking. If the data rate is low or data loss is acceptable then flow control may be omitted.

@** The program.

@c
@<Header files@>@;
@<Macros@>@;
@<Type definitions@>@;
@<Function prototypes@>@;
@<Inline functions@>@;
@<Global variables@>@;
@<Main program loop@>@;

@ @<Only try to read in bytes from the CDC interface if the transmit buffer is not full@>=
if (!(RingBuffer_IsFull(&USBtoUSART_Buffer))) {
  int16_t ReceivedByte = CDC_Device_ReceiveByte(&VirtualSerial_CDC_Interface);
  @<Store received byte into the USART transmit buffer@>@;
}

@ @<Store received byte into the USART transmit buffer@>=
if (!(ReceivedByte < 0))
  RingBuffer_Insert(&USBtoUSART_Buffer, ReceivedByte);

@ Check if a packet is already enqueued to the host - if so, we shouldn't try to send
more data
until it completes as there is a chance nothing is listening and a lengthy timeout could
occur.

@<Try to send more data@>=
if (@<Endpoint is ready for an IN packet@>) {
  @<Calculate bytes to send@>@;
  @<Read bytes from the USART receive buffer into the USB IN endpoint@>@;
}

@ Never send more than one bank size less one byte to the host at a time, so that we
don't block
while a Zero Length Packet (ZLP) to terminate the transfer is sent if the host isn't
listening.

@d MIN(x, y)               (((x) < (y)) ? (x) : (y))

@<Calculate bytes to send@>=
uint8_t BytesToSend = MIN(BufferCount, (CDC_TXRX_EPSIZE - 1));

@ @<Read bytes from the USART receive buffer into the USB IN endpoint@>=
while (BytesToSend--) {
  @<Try to send the next byte of data to the host, abort if there is an error
    without dequeuing@>@;
  @<Dequeue the already sent byte from the buffer now we have confirmed that no
    transmission error occurred@>@;
}

@ @<Try to send the next byte of data to the host, abort if there is an error without
    dequeuing@>=
if (CDC_Device_SendByte(&VirtualSerial_CDC_Interface,
    RingBuffer_Peek(&USARTtoUSB_Buffer)) != ENDPOINT_READYWAIT_NO_ERROR) break;

@ @<Dequeue the already sent byte from the buffer now we have confirmed that no
    transmission error occurred@>=
RingBuffer_Remove(&USARTtoUSB_Buffer);

@ @<Load the next byte from ring buffer into the USART transmit buffer@>=
if (@<USART Data Register Empty@> && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
  UDR1 = RingBuffer_Remove(&USBtoUSART_Buffer); /* transmit a given raw byte through the USART */

@ The transmit buffer can only be written when the |UDRE1| bit in the |UCSR1A| register is set.

@<USART Data Register Empty@>=
(UCSR1A & (1 << UDRE1))

@ Circular buffer to hold data from the host before it is sent to the device via the
serial port.

@<Global...@>=
RingBuffer_t USBtoUSART_Buffer;

@ Underlying data buffer for |USBtoUSART_Buffer|, where the stored bytes are located.

@<Global...@>=
uint8_t USBtoUSART_Buffer_Data[128];

@ Circular buffer to hold data from the serial port before it is sent to the host.

@<Global...@>=
RingBuffer_t USARTtoUSB_Buffer;

@ Underlying data buffer for |USARTtoUSB_Buffer|, where the stored bytes are located.

@<Global...@>=
uint8_t USARTtoUSB_Buffer_Data[128];

@ ISR to manage the reception of data from the serial port, placing received bytes into
a circular buffer for later transmission to the host.
Interrupt is enabled via |RXCIE1|.

@c
ISR(USART1_RX_vect)
{
  uint8_t ReceivedByte = UDR1;
  if ((USB_DeviceState == DEVICE_STATE_CONFIGURED) &&
  !(RingBuffer_IsFull(&USARTtoUSB_Buffer)))
  RingBuffer_Insert(&USARTtoUSB_Buffer, ReceivedByte);
}

@ CDC class driver event handler for a line encoding change event on a CDC interface. This
event fires each time the host requests a
line encoding change (containing the serial parity, baud and other configuration information)
and may be hooked in the
user program by declaring a handler function with the same name and parameters listed here.
The new line encoding
settings are available in the |LineEncoding| structure inside the CDC interface structure
passed as a parameter.

@<Func...@>=
void EVENT_CDC_Device_LineEncodingChanged(void);

@ @c
void EVENT_CDC_Device_LineEncodingChanged(void)
{
	uint8_t ConfigMask = 0;

	switch (VirtualSerial_CDC_Interface.State.LineEncoding.ParityType)
	{
		case CDC_PARITY_ODD:
			ConfigMask = ((1 << UPM11) | (1 << UPM10)); @+
@^see datasheet@>
			break;
		case CDC_PARITY_EVEN:
			ConfigMask = (1 << UPM11); @+
			break;
	}

  if (VirtualSerial_CDC_Interface.State.LineEncoding.CharFormat == CDC_LINEENCODING_TWO_STOP_BITS)
	  ConfigMask |= (1 << USBS1);
@^see datasheet@>

	switch (VirtualSerial_CDC_Interface.State.LineEncoding.DataBits)
	{
		case 6:
			ConfigMask |= (1 << UCSZ10); @+
			break;
		case 7:
			ConfigMask |= (1 << UCSZ11); @+
			break;
		case 8:
@^see datasheet@>
			ConfigMask |= ((1 << UCSZ11) | (1 << UCSZ10)); @+
			break;
	}

        @<Turn off USART before reconfiguring it@>@;
	@<Configure UART@>@;
}

@ Must turn off USART before reconfiguring it, otherwise incorrect operation may occur.

@<Turn off USART before reconfiguring it@>=
UCSR1B = 0;
UCSR1C = 0;
UCSR1A = 0;

@ Setting |U2X1| bit will reduce the divisor of the baud rate divider from 16 to 8,
effectively doubling the transfer rate. Note however that the Receiver will in this
case only use half the number of samples (reduced from 16 to 8) for data sampling
and clock recovery, and therefore a more accurate baud rate setting and system
clock are required when this mode is used. For the Transmitter, there are no downsides.

Using a CPU clock of 4 MHz, 9600 Bd can be achieved with an acceptable
tolerance without setting \.{U2X} (prescaler 25), while 38400 Bd
require \.{U2X} to be set (prescaler 12).

The USART Baud Rate Register (UBRR) and the down-counter connected to it functions
as a programmable prescaler or baud rate generator. The down-counter, running at
system clock ($F_{OSC}$), is loaded with the UBRR value each time the counter has counted
down to zero or when the UBRRL Register is written. A clock is generated each time
the counter reaches zero.

This clock is the baud rate generator clock output (= $F_{OSC}/(UBRR+1)$). The
transmitter divides the baud rate generator clock output by 2, 8, or 16 depending
on mode. The baud rate generator output is used directly by the receiver's clock
and data recovery units.

Below are the equations for calculating baud rate and UBRR value:

$$\hbox to16cm{\vbox to5.14cm{\vfil\special{psfile=baud-rate-calculation.eps
  clip llx=0 lly=0 urx=470 ury=151 rwi=4535}}\hfil}$$

\item{1.} $BAUD$ = Baud Rate in Bits/Second (bps) (Always remember, Bps = Bytes/Second,
whereas bps = Bits/Second)
\item{2.} $F_{OSC}$  = System Clock Frequency (1MHz) (or as per use in case of external oscillator)
\item{3.} $UBRR$ = Contents of |UBRRL| and |UBRRH| registers

@d BAUD VirtualSerial_CDC_Interface.State.LineEncoding.BaudRateBPS
@d UBRRVAL ((F_CPU / 16 + BAUD / 2) / BAUD - 1)
@d UBRRVAL_2X ((F_CPU / 8 + BAUD / 2) / BAUD - 1)
@d TOLERANCE 2 /* baud rate tolerance (in percent) that is acceptable during the calculations */
@d UPPER_BOUND (16 * (UBRRVAL + 1) * (100 * BAUD + BAUD * TOLERANCE))
@d LOWER_BOUND (16 * (UBRRVAL + 1) * (100 * BAUD - BAUD * TOLERANCE))

@<Configure UART@>=
if (100 * F_CPU < LOWER_BOUND || 100 * F_CPU > UPPER_BOUND) {
  UBRR1 = UBRRVAL_2X;
  UCSR1A = (1 << U2X1); /* double the transfer rate */
}
else { /* within bounds */
  UBRR1 = UBRRVAL;
  UCSR1A = 0; /* normal transfer rate */
}
UCSR1C = ConfigMask;
UCSR1B = ((1 << RXCIE1) | (1 << TXEN1) | (1 << RXEN1));

@ Function to retrieve a given descriptor's size and memory location from the given
descriptor type value,
index and language ID. This function MUST be overridden in the user application
(added with full, identical
prototype and name so that the library can call it to retrieve descriptor data.

When the device receives a Get Descriptor request on the control
endpoint, this function
is called so that the descriptor details can be passed back and the appropriate descriptor
sent back to the
USB host.

|wValue| -- The type of the descriptor to retrieve in the upper
byte, and the index in the lower byte (when more than one descriptor of the given
type exists, such as the case of string descriptors). The type may be one of
the standard types defined in the |DescriptorTypes_t| enum, or may be a
class-specific descriptor type value.

|DescriptorAddress| -- pointer to the descriptor in memory. This should be
set by the routine to the address of the descriptor.

Note, that all descriptors are located in FLASH memory
(i.e., not in RAM or EEPROM) via the |PROGMEM| attribute.

Returns size in bytes of the descriptor if it exists, zero or |NO_DESCRIPTOR| otherwise.

@<Func...@>=
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
                                    const void** const DescriptorAddress);

@ @dSTRING_ID_LANGUAGE 0 /* Supported Languages string descriptor
    ID (must be zero) */
@d STRING_ID_MANUFACTURER 1 /* Manufacturer string ID */
@d STRING_ID_PRODUCT 2 /* Product string ID */

@c
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
                                    const void** const DescriptorAddress)
{
	const uint8_t  DescriptorType   = (wValue >> 8);
	const uint8_t  DescriptorNumber = (wValue & 0xFF);

	const void* Address = NULL;
	uint16_t    Size    = NO_DESCRIPTOR;

	switch (DescriptorType)
	{
		case DTYPE_DEVICE: @/
			Address = &DeviceDescriptor;
			Size    = sizeof (USB_Descriptor_Device_t);
			break;
		case DTYPE_CONFIGURATION: @/
			Address = &ConfigurationDescriptor;
			Size    = sizeof (USB_Descriptor_Config_t);
			break;
		case DTYPE_STRING: @/
			switch (DescriptorNumber)
			{
				case STRING_ID_LANGUAGE: @/
					Address = &LanguageString;
				Size    = pgm_read_byte(&LanguageString.Header.Size);
					break;
				case STRING_ID_MANUFACTURER: @/
					Address = &ManufacturerString;
				Size    = pgm_read_byte(&ManufacturerString.Header.Size);
					break;
				case STRING_ID_PRODUCT: @/
					Address = &ProductString;
				Size    = pgm_read_byte(&ProductString.Header.Size);
					break;
			}

			break;
	}

	*DescriptorAddress = Address;
	return Size;
}

@* Main USB service task management.

@ This is the main USB management task. The USB driver requires this task to be executed
continuously when the USB system is active (attached to a host)
in order to manage USB communications. This task may be executed inside an RTOS,
fast timer ISR or the main user application loop.

Each packet must be acknowledged or sent within 50ms or the host will abort the transfer.
Use interrupts to manage control endpoint if you are out of this limit.

TODO: sometimes device fails to detect - this is not connected with
the fact that control endpoint is managed not via interrupts (checked it) - the
reason is somewhere else - find it

conclusion: we must send packet first, only then host sends setup packet (REQ_GET_DESCRIPTOR)
setup address = to device
device not accepting address
power cycle

setup device = to host

after power cycle REQ_SET_ADDRESS is called first and connection goes fine afterwards

@<Manage control endpoint@>=
#if 1==0
/* FIXME: is it needed? */
	if (USB_DeviceState == DEVICE_STATE_UNATTACHED)
	  return;
#endif

  uint8_t PrevEndpoint = get_current_endpoint();
  UENUM = ENDPOINT_CONTROLEP; /* select endpoint */
  if (@<Endpoint has received a SETUP packet@>) {
    /* FIXME: several SETUP packets must be received before EORSTI interrupt can be
       disabled - find out after which packet EORSTI interrput can be disabled
       and disable it here, and also ensure that until EORSTI interrupt is
       disabled (and a short time after it) no two identical SETUP packets
       arrive */
    USB_Device_ProcessControlRequest();
first = 0;
  }
  else {
if (first)        Endpoint_ConfigureEndpoint(ENDPOINT_CONTROLEP, EP_TYPE_CONTROL,
      USB_Device_ControlEndpointSize, 1);
  }
  UENUM = PrevEndpoint & ENDPOINT_EPNUM_MASK; /* select endpoint */

@* USB controller interrupt service routine management.

@ @<Address of USB Device is set@>=
(UDADDR & (1 << ADDEN))

@* USB Controller definitions for the AVR8 microcontrollers.

@ Enable internal 3.3V USB data pad regulator to regulate the voltage of the D+/D- pads,
which must be within a 3.0-3.6V range.

PLL (Phase-Locked Loop) is used to generate the high frequency clock that the USB controller
requires.
Modern SoCs use PLL to generate (almost) any clock that might be needed for
interfaces. In simplified terms, the PLL circuit employs a high-frequency VCO
(Voltage-controlled oscillator), then uses difital frequency dividers on both VCO and
input clock, and generates a voltage feedback based on the frequency ratio. This feedback
controls the VCO, such that the entire loop is locked to the desired frequency.
Set |PINDIV| to configure the PLL input prescaler to generate the 8MHz input clock for the
PLL from 16 MHz clock source.
When the |PLLE| is set, the PLL is started.

Host port activates VBUS (+5V).
The voltage source on the pull-up resistor for D+ line is taken from VBUS.
When host port detects the pull-up, it asserts
|USB_RESET| state on the bus, driving both D+ and D- lines to ground.
This happens several times (for unknown reason), so |EORSTE| interrupt must be used
Simply using \\{\_delay\_ms} makes the following errors appear prior to
normal logs for the device:
kernel: [495632.527201] usb 3-1.1: new full-speed USB device number 98 using xhci_hcd
kernel: [495632.607322] usb 3-1.1: device descriptor read/64, error -32
kernel: [495632.795324] usb 3-1.1: device descriptor read/64, error -32
kernel: [495632.983053] usb 3-1.1: new full-speed USB device number 99 using xhci_hcd
kernel: [495633.063348] usb 3-1.1: device descriptor read/64, error -32
kernel: [495633.251354] usb 3-1.1: device descriptor read/64, error -32
kernel: [495633.359724] usb 3-1-port1: attempt power cycle

@<Initialize USB@>=
UHWCON |= 1 << UVREGE; /* enable data pad regulator */
@#
PLLFRQ |= (1 << PDIV2); /* default */
PLLCSR |= 1 << PINDIV; /* must be set before starting PLL */
PLLCSR |= 1 << PLLE; /* start PLL */
while (!(PLLCSR & (1 << PLOCK))) ; /* wait until PLL is ready */
@#
USBCON |= 1 << USBE; /* enable USB controller */
USBCON &= ~(1 << FRZCLK); /* enable clock input */
UDCON &= ~(1 << LSM); /* set full-speed mode */
@#
USBCON |= 1 << OTGPADE; /* enable VBUS pin */
UDCON &= ~(1 << DETACH); /* enable pull-up on D+ */

@* USB Endpoint definitions.

@ Configures a table of endpoint descriptions, in sequence. This function can be used to
configure multiple
endpoints at the same time.

Note, that endpoints with a zero address will be ignored, thus this function cannot be used
to configure the control endpoint.

|Table| -- pointer to a table of endpoint descriptions. \par
|Entries| -- number of entries in the endpoint table to configure.

Return true if all endpoints configured successfully, false otherwise.

@<Func...@>=
bool Endpoint_ConfigureEndpointTable(const USB_Endpoint_Table_t* const Table,
                                     const uint8_t Entries);

@ @c
bool Endpoint_ConfigureEndpointTable(const USB_Endpoint_Table_t* const Table,
                                     const uint8_t Entries)
{
	for (uint8_t i = 0; i < Entries; i++)
	{
		if (!(Table[i].Address))
		  continue;

 if (!(Endpoint_ConfigureEndpoint(Table[i].Address, Table[i].Type, Table[i].Size, Table[i].Banks)))
		  return false;
	}

	return true;
}

@ Completes the status stage of a control transfer on a CONTROL type endpoint automatically,
with respect to the data direction. This is a convenience function which can be used to
simplify user control request handling.

Note, that this routine should not be called on non CONTROL type endpoints.

@<Func...@>=
void Endpoint_ClearStatusStage(void);

@ @c
void Endpoint_ClearStatusStage(void)
{
	if (USB_ControlRequest.bmRequestType & REQDIR_DEVICETOHOST) {
		while (!@<Endpoint received an OUT packet@>) {
			if (USB_DeviceState == DEVICE_STATE_UNATTACHED)
			  return;
		}

		@<Clear OUT packet on endpoint@>@;
	}
	else {
		while (!@<Endpoint is ready for an IN packet@>) {
			if (USB_DeviceState == DEVICE_STATE_UNATTACHED)
			  return;
		}

		@<Clear IN packet on endpoint@>@;
	}
}

@ Spin-loops until the currently selected non-control endpoint is ready for the next packet
of data to be read or written to it.

Note, that this routine should not be called on CONTROL type endpoints.

Returns one of the following values:

@d ENDPOINT_READYWAIT_NO_ERROR 0 /* endpoint is ready for next packet, no error */
@d ENDPOINT_READYWAIT_ENDPOINT_STALLED 1 /* endpoint was stalled during the stream transfer
  by the host or device */
@d ENDPOINT_READYWAIT_DEV_DISCONNECTED 2 /* device was disconnected from the host while
                                              waiting for the endpoint to become ready */
@d ENDPOINT_READYWAIT_BUS_SUSPENDED 3 /* the USB bus has been suspended by the host and
                                        no USB endpoint traffic can occur until the bus
                                        has resumed */
@d ENDPOINT_READYWAIT_TIMEOUT 4 /* the host failed to accept or send the next packet
                                      within the software timeout period set by the
                                      |USB_STREAM_TIMEOUT_MS| macro */

@<Func...@>=
uint8_t Endpoint_WaitUntilReady(void);

@ @c
uint8_t Endpoint_WaitUntilReady(void)
{
  uint8_t  TimeoutMSRem = USB_STREAM_TIMEOUT_MS;

  uint16_t PreviousFrameNumber = @[@<Get USB frame number@>@];

  while (1) {
    if (@<Endpoint's direction is IN@>) {
      if (@<Endpoint is ready for an IN packet@>)
        return ENDPOINT_READYWAIT_NO_ERROR;
    }
    else {
      if (@<Endpoint received an OUT packet@>)
        return ENDPOINT_READYWAIT_NO_ERROR;
    }

    uint8_t USB_DeviceState_LCL = USB_DeviceState;

    if (USB_DeviceState_LCL == DEVICE_STATE_UNATTACHED)
      return ENDPOINT_READYWAIT_DEV_DISCONNECTED;
    else if (USB_DeviceState_LCL == DEVICE_STATE_SUSPENDED)
      return ENDPOINT_READYWAIT_BUS_SUSPENDED;
    else if (@<Endpoint is stalled@>)
      return ENDPOINT_READYWAIT_ENDPOINT_STALLED;

    uint16_t CurrentFrameNumber = @[@<Get USB frame number@>@];

    if (CurrentFrameNumber != PreviousFrameNumber) {
      PreviousFrameNumber = CurrentFrameNumber;

      if (!(TimeoutMSRem--))
        return ENDPOINT_READYWAIT_TIMEOUT;
    }
  }
}

@ Returns the current USB frame number from the USB controller. Every millisecond the USB bus
is active (i.e. enumerated to a host) the frame number is incremented by one.

@<Get USB frame number@>=
UDFNUM

@* USB CDC Class driver.

@ @<Func...@>=
void CDC_Device_ProcessControlRequest(void);

@ @c
void CDC_Device_ProcessControlRequest(void)
{
  if (USB_ControlRequest.wIndex != VirtualSerial_CDC_Interface.Config.ControlInterfaceNumber)
    return;

  switch (USB_ControlRequest.bRequest)
  {
    case CDC_REQ_GET_LINE_ENCODING:
      if (USB_ControlRequest.bmRequestType ==
         (REQDIR_DEVICETOHOST | REQTYPE_CLASS | REQREC_INTERFACE)) {
        @<Clear a received SETUP packet on endpoint@>@;

        while (!@<Endpoint is ready for an IN packet@>) ;

        Endpoint_Write_32_LE(VirtualSerial_CDC_Interface.State.LineEncoding.BaudRateBPS);
        Endpoint_Write_8(VirtualSerial_CDC_Interface.State.LineEncoding.CharFormat);
        Endpoint_Write_8(VirtualSerial_CDC_Interface.State.LineEncoding.ParityType);
        Endpoint_Write_8(VirtualSerial_CDC_Interface.State.LineEncoding.DataBits);

        @<Clear IN packet on endpoint@>@;
        Endpoint_ClearStatusStage();
      }
      break;
    case CDC_REQ_SET_LINE_ENCODING:
      if (USB_ControlRequest.bmRequestType ==
         (REQDIR_HOSTTODEVICE | REQTYPE_CLASS | REQREC_INTERFACE)) {
        @<Clear a received SETUP packet on endpoint@>@;

        while (!@<Endpoint received an OUT packet@>) {
          if (USB_DeviceState == DEVICE_STATE_UNATTACHED)
            return;
        }

        VirtualSerial_CDC_Interface.State.LineEncoding.BaudRateBPS = Endpoint_Read_32_LE();
        VirtualSerial_CDC_Interface.State.LineEncoding.CharFormat = Endpoint_Read_8();
        VirtualSerial_CDC_Interface.State.LineEncoding.ParityType = Endpoint_Read_8();
        VirtualSerial_CDC_Interface.State.LineEncoding.DataBits = Endpoint_Read_8();

        @<Clear OUT packet on endpoint@>@;
        Endpoint_ClearStatusStage();

        EVENT_CDC_Device_LineEncodingChanged();
      }
      break;
    case CDC_REQ_SET_CONTROL_LINE_STATE:
      if (USB_ControlRequest.bmRequestType ==
         (REQDIR_HOSTTODEVICE | REQTYPE_CLASS | REQREC_INTERFACE)) {
        @<Clear a received SETUP packet on endpoint@>@;
        Endpoint_ClearStatusStage();

      VirtualSerial_CDC_Interface.State.ControlLineStates.HostToDevice = USB_ControlRequest.wValue;

        @<Set |DTR| pin@>@;
      }
      break;
    case CDC_REQ_SEND_BREAK:
      if (USB_ControlRequest.bmRequestType ==
         (REQDIR_HOSTTODEVICE | REQTYPE_CLASS | REQREC_INTERFACE)) {
        @<Clear a received SETUP packet on endpoint@>@;
        Endpoint_ClearStatusStage();
      }
      break;
  }
}

@ Control line state changed on a CDC interface. This fires
each time the host requests a
control line state change (containing the virtual serial control line states, such as DTR).
The new control line states
are available in the |ControlLineStates.HostToDevice| value inside the CDC interface
structure passed as a parameter, set as a mask of \.{CDC\_CONTROL\_LINE\_OUT\_*} masks.

@<Set |DTR| pin@>=
if (VirtualSerial_CDC_Interface.State.ControlLineStates.HostToDevice & CDC_CONTROL_LINE_OUT_DTR) {
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
  PORTB &= ~(1 << PB0); /* led off */
}
else {
  PORTE |= 1 << PE6; /* |DTR| pin high */
  PORTB |= 1 << PB0; /* led on */
}

@ Configures the endpoints of a given CDC interface, ready for use. This should be linked to
the library
|EVENT_USB_Device_ConfigurationChanged| event so that the endpoints are configured when
the configuration containing the given CDC interface is selected.

|CDCInterfaceInfo| -- pointer to a structure containing a CDC Class configuration and state.

Returns true if the endpoints were successfully configured, false otherwise.

@<Func...@>=
bool CDC_Device_ConfigureEndpoints(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo);

@ @c
bool CDC_Device_ConfigureEndpoints(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	memset(&CDCInterfaceInfo->State, 0x00, sizeof(CDCInterfaceInfo->State));

	CDCInterfaceInfo->Config.DataINEndpoint.Type       = EP_TYPE_BULK;
	CDCInterfaceInfo->Config.DataOUTEndpoint.Type      = EP_TYPE_BULK;
	CDCInterfaceInfo->Config.NotificationEndpoint.Type = EP_TYPE_INTERRUPT;

	if (!(Endpoint_ConfigureEndpointTable(&CDCInterfaceInfo->Config.DataINEndpoint, 1)))
	  return false;

	if (!(Endpoint_ConfigureEndpointTable(&CDCInterfaceInfo->Config.DataOUTEndpoint, 1)))
	  return false;

	if (!(Endpoint_ConfigureEndpointTable(&CDCInterfaceInfo->Config.NotificationEndpoint, 1)))
	  return false;

	return true;
}

@ General management task for a given CDC class interface, required for the correct operation
of the interface. This should
be called frequently in the main program loop, before |@<Manage control endpoint@>|.

|CDCInterfaceInfo| -- pointer to a structure containing a CDC Class configuration and state.

@<Func...@>=
void CDC_Device_USBTask(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo);

@ @c
void CDC_Device_USBTask(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_CONFIGURED) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return;

  UENUM = CDCInterfaceInfo->Config.DataINEndpoint.Address & ENDPOINT_EPNUM_MASK;
    /* select endpoint */

	if (@<Endpoint is ready for an IN packet@>)
	  CDC_Device_Flush(CDCInterfaceInfo);
}

@ Sends a given byte to the attached USB host, if connected. If a host is not connected
when the function is called, the
byte is discarded. Bytes will be queued for transmission to the host until either the
endpoint bank becomes full, or the
|CDC_Device_Flush| function is called to flush the pending data to the host. This
allows for multiple bytes to be
packed into a single endpoint packet, increasing data throughput.

This function must only be called when the Device state machine is in the
|DEVICE_STATE_CONFIGURED| state or the call will fail.

|CDCInterfaceInfo| --  pointer to a structure containing a CDC Class
configuration and state.
|Data| -- byte of data to send to the host.

Returns a \.{ENDPOINT\_READYWAIT\_*} value.

@<Func...@>=
uint8_t CDC_Device_SendByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const uint8_t Data);

@ @c
uint8_t CDC_Device_SendByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const uint8_t Data)
{
	if ((USB_DeviceState != DEVICE_STATE_CONFIGURED) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_DEV_DISCONNECTED;

  UENUM = CDCInterfaceInfo->Config.DataINEndpoint.Address & ENDPOINT_EPNUM_MASK;
    /* select endpoint */

	if (!@<Read-write is allowed for endpoint@>) {
		@<Clear IN packet on endpoint@>@;

		uint8_t ErrorCode;

		if ((ErrorCode = Endpoint_WaitUntilReady()) != ENDPOINT_READYWAIT_NO_ERROR)
		  return ErrorCode;
	}

	Endpoint_Write_8(Data);
	return ENDPOINT_READYWAIT_NO_ERROR;
}

@ Flushes any data waiting to be sent, ensuring that the send buffer is cleared.

This function must only be called when the Device state machine is in the
|DEVICE_STATE_CONFIGURED| state or the call will fail.

|CDCInterfaceInfo| -- pointer to a structure containing a CDC Class configuration
and state.

Returns a \.{ENDPOINT\_READYWAIT\_*} value.

@<Func...@>=
uint8_t CDC_Device_Flush(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo);

@ @c
uint8_t CDC_Device_Flush(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
  if ((USB_DeviceState != DEVICE_STATE_CONFIGURED) ||
      !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
    return ENDPOINT_DEV_DISCONNECTED;

  uint8_t ErrorCode;

  UENUM = CDCInterfaceInfo->Config.DataINEndpoint.Address & ENDPOINT_EPNUM_MASK;
    /* select endpoint */

  if (@<Number of bytes in endpoint@>
                                      == 0)
    return ENDPOINT_READYWAIT_NO_ERROR;

  bool BankFull = !@<Read-write is allowed for endpoint@>;

  @<Clear IN packet on endpoint@>@;

  if (BankFull) {
    if ((ErrorCode = Endpoint_WaitUntilReady()) != ENDPOINT_READYWAIT_NO_ERROR)
      return ErrorCode;

    @<Clear IN packet on endpoint@>@;
  }

  return ENDPOINT_READYWAIT_NO_ERROR;
}

@ Reads a byte of data from the host. If no data is waiting to be read of if a USB host is
not connected, the function
returns a negative value. The |CDC_Device_BytesReceived| function may be queried in
advance to determine how many
bytes are currently buffered in the CDC interface's data receive endpoint bank, and thus how
many repeated calls to this
function which are guaranteed to succeed.

This function must only be called when the Device state machine is in the
|DEVICE_STATE_CONFIGURED| state or the call will fail.

|CDCInterfaceInfo| -- pointer to a structure containing a CDC Class
configuration and state.

Returns next received byte from the host, or a negative value if no data received.

@<Func...@>=
int16_t CDC_Device_ReceiveByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo);

@ @c
int16_t CDC_Device_ReceiveByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
  if ((USB_DeviceState != DEVICE_STATE_CONFIGURED) ||
      !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
    return -1;

  int16_t ReceivedByte = -1;

  UENUM = CDCInterfaceInfo->Config.DataOUTEndpoint.Address & ENDPOINT_EPNUM_MASK;
    /* select endpoint */

  if (@<Endpoint received an OUT packet@>) {
    if (@<Number of bytes in endpoint@> != 0)
      ReceivedByte = Endpoint_Read_8();

    if (@<Number of bytes in endpoint@>
                                        == 0)
      @<Clear OUT packet on endpoint@>@;
  }

  return ReceivedByte;
}

@* USB device standard request management.

@ @<Func...@>=
void USB_Device_ProcessControlRequest(void);

@ Unknown requests are automatically STALLed.

@c
void USB_Device_ProcessControlRequest(void)
{
  uint8_t* RequestHeader = (uint8_t*) &USB_ControlRequest;

  for (uint8_t RequestHeaderByte = 0; RequestHeaderByte < sizeof (USB_Request_Header_t);
    RequestHeaderByte++)
	  *(RequestHeader++) = Endpoint_Read_8();
  /* FIXME: call |@<Endpoint has received a SETUP packet@>| here instead of in |@<Manage...@>|? */
  CDC_Device_ProcessControlRequest();

    uint8_t bmRequestType = USB_ControlRequest.bmRequestType;

    switch (USB_ControlRequest.bRequest) {
    case REQ_GET_STATUS:
	if ((bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE)) ||
		(bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_ENDPOINT)))
			USB_Device_GetStatus();
	
	break;
    case REQ_CLEAR_FEATURE:
    case REQ_SET_FEATURE:
	if ((bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_DEVICE)) ||
		(bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_ENDPOINT)))
					USB_Device_ClearSetFeature();
	break;
    case REQ_SET_ADDRESS:
	if (bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_DEVICE))
		  USB_Device_SetAddress();
	break;
    case REQ_GET_DESCRIPTOR:
if (first) PORTC|=1<<PC7; /* works before power cycle */
	if ((bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE)) ||
		(bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_INTERFACE)))
					USB_Device_GetDescriptor();
	break;
    case REQ_GET_CONFIGURATION:
	if (bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE))
		USB_Device_GetConfiguration();
	break;
    case REQ_SET_CONFIGURATION:
	if (bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_DEVICE))
		USB_Device_SetConfiguration();
	break;
    default:
	break;
    }

  if (@<Endpoint has received a SETUP packet@>) { /* SETUP packet is cleared in above |case|
    calls */
    @<Clear a received SETUP packet on endpoint@>@;
    @<Stall transaction on endpoint@>@;
  }
}

@ @<Function prototypes@>=
void USB_Device_SetAddress(void);

@ @c
void USB_Device_SetAddress(void)
{
	uint8_t DeviceAddress = (USB_ControlRequest.wValue & 0x7F);

  @<Set device address@>@;

  @<Clear a received SETUP packet on endpoint@>@;

	Endpoint_ClearStatusStage();

	while (!@<Endpoint is ready for an IN packet@>) ;

  @<Enable device address@>@;

	USB_DeviceState = (DeviceAddress) ? DEVICE_STATE_ADDRESSED : DEVICE_STATE_DEFAULT;
}

@ @<Set device address@>=
UDADDR = (UDADDR & (1 << ADDEN)) | (DeviceAddress & 0x7F);

@ @<Enable device address@>=
UDADDR |= (1 << ADDEN);

@ @<Function prototypes@>=
void USB_Device_SetConfiguration(void);

@ @c
void USB_Device_SetConfiguration(void)
{
  if ((uint8_t) USB_ControlRequest.wValue > FIXED_NUM_CONFIGURATIONS)
	return;

  @<Clear a received SETUP packet on endpoint@>@;

  USB_Device_ConfigurationNumber = (uint8_t) USB_ControlRequest.wValue;

  Endpoint_ClearStatusStage();

  if (USB_Device_ConfigurationNumber)
    USB_DeviceState = DEVICE_STATE_CONFIGURED;
  else
    USB_DeviceState = @<Address of USB Device is set@> ?
      DEVICE_STATE_CONFIGURED : DEVICE_STATE_POWERED;

  EVENT_USB_Device_ConfigurationChanged();
}

@ @<Function prototypes@>=
void USB_Device_GetConfiguration(void);

@ @c
void USB_Device_GetConfiguration(void)
{
  @<Clear a received SETUP packet on endpoint@>@;

	Endpoint_Write_8(USB_Device_ConfigurationNumber);
  @<Clear IN packet on endpoint@>@;

	Endpoint_ClearStatusStage();
}

@ @<Function prototypes@>=
void USB_Device_GetInternalSerialDescriptor(void);

@ @c
void USB_Device_GetInternalSerialDescriptor(void)
{
	struct
	{
		USB_Descriptor_Header_t Header;
		uint16_t                UnicodeString[INTERNAL_SERIAL_LENGTH_BITS / 4];
	} SignatureDescriptor;

	SignatureDescriptor.Header.Type = DTYPE_STRING;
	SignatureDescriptor.Header.Size = USB_STRING_LEN(INTERNAL_SERIAL_LENGTH_BITS / 4);

	USB_Device_GetSerialString(SignatureDescriptor.UnicodeString);

  @<Clear a received SETUP packet on endpoint@>@;

	Endpoint_Write_Control_Stream_LE(&SignatureDescriptor, sizeof(SignatureDescriptor));
  @<Clear OUT packet on endpoint@>@;
}

@ @<Function prototypes@>=
void USB_Device_GetDescriptor(void);

@ @c
void USB_Device_GetDescriptor(void)
{
	const void* DescriptorPointer;
	uint16_t DescriptorSize;

	if (USB_ControlRequest.wValue == ((DTYPE_STRING << 8) | USE_INTERNAL_SERIAL))
	{
		USB_Device_GetInternalSerialDescriptor();
		return;
	}

	if ((DescriptorSize = CALLBACK_USB_GetDescriptor(USB_ControlRequest.wValue,
             &DescriptorPointer)) == NO_DESCRIPTOR)
		return;

  @<Clear a received SETUP packet on endpoint@>@;

	Endpoint_Write_Control_PStream_LE(DescriptorPointer, DescriptorSize);

  @<Clear OUT packet on endpoint@>@;
}

@ @<Function prototypes@>=
void USB_Device_GetStatus(void);

@ @c
void USB_Device_GetStatus(void)
{
  uint8_t CurrentStatus = 0;

  switch (USB_ControlRequest.bmRequestType)
  {
	case (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE):
		/* FIXME: can this be removed? */
		break;
	case (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_ENDPOINT):
        {
		uint8_t endpoint_index = USB_ControlRequest.wIndex;

		if (endpoint_index >= ENDPOINT_TOTAL_ENDPOINTS)
			return;

                UENUM = endpoint_index & ENDPOINT_EPNUM_MASK; /* select endpoint */

		CurrentStatus = @[@<Endpoint is stalled@>@];

                UENUM = ENDPOINT_CONTROLEP; /* select endpoint */

		break;
        }
	default:
		return;
  }

  @<Clear a received SETUP packet on endpoint@>@;

  Endpoint_Write_16_LE(CurrentStatus);
  @<Clear IN packet on endpoint@>@;

  Endpoint_ClearStatusStage();
}

@ @<Function prototypes@>=
void USB_Device_ClearSetFeature(void);

@ @c
void USB_Device_ClearSetFeature(void)
{
  switch (USB_ControlRequest.bmRequestType & CONTROL_REQTYPE_RECIPIENT)
  {
    case REQREC_DEVICE:
	/* FIXME: can we remove this? */
	break;
    case REQREC_ENDPOINT:
      if ((uint8_t) USB_ControlRequest.wValue == FEATURE_SEL_ENDPOINT_HALT) {
        uint8_t endpoint_index = USB_ControlRequest.wIndex;

        if (endpoint_index == ENDPOINT_CONTROLEP || endpoint_index >= ENDPOINT_TOTAL_ENDPOINTS)
		  return;

        UENUM = endpoint_index; /* select endpoint */

        if (@<Endpoint is enabled@>) {
          if (USB_ControlRequest.bRequest == REQ_SET_FEATURE)
            @<Stall transaction on endpoint@>@;
          else {
            @<Clear STALL condition on endpoint@>@;
            Endpoint_ResetEndpoint(endpoint_index);
            @<Reset data toggle of endpoint@>@;
          }
        }
      }
      break;
    default:
      return;
  }

  UENUM = ENDPOINT_CONTROLEP; /* select endpoint */

  @<Clear a received SETUP packet on endpoint@>@;

  Endpoint_ClearStatusStage();
}

@ Determines if the currently selected endpoint is enabled, but not necessarily configured.

Returns true if the currently selected endpoint is enabled, false otherwise.

@<Endpoint is enabled@>=
(UECONX & (1 << EPEN))

@ Resets the data toggle of the currently selected endpoint.

@<Reset data toggle of endpoint@>=
UECONX |= (1 << RSTDT);

@* Endpoint data stream.
Endpoint data stream transmission and reception management.

@ Writes the given number of bytes to the CONTROL type endpoint from the given buffer in
little endian,
sending full packets to the host as needed. The host OUT acknowledgement is not automatically
cleared
in both failure and success states; the user is responsible for manually clearing the status
OUT packet
to finalize the transfer's status stage via the |@<Clear OUT packet on endpoint@>| macro.

This function automatically sends the last packet in the data stage of the transaction;
when the
function returns, the user is responsible for clearing the status stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.

This routine should only be used on CONTROL type endpoints.

Unlike the standard stream read/write commands, the control stream commands cannot
be chained
together; i.e. the entire stream data must be read or written at the one time.

|Buffer| -- pointer to the source data buffer to read from.
|Length| -- number of bytes to read for the currently selected endpoint into the buffer.

Returns a \.{ENDPOINT\_RWCSTREAM\_*} value.

@<Func...@>=
uint8_t Endpoint_Write_Control_Stream_LE(const void* const Buffer, uint16_t Length);
@ @c
uint8_t Endpoint_Write_Control_Stream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  @<Clear IN packet on endpoint@>@;

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_UNATTACHED)
		  return ENDPOINT_DEV_DISCONNECTED;
		else if (USB_DeviceState_LCL == DEVICE_STATE_SUSPENDED)
		  return ENDPOINT_BUS_SUSPENDED;
		else if (@<Endpoint has received a SETUP packet@>)
		  return ENDPOINT_HOST_ABORTED;
		else if (@<Endpoint received an OUT packet@>)
		  break;

		if (@<Endpoint is ready for an IN packet@>) {
			uint16_t BytesInEndpoint = @[@<Number of bytes in endpoint@>@];

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(*DataStream);
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			@<Clear IN packet on endpoint@>@;
		}
	}

	while (!@<Endpoint received an OUT packet@>) {
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_UNATTACHED)
		  return ENDPOINT_DEV_DISCONNECTED;
		else if (USB_DeviceState_LCL == DEVICE_STATE_SUSPENDED)
		  return ENDPOINT_BUS_SUSPENDED;
		else if (@<Endpoint has received a SETUP packet@>)
		  return ENDPOINT_HOST_ABORTED;
	}

	return ENDPOINT_NO_ERROR;
}

@ FLASH buffer source version of |Endpoint_Write_Control_Stream_LE|.

The FLASH data must be located in the first 64KB of FLASH for this function to work correctly.

This function automatically sends the last packet in the data stage of the transaction;
when the function returns, the user is responsible for clearing the
status stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.

This routine should only be used on CONTROL type endpoints.

Unlike the standard stream read/write commands, the control stream commands cannot be
chained together; i.e. the entire stream data must be read or written at the one time.

|Buffer| -- pointer to the source data buffer to read from.
|Length| -- number of bytes to read for the currently selected endpoint into the buffer.

Returns a \.{ENDPOINT\_RWCSTREAM\_*} value.

@<Func...@>=
uint8_t Endpoint_Write_Control_PStream_LE(const void* const Buffer, uint16_t Length);
@ @c
uint8_t Endpoint_Write_Control_PStream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  @<Clear IN packet on endpoint@>@;

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_UNATTACHED)
		  return ENDPOINT_DEV_DISCONNECTED;
		else if (USB_DeviceState_LCL == DEVICE_STATE_SUSPENDED)
		  return ENDPOINT_BUS_SUSPENDED;
		else if (@<Endpoint has received a SETUP packet@>)
		  return ENDPOINT_HOST_ABORTED;
		else if (@<Endpoint received an OUT packet@>)
		  break;

		if (@<Endpoint is ready for an IN packet@>) {
			uint16_t BytesInEndpoint = @[@<Number of bytes in endpoint@>@];

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(pgm_read_byte(DataStream));
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			@<Clear IN packet on endpoint@>@;
		}
	}

	while (!@<Endpoint received an OUT packet@>) {
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_UNATTACHED)
		  return ENDPOINT_DEV_DISCONNECTED;
		else if (USB_DeviceState_LCL == DEVICE_STATE_SUSPENDED)
		  return ENDPOINT_BUS_SUSPENDED;
		else if (@<Endpoint has received a SETUP packet@>)
		  return ENDPOINT_HOST_ABORTED;
	}

	return ENDPOINT_NO_ERROR;
}

@** USB.
The USB functionality.

@* Core driver for the microcontroller hardware USB module.

@*1 Driver and framework for the USB controller.
The USB stack requires the sole control over the USB controller in the microcontroller
only; i.e. it does not
require any additional timers or other peripherals to operate. This ensures that the USB
stack requires as few
resources as possible.

Here the USB stack is used in Device Mode for connections to USB Hosts.

@*2 USB Class Drivers.
Driver for the standardized CDC USB device class.

Class drivers give a framework which sits on top of the low level library API,
allowing for standard
USB classes to be implemented in a project with minimal user code.

These drivers can
be used in
conjunction with the library low level APIs to implement interfaces both via the
class drivers and via
the standard library APIs.

Multiple device mode class drivers can be used within a project, including multiple
instances of the
same class driver. In this way, USB Hosts and Devices can be made quickly using the
internal class drivers
so that more time and effort can be put into the end application instead of the USB protocol.

CDC-ACM class driver is used here.

@*1 Using the Class Drivers.
To make the Class drivers easy to integrate into a user application, they all
implement a standardized
design with similarly named/used function, enums, defines and types. The two different
modes are implemented
slightly differently, and thus will be explained separately. For information on a
specific class driver, read
the class driver's module documentation.

@*2 Device Mode Class Drivers.
Implementing a Device Mode Class Driver in a user application requires a number of steps
to be followed. Firstly,
the module configuration and state structure must be added to the project source.
These structures are named in a
similar manner between classes, that of |USB_ClassInfo_CDC_Device_t|,
and are used to hold the
complete state and configuration for each class instance. Multiple class instances is
where the power of the class
drivers lie; multiple interfaces of the same class simply require more instances of the
Class Driver's \&{USB\_ClassInfo\_*}
structure.

Inside the ClassInfo structure lies two sections, a |Config| section, and a
|State| section. The |Config| section contains the instance's configuration parameters.

@ LUFA CDC Class driver interface configuration and state information.
This structure is
passed to all CDC Class driver functions, so that multiple instances of the same class
within a device can be differentiated from one another.

Initialize instance (i.e., set \\{Config} field) of the CDC Class Driver structure.

Note, that the class driver's configuration parameters should match those used in the
device's descriptors that are sent to the host.

@<Global...@>=
USB_ClassInfo_CDC_Device_t VirtualSerial_CDC_Interface = {@|
  @<Initialize \\{Config} field of |USB_ClassInfo_CDC_Device_t|@>@/
};

@ @<Initialize \\{Config} field of |USB_ClassInfo_CDC_Device_t|@>= {@|
  INTERFACE_ID_CDC_CCI, @|
  {@, CDC_TX_EPADDR, CDC_TXRX_EPSIZE, 1 @,}, @|
  {@, CDC_RX_EPADDR, CDC_TXRX_EPSIZE, 1 @,}, @|
  {@, CDC_NOTIFICATION_EPADDR, CDC_NOTIFICATION_EPSIZE, 1 @,} @/
}

@ To initialize the Class driver instance, the driver's
|CDC_Device_ConfigureEndpoints| function
should be called in response to the |EVENT_USB_Device_ConfigurationChanged| event.
This function will return a
boolean true value if the driver successfully initialized the instance. Like all the
class driver functions, this function
takes in the address of the specific instance you wish to initialize
(this was done to be able to initialize multiple separate instances of the same class
type).

Event handler for USB configuration number change event.
This event fires when a the USB host changes the
selected configuration number while in device mode. This event should be hooked in device
applications to create the endpoints and configure the device for the selected configuration.

This event is time-critical; exceeding OS-specific delays within this event handler
(typically of around
one second) will prevent the device from enumerating correctly.

This event fires after the value of |USB_Device_ConfigurationNumber| has been changed.

@<Func...@>=
void EVENT_USB_Device_ConfigurationChanged(void);

@ @c
void EVENT_USB_Device_ConfigurationChanged(void)
{
  if (CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface)) /* USB interface is ready */
    PORTD &= ~(1 << PD5);
  else /* an error has occurred in the USB interface */
    PORTD |= 1 << PD5;
}

@ Once initialized, it is important to maintain the CDC class instance state by repeatedly
calling the Class Driver's |CDC_Device_USBTask| function in the main program loop.
It needs to be called before |@<Manage control endpoint@>|.

@<Main program loop@>=
int first = 1;
int main(void)
{
DDRC |= 1 << PC7;
  DDRE |= 1 << PE6;
  PORTE |= 1 << PE6; /* |DTR| pin high */
  DDRB |= 1 << PB0;
  PORTB |= 1 << PB0; /* led on */

  DDRD |= 1 << PD5;
  PORTD |= 1 << PD5; /* indicate that microcontroller is connecting */

  clock_prescale_set(clock_div_1); /* disable clock division */

  sei();

  USB_DeviceState = DEVICE_STATE_DEFAULT;
  USB_Device_ConfigurationNumber = 0;

  @<Initialize USB@>@;

#if 1==0
  TCCR0B = (1 << CS02); /* from arduino-usbserial; start the flush timer so that overflows occur
                           rapidly to push received bytes to the USB interface */
#endif

  RingBuffer_InitBuffer(&USBtoUSART_Buffer, USBtoUSART_Buffer_Data,
    sizeof USBtoUSART_Buffer_Data);
  RingBuffer_InitBuffer(&USARTtoUSB_Buffer, USARTtoUSB_Buffer_Data,
    sizeof USARTtoUSB_Buffer_Data);

  while (1) {
    @<Only try to read in bytes from the CDC interface if the transmit buffer...@>@;
    uint16_t BufferCount = RingBuffer_GetCount(&USARTtoUSB_Buffer);
    if (BufferCount) {
      UENUM = VirtualSerial_CDC_Interface.Config.DataINEndpoint.Address & ENDPOINT_EPNUM_MASK;
        /* select endpoint */
      @<Try to send more data@>@;
    }
    @<Load the next byte...@>@;

    CDC_Device_USBTask(&VirtualSerial_CDC_Interface);
    @<Manage control endpoint@>@;
  }
}

@ Class driver also defines a callback function |CALLBACK_USB_GetDescriptor|.
In addition, each class
driver may
also define a set of events (identifiable by their prefix of \\{EVENT\_*} in the
function's name), which
the user application may choose to implement, or ignore if not needed.

{\emergencystretch=2cm The individual Device Mode Class Driver documentation contains more
information on the
non-standardized,
class-specific functions which the user application can then use on the driver instances,
such as data
read and write routines. See each driver's individual documentation for more information
on the
class-specific functions.\par}

@* Attributes.
Special function/variable attribute macros.

This contains macros for applying specific attributes to functions and variables
to control various optimizer and code generation features of the compiler.

@ Forces the compiler to inline the specified function. When applied, the given function will be
in-lined under all circumstances.

@<Macros@>=
#define ALWAYS @t\hskip9pt@> __attribute__ @t\hskip-5pt@> ((always_inline))

@ Marks a variable or struct element for packing into the smallest space available, omitting any
alignment bytes usually added between fields to optimize field accesses.

@<Macros@>=
#define PACKED @t\hskip9pt@> __attribute__ @t\hskip-5pt@> ((packed))

@* Configuration.
Configure compile time options,
as an alternative to the compile time constants supplied through
the makefile.

@ By default, the library determines the size of the control endpoint by reading the device
descriptor. Normally this reduces the amount of configuration required for the library, allows
the value to change dynamically (if descriptors are stored in EEPROM or RAM rather than flash
memory) and reduces code maintenance. However, this token can be defined to a non-zero value
instead to give the size in bytes of the control endpoint, to reduce the size of the compiled
binary.

@<Macros@>=
#define FIXED_CONTROL_ENDPOINT_SIZE      8

@ By default, the library determines the number of configurations a USB device supports by
reading the device descriptor. This reduces the amount of configuration required to set up the
library, and allows the value to change dynamically (if descriptors are stored in EEPROM or RAM
rather than flash memory) and reduces code maintenance. However, this value may be fixed via this
token to reduce the compiled size of the binary at the expense of flexibility.

@<Macros@>=
#define FIXED_NUM_CONFIGURATIONS         1

@* USBController.
USB Controller definitions for general USB controller management.
Functions, macros, variables, enums and types related to the setup and management of the USB
 interface.

@ Endpoint direction masks.

@<Macros@>=
#define ENDPOINT_DIR_IN 0x80 /* endpoint address direction mask for an IN direction (Device to
  Host) endpoint; it may be ORed with the index of the address within a device to obtain the full
  endpoint address */

@ Endpoint type masks.

@<Macros@>=
#define EP_TYPE_CONTROL 0x00 /* mask for a CONTROL type endpoint */
#define EP_TYPE_BULK 0x02 /* mask for a BULK type endpoint */
#define EP_TYPE_INTERRUPT 0x03 /* mask for an INTERRUPT type endpoint */

@* USBController AVR8.
USB Controller definitions for the AVR8 microcontrollers.
Functions, macros, variables, enums and types related to the setup and management of
the USB interface.

@*1 USB Controller Option Masks.

@ Constant for the maximum software timeout period of the USB data stream transfer functions
(both control and standard). If the next packet of a stream
is not received or acknowledged within this time period, the stream function will fail.

@<Macros@>=
#define USB_STREAM_TIMEOUT_MS       100

@* Endpoint.
Endpoint data read/write definitions.
Functions, macros, variables, enums and types related to data reading and writing from and
to endpoints.

USB Endpoint package management definitions.
Functions, macros, variables, enums and types related to packet management of endpoints.

Endpoint management definitions.
Functions, macros and enums related to endpoint management. This
contains the endpoint management macros, as well as endpoint interrupt and data
send/receive functions for various data types.

@ Type define for a endpoint table entry, used to configure endpoints
in groups via \hfil\break |Endpoint_ConfigureEndpointTable|.

@s USB_Endpoint_Table_t int

@<Type definitions@>=
typedef struct
{
	uint8_t  Address; /* address of the endpoint to configure, or zero if the table
 entry is to be unused */
	uint16_t Size; /* size of the endpoint bank, in bytes */
	uint8_t  Banks; /* number of hardware banks to use for the endpoint */
        uint8_t  Type; /* type of the endpoint, a \.{EP\_TYPE\_*} mask */
} USB_Endpoint_Table_t;

@ Endpoint number mask, for masking against endpoint addresses to retrieve the endpoint's
numerical address in the device.

@<Macros@>=
#define ENDPOINT_EPNUM_MASK                     0x0F

@ Endpoint address for the default control endpoint, which always resides in address 0. This is
defined for convenience to give more readable code when used with the endpoint macros.

@<Macros@>=
#define ENDPOINT_CONTROLEP                      0

@ @<Inline...@>=
inline
@,@=ALWAYS@>
uint8_t Endpoint_BytesToEPSizeMask(const uint16_t Bytes)
{
	uint8_t  MaskVal    = 0;
	uint16_t CheckBytes = 8;

	while (CheckBytes < Bytes)
	{
		MaskVal++;
		CheckBytes <<= 1;
	}

	return (MaskVal << EPSIZE0);
}

@ Enables the currently selected endpoint so that data can be sent and received through it to
and from a host.

Note, that endpoints must first be configured properly via |Endpoint_ConfigureEndpoint|.

@<Enable endpoint@>=
UECONX |= (1 << EPEN);

@ Disables the currently selected endpoint so that data cannot be sent and received through it
to and from a host.

@<Disable endpoint@>=
UECONX &= ~(1 << EPEN);

@ Determines if the currently selected endpoint is configured.

Returns boolean true if the currently selected endpoint has been configured, false
otherwise.

@<Endpoint is configured@>=
(UESTA0X & (1 << CFGOK))

@ Total number of endpoints (including the default control endpoint at address 0) which may
be used in the device. Different USB AVR models support different amounts of endpoints,
this value reflects the maximum number of endpoints for the currently selected AVR model.

@<Macros@>=
#define ENDPOINT_TOTAL_ENDPOINTS 7

@ Configures the specified endpoint address with the given endpoint type, bank size and
number of hardware
banks. Once configured, the endpoint may be read from or written to, depending on its
direction.

|Address| is endpoint address to configure.

|Type| is type of endpoint to configure, a \.{EP\_TYPE\_*} mask. Not all
endpoint types are available on Low Speed USB devices - refer to the USB 2.0 specification.

|Size| is size of the endpoint's bank, where packets are stored before they
are transmitted to the USB host, or after they have been received from the USB host
(depending on the endpoint's data direction). The bank size must indicate the
maximum packet size that the endpoint can handle.

|Banks| is number of banks to use for the endpoint being configured.

Note, that different endpoints may have different maximum packet sizes based on the
endpoint's index - please refer to the microcontroller's datasheet to determine the maximum bank
size for each endpoint.

The default control endpoint is configured {\it not via this function - where\/}?

Note, that this routine will automatically select the specified endpoint upon success. Upon
failure, the endpoint which failed to reconfigure correctly will be selected.

Returns true if the configuration succeeded, false otherwise.

@<Inline...@>=
inline
@,@=ALWAYS@>
bool Endpoint_ConfigureEndpoint(const uint8_t Address,
                                              const uint8_t Type,
                                              const uint16_t Size,
                                              const uint8_t Banks)
{
	uint8_t Number = (Address & ENDPOINT_EPNUM_MASK);

	if (Number >= ENDPOINT_TOTAL_ENDPOINTS)
	  return false;

  uint8_t UECFG0XData = (Type << EPTYPE0) | ((Address & ENDPOINT_DIR_IN) ? (1 << EPDIR) : 0);
  uint8_t UECFG1XData = (1 << ALLOC) | ((Banks > 1) ? (1 << EPBK0) : 0) |
    Endpoint_BytesToEPSizeMask(Size);

        for (uint8_t EPNum = Number; EPNum < ENDPOINT_TOTAL_ENDPOINTS; EPNum++) {
                uint8_t UECFG0XTemp;
                uint8_t UECFG1XTemp;
                uint8_t UEIENXTemp;

                UENUM = EPNum; /* select endpoint */

                if (EPNum == Number) {
                        UECFG0XTemp = UECFG0XData;
                        UECFG1XTemp = UECFG1XData;
                        UEIENXTemp  = 0;
                }
                else {
                        UECFG0XTemp = UECFG0X;
                        UECFG1XTemp = UECFG1X;
                        UEIENXTemp  = UEIENX;
                }

                if (!(UECFG1XTemp & (1 << ALLOC)))
                  continue;

    @<Disable endpoint@>@;
                UECFG1X &= ~(1 << ALLOC);


                @<Enable endpoint@>@;
                UECFG0X = UECFG0XTemp;
                UECFG1X = UECFG1XTemp;
                UEIENX  = UEIENXTemp;

                if (!@<Endpoint is configured@>)
                  return false;
        }

  UENUM = Number & ENDPOINT_EPNUM_MASK; /* select endpoint */
  return true;
}

@ Indicates the number of bytes currently stored in the current endpoint's selected bank.
Returns total number of bytes in the currently selected Endpoint's FIFO buffer.

@<Number of bytes in endpoint@>=
(((uint16_t)UEBCHX << 8) | UEBCLX)

@ Determines the currently selected endpoint's direction.

@<Endpoint's direction is IN@>=
(UECFG0X & (1 << EPDIR))

@ Get the endpoint address of the currently selected endpoint. This is typically used to save
the currently selected endpoint so that it can be restored after another endpoint has been
manipulated.

|UENUM| -- endpoint index.\par

@<Inline...@>=
inline
@,@=ALWAYS@>
uint8_t get_current_endpoint(void)
{
  return @<Endpoint's direction is IN@> ? (UENUM | ENDPOINT_DIR_IN) : UENUM;
}

@ Resets the endpoint bank FIFO. This clears all the endpoint banks and resets the USB
controller's data In and Out pointers to the bank's contents.

|Address| is endpoint address whose FIFO buffers are to be reset.

@<Inline...@>=
inline
@,@=ALWAYS@>
void Endpoint_ResetEndpoint(const uint8_t Address)
{
	UERST = (1 << (Address & ENDPOINT_EPNUM_MASK));
	UERST = 0;
}

@ Determines if the currently selected endpoint may be read from (if data is waiting in
the endpoint
bank and the endpoint is an OUT direction, or if the bank is not yet full if the endpoint
is an IN
direction). This function will return false if an error has occurred in the endpoint, if
the endpoint
is an OUT direction and no packet (or an empty packet) has been received, or if the endpoint
is an IN
direction and the endpoint bank is full.

Returns boolean true if the currently selected endpoint may be read from or written to,
depending on its direction.

@<Read-write is allowed for endpoint@>=
(UEINTX & (1 << RWAL))

@ Determines if the selected IN endpoint is ready for a new packet to be sent to the host.

@<Endpoint is ready for an IN packet@>=
(UEINTX & (1 << TXINI))

@ Determines if the selected OUT endpoint has received new packet from the host.

@<Endpoint received an OUT packet@>=
(UEINTX & (1 << RXOUTI))

@ Determines if the current CONTROL type endpoint has received a SETUP packet.

@<Endpoint has received a SETUP packet@>=
(UEINTX & (1 << RXSTPI))

@ Clears a received SETUP packet on the currently selected CONTROL type endpoint, freeing up the
endpoint for the next packet.
Note, that this is not applicable for non CONTROL type endpoints.

@<Clear a received SETUP packet on endpoint@>=
UEINTX &= ~(1 << RXSTPI);

@ Sends an IN packet to the host on the currently selected endpoint, freeing up the endpoint
for the next packet and switching to the alternative endpoint bank if double banked.

@<Clear IN packet on endpoint@>=
UEINTX &= ~((1 << TXINI) | (1 << FIFOCON));

@ Acknowledges an OUT packet to the host on the currently selected endpoint, freeing up
the endpoint for the next packet and switching to the alternative endpoint bank if double banked.

@<Clear OUT packet on endpoint@>=
UEINTX &= ~((1 << RXOUTI) | (1 << FIFOCON));

@ Stalls the current endpoint, indicating to the host that a logical problem occurred with the
indicated endpoint and that the current transfer sequence should be aborted. This provides a
way for devices to indicate invalid commands to the host so that the current transfer can be
aborted and the host can begin its own recovery sequence.

The currently selected endpoint remains stalled until either the
|@<Clear STALL condition on endpoint@>| macro
is called, or the host issues a CLEAR FEATURE request to the device for the currently selected
endpoint.

@<Stall transaction on endpoint@>=
UECONX |= (1 << STALLRQ);

@ Clears the STALL condition on the currently selected endpoint.

@<Clear STALL condition on endpoint@>=
UECONX |= (1 << STALLRQC);

@ Determines if the currently selected endpoint is stalled.

@<Endpoint is stalled@>=
(UECONX & (1 << STALLRQ))

@ Reads next byte from the currently selected endpoint's bank (i.e., FIFO buffer),
for OUT direction endpoints.

@<Inline...@>=
inline
@,@=ALWAYS@>
uint8_t Endpoint_Read_8(void)
{
  return UEDATX;
}

@ Writes one byte to the currently selected endpoint's bank (i.e., FIFO buffer),
for IN direction endpoints.

@<Inline...@>=
inline
@,@=ALWAYS@>
void Endpoint_Write_8(const uint8_t Data)
{
  UEDATX = Data;
}

@ Discards one byte from the currently selected endpoint's bank (i.e., FIFO buffer),
for OUT direction endpoints.

@<Inline...@>=
inline
@,@=ALWAYS@>
void Endpoint_Discard_8(void)
{
  (void) UEDATX;
}

@ Writes two bytes to the currently selected endpoint's bank (i.e., FIFO buffer)
in little endian format, for IN direction endpoints.

@<Inline...@>=
inline
@,@=ALWAYS@>
void Endpoint_Write_16_LE(const uint16_t Data)
{
	UEDATX = (Data & 0xFF);
	UEDATX = (Data >> 8);
}

@ Reads next four bytes from the currently selected endpoint's bank (i.e., FIFO buffer)
in little endian format, for OUT direction endpoints.

@<Inline...@>=
inline
@,@=ALWAYS@>
uint32_t Endpoint_Read_32_LE(void)
{
	union
	{
		uint32_t Value;
		uint8_t  Bytes[4];
	} Data;

	Data.Bytes[0] = UEDATX;
	Data.Bytes[1] = UEDATX;
	Data.Bytes[2] = UEDATX;
	Data.Bytes[3] = UEDATX;

	return Data.Value;
}

@ Writes four bytes to the currently selected endpoint's bank (i.e., FIFO buffer)
in little endian format, for IN direction endpoints.

@<Inline...@>=
inline
@,@=ALWAYS@>
void Endpoint_Write_32_LE(const uint32_t Data)
{
	UEDATX = (Data &  0xFF);
	UEDATX = (Data >> 8);
	UEDATX = (Data >> 16);
	UEDATX = (Data >> 24);
}

@ Global indicating the maximum packet size of the default control endpoint located at address
0 in the device. This value is set to the value indicated in the device descriptor in the user
project once the USB interface is initialized into device mode.

If space is an issue, it is possible to fix this to a static value by defining the control
endpoint size in the |FIXED_CONTROL_ENDPOINT_SIZE| token passed to the compiler in the
makefile
via the -D switch. When a fixed control endpoint size is used, the size is no longer
dynamically
read from the descriptors at runtime and instead fixed to the given value. When used, it is
important that the descriptor control endpoint size value matches the size given as the
|FIXED_CONTROL_ENDPOINT_SIZE| token - it is recommended that the
|FIXED_CONTROL_ENDPOINT_SIZE| token
be used in the device descriptors to ensure this.

This variable should be treated as read-only, and never manually
changed in value.

@<Macros@>=
#define USB_Device_ControlEndpointSize FIXED_CONTROL_ENDPOINT_SIZE

@* Device.
USB Device management definitions.

@*1 Various states of the USB Device state machine.

For information on each possible USB device state, refer to the USB 2.0 specification.

See |USB_DeviceState|, which stores the current device state machine state.

@ This state indicates
that the device is not currently connected to a host.

@<Macros@>=
#define DEVICE_STATE_UNATTACHED 0

@ This state indicates
that the device is connected to a host, but enumeration has not
yet begun.

@<Macros@>=
#define DEVICE_STATE_POWERED 1

@ This state indicates
that the device's USB bus has been reset by the host and it is
now waiting for the host to begin the enumeration process.

@<Macros@>=
#define DEVICE_STATE_DEFAULT 2

@ This state indicates
that the device has been addressed by the USB Host, but is not
yet configured.

@<Macros@>=
#define DEVICE_STATE_ADDRESSED 3

@ This state indicates
that the device has been enumerated by the host and is ready
for USB communications to begin.

@<Macros@>=
#define DEVICE_STATE_CONFIGURED 4

@ This state indicates
that the USB bus has been suspended by the host, and the device
should power down to a minimal power level until the bus is resumed.

@<Macros@>=
#define DEVICE_STATE_SUSPENDED 5

@*1 USB Device Mode Option Masks.

@ String descriptor index for the device's unique serial number string descriptor within
the device.
This unique serial number is used by the host to associate resources to the device (such as
drivers or COM port
number allocations) to a device regardless of the port it is plugged in to on the host. Some
microcontrollers contain
a unique serial number internally, and setting the device descriptors serial number string index
to this value will cause it to use the internal serial number.

On unsupported devices, this will evaluate to |NO_DESCRIPTOR| and so will force the host to
create a pseudo-serial number for the device.

@<Macros@>=
#define USE_INTERNAL_SERIAL            0xDC

@ Length of the device's unique internal serial number, in bits, if present on the selected
microcontroller model.

@<Macros@>=
#define INTERNAL_SERIAL_LENGTH_BITS    80

@ Start address of the internal serial number, in the appropriate address space, if present on
the selected microcontroller model.

@<Macros@>=
#define INTERNAL_SERIAL_START_ADDRESS  0x0E

@ @<Func...@>=
inline void USB_Device_GetSerialString(uint16_t* const UnicodeString);
@ @c
inline void USB_Device_GetSerialString(uint16_t* const UnicodeString)
{
  cli();

  uint8_t SigReadAddress = INTERNAL_SERIAL_START_ADDRESS;

  for (uint8_t SerialCharNum = 0; SerialCharNum < (INTERNAL_SERIAL_LENGTH_BITS / 4);
    SerialCharNum++) {
		uint8_t SerialByte = boot_signature_byte_get(SigReadAddress);

		if (SerialCharNum & 0x01) {
			SerialByte >>= 4;
			SigReadAddress++;
		}

		SerialByte &= 0x0F;

		UnicodeString[SerialCharNum] = (SerialByte >= 10) ?
		   (('A' - 10) + SerialByte) : ('0' + SerialByte);
	}

  sei();
}

@* StdRequestType.
USB control endpoint request definitions.

Contains definitions for the various control request parameters, so that
the request details (such as data direction, request recipient, etc.) can be extracted
via masking.

@ Mask for the request type parameter, to indicate the direction of the request data
(Host to Device or Device to Host). The result of this mask should then be compared to
the request direction masks.

See \.{REQDIR\_*} macros for masks indicating the request data direction.

@<Macros@>=
#define CONTROL_REQTYPE_DIRECTION  0x80

@ Mask for the request type parameter, to indicate the type of request (Device, Class or Vendor
Specific). The result of this mask should then be compared to the request type masks.

See \.{REQTYPE\_*} macros for masks indicating the request type.

@<Macros@>=
#define CONTROL_REQTYPE_TYPE       0x60

@ Mask for the request type parameter, to indicate the recipient of the request (Device,
Interface Endpoint or Other). The result of this mask should then be compared to the request
recipient masks.

See \.{REQREC\_*} macros for masks indicating the request recipient.

@<Macros@>=
#define CONTROL_REQTYPE_RECIPIENT  0x1F

@*1 Control Request Data Direction Masks.

@ Request data direction mask, indicating that the request data will flow from host to device.

See |CONTROL_REQTYPE_DIRECTION| macro.

@<Macros@>=
#define REQDIR_HOSTTODEVICE        (0 << 7)

@ Request data direction mask, indicating that the request data will flow from device to host.

See |CONTROL_REQTYPE_DIRECTION| macro.

@<Macros@>=
#define REQDIR_DEVICETOHOST        (1 << 7)

@*1 Control Request Type Masks.

@ Request type mask, indicating that the request is a standard request.

See |CONTROL_REQTYPE_TYPE| macro.

@<Macros@>=
#define REQTYPE_STANDARD           (0 << 5)

@ Request type mask, indicating that the request is a class-specific request.

See |CONTROL_REQTYPE_TYPE| macro.

@<Macros@>=
#define REQTYPE_CLASS              (1 << 5)

@ Request type mask, indicating that the request is a vendor specific request.

See |CONTROL_REQTYPE_TYPE| macro.

@<Macros@>=
#define REQTYPE_VENDOR             (2 << 5)

@*1 Control Request Recipient Masks.

@ Request recipient mask, indicating that the request is to be issued to the device as a whole.

See |CONTROL_REQTYPE_RECIPIENT| macro.

@<Macros@>=
#define REQREC_DEVICE              (0 << 0)

@ Request recipient mask, indicating that the request is to be issued to an interface in the
currently selected configuration.

See |CONTROL_REQTYPE_RECIPIENT| macro.

@<Macros@>=
#define REQREC_INTERFACE           (1 << 0)

@ Request recipient mask, indicating that the request is to be issued to an endpoint in the
currently selected configuration.

See |CONTROL_REQTYPE_RECIPIENT| macro.

@<Macros@>=
#define REQREC_ENDPOINT            (2 << 0)

@ Request recipient mask, indicating that the request is to be issued to an unspecified element
in the currently selected configuration.

See |CONTROL_REQTYPE_RECIPIENT| macro.

@<Macros@>=
#define REQREC_OTHER               (3 << 0)

@*1 Standard USB Control Request.

Type define for a standard USB control request.

See The USB 2.0 specification for more information on standard control requests.

@s USB_Request_Header_t int

@<Type definitions@>=
typedef struct
{
  uint8_t  bmRequestType; /* type of the request */
  uint8_t  bRequest; /* request command code */
  uint16_t wValue; /* parameter of the request */
  uint16_t wIndex; /* parameter of the request (endpoint index; FIXME: why if
    it is |uint8_t| it does not work?) */
  uint16_t wLength; /* length of the data to transfer in bytes */
} @=PACKED@>
  USB_Request_Header_t;

@*1 Enumeration for the various standard request commands. These commands are applicable when the
request type is |REQTYPE_STANDARD| (with the exception of |REQ_GET_DESCRIPTOR|, which is
always handled regardless of the request type value).

See Chapter 9 of the USB 2.0 Specification.

@ @<Macros@>=
#define REQ_GET_STATUS 0
#define REQ_CLEAR_FEATURE 1
#define REQ_SET_FEATURE 3
#define REQ_SET_ADDRESS 5
#define REQ_GET_DESCRIPTOR 6
#define REQ_SET_DESCRIPTOR 7
#define REQ_GET_CONFIGURATION 8
#define REQ_SET_CONFIGURATION 9
#define REQ_GET_NITERFACE 10
#define REQ_SET_INTERFACE 11
#define REQ_SYNCH_FRAME 12

@*1 Feature Selector values.
Feature Selector values for Set Feature and Clear Feature standard control requests
directed to the device, interface and endpoint recipients.

@ Feature selector for Clear Feature or Set Feature commands. When
used in a Set Feature or Clear Feature request this indicates that an
endpoint (whose address is given elsewhere in the request) should have
its stall condition changed.

@<Macros@>=
#define FEATURE_SEL_ENDPOINT_HALT 0x00

@* USB device standard request management.
This contains the function prototypes necessary for the processing of incoming standard
control requests.

@ Indicates the currently set configuration number of the device. USB devices may have several
different configurations which the host can select between; this indicates the currently
selected value, or 0 if no configuration has been selected.

@<Global var...@>=
uint8_t USB_Device_ConfigurationNumber;

@* Endpoint data stream.
Endpoint data stream transmission and reception management.

Functions, macros, variables, enums and types related to data reading and writing of
data streams from and to endpoints.

@ Possible error return codes of the \\{Endpoint\_*\_Control\_Stream\_*} functions.

@<Macros@>=
#define ENDPOINT_NO_ERROR 0 /* command completed successfully, no error */
#define ENDPOINT_HOST_ABORTED 1 /* aborted the transfer prematurely */
#define ENDPOINT_DEV_DISCONNECTED 2 /* device was disconnected from the host during
                                                   the transfer */
#define ENDPOINT_BUS_SUSPENDED 3 /* the USB bus has been suspended by the host and
		                             no USB endpoint traffic can occur until the bus
		                             has resumed */

@* USBTask.
Main USB service task management.

This contains the function definitions required for the main USB service task,
which must be called to ensure that the USB connection to a connected USB device
is maintained.

@ Structure containing the last received Control request.

@<Global variables@>=
USB_Request_Header_t USB_ControlRequest;

@ One of the most frequently used global variables in the stack is the |USB_DeviceState|
global, which indicates the current state of the Device State Machine. To reduce the
amount of code and time required to access and modify this global in an application,
|DEVICE_STATE_AS_GPIOR| may be defined to a value between 0 and 2 to fix the state
variable into one of the three general purpose IO registers inside the AVR reserved
for application use. So as it is defined, the corresponding |GPIOR| register should
not be used within the user application except implicitly via the library APIs.

@d DEVICE_STATE_AS_GPIOR 0

@<Macros@>=
#define CONCAT(x, y)            x ## y
#define CONCAT_EXPANDED(x, y)   CONCAT(x, y)
#define USB_DeviceState CONCAT_EXPANDED(GPIOR, DEVICE_STATE_AS_GPIOR) /* expands into
  |(*(volatile uint8_t *)((0x1E) + 0x20))| */

@* USB Event management.
This contains macros and functions relating to the management of library events, which
are small
pieces of code similar to ISRs which are run when a given condition is met. Each event
can be fired from
multiple places in the user or library code, which may or may not be inside an ISR, thus
each handler
should be written to be as small and fast as possible to prevent possible problems.

Events can be hooked by the user application by declaring a handler function with the
same name and parameters
listed here. If an event with no user-associated handler is fired within the library,
it by default maps to an
internal empty stub function.

Each event must only have one associated event handler, but can be raised by multiple
sources by calling the
event handler function (with any required event parameters).

@* StdDescriptors.
Common standard USB Descriptor definitions.
Standard USB device descriptor defines and retrieval routines. This contains
structures and macros for the easy creation of standard USB descriptors.

@ Indicates that a given descriptor does not exist in the device. This can be used inside
descriptors for string descriptor indexes, or may be use as a return value for
|CALLBACK_USB_GetDescriptor| when
the specified descriptor does not exist.

@<Macros@>=
#define NO_DESCRIPTOR 0

@ Macro to calculate the power value for the configuration descriptor, from a given number
of milliamperes.
Parameter is maximum number of milliamps the device consumes when the given
configuration is selected.

@<Macros@>=
#define USB_CONFIG_POWER_MA(mA) ((mA) >> 1)

@ Macro to calculate the Unicode length of a string with a given number of Unicode characters.
Should be used in string descriptor's headers for giving the string descriptor's byte length.

Parameter is number of Unicode characters in the string text.

@<Macros@>=
#define USB_STRING_LEN(UnicodeChars) (sizeof (USB_Descriptor_Header_t) + ((UnicodeChars) << 1))

@ Convenience macro to easily create |USB_Descriptor_String_t| instances from a wide
character string.

Parameter is string to initialize a USB String Descriptor structure with.

@<Macros@>=
#define USB_STRING_DESCRIPTOR(String) { \
  { \
    sizeof (USB_Descriptor_Header_t) + ( sizeof (String) - 2 ), \
    DTYPE_STRING \
  }, \
  String \
}

@ Macro to encode a given major/minor/revision version number into Binary Coded Decimal
format for descriptor
fields requiring BCD encoding, such as the USB version number in the standard device
descriptor.

Note, that this value is automatically converted into Little Endian, suitable for direct use
inside device descriptors without endianness conversion macros.

Parameters are: major version number to encode, minor version number to encode,
revision version number to encode.

@<Macros@>=
#define VERSION_BCD(Major, Minor, Revision) \
                                          ((Major & 0xFF) << 8) | \
                                                       ((Minor & 0x0F) << 4) | \
                                                       (Revision & 0x0F)

@*1 USB Configuration Descriptor Attribute Masks.

@ Mask for the reserved bit in the Configuration Descriptor's |ConfigAttributes| field,
which must be set on all devices for historical purposes.

@<Macros@>=
#define USB_CONFIG_ATTR_RESERVED          0x80

@ Can be masked with other configuration descriptor attributes for a
\hfil\break |USB_Descriptor_Config_Header_t|
descriptor's |ConfigAttributes| value to indicate that the specified configuration
can draw its power from the device's own power source.

@<Macros@>=
#define USB_CONFIG_ATTR_SELFPOWERED 0x40

@*1 Endpoint Descriptor Attribute Masks.

@ Can be masked with other endpoint descriptor attributes for a
|USB_Descriptor_Endpoint_t| descriptor's
|Attributes| value to indicate that the specified endpoint is not synchronized.

See the USB specification for more details on the possible Endpoint attributes.

@<Macros@>=
#define ENDPOINT_ATTR_NO_SYNC (0 << 2)

@*1 Endpoint Descriptor Usage Masks.

@ Can be masked with other endpoint descriptor attributes for a
|USB_Descriptor_Endpoint_t| descriptor's
|Attributes| value to indicate that the specified endpoint is used for data transfers.

See the USB specification for more details on the possible Endpoint usage attributes.

@<Macros@>=
#define ENDPOINT_USAGE_DATA               (0 << 4)

@ Enum for the possible standard descriptor types, as given in each descriptor's header.

@<Macros@>=
#define DTYPE_DEVICE 0x01 /* device descriptor */
#define DTYPE_CONFIGURATION 0x02 /* configuration descriptor */
#define DTYPE_STRING 0x03 /* string descriptor */
#define DTYPE_INTERFACE 0x04 /* interface descriptor */
#define DTYPE_ENDPOINT 0x05 /* endpoint descriptor */
#define DTYPE_CS_INTERFACE 0x24 /* class specific interface descriptor */

@ Standard USB Descriptor Header (LUFA naming conventions).

Type define for all descriptors' standard header, indicating the descriptor's length
and type. This structure
uses LUFA-specific element names to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Header\_t} for the version of this type with standard element names.

@s USB_Descriptor_Header_t int

@<Type definitions@>=
typedef struct
{
  uint8_t Size; /* size of the descriptor, in bytes */
  uint8_t Type; /* type of the descriptor, either a value in \.{DTYPE\_*} or
    a value given by the specific class */
} @=PACKED@>
  USB_Descriptor_Header_t;

@ Standard USB Descriptor Header (USB-IF naming conventions).

Type define for all descriptors' standard header, indicating the descriptor's length and
type. This structure
uses the relevant standard's given element names to ensure compatibility with the standard.

See |USB_Descriptor_Header_t| for the version of this type with non-standard LUFA
specific element names.

@s USB_StdDescriptor_Header_t int

@(/dev/null@>=
typedef struct
{
  uint8_t bLength; /* size of the descriptor, in bytes */
  uint8_t bDescriptorType; /* type of the descriptor, either a value in
  \.{DTYPE\_*} or a value given by the specific class */
} @=PACKED@>
  USB_StdDescriptor_Header_t;

@ Standard USB Device Descriptor (LUFA naming conventions).

Type define for a standard Device Descriptor. This structure uses LUFA-specific
element names to make each
element's purpose clearer.

See \&{USB\_StdDescriptor\_Device\_t} for the version of this type with standard element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Device_t int

@<Type definitions@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* descriptor header, including type and size */

  uint16_t USBSpecification; /* BCD of the supported USB specification;
    see |VERSION_BCD| utility macro */
  uint8_t  Class; /* USB device class */
  uint8_t  SubClass; /* USB device subclass */
  uint8_t  Protocol; /* USB device protocol */

  uint8_t  Endpoint0Size; /* size of the control (address 0) endpoint's bank in bytes */

  uint16_t VendorID; /* vendor ID for the USB product */
  uint16_t ProductID; /* unique product ID for the USB product */
  uint16_t ReleaseNumber; /* product release (version) number;
    see |VERSION_BCD| utility macro */
  uint8_t  ManufacturerStrIndex; /* string index for the manufacturer's name; the
	host will request this string via a separate
        control request for the string descriptor;
	if no string supplied, use |NO_DESCRIPTOR| */
  uint8_t  ProductStrIndex; /* string index for the product name/details;
	                       see |ManufacturerStrIndex| structure entry */
  uint8_t  SerialNumStrIndex; /* string index for the product's globally unique hexadecimal
	                         serial number, in uppercase Unicode ASCII;
    on some microcontroller models, there is an embedded serial number
    in the chip which can be used for the device serial number;
    to use this serial number, set this to |USE_INTERNAL_SERIAL|;
    on unsupported devices, this will evaluate to |NO_DESCRIPTOR|
    and will cause the host to generate a pseudo-unique value for the
    device upon insertion; see |ManufacturerStrIndex| structure entry */
  uint8_t  NumberOfConfigurations; /* total number of configurations supported by
	                              the device */
} @=PACKED@>
  USB_Descriptor_Device_t;

@ Standard USB Device Descriptor (USB-IF naming conventions).

Type define for a standard Device Descriptor. This structure uses the relevant
standard's given element names
to ensure compatibility with the standard.

See |USB_Descriptor_Device_t| for the version of this type with non-standard
LUFA specific element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_StdDescriptor_Device_t int

@(/dev/null@>=
typedef struct {
  uint8_t  bLength; /* size of the descriptor, in bytes */
  uint8_t  bDescriptorType; /* type of the descriptor, either a value in
          \.{DTYPE\_*} or a value given by the specific class */
  uint16_t bcdUSB; /* BCD of the supported USB specification;
    see |VERSION_BCD| utility macro */
  uint8_t  bDeviceClass; /* USB device class */
  uint8_t  bDeviceSubClass; /* USB device subclass */
  uint8_t  bDeviceProtocol; /* USB device protocol */
  uint8_t  bMaxPacketSize0; /* size of the control (address 0) endpoint's bank in bytes */
  uint16_t idVendor; /* vendor ID for the USB product */
  uint16_t idProduct; /* unique product ID for the USB product */
  uint16_t bcdDevice; /* product release (version) number;
    see |VERSION_BCD| utility macro */
  uint8_t  iManufacturer; /* string index for the manufacturer's name; the
	host will request this string via a separate
	control request for the string descriptor;
	if no string supplied, use |NO_DESCRIPTOR| */
  uint8_t  iProduct; /* string index for the product name/details;
    see |ManufacturerStrIndex| structure entry */
  uint8_t iSerialNumber; /* string index for the product's globally unique hexadecimal
	                    serial number, in uppercase Unicode ASCII;
    on some microcontroller models, there is an embedded serial number
    in the chip which can be used for the device serial number;
    to use this serial number, set this to |USE_INTERNAL_SERIAL|;
    on unsupported devices, this will evaluate to |NO_DESCRIPTOR|
    and will cause the host to generate a pseudo-unique value for the
    device upon insertion; see |ManufacturerStrIndex| structure entry */
  uint8_t  bNumConfigurations; /* total number of configurations supported by
	                          the device */
} @=PACKED@>
  USB_StdDescriptor_Device_t;

@ Standard USB Device Qualifier Descriptor (LUFA naming conventions).

Type define for a standard Device Qualifier Descriptor. This structure uses LUFA-specific
element names to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_DeviceQualifier\_t} for the version of this type with standard
element names.

@s USB_Descriptor_DeviceQualifier_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Header_t Header; /* descriptor header, including type and size */

	uint16_t USBSpecification; /* BCD of the supported USB specification;
          see |VERSION_BCD| utility macro */
	uint8_t  Class; /* USB device class */
	uint8_t  SubClass; /* USB device subclass */
	uint8_t  Protocol; /* USB device protocol */

	uint8_t  Endpoint0Size; /* size of the control (address 0) endpoint's bank in bytes */
	uint8_t  NumberOfConfigurations; /* total number of configurations supported by
	                                     the device.
                                */
	uint8_t  Reserved; /* reserved for future use, must be 0 */
} @=PACKED@>
  USB_Descriptor_DeviceQualifier_t;

@ Standard USB Device Qualifier Descriptor (USB-IF naming conventions).

Type define for a standard Device Qualifier Descriptor. This structure uses the relevant
standard's given element names
to ensure compatibility with the standard.

See |USB_Descriptor_DeviceQualifier_t| for the version of this type with
non-standard LUFA specific element names.

@s USB_StdDescriptor_DeviceQualifier_t int

@(/dev/null@>=
typedef struct {
	uint8_t  bLength; /* size of the descriptor, in bytes */
  uint8_t  bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
	uint16_t bcdUSB; /* BCD of the supported USB specification;
          see |VERSION_BCD| utility macro */
	uint8_t  bDeviceClass; /* USB device class */
	uint8_t  bDeviceSubClass; /* USB device subclass */
	uint8_t  bDeviceProtocol; /* USB device protocol */
	uint8_t  bMaxPacketSize0; /* size of the control (address 0) endpoint's bank in bytes */
	uint8_t  bNumConfigurations; /* total number of configurations supported by
	                              *   the device.
	                              */
	uint8_t  bReserved; /* reserved for future use, must be 0 */
} @=PACKED@>
  USB_StdDescriptor_DeviceQualifier_t;

@ Standard USB Configuration Descriptor (LUFA naming conventions).

Type define for a standard Configuration Descriptor header. This structure uses
LUFA-specific element names
to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Config\_Header\_t} for the version of this type with standard
element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Config_Header_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Header_t Header; /* descriptor header, including type and size */

	uint16_t TotalConfigurationSize; /* size of the configuration descriptor header,
	                                     and all sub descriptors inside the configuration.
	                                  */
	uint8_t  TotalInterfaces; /* total number of interfaces in the configuration */

	uint8_t  ConfigurationNumber; /* configuration index of the current configuration */
  uint8_t  ConfigurationStrIndex; /* Index of a string descriptor describing the configuration */

	uint8_t  ConfigAttributes; /* configuration attributes, comprised of a mask of
  \.{USB\_CONFIG\_ATTR\_*} masks; on all devices, this should include
  |USB_CONFIG_ATTR_RESERVED| at a minimum */

	uint8_t  MaxPowerConsumption; /* maximum power consumption of the device while in the
	                                  current configuration, calculated by the
  |USB_CONFIG_POWER_MA|
	                                  macro */
} @=PACKED@>
  USB_Descriptor_Config_Header_t;

@ Standard USB Configuration Descriptor (USB-IF naming conventions).

Type define for a standard Configuration Descriptor header. This structure uses the
relevant standard's given element names
to ensure compatibility with the standard.

See |USB_Descriptor_Device_t| for the version of this type with non-standard LUFA
specific element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_StdDescriptor_Config_Header_t int

@(/dev/null@>=
typedef struct
{
	uint8_t  bLength; /* size of the descriptor, in bytes */
  uint8_t  bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
	uint16_t wTotalLength; /* size of the configuration descriptor header,
                              and all sub descriptors inside the configuration.
                           */
	uint8_t  bNumInterfaces; /* total number of interfaces in the configuration */
	uint8_t  bConfigurationValue; /* configuration index of the current configuration */
	uint8_t  iConfiguration; /* index of a string descriptor describing the configuration */
	uint8_t  bmAttributes; /* configuration attributes, comprised of a mask of
  \.{USB\_CONFIG\_ATTR\_*} masks; on all devices, this should include
  |USB_CONFIG_ATTR_RESERVED| at a minimum */
	uint8_t  bMaxPower; /* maximum power consumption of the device while in the
	                     current configuration, calculated by the |USB_CONFIG_POWER_MA|
	                     macro */
} @=PACKED@>
  USB_StdDescriptor_Config_Header_t;

@ Standard USB Interface Descriptor (LUFA naming conventions).

Type define for a standard Interface Descriptor. This structure uses LUFA-specific element
names to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Interface\_t} for the version of this type with standard element
names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Interface_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Header_t Header; /* descriptor header, including type and size */

	uint8_t InterfaceNumber; /* index of the interface in the current configuration */
	uint8_t AlternateSetting; /* alternate setting for the interface number. The same
	                              interface number can have multiple alternate settings
	                              with different endpoint configurations, which can be
	                              selected by the host.
	                           */
	uint8_t TotalEndpoints; /* total number of endpoints in the interface */

	uint8_t Class; /* interface class ID */
	uint8_t SubClass; /* interface subclass ID */
	uint8_t Protocol; /* interface protocol ID */

	uint8_t InterfaceStrIndex; /* index of the string descriptor describing the interface */
} @=PACKED@>
  USB_Descriptor_Interface_t;

@ Standard USB Interface Descriptor (USB-IF naming conventions).

Type define for a standard Interface Descriptor. This structure uses the relevant
standard's given element names
to ensure compatibility with the standard.

See |USB_Descriptor_Interface_t| for the version of this type with non-standard LUFA
specific element names.

@s USB_StdDescriptor_Interface_t int

@(/dev/null@>=
typedef struct {
  uint8_t bLength; /* size of the descriptor, in bytes */
  uint8_t bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
	uint8_t bInterfaceNumber; /* index of the interface in the current configuration */
	uint8_t bAlternateSetting; /* alternate setting for the interface number. The same
	                               interface number can have multiple alternate settings
	                               with different endpoint configurations, which can be
	                               selected by the host.
	                            */
	uint8_t bNumEndpoints; /* total number of endpoints in the interface */
	uint8_t bInterfaceClass; /* interface class ID */
	uint8_t bInterfaceSubClass; /* interface subclass ID */
	uint8_t bInterfaceProtocol; /* interface protocol ID */
	uint8_t iInterface; /* index of the string descriptor describing the
	                        interface.
	                     */
} @=PACKED@>
  USB_StdDescriptor_Interface_t;

@ Standard USB Endpoint Descriptor (LUFA naming conventions).

Type define for a standard Endpoint Descriptor. This structure uses LUFA-specific element names
to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Endpoint\_t} for the version of this type with standard element
names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Endpoint_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Header_t Header; /* descriptor header, including type and size */

  uint8_t  EndpointAddress; /* logical address of the endpoint within the device for
    the current configuration, including direction mask.
	                           */
  uint8_t  Attributes; /* endpoint attributes, comprised of a mask of the endpoint
    type (\.{EP\_TYPE\_*}) and attributes (\.{ENDPOINT\_ATTR\_*}) masks */
  uint16_t EndpointSize; /* size of the endpoint bank, in bytes. This indicates the
    maximum packet size that the endpoint can receive at a time */
  uint8_t  PollingIntervalMS; /* polling interval in milliseconds for the endpoint
    if it is an INTERRUPT or ISOCHRONOUS type */
} @=PACKED@>
  USB_Descriptor_Endpoint_t;

@ Standard USB Endpoint Descriptor (USB-IF naming conventions).

Type define for a standard Endpoint Descriptor. This structure uses the relevant
standard's given
element names to ensure compatibility with the standard.

See |USB_Descriptor_Endpoint_t| for the version of this type with non-standard LUFA
specific element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_StdDescriptor_Endpoint_t int

@(/dev/null@>=
typedef struct {
  uint8_t  bLength; /* size of the descriptor, in bytes */
  uint8_t  bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
  uint8_t  bEndpointAddress; /* logical address of the endpoint within the
    device for the current configuration, including direction mask */
  uint8_t  bmAttributes; /* endpoint attributes, comprised of a mask of the
    endpoint type (\.{EP\_TYPE\_*}) and attributes (\.{ENDPOINT\_ATTR\_*}) masks */
  uint16_t wMaxPacketSize; /* size of the endpoint bank, in bytes. This indicates
    the maximum packet size that the endpoint can receive at a time */
  uint8_t  bInterval; /* polling interval in milliseconds for the endpoint if it is
    an INTERRUPT or ISOCHRONOUS type */
} @=PACKED@>
  USB_StdDescriptor_Endpoint_t;

@ Standard USB String Descriptor (LUFA naming conventions).

Type define for a standard string descriptor. Unlike other standard descriptors, the length
of the descriptor for placement in the descriptor header must be determined by the
|USB_STRING_LEN|
macro rather than by the size of the descriptor structure, as the length is not fixed.

This structure should also be used for string index 0, which contains the supported
language IDs for
the device as an array.

This structure uses LUFA-specific element names to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_String\_t} for the version of this type with standard element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_String_t int

@<Type definitions@>=
typedef struct
{
	USB_Descriptor_Header_t Header; /* descriptor header, including type and size */

	wchar_t  UnicodeString[];
} @=PACKED@>
  USB_Descriptor_String_t;

@ Standard USB String Descriptor (USB-IF naming conventions).

Type define for a standard string descriptor. Unlike other standard descriptors, the length
of the descriptor for placement in the descriptor header must be determined by the
|USB_STRING_LEN|
macro rather than by the size of the descriptor structure, as the length is not fixed.

This structure should also be used for string index 0, which contains the supported
language IDs for
the device as an array.

This structure uses the relevant standard's given element names to ensure compatibility
with the standard.

See |USB_Descriptor_String_t| for the version of this type with with non-standard
LUFA specific element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_StdDescriptor_String_t int

@(/dev/null@>=
typedef struct {
  uint8_t bLength; /* size of the descriptor, in bytes */
  uint8_t bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
  uint16_t bString[]; /* string data, as unicode characters (alternatively, string
    language IDs); if normal ASCII characters are to be used, they must be
    added as an array of characters rather than a normal C string so that they
    are widened to Unicode size; under GCC, strings prefixed with the "L" character
    are considered to be Unicode strings, and may be used instead
    of an explicit array of ASCII characters */
} @=PACKED@>
  USB_StdDescriptor_String_t;

@** CDC Class Driver module. This module contains an
implementation of the USB CDC-ACM class Virtual Serial Ports.

Note: the CDC class can instead be implemented manually via the low-level APIs.

@* CDCClassCommon.
Common definitions and declarations for the USB CDC Class driver.
Constants, Types and Enum definitions for the USB CDC Class.

@*1 Virtual Control Line Masks.

@ Mask for the DTR handshake line for use with the |CDC_REQ_SET_CONTROL_LINE_STATE|
class-specific request
from the host, to indicate that the DTR line state should be high.

@<Macros@>=
#define CDC_CONTROL_LINE_OUT_DTR         (1 << 0)

@ Mask for the RTS handshake line for use with the |CDC_REQ_SET_CONTROL_LINE_STATE|
class-specific request
from the host, to indicate that the RTS line state should be high.

@<Macros@>=
#define CDC_CONTROL_LINE_OUT_RTS         (1 << 1)

@ Mask for the DCD handshake line for use with the |CDC_NOTIF_SERIAL_STATE| class-specific
notification
from the device to the host, to indicate that the DCD line state is currently high.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_DCD          (1 << 0)

@ Mask for the DSR handshake line for use with the |CDC_NOTIF_SERIAL_STATE| class-specific
notification
from the device to the host, to indicate that the DSR line state is currently high.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_DSR          (1 << 1)

@ Mask for the BREAK handshake line for use with the |CDC_NOTIF_SERIAL_STATE| class-specific
notification
from the device to the host, to indicate that the BREAK line state is currently high.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_BREAK        (1 << 2)

@ Mask for the RING handshake line for use with the |CDC_NOTIF_SERIAL_STATE| class-specific
notification
from the device to the host, to indicate that the RING line state is currently high.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_RING         (1 << 3)

@ Mask for use with the |CDC_NOTIF_SERIAL_STATE| class-specific notification from the device
to the host, to indicate that a framing error has occurred on the virtual serial port.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_FRAMEERROR   (1 << 4)

@ Mask for use with the |CDC_NOTIF_SERIAL_STATE| class-specific notification from the device
to the host, to indicate that a parity error has occurred on the virtual serial port.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_PARITYERROR  (1 << 5)

@ Mask for use with the |CDC_NOTIF_SERIAL_STATE| class-specific notification from the device
to the host, to indicate that a data overrun error has occurred on the virtual serial port.

@<Macros@>=
#define CDC_CONTROL_LINE_IN_OVERRUNERROR (1 << 6)

@ Macro to define a CDC class-specific functional descriptor. CDC functional descriptors have a
uniform structure but variable sized data payloads, thus cannot be represented accurately by
a single \c typedef \c struct. A macro is used instead so that functional descriptors
can be created
easily by specifying the size of the payload. This allows \c sizeof() to work correctly.

|DataSize| -- size in bytes of the CDC functional descriptor's data payload.

@<Macros@>=
#define CDC_FUNCTIONAL_DESCRIPTOR(DataSize)        \
     struct {                                      \
          USB_Descriptor_Header_t Header;          \
	  uint8_t                 SubType;         \
          uint8_t                 Data[DataSize];  \
     }

@ Possible Class, Subclass and Protocol values of device and interface descriptors
relating to the CDC device class.

@<Macros@>=
#define CDC_CSCP_CDC_CLASS 0x02 /* device or interface belongs to the CDC class */
#define CDC_CSCP_NO_SPECIFIC_SUBCLASS 0x00 /* device or interface belongs to no specific
    subclass of the CDC class */
#define CDC_CSCP_ACM_SUBCLASS 0x02 /* device or interface belongs to the
    Abstract Control Model CDC subclass */
#define CDC_CSCP_AT_COMMAND_PROTOCOL 0x01 /* device
    or interface belongs to the AT Command protocol of the CDC class */
#define CDC_CSCP_NO_SPECIFIC_PROTOCOL 0x00 /* device
    or interface belongs to no specific protocol of the CDC class */
#define CDC_CSCP_CDC_DATA_CLASS 0x0A /* device or interface
			       belongs to the CDC Data class */
#define CDC_CSCP_NO_DATA_SUBCLASS 0x00 /* device or interface belongs to no specific subclass
  of the CDC data class */
#define CDC_CSCP_NO_DATA_PROTOCOL 0x00 /* device or interface
                                  belongs to no specific protocol of the CDC data class */

@ CDC class specific control requests that can be issued by the USB bus host.

@<Macros@>=
#define CDC_REQ_SET_LINE_ENCODING 0x20 /* set the current virtual serial port configuration
  settings */
#define CDC_REQ_GET_LINE_ENCODING 0x21 /* get the current virtual serial port configuration
  settings */
#define CDC_REQ_SET_CONTROL_LINE_STATE 0x22 /* set the current virtual serial port handshake
  line states */
#define CDC_REQ_SEND_BREAK 0x23 /* send a break to the receiver via the carrier channel */

@ {\emergencystretch=2cm
CDC class specific notification request that can be issued by a CDC device
to a host. Notification type constant for a change in the virtual
serial port handshake line states, for use with a |USB_Request_Header_t|
notification structure when sent to the host via the CDC notification endpoint.
\par}

FIXME: why it is not used anywhere? see git lg
@^FIXME@>

@<Macros@>=
#define CDC_NOTIF_SERIAL_STATE 0x20

@ CDC class specific interface descriptor subtypes.

@<Macros@>=
#define CDC_DSUBTYPE_CS_INTERFACE_HEADER 0x00 /* Header functional descriptor */
#define CDC_DSUBTYPE_CS_INTERFACE_ACM 0x02 /* Abstract Control Model functional descriptor */
#define CDC_DSUBTYPE_CS_INTERFACE_UNION 0x06 /* Union functional descriptor */

@ Possible line encoding formats of a virtual serial port.

@<Macros@>=
#define CDC_LINEENCODING_TWO_STOP_BITS 2 /* each frame contains two stop bits */

@ Possible line encoding parity settings of a virtual serial port.

@<Macros@>=
#define CDC_PARITY_EVEN 2 /* even parity bit mode on each frame */
#define CDC_PARITY_ODD 1 /* odd parity bit mode on each frame */

@ CDC class-specific Functional Header Descriptor (LUFA naming conventions).

Type define for a CDC class-specific functional header descriptor. This indicates to the
host that the device
contains one or more CDC functional data descriptors, which give the CDC interface's
capabilities and configuration.
See the CDC class specification for more details.

See \&{USB\_CDC\_StdDescriptor\_Functional\_Header\_t} for the version of this type with
standard element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_CDC_Descriptor_Func_Header_t int

@<Type definitions@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* regular descriptor header containing the descriptor's
    type and length */
  uint8_t Subtype; /* sub type value used to distinguish between CDC class-specific descriptors,
                      must be |CDC_DSUBTYPE_CS_INTERFACE_HEADER| */
  uint16_t CDCSpecification; /* version number of the CDC specification implemented by the
    device, encoded in BCD format; see |VERSION_BCD| utility macro */
} @=PACKED@>
  USB_CDC_Descriptor_Func_Header_t;

@ CDC class-specific Functional Header Descriptor (USB-IF naming conventions).

Type define for a CDC class-specific functional header descriptor. This indicates to the host
that the device
contains one or more CDC functional data descriptors, which give the CDC interface's
capabilities and configuration.
See the CDC class specification for more details.

See |USB_CDC_Descriptor_Func_Header_t| for the version of this type with non-standard
LUFA specific element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_CDC_StdDescriptor_Functional_Header_t int

@(/dev/null@>=
typedef struct {
  uint8_t  bFunctionLength; /* size of the descriptor, in bytes */
  uint8_t  bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
  uint8_t  bDescriptorSubType; /* sub type value used to distinguish between CDC
    class-specific descriptors, must be |CDC_DSUBTYPE_CS_INTERFACE_HEADER| */
  uint16_t bcdCDC; /* version number of the CDC specification implemented by the device,
    encoded in BCD format; see |VERSION_BCD| utility macro */
} @=PACKED@>
  USB_CDC_StdDescriptor_Functional_Header_t;

@ CDC class-specific Functional ACM Descriptor (LUFA naming conventions).

Type define for a CDC class-specific functional ACM descriptor. This indicates to the
host that the CDC interface
supports the CDC ACM subclass of the CDC specification. See the CDC class specification
for more details.

See \&{USB\_CDC\_StdDescriptor\_Functional\_ACM\_t} for the version of this type with
standard element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_CDC_Descriptor_Func_ACM_t int

@<Type definitions@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* regular descriptor header containing the descriptor's
    type and length */
  uint8_t Subtype; /* sub type value used to distinguish between CDC
    class-specific descriptors, must be |CDC_DSUBTYPE_CS_INTERFACE_ACM| */
  uint8_t Capabilities; /* capabilities of the ACM interface, given as a bit
    mask; for most devices, this should be set to a fixed value of |0x06| --- for
    other capabilities, refer to the CDC ACM specification */
} @=PACKED@>
  USB_CDC_Descriptor_Func_ACM_t;

@ CDC class-specific Functional ACM Descriptor (USB-IF naming conventions).

Type define for a CDC class-specific functional ACM descriptor. This indicates to the host
that the CDC interface
supports the CDC ACM subclass of the CDC specification. See the CDC class specification for
more details.

See |USB_CDC_Descriptor_Func_ACM_t| for the version of this type with non-standard
LUFA specific element names.

@s USB_CDC_StdDescriptor_Functional_ACM_t int

@(/dev/null@>=
typedef struct {
	uint8_t bFunctionLength; /* size of the descriptor, in bytes */
	uint8_t bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
	uint8_t bDescriptorSubType; /* sub type value used to distinguish between CDC
    class-specific descriptors, must be |CDC_DSUBTYPE_CS_INTERFACE_ACM| */
	uint8_t bmCapabilities; /* capabilities of the ACM interface, given as a bit mask;
    for most devices, this should be set to a fixed value of |0x06| --- for other
    capabilities, refer to the CDC ACM specification */
} @=PACKED@>
  USB_CDC_StdDescriptor_Functional_ACM_t;

@ CDC class-specific Functional Union Descriptor (LUFA naming conventions).

Type define for a CDC class-specific functional Union descriptor. This indicates to the
host that specific
CDC control and data interfaces are related. See the CDC class specification for more details.

See \&{USB\_CDC\_StdDescriptor\_Functional\_Union\_t} for the version of this type with
standard element names.

Regardless of CPU architecture, these values should be stored as little endian.

@s USB_CDC_Descriptor_Func_Union_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Header_t Header; /* regular descriptor header containing the
    descriptor's type and length */
	uint8_t Subtype; /* sub type value used to distinguish between CDC
    class-specific descriptors, must be |CDC_DSUBTYPE_CS_INTERFACE_UNION| */
	uint8_t MasterInterfaceNumber; /* interface number of the CDC
    Control interface */
	uint8_t SlaveInterfaceNumber; /* interface number of the CDC Data
    interface */
} @=PACKED@>
  USB_CDC_Descriptor_Func_Union_t;

@ CDC class-specific Functional Union Descriptor (USB-IF naming conventions).

Type define for a CDC class-specific functional Union descriptor. This indicates to the
host that specific
CDC control and data interfaces are related. See the CDC class specification for more details.

See |USB_CDC_Descriptor_Func_Union_t| for the version of this type with non-standard
LUFA specific element names.

@s USB_CDC_StdDescriptor_Functional_Union_t int

@(/dev/null@>=
typedef struct {
	uint8_t bFunctionLength; /* size of the descriptor, in bytes */
	uint8_t bDescriptorType; /* type of the descriptor, either a value in
    \.{DTYPE\_*} or a value given by the specific class */
	uint8_t bDescriptorSubType; /* sub type value used to distinguish between CDC
    class-specific descriptors, must be |CDC_DSUBTYPE_CS_INTERFACE_UNION| */
	uint8_t bMasterInterface; /* interface number of the CDC Control interface */
	uint8_t bSlaveInterface0; /* interface number of the CDC Data interface */
} @=PACKED@>
  USB_CDC_StdDescriptor_Functional_Union_t;

@ CDC Virtual Serial Port Line Encoding Settings Structure.

Type define for a CDC Line Encoding structure, used to hold the various encoding
parameters for a virtual serial port.

Regardless of CPU architecture, these values should be stored as little endian.

@s CDC_LineEncoding_t int

@<Type definitions@>=
typedef struct {
  uint32_t BaudRateBPS; /* baud rate of the virtual serial port, in bits per second */
  uint8_t  CharFormat; /* character format of the virtual serial port, a
    \.{CDC\_LINEENCODING\_*} value */
  uint8_t  ParityType; /* parity setting of the virtual serial port, a
    \.{CDC\_PARITY\_*} value */
  uint8_t  DataBits; /* bits of data per character of the virtual serial port */
} @=PACKED@>
  CDC_LineEncoding_t;

@* CDC Class driver.

There are several major drawbacks to the CDC-ACM standard USB class, however
it is very standardized and thus usually available as a built-in driver on
most platforms, and so is a better choice than a proprietary serial class.

One major issue with CDC-ACM is that it requires two Interface descriptors,
which will upset most hosts when part of a multi-function "Composite" USB
device. This is because each interface will be loaded into a separate driver
instance, causing the two interfaces be become unlinked. To prevent this, you
should use the "Interface Association Descriptor" addendum to the USB 2.0 standard
which is available on most OSes when creating Composite devices.

Another major oversight is that there is no mechanism for the host to notify the
device that there is a data sink on the host side ready to accept data. This
means that the device may try to send data while the host isn't listening, causing
lengthy blocking timeouts in the transmission routines. It is thus highly recommended
that the virtual serial line DTR (Data Terminal Ready) signal be used where possible
to determine if a host application is ready for data.

http://www.recursion.jp/prose/avrcdc/

@ CDC Class Device Mode Configuration and State Structure.

Class state structure. An instance of this structure should be made for each CDC interface
within the user application, and passed to each of the CDC class driver functions as the
CDCInterfaceInfo parameter. This stores each CDC interface's configuration and state
information.

@s USB_ClassInfo_CDC_Device_t int

@<Type definitions@>=
typedef struct {
  struct
  {
    uint8_t ControlInterfaceNumber; /* interface number of the CDC control interface within
      the device */

    USB_Endpoint_Table_t DataINEndpoint; /* data IN endpoint configuration table */
    USB_Endpoint_Table_t DataOUTEndpoint; /* data OUT endpoint configuration table */
    USB_Endpoint_Table_t NotificationEndpoint; /* notification IN Endpoint configuration
      table */
  } Config; /* config data for the USB class interface within the device. All elements in
    this section must be set or the interface will fail to enumerate and operate correctly */
  struct {
    struct {
      uint16_t HostToDevice; /* control line states from the host to device, as a set of
        \.{CDC\_CONTROL\_LINE\_OUT\_*} masks. This value is updated each time
        |CDC_Device_USBTask| is called */
      uint16_t DeviceToHost; /* control line states from the device to host, as a set of
        \.{CDC\_CONTROL\_LINE\_IN\_*} masks */
  } ControlLineStates; /* current states of the virtual serial port's control lines between
    the device and host */

  CDC_LineEncoding_t LineEncoding; /* line encoding used in the virtual serial port, for the
    device's information; this is generally only used if the virtual serial port data is to be
    reconstructed on a physical UART */
  } State; /* state data for the USB class interface within the device. All elements in this
    section are reset to their defaults when the interface is enumerated */
} USB_ClassInfo_CDC_Device_t;

@** USB Device Descriptors. Used in USB device mode. Descriptors are special
computer-readable structures which the host requests upon device enumeration, to determine
the device's capabilities and functions.

@ Device descriptor structure. This descriptor, located in FLASH memory, describes the
overall
device characteristics, including the supported USB version, control endpoint size and the
number of device configurations.
The descriptor is read out by the USB host when the enumeration
process begins.

@<Global...@>=
const USB_Descriptor_Device_t
@=PROGMEM@>@,@,
DeviceDescriptor = {@|
  @<Initialize header of USB device descriptor@>, @|
  VERSION_BCD(1,1,0), @|
  CDC_CSCP_CDC_CLASS, @|
  CDC_CSCP_NO_SPECIFIC_SUBCLASS, @|
  CDC_CSCP_NO_SPECIFIC_PROTOCOL, @|
  FIXED_CONTROL_ENDPOINT_SIZE, @|
  0x03EB, @|
  0x204B, @|
  VERSION_BCD(0,0,1), @|
  STRING_ID_MANUFACTURER, @|
  STRING_ID_PRODUCT, @|
  USE_INTERNAL_SERIAL, @|
  FIXED_NUM_CONFIGURATIONS @/
};

@ @<Initialize header of USB device descriptor@>=
{@, sizeof (USB_Descriptor_Device_t), DTYPE_DEVICE @,}

@ Configuration descriptor structure. This descriptor, located in FLASH memory, describes
the usage
of the device in one of its supported configurations, including information about any
device interfaces
and endpoints.
The descriptor is read out by the USB host during the enumeration process when selecting
a configuration so that the host may correctly communicate with the USB device.

@d CDC_NOTIFICATION_EPADDR (ENDPOINT_DIR_IN | 2) /* endpoint address of the CDC
  device-to-host notification IN endpoint */
@d CDC_TX_EPADDR (ENDPOINT_DIR_IN | 3) /* endpoint address of the CDC device-to-host
  data IN endpoint */
@d CDC_RX_EPADDR 4 /* endpoint address of the CDC host-to-device
  data OUT endpoint */
@d CDC_NOTIFICATION_EPSIZE 8 /* size in bytes of the CDC device-to-host notification IN
  endpoint */
@d CDC_TXRX_EPSIZE 16 /* size in bytes of the CDC data IN and OUT endpoints */

@<Global...@>=
const USB_Descriptor_Config_t
@=PROGMEM@>@,@,
ConfigurationDescriptor = {@|
  @<Initialize header of standard Configuration Descriptor@>,@|
  @<Initialize CDC Command Interface@>,@|
  @<Initialize CDC Data Interface@>@/
};

@ @<Initialize CDC Command Interface@>=
@<Initialize |CDC_CCI_Interface|@>,@/
@<Initialize |CDC_Functional_Header|@>,@/
@<Initialize |CDC_Functional_ACM|@>,@/
@<Initialize |CDC_Functional_Union|@>,@/
@<Initialize |CDC_Notification_Endpoint|@>

@ @<Initialize CDC Data Interface@>=
@<Initialize |CDC_DCI_Interface|@>,@/
@<Initialize |CDC_DataOut_Endpoint|@>,@/
@<Initialize |CDC_DataIn_Endpoint|@>

@ Type define for the device configuration descriptor structure. This must be defined in
the
application code, as the configuration descriptor contains several sub-descriptors which
vary between devices, and which describe the device's usage to the host.

@s USB_Descriptor_Config_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Config_Header_t Config; @+@t}\6{@>
	@<CDC Command Interface@>@;
	@<CDC Data Interface@>@;
} USB_Descriptor_Config_t;

@ @<CDC Command Interface@>=
        USB_Descriptor_Interface_t               CDC_CCI_Interface;
        USB_CDC_Descriptor_Func_Header_t    CDC_Functional_Header;
        USB_CDC_Descriptor_Func_ACM_t       CDC_Functional_ACM;
        USB_CDC_Descriptor_Func_Union_t     CDC_Functional_Union;
        USB_Descriptor_Endpoint_t                CDC_NotificationEndpoint;

@ @<CDC Data Interface@>=
        USB_Descriptor_Interface_t               CDC_DCI_Interface;
        USB_Descriptor_Endpoint_t                CDC_DataOut_Endpoint;
        USB_Descriptor_Endpoint_t                CDC_DataIn_Endpoint;

@ @<Initialize header of standard Configuration Descriptor@>= {@|
  {@, sizeof (USB_Descriptor_Config_Header_t), DTYPE_CONFIGURATION @,}, @|
  sizeof (USB_Descriptor_Config_t),@|
  2,@|
  1,@|
  NO_DESCRIPTOR,@|
  (USB_CONFIG_ATTR_RESERVED | USB_CONFIG_ATTR_SELFPOWERED),@|
  USB_CONFIG_POWER_MA(100)@/
}

@ @<Initialize |CDC_CCI_Interface|@>= {@|
  {@, sizeof (USB_Descriptor_Interface_t), DTYPE_INTERFACE @,},@|
  INTERFACE_ID_CDC_CCI,@|
  0,@|
  1,@|
  CDC_CSCP_CDC_CLASS,@|
  CDC_CSCP_ACM_SUBCLASS,@|
  CDC_CSCP_AT_COMMAND_PROTOCOL,@|
  NO_DESCRIPTOR @/
}

@ @<Initialize |CDC_Functional_Header|@>= {@|
  {@, sizeof (USB_CDC_Descriptor_Func_Header_t), DTYPE_CS_INTERFACE @,},@|
  CDC_DSUBTYPE_CS_INTERFACE_HEADER,@|
  VERSION_BCD(1,1,0) @/
}

@ @<Initialize |CDC_Functional_ACM|@>= {@|
  {@, sizeof (USB_CDC_Descriptor_Func_ACM_t), DTYPE_CS_INTERFACE @,},@|
  CDC_DSUBTYPE_CS_INTERFACE_ACM,@|
  0x06 @/
}

@ @d INTERFACE_ID_CDC_CCI 0 /* CDC CCI interface descriptor ID */
@d INTERFACE_ID_CDC_DCI 1 /* CDC DCI interface descriptor ID */

@<Initialize |CDC_Functional_Union|@>= {@|
  {@, sizeof (USB_CDC_Descriptor_Func_Union_t), DTYPE_CS_INTERFACE @,},@|
  CDC_DSUBTYPE_CS_INTERFACE_UNION,@|
  INTERFACE_ID_CDC_CCI,@|
  INTERFACE_ID_CDC_DCI @/
}

@ @<Initialize |CDC_Notification_Endpoint|@>= {@|
  {@, sizeof (USB_Descriptor_Endpoint_t), DTYPE_ENDPOINT @,},@|
  CDC_NOTIFICATION_EPADDR,@|
  (EP_TYPE_INTERRUPT | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_NOTIFICATION_EPSIZE,@|
  0xFF @/
}

@ @<Initialize |CDC_DCI_Interface|@>= {@|
  {@, sizeof (USB_Descriptor_Interface_t), DTYPE_INTERFACE @,},@|
  INTERFACE_ID_CDC_DCI,@|
  0,@|
  2,@|
  CDC_CSCP_CDC_DATA_CLASS,@|
  CDC_CSCP_NO_DATA_SUBCLASS,@|
  CDC_CSCP_NO_DATA_PROTOCOL,@|
  NO_DESCRIPTOR @/
}

@ @<Initialize |CDC_DataOut_Endpoint|@>= {@|
  {@, sizeof (USB_Descriptor_Endpoint_t), DTYPE_ENDPOINT @,},@|
  CDC_RX_EPADDR,@|
  (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_TXRX_EPSIZE,@|
  0x05 @/
}

@ @<Initialize |CDC_DataIn_Endpoint|@>= {@|
  {@, sizeof (USB_Descriptor_Endpoint_t), DTYPE_ENDPOINT @,},@|
  CDC_TX_EPADDR,@|
  (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_TXRX_EPSIZE,@|
  0x05 @/
}

@ Language descriptor structure. This descriptor, located in FLASH memory, is returned
when the host requests
the string descriptor with index 0 (the first index). It is actually an array of 16-bit
integers, which indicate
via the language ID table available at USB.org what languages the device supports for its
string descriptors.

String language ID for the English language is used
to indicate that the English language is supported by the device in its string descriptors.

@d LANGUAGE_ID_ENG 0x0409

@<Global...@>=
const USB_Descriptor_String_t
@=PROGMEM@>@,@,
LanguageString = {
  {
    sizeof (USB_Descriptor_Header_t) + sizeof ((uint16_t){LANGUAGE_ID_ENG}),
    DTYPE_STRING
  },
  {LANGUAGE_ID_ENG}
};

@ Manufacturer descriptor string. This is a Unicode string containing the manufacturer's
details in human readable
form, and is read out upon request by the host when the appropriate string ID is
requested, listed in the Device
Descriptor.

@<Global...@>=
const USB_Descriptor_String_t
@=PROGMEM@>@,@,
ManufacturerString = USB_STRING_DESCRIPTOR(L"Dean Camera");

@ Product descriptor string. This is a Unicode string containing the product's details
in human readable form,
and is read out upon request by the host when the appropriate string ID is requested,
listed in the Device
Descriptor.

@<Global...@>=
const USB_Descriptor_String_t
@=PROGMEM@>@,@,
ProductString = USB_STRING_DESCRIPTOR(L"LUFA USB-RS232 Adapter");

@** RingBuffer.
Lightweight ring (circular) buffer, for fast insertion/deletion of bytes.

Lightweight ring buffer, for fast insertion/deletion. Multiple buffers can be created of
different sizes to suit different needs.

Note that for each buffer, insertion and removal operations may occur at the same time (via
a multi-threaded ISR based system) however the same kind of operation (two or more insertions
or deletions) must not overlap. If there is possibility of two or more of the same kind of
operating occurring at the same point in time, atomic (mutex) locking should be used.

@* Generic Byte Ring Buffer.

TODO: put here info from
{\tt\catcode`_11 https://en.wikipedia.org/wiki/Circular_buffer}
@^TODO@>

TODO: see ring buffer in arduino-usbserial on my github - there another version is used
@^TODO@>

Lightweight ring buffer, for fast insertion/deletion of bytes.
Multiple buffers can be created of
different sizes to suit different needs.

Note that for each buffer, insertion and removal operations may occur at the same time (via
a multi-threaded ISR based system) however the same kind of operation (two or more insertions
or deletions) must not overlap. If there is possibility of two or more of the same kind of
operating occurring at the same point in time, atomic (mutex) locking should be used.

@ The following snippet is an example of how this module may be used within a typical
application.

@s RingBuffer_t int

@(/dev/null@>=
RingBuffer_t Buffer; /* create the buffer structure and its underlying storage array */
uint8_t BufferData[128];

RingBuffer_InitBuffer(&Buffer, BufferData, sizeof(BufferData)); /* initialize the buffer
  with the created storage array */

RingBuffer_Insert(&Buffer, 'H');
RingBuffer_Insert(&Buffer, 'E');
RingBuffer_Insert(&Buffer, 'L');
RingBuffer_Insert(&Buffer, 'L');
RingBuffer_Insert(&Buffer, 'O');

uint16_t BufferCount = RingBuffer_GetCount(&Buffer); /* cache the number of stored bytes
  in the buffer */

printf("Buffer Length: %d, Buffer Data: \r\n", BufferCount); /* printer stored data length */

while (BufferCount--) /* print contents of the buffer one character at a time */
  putc(RingBuffer_Remove(&Buffer));

@ Ring Buffer Management Structure.

Type define for a new ring buffer object. Buffers should be initialized via a call to
|RingBuffer_InitBuffer| before use.

@s RingBuffer_t int

@<Type definitions@>=
typedef struct {
	uint8_t* In; /* current storage location in the circular buffer */
	uint8_t* Out; /* current retrieval location in the circular buffer */
	uint8_t* Start; /* pointer to the start of the buffer's underlying storage array */
	uint8_t* End; /* pointer to the end of the buffer's underlying storage array */
	uint16_t Size; /* size of the buffer's underlying storage array */
	uint16_t Count; /* number of bytes currently stored in the buffer */
} RingBuffer_t;

@ Forces GCC to use pointer indirection (via the device's pointer register pairs) when
accessing the given
struct pointer. In some cases GCC will emit non-optimal assembly code when accessing
a structure through
a pointer, resulting in a larger binary. When this macro is used on a (non |const|)
structure pointer before
use, it will force GCC to use pointer indirection on the elements rather than direct
store and load instructions.

|StructPtr| is pointer to a structure which is to be forced into indirect
access mode.

@<Macros@>=
#define GCC_FORCE_POINTER_ACCESS(StructPtr) \
  __asm__ __volatile__("" : "=b" (StructPtr) : "0" (StructPtr))

@ Initializes a ring buffer ready for use. Buffers must be initialized via this function
before any operations are called upon them. Already initialized buffers may be reset
by re-initializing them using this function.

|Buffer| is a pointer to a ring buffer structure to initialize. \par
|DataPtr| is a pointer to a global array that will hold the data stored into the ring buffer. \par
|Size| is a maximum number of bytes that can be stored in the underlying data array. \par

@<Func...@>=
inline void RingBuffer_InitBuffer(RingBuffer_t* Buffer, uint8_t* const DataPtr,
                     const uint16_t Size);
@ @c
inline void RingBuffer_InitBuffer(RingBuffer_t* Buffer,
                                        uint8_t* const DataPtr,
                                        const uint16_t Size)
{
  GCC_FORCE_POINTER_ACCESS(Buffer);
  cli();

	Buffer->In     = DataPtr;
	Buffer->Out    = DataPtr;
	Buffer->Start  = &DataPtr[0];
	Buffer->End    = &DataPtr[Size];
	Buffer->Size   = Size;
	Buffer->Count  = 0;

  sei();
}

@ Retrieves the current number of bytes stored in a particular buffer. This value is computed
by entering an atomic lock on the buffer, so that the buffer cannot be modified while the
computation takes place. This value should be cached when reading out the contents of the buffer,
so that as small a time as possible is spent in an atomic lock.

Note, that the value returned by this function is guaranteed to only be the minimum number of bytes
stored in the given buffer; this value may change as other threads write new data, thus
the returned number should be used only to determine how many successive reads may safely
be performed on the buffer.

|Buffer| is a pointer to a ring buffer structure whose count is to be computed.

Returns number of bytes currently stored in the buffer.

@<Func...@>=
inline uint16_t RingBuffer_GetCount(RingBuffer_t* const Buffer);
@ @c
inline uint16_t RingBuffer_GetCount(RingBuffer_t* const Buffer)
{
  uint16_t Count;

  cli();

  Count = Buffer->Count;

  sei();
	return Count;
}

@ Retrieves the free space in a particular buffer. This value is computed by entering an atomic
lock on the buffer, so that the buffer cannot be modified while the computation takes place.

Note, that the value returned by this function is guaranteed to only be the maximum number of bytes
free in the given buffer; this value may change as other threads write new data, thus
the returned number should be used only to determine how many successive writes may safely
be performed on the buffer when there is a single writer thread.

|Buffer| is a pointer to a ring buffer structure whose free count is to be computed.

Returns number of free bytes in the buffer.

@<Func...@>=
inline uint16_t RingBuffer_GetFreeCount(RingBuffer_t* const Buffer);
@ @c
inline uint16_t RingBuffer_GetFreeCount(RingBuffer_t* const Buffer)
{
	return (Buffer->Size - RingBuffer_GetCount(Buffer));
}

@ Atomically determines if the specified ring buffer contains any data. This should
be tested before removing data from the buffer, to ensure that the buffer does not
underflow.

If the data is to be removed in a loop, store the total number of bytes stored in the
buffer (via a call to the |RingBuffer_GetCount| function) in a temporary variable
to reduce the time spent in atomicity locks.

|Buffer| is a pointer to a ring buffer structure to insert into.

Returns true if the buffer contains no free space, false otherwise.

@<Func...@>=
inline bool RingBuffer_IsEmpty(RingBuffer_t* const Buffer);
@ @c
inline bool RingBuffer_IsEmpty(RingBuffer_t* const Buffer)
{
	return (RingBuffer_GetCount(Buffer) == 0);
}

@ Atomically determines if the specified ring buffer contains any free space. This should
be tested before storing data to the buffer, to ensure that no data is lost due to a
buffer overrun.

|Buffer| is a pointer to a ring buffer structure to insert into.

Returns true if the buffer contains no free space, false otherwise.

@<Func...@>=
inline bool RingBuffer_IsFull(RingBuffer_t* const Buffer);
@ @c
inline bool RingBuffer_IsFull(RingBuffer_t* const Buffer)
{
  return (RingBuffer_GetCount(Buffer) == Buffer->Size);
}

@ Inserts an element into the ring buffer.

Only one execution thread (main program thread or an ISR) may insert into a single buffer
otherwise data corruption may occur. Insertion and removal may occur from different
execution threads.

|Buffer| is a pointer to a ring buffer structure to insert into.
|Data| is data element to insert into the buffer.

@<Func...@>=
inline void RingBuffer_Insert(RingBuffer_t* Buffer, const uint8_t Data);
@ @c
inline void RingBuffer_Insert(RingBuffer_t* Buffer, const uint8_t Data)
{
	GCC_FORCE_POINTER_ACCESS(Buffer);

	*Buffer->In = Data;

	if (++Buffer->In == Buffer->End)
	  Buffer->In = Buffer->Start;

  cli();

	Buffer->Count++;

  sei();
}

@ Removes an element from the ring buffer.

Only one execution thread (main program thread or an ISR) may remove from a single
buffer otherwise data corruption may occur. Insertion and removal may occur from different
execution threads.

|Buffer| is a pointer to a ring buffer structure to retrieve from.

Returns next data element stored in the buffer.

@<Func...@>=
inline uint8_t RingBuffer_Remove(RingBuffer_t* Buffer);
@ @c
inline uint8_t RingBuffer_Remove(RingBuffer_t* Buffer)
{
	GCC_FORCE_POINTER_ACCESS(Buffer);

	uint8_t Data = *Buffer->Out;

	if (++Buffer->Out == Buffer->End)
	  Buffer->Out = Buffer->Start;

  cli();

	Buffer->Count--;

  sei();

	return Data;
}

@ Returns the next element stored in the ring buffer, without removing it.

|Buffer| is a pointer to a ring buffer structure to retrieve from.

Returns next data element stored in the buffer.

@<Func...@>=
inline uint8_t RingBuffer_Peek(RingBuffer_t* const Buffer);
@ @c
inline uint8_t RingBuffer_Peek(RingBuffer_t* const Buffer)
{
	return *Buffer->Out;
}

@** Headers.
\secpagedepth=0 % index on current page

@<Header files@>=
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/power.h> /* |clock_prescale_set|, |clock_div_1| */
#include <avr/pgmspace.h>
#include <avr/io.h>
#include <avr/pgmspace.h> /* |PROGMEM| */
#include <avr/eeprom.h>
#include <avr/boot.h> /* |boot_signature_byte_get| */
#include <math.h>
#include <util/delay.h>

@** Index.
