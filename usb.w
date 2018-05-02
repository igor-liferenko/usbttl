%TODO: convert all functions to lowercase with _

%NOTE: to test, use avr/check.w + see cweb/SERIAL_TODO

%NOTE: do not do via
% USB_StdDescriptor_Config_Header_t
%and
% USB_StdDescriptor_Endpoint_t
%until you do everything in one file (even when you do all in one file, think
%if doing via |USB_StdDescriptor_Config_Header_t| is better than default)

% TODO: make DTR work (see arduino's modification of this firmware at
% https://github.com/arduino/Arduino/tree/master/hardware/arduino/%
%   avr/firmwares/atmegaxxu2)

%TODO put here info from https://en.wikipedia.org/wiki/Circular_buffer

\let\lheader\rheader

\secpagedepth=1 % begin new page only on **

@* Data throughput, latency and handshaking issues.
The Universal Serial Bus may be new to some users and developers. Here are
described the major architecture differences that need to be considered by both software and
hardware designers when changing from a traditional RS232 based solution to one that uses
the USB to serial interface devices.

@*1 The need for handshaking.
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

@*1 Data transfer comparison.
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

@*1 Continuous data --- smoothing the lumps.
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

@*1 Small amounts of data or end of buffer conditions.
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

@* Effect of USB buffer size and the latency timer on data throughput.
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

@*1 Event Characters.
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

@*1 Flushing the receive buffer using the modem status lines.
Flow control can be used by some chips to flush
the buffer in the chip. Changing one of the modem status lines will do this. The modem status
lines can be controlled by an external device or from the host PC itself. If an unused output line
(DTR) is connected to one of the unused inputs (DSR), then if the DTR line is changed by the
application program from low to high or high to low, this will cause a change on DSR and make it
flush the buffer.

@*1 Flow Control.
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

@* Main program entry point. This routine contains the overall program flow, including
initial
setup of all components and the main program loop.

@c
@<Header files@>@;
@<Type definitions@>@;
@<Function prototypes@>@;
@<Global variables@>@;

int main(void)
{
  SetupHardware();
  RingBuffer_InitBuffer(&USBtoUSART_Buffer, USBtoUSART_Buffer_Data,
    sizeof USBtoUSART_Buffer_Data);
  RingBuffer_InitBuffer(&USARTtoUSB_Buffer, USARTtoUSB_Buffer_Data,
    sizeof USARTtoUSB_Buffer_Data);

  @<Indicate that USB device is disconnected@>@;
  GlobalInterruptEnable();

  while (1) {
    @<Only try to read in bytes from the CDC interface if the transmit buffer...@>@;
    uint16_t BufferCount = RingBuffer_GetCount(&USARTtoUSB_Buffer);
    if (BufferCount) {
      Endpoint_SelectEndpoint(VirtualSerial_CDC_Interface.Config.DataINEndpoint.Address);
      @<Try to send more data@>@;
    }
    @<Load the next byte from the USART transmit buffer into the USART if transmit...@>@;
    CDC_DeviceTask(&VirtualSerial_CDC_Interface);
    USB_DeviceTask();
  }
}

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
if (Endpoint_IsINReady()) {
  @<Calculate bytes to send@>@;
  @<Read bytes from the USART receive buffer into the USB IN endpoint@>@;
}

@ Never send more than one bank size less one byte to the host at a time, so that we
don't block
while a Zero Length Packet (ZLP) to terminate the transfer is sent if the host isn't
listening.

@<Calculate bytes to send@>=
uint8_t BytesToSend = MIN(BufferCount, (CDC_TXRX_EPSIZE - 1));

@ @<Read bytes from the USART receive buffer into the USB IN endpoint@>=
while (BytesToSend--) {
  @<Try to send the next byte of data to the host, abort if there is an error
    without dequeuing@>@;
  @<Dequeue the already sent byte from the buffer now we have confirmed that no
    transmission error occurred@>@;
}

@ @d ENDPOINT_READYWAIT_NO_ERROR 0 /* Endpoint is ready for next packet, no error */

@<Try to send the next byte of data to the host, abort if there is an error without
    dequeuing@>=
if (CDC_Device_SendByte(&VirtualSerial_CDC_Interface,
    RingBuffer_Peek(&USARTtoUSB_Buffer)) != ENDPOINT_READYWAIT_NO_ERROR) break;

@ @<Dequeue the already sent byte from the buffer now we have confirmed that no
    transmission error occurred@>=
RingBuffer_Remove(&USARTtoUSB_Buffer);

@ @<Load the next byte from the USART transmit buffer into the USART if transmit buffer
    space is available@>=
if (@<Serial is send-ready@> && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
  UDR1 = RingBuffer_Remove(&USBtoUSART_Buffer); /* transmit a given raw byte through the USART */

@ Indicates whether there is hardware buffer space for a new transmit on the USART.
Return true if a character can be queued for transmission immediately, false otherwise.

@<Serial is send-ready@>=
(UCSR1A & (1 << UDRE1))

@ LED mask for the library LED driver, to indicate that the USB interface is not ready.

@<Indicate that USB device is disconnected@>=
LEDs_SetAllLEDs(LEDS_LED1);

@ Circular buffer to hold data from the host before it is sent to the device via the
serial port.

@s RingBuffer_t int

@<Global...@>=
RingBuffer_t USBtoUSART_Buffer;

@ Underlying data buffer for |USBtoUSART_Buffer|, where the stored bytes are located.

@<Global...@>=
uint8_t      USBtoUSART_Buffer_Data[128];

@ Circular buffer to hold data from the serial port before it is sent to the host.

@<Global...@>=
RingBuffer_t USARTtoUSB_Buffer;

@ Underlying data buffer for |USARTtoUSB_Buffer|, where the stored bytes are located.

@<Global...@>=
uint8_t      USARTtoUSB_Buffer_Data[128];

@ Configures the board hardware and chip peripherals for the demo's functionality.

@<Function prototypes@>=
void SetupHardware(void);

@ @c
void SetupHardware(void)
{
#if (ARCH == ARCH_AVR8)
	@<Disable watchdog if enabled by bootloader/fuses@>@;
	clock_prescale_set(clock_div_1); /* disable clock division */
#endif
  @<Hardware initialization@>@;
}

@ @<Disable watchdog if enabled by bootloader/fuses@>=
MCUSR &= ~(1 << WDRF);
@^see datasheet@>
wdt_disable();

@ @<Hardware initialization@>=
LEDs_Init();
USB_Init();

@ Event handler for the library USB Connection event.

LED mask for the library LED driver, to indicate that the USB interface is enumerating.

@c
void EVENT_USB_Device_Connect(void)
{
	LEDs_SetAllLEDs(LEDS_LED2 | LEDS_LED3);
}

@ Event handler for the library USB Disconnection event.

@c
void EVENT_USB_Device_Disconnect(void)
{
  @<Indicate that USB device is disconnected@>@;
}

@ Event handler for the library USB Configuration Changed event.

@d LEDMASK_USB_READY (LEDS_LED2 | LEDS_LED4)
@d LEDMASK_USB_ERROR (LEDS_LED1 | LEDS_LED3)

@c
void EVENT_USB_Device_ConfigurationChanged(void)
{
	bool ConfigSuccess = true;
	ConfigSuccess &= CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface);
	LEDs_SetAllLEDs(ConfigSuccess ? LEDMASK_USB_READY : LEDMASK_USB_ERROR);
}

@ Event handler for the library USB Control Request reception event.

@c
void EVENT_USB_Device_ControlRequest(void)
{
	CDC_Device_ProcessControlRequest(&VirtualSerial_CDC_Interface);
}

@ ISR to manage the reception of data from the serial port, placing received bytes into
a circular buffer
for later transmission to the host.

Macro for the definition of interrupt service routines, so that the compiler can
 insert the required
  prologue and epilogue code to properly manage the interrupt routine without affecting
 the main thread's
  state with unintentional side-effects.

  Interrupt handlers written using this macro may still need to be registered with the
 microcontroller's
  Interrupt Controller (if present) before they will properly handle incoming interrupt events.

@d DEVICE_STATE_CONFIGURED 4 /* may be implemented by the user project. This state indicates
  that the device has been enumerated by the host and is ready for USB communications to begin */

@c
ISR(USART1_RX_vect, ISR_BLOCK)
{
	uint8_t ReceivedByte = UDR1;
@^see datasheet@>
	if ((USB_DeviceState == DEVICE_STATE_CONFIGURED) &&
 !(RingBuffer_IsFull(&USARTtoUSB_Buffer)))
	  RingBuffer_Insert(&USARTtoUSB_Buffer, ReceivedByte);
}

@ Event handler for the CDC Class driver Line Encoding Changed event.
|CDCInterfaceInfo| is a pointer to the CDC
class interface configuration structure.

@d CDC_LINEENCODING_TWO_STOP_BITS 2 /* each frame contains two stop bits */
@d CDC_PARITY_EVEN 2
@d CDC_PARITY_ODD 1

@c
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	uint8_t ConfigMask = 0;

	switch (CDCInterfaceInfo->State.LineEncoding.ParityType)
	{
		case CDC_PARITY_ODD:
			ConfigMask = ((1 << UPM11) | (1 << UPM10)); @+
@^see datasheet@>
			break;
		case CDC_PARITY_EVEN:
			ConfigMask = (1 << UPM11); @+
			break;
	}

  if (CDCInterfaceInfo->State.LineEncoding.CharFormat == CDC_LINEENCODING_TWO_STOP_BITS)
	  ConfigMask |= (1 << USBS1);
@^see datasheet@>

	switch (CDCInterfaceInfo->State.LineEncoding.DataBits)
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

  PORTD |= (1 << 3); /* keep the TX line held high (idle) while the USART is
                        reconfigured */

        @<Turn off USART before reconfiguring it@>@;
	@<Set the new baud rate before configuring the USART@>@;
	@<Reconfigure the USART in double speed mode for a wider baud rate range...@>@;
	PORTD &= ~(1 << 3); /* release the TX line after the USART has been reconfigured */
}

@ Must turn off USART before reconfiguring it, otherwise incorrect operation may occur.

@<Turn off USART before reconfiguring it@>=
UCSR1B = 0;
UCSR1A = 0;
UCSR1C = 0;
@^see datasheet@>

@ Macro |SERIAL_2X_UBBRVAL| is for calculating the baud value from a given baud rate when the
\.{U2X} (double speed) bit is set. Returns closest UBRR register value for the given UART
frequency.

@d SERIAL_2X_UBBRVAL(Baud) ((((F_CPU / 8) + (Baud / 2)) / (Baud)) - 1)

@<Set the new baud rate before configuring the USART@>=
UBRR1 = SERIAL_2X_UBBRVAL(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS);

@ @<Reconfigure the USART in double speed mode for a wider baud rate range at the
    expense of accuracy@>=
UCSR1C = ConfigMask;
UCSR1A = (1 << U2X1);
UCSR1B = ((1 << RXCIE1) | (1 << TXEN1) | (1 << RXEN1));
@^see datasheet@>

@ Initializes the USART, ready for serial data transmission and reception. This initializes
the interface to standard 8-bit, no parity, 1 stop bit settings suitable for most applications.

\\{BaudRate} (|uint32_t|) is serial baud rate, in bits per second. This should be the target
baud rate regardless of the \\{DoubleSpeed} parameter's value.

\\{DoubleSpeed} (|bool|) enables double speed mode when set, halving the sample time to
double the baud rate.

Macro \.{SERIAL\_UBBRVAL} is for calculating the baud value from a given baud rate when the \.{U2X}
(double speed) bit is not set. Returns closest UBRR register value for the given UART frequency.

@d SERIAL_UBBRVAL(Baud) ((((F_CPU / 16) + (Baud / 2)) / (Baud)) - 1)

@(/dev/null@>=
UBRR1  = (DoubleSpeed ? SERIAL_2X_UBBRVAL(BaudRate) : SERIAL_UBBRVAL(BaudRate));

UCSR1C = ((1 << UCSZ11) | (1 << UCSZ10));
UCSR1A = (DoubleSpeed ? (1 << U2X1) : 0);
UCSR1B = ((1 << TXEN1)  | (1 << RXEN1));

DDRD  |= (1 << 3);
PORTD |= (1 << 2);

@* USB Device Descriptors. Used in USB device mode. Descriptors are special
computer-readable structures which the host requests upon device enumeration, to determine
the device's capabilities and functions.

@ Device descriptor structure. This descriptor, located in FLASH memory, describes the
overall
device characteristics, including the supported USB version, control endpoint size and the
number of device configurations.
The descriptor is read out by the USB host when the enumeration
process begins.

@d CDC_CSCP_NO_SPECIFIC_SUBCLASS 0x00 /* Subclass value indicating that the device or interface
  belongs to no specific subclass of the CDC class */
@d CDC_CSCP_NO_SPECIFIC_PROTOCOL 0x00 /* Protocol value indicating that the device or interface
   belongs to no specific protocol of the CDC class */

@<Global...@>=
const USB_Descriptor_Device_t PROGMEM DeviceDescriptor = {@|
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

@ @d DTYPE_DEVICE 0x01 /* indicates that the descriptor is a device descriptor */

@<Initialize header of USB device descriptor@>=
{@, sizeof (USB_Descriptor_Device_t), DTYPE_DEVICE @,}

@ Configuration descriptor structure. This descriptor, located in FLASH memory, describes
the usage
of the device in one of its supported configurations, including information about any
device interfaces
and endpoints.
The descriptor is read out by the USB host during the enumeration process when selecting
a configuration so that the host may correctly communicate with the USB device.

@d CDC_NOTIFICATION_EPADDR (ENDPOINT_DIR_IN  | 2) /* endpoint address of the CDC
  device-to-host notification IN endpoint */
@d CDC_TX_EPADDR (ENDPOINT_DIR_IN  | 3) /* endpoint address of the CDC device-to-host
  data IN endpoint */
@d CDC_RX_EPADDR (ENDPOINT_DIR_OUT | 4) /* endpoint address of the CDC host-to-device
  data OUT endpoint */
@d CDC_NOTIFICATION_EPSIZE 8 /* size in bytes of the CDC device-to-host notification IN
  endpoint */
@d CDC_TXRX_EPSIZE 16 /* size in bytes of the CDC data IN and OUT endpoints */
@s USB_Descriptor_Config_t int

@<Global...@>=
const USB_Descriptor_Config_t PROGMEM ConfigurationDescriptor = {@|
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

@s USB_Descriptor_Config_Header_t int
@s USB_Descriptor_Interface_t int
@s USB_CDC_Descriptor_Func_Header_t int
@s USB_CDC_Descriptor_Func_ACM_t int
@s USB_CDC_Descriptor_Func_Union_t int
@s USB_Descriptor_Endpoint_t int

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

@ @d DTYPE_CONFIGURATION 0x02 /* configuration descriptor */

@<Initialize header of standard Configuration Descriptor@>= {@|
  {@, sizeof (USB_Descriptor_Config_Header_t), DTYPE_CONFIGURATION @,}, @|
  sizeof @[@](USB_Descriptor_Config_t),@|
  2,@|
  1,@|
  NO_DESCRIPTOR,@|
  (USB_CONFIG_ATTR_RESERVED | USB_CONFIG_ATTR_SELFPOWERED),@|
  USB_CONFIG_POWER_MA(100)@/
}

@ @d CDC_CSCP_CDC_CLASS 0x02 /* Class value indicating that the device or interface
    belongs to the CDC class */
@d CDC_CSCP_ACM_SUBCLASS 0x02 /* Subclass value indicating
    that the device or interface belongs to the Abstract Control Model CDC subclass */
@d CDC_CSCP_AT_COMMAND_PROTOCOL 0x01 /* Protocol value indicating that the device
    or interface belongs to the AT Command protocol of the CDC class */
@d DTYPE_INTERFACE 0x04 /* indicates that the descriptor is an interface descriptor */

@<Initialize |CDC_CCI_Interface|@>= {@|
  {@, sizeof (USB_Descriptor_Interface_t), DTYPE_INTERFACE @,},@|
  INTERFACE_ID_CDC_CCI,@|
  0,@|
  1,@|
  CDC_CSCP_CDC_CLASS,@|
  CDC_CSCP_ACM_SUBCLASS,@|
  CDC_CSCP_AT_COMMAND_PROTOCOL,@|
  NO_DESCRIPTOR @/
}

@ @d CDC_DSUBTYPE_CS_INTERFACE_HEADER 0x00 /* CDC class-specific Header
  functional descriptor */
@d DTYPE_CS_INTERFACE 0x24 /* indicates that the descriptor is a class
  specific interface descriptor */

@<Initialize |CDC_Functional_Header|@>= {@|
  {@, sizeof (USB_CDC_Descriptor_Func_Header_t), DTYPE_CS_INTERFACE @,},@|
  CDC_DSUBTYPE_CS_INTERFACE_HEADER,@|
  VERSION_BCD(1,1,0) @/
}

@ @d CDC_DSUBTYPE_CS_INTERFACE_ACM 0x02 /* CDC class-specific Abstract Control Model
  functional descriptor */

@<Initialize |CDC_Functional_ACM|@>= {@|
  {@, sizeof (USB_CDC_Descriptor_Func_ACM_t), DTYPE_CS_INTERFACE @,},@|
  CDC_DSUBTYPE_CS_INTERFACE_ACM,@|
  0x06 @/
}

@ @d INTERFACE_ID_CDC_CCI 0 /* CDC CCI interface descriptor ID */
@d INTERFACE_ID_CDC_DCI 1 /* CDC DCI interface descriptor ID */
@d CDC_DSUBTYPE_CS_INTERFACE_UNION 0x06 /* CDC class-specific Union functional descriptor */

@<Initialize |CDC_Functional_Union|@>= {@|
  {@, sizeof (USB_CDC_Descriptor_Func_Union_t), DTYPE_CS_INTERFACE @,},@|
  CDC_DSUBTYPE_CS_INTERFACE_UNION,@|
  INTERFACE_ID_CDC_CCI,@|
  INTERFACE_ID_CDC_DCI @/
}

@ @d DTYPE_ENDPOINT 0x05 /* indicates that the descriptor is an endpoint descriptor */

@<Initialize |CDC_Notification_Endpoint|@>= {@|
  {@, sizeof (USB_Descriptor_Endpoint_t), DTYPE_ENDPOINT @,},@|
  CDC_NOTIFICATION_EPADDR,@|
  (EP_TYPE_INTERRUPT | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_NOTIFICATION_EPSIZE,@|
  0xFF @/
}

@ @d CDC_CSCP_NO_DATA_PROTOCOL 0x00 /* Protocol value indicating
     that the device or interface belongs to no specific protocol of the CDC data class */
@d CDC_CSCP_NO_DATA_SUBCLASS 0x00 /* Subclass value indicating
    that the device or interface belongs to no specific subclass of the CDC data class */
@d CDC_CSCP_CDC_DATA_CLASS 0x0A /* Class value indicating that the device or interface
    belongs to the CDC Data class */
@<Initialize |CDC_DCI_Interface|@>= {@|
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
const USB_Descriptor_String_t PROGMEM LanguageString = {
  {
    sizeof (USB_Descriptor_Header_t) + sizeof ((uint16_t){LANGUAGE_ID_ENG}),
    DTYPE_String
  },
  {LANGUAGE_ID_ENG}
};

@ Manufacturer descriptor string. This is a Unicode string containing the manufacturer's
details in human readable
form, and is read out upon request by the host when the appropriate string ID is
requested, listed in the Device
Descriptor.

@<Global...@>=
const USB_Descriptor_String_t PROGMEM ManufacturerString =
  USB_STRING_DESCRIPTOR(L"Dean Camera");

@ Product descriptor string. This is a Unicode string containing the product's details
in human readable form,
and is read out upon request by the host when the appropriate string ID is requested,
listed in the Device
Descriptor.

@<Global...@>=
const USB_Descriptor_String_t PROGMEM ProductString =
  USB_STRING_DESCRIPTOR(L"LUFA USB-RS232 Adapter");

@ This function is called by the library when in device mode, and must be overridden
(see library "USB Descriptors"
documentation) by the application code so that the address and size of a requested
descriptor can be given
to the USB library. When the device receives a Get Descriptor request on the control
endpoint, this function
is called so that the descriptor details can be passed back and the appropriate descriptor
sent back to the
USB host.

@<Function prototypes@>=
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
                                    const uint16_t wIndex,
                                    const void** const DescriptorAddress)
                                    ATTR_WARN_UNUSED_RESULT ATTR_NON_NULL_PTR_ARG(3);

@ @dSTRING_ID_LANGUAGE 0 /* Supported Languages string descriptor
    ID (must be zero) */
@d STRING_ID_MANUFACTURER 1 /* Manufacturer string ID */
@d STRING_ID_PRODUCT 2 /* Product string ID */
@d DTYPE_STRING 0x03 /* indicates that the descriptor is a string descriptor */

@c
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
                                    const uint16_t wIndex,
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

@* USB Event management definitions.

@ @c
void EVENT_USB_Device_Suspend(void)
{
}
void EVENT_USB_Device_StartOfFrame(void)
{
}
void EVENT_USB_Device_WakeUp(void)
{
}
void EVENT_USB_Device_Reset(void)
{
}

@* Main USB service task management.

@ @c
void USB_DeviceTask(void)
{
	if (USB_DeviceState == DEVICE_STATE_Unattached)
	  return;

	uint8_t PrevEndpoint = Endpoint_GetCurrentEndpoint();

	Endpoint_SelectEndpoint(ENDPOINT_CONTROLEP);

	if (Endpoint_IsSETUPReceived())
	  USB_Device_ProcessControlRequest();

	Endpoint_SelectEndpoint(PrevEndpoint);
}

@* USB controller interrupt service routine management.

@ @c
void USB_INT_DisableAllInterrupts(void)
{
	USBCON &= ~(1 << VBUSTE);
	UDIEN   = 0;
}

void USB_INT_ClearAllInterrupts(void)
{
	USBINT = 0;
	UDINT  = 0;
}

ISR(USB_GEN_vect, ISR_BLOCK)
{
  if (USB_INT_HasOccurred(USB_INT_SOFI) && USB_INT_IsEnabled(USB_INT_SOFI)) {
    USB_INT_Clear(USB_INT_SOFI);
    EVENT_USB_Device_StartOfFrame();
  }

  if (USB_INT_HasOccurred(USB_INT_VBUSTI) && USB_INT_IsEnabled(USB_INT_VBUSTI)) {
    USB_INT_Clear(USB_INT_VBUSTI);

    if (@<VBUS line is high@>) {
      if (!(USB_Options & USB_OPT_MANUAL_PLL)) {
        @<USB PLL on@>@;
        while (!@<USB PLL is ready@>) ;
      }

			USB_DeviceState = DEVICE_STATE_Powered;
			EVENT_USB_Device_Connect();
		}
		else
		{
			if (!(USB_Options & USB_OPT_MANUAL_PLL))
			  @<USB PLL off@>@;

			USB_DeviceState = DEVICE_STATE_Unattached;
			EVENT_USB_Device_Disconnect();
		}
	}

	if (USB_INT_HasOccurred(USB_INT_SUSPI) && USB_INT_IsEnabled(USB_INT_SUSPI))
	{
		USB_INT_Disable(USB_INT_SUSPI);
		USB_INT_Enable(USB_INT_WAKEUPI);

		@<USB CLK freeze@>@;

		if (!(USB_Options & USB_OPT_MANUAL_PLL))
		  @<USB PLL off@>@;

		USB_DeviceState = DEVICE_STATE_Suspended;
		EVENT_USB_Device_Suspend();
	}

  if (USB_INT_HasOccurred(USB_INT_WAKEUPI) && USB_INT_IsEnabled(USB_INT_WAKEUPI)) {
    if (!(USB_Options & USB_OPT_MANUAL_PLL)) {
      @<USB PLL on@>@;
      while (!@<USB PLL is ready@>) ;
    }

    @<USB CLK unfreeze@>@;

    USB_INT_Clear(USB_INT_WAKEUPI);

    USB_INT_Disable(USB_INT_WAKEUPI);
    USB_INT_Enable(USB_INT_SUSPI);

    if (USB_Device_ConfigurationNumber)
      USB_DeviceState = DEVICE_STATE_Configured;
    else
      USB_DeviceState = @<Address of USB Device is set@> ?
        DEVICE_STATE_Addressed : DEVICE_STATE_Powered;

    EVENT_USB_Device_WakeUp();
  }

	if (USB_INT_HasOccurred(USB_INT_EORSTI) && USB_INT_IsEnabled(USB_INT_EORSTI))
	{
		USB_INT_Clear(USB_INT_EORSTI);

		USB_DeviceState                = DEVICE_STATE_Default;
		USB_Device_ConfigurationNumber = 0;

		USB_INT_Clear(USB_INT_SUSPI);
		USB_INT_Disable(USB_INT_SUSPI);
		USB_INT_Enable(USB_INT_WAKEUPI);

		Endpoint_ConfigureEndpoint(ENDPOINT_CONTROLEP, EP_TYPE_CONTROL,
		                           USB_Device_ControlEndpointSize, 1);

		USB_INT_Enable(USB_INT_RXSTPI);

		EVENT_USB_Device_Reset();
	}
}

ISR(USB_COM_vect, ISR_BLOCK)
{
	uint8_t PrevSelectedEndpoint = Endpoint_GetCurrentEndpoint();

	Endpoint_SelectEndpoint(ENDPOINT_CONTROLEP);
	USB_INT_Disable(USB_INT_RXSTPI);

	GlobalInterruptEnable();

	USB_Device_ProcessControlRequest();

	Endpoint_SelectEndpoint(ENDPOINT_CONTROLEP);
	USB_INT_Enable(USB_INT_RXSTPI);
	Endpoint_SelectEndpoint(PrevSelectedEndpoint);
}

@ Determine if the VBUS line is currently high (i.e. the USB host is supplying power).
True if the VBUS line is currently detecting power from a host,
false otherwise.

@<VBUS line is high@>=
(USBSTA & (1 << VBUS))

@ Enable internal 3.3V USB data pad regulator to regulate the data pin voltages from the
VBUS level down to a level within the range allowable by the USB standard
(i.e., don't use AVR's VCC level for the data pads).

@<USB PLL on@>=
PLLCSR = USB_PLL_PSC;
PLLCSR = (USB_PLL_PSC | (1 << PLLE));

@ @<USB PLL off@>=
PLLCSR = 0;

@ @<USB PLL is ready@>=
(PLLCSR & (1 << PLOCK))

@ @<USB CLK freeze@>=
USBCON |=  (1 << FRZCLK);

@ @<USB CLK unfreeze@>=
USBCON &= ~(1 << FRZCLK);

@ @<Address of USB Device is set@>=
(UDADDR & (1 << ADDEN))

@* USB Controller definitions for the AVR8 microcontrollers.

@ Main function to initialize and start the USB interface. Once active, the USB interface will
allow for device connection to a host.

As the USB library relies on interrupts for the enumeration processes,
the user must enable global interrupts before or shortly after this function is called.
Interrupts must be enabled within 500ms of this function being called to ensure
that the host does not time out whilst enumerating the device.

Calling this function when the USB interface is already initialized will cause a complete USB
interface reset and re-enumeration.

|Mode| is mask indicating what mode the USB interface is to be initialized to,
a value from the |USB_Modes_t| enum.
Note, that this parameter does not exist on devices with only one supported USB
mode (device or host).

|Options| is mask indicating the options which should be used when initializing the USB
interface to control the USB interface's behavior. This should be
comprised of a \.{USB\_OPT\_REG\_*} mask to control the regulator, a \.{USB\_OPT\_*\_PLL}
mask to control the PLL, and a \.{USB\_DEVICE\_OPT\_*} mask (when the device mode is enabled)
to set the device mode speed.

@<Function prototypes@>=
void USB_Init(void);

@ @c
void USB_Init(void)
{
  @<USB REG on@>@;

	if (!(USB_Options & USB_OPT_MANUAL_PLL))
		PLLFRQ = (1 << PDIV2);

	USB_IsInitialized = true;

	USB_ResetInterface();
}

@ @<USB REG on@>=
UHWCON |=  (1 << UVREGE);

@ Remove the device from any
attached host, ceasing USB communications. If no host is present, this prevents any host from
enumerating the device once attached until |USB_Attach| is called.

@<Detach the device from the USB bus@>=
UDCON  |=  (1 << DETACH);

@ @c
void USB_ResetInterface(void)
{
	USB_INT_DisableAllInterrupts();
	USB_INT_ClearAllInterrupts();

	USB_Controller_Reset();

	@<USB CLK unfreeze@>@;

	if (!(USB_Options & USB_OPT_MANUAL_PLL))
		@<USB PLL off@>@;

	USB_Init_Device();

	USBCON |=  (1 << OTGPADE); /* enable VBUS pad */
}

@ @<Function prototypes@>=
void USB_Init_Device(void);

@ @c
void USB_Init_Device(void)
{
	USB_DeviceState                 = DEVICE_STATE_Unattached;
	USB_Device_ConfigurationNumber  = 0;

	USB_Device_RemoteWakeupEnabled  = false;

	USB_Device_CurrentlySelfPowered = false;

  if (USB_Options & USB_DEVICE_OPT_LOWSPEED)
    @<Set low speed@>@;
  else
    @<Set full speed@>@;

	USB_INT_Enable(USB_INT_VBUSTI);

	Endpoint_ConfigureEndpoint(ENDPOINT_CONTROLEP, EP_TYPE_CONTROL,
							   USB_Device_ControlEndpointSize, 1);

	USB_INT_Clear(USB_INT_SUSPI);
	USB_INT_Enable(USB_INT_SUSPI);
	USB_INT_Enable(USB_INT_EORSTI);

  @<Attach the device to the USB bus@>@;
}

@ Announce the device's presence to any attached
USB host, starting the enumeration process. If no host is present, attaching the device
will allow for enumeration once a host is connected to the device.

@<Attach the device to the USB bus@>=
UDCON  &= ~(1 << DETACH);

@ @<Set low speed@>=
UDCON |=  (1 << LSM);

@ @<Set full speed@>=
UDCON &= ~(1 << LSM);

@* USB Endpoint definitions for the AVR8 microcontrollers.

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

@ @c
bool Endpoint_ConfigureEndpoint_Prv(const uint8_t Number,
                                    const uint8_t UECFG0XData,
                                    const uint8_t UECFG1XData)
{
	for (uint8_t EPNum = Number; EPNum < ENDPOINT_TOTAL_ENDPOINTS; EPNum++)
	{
		uint8_t UECFG0XTemp;
		uint8_t UECFG1XTemp;
		uint8_t UEIENXTemp;

		Endpoint_SelectEndpoint(EPNum);

		if (EPNum == Number)
		{
			UECFG0XTemp = UECFG0XData;
			UECFG1XTemp = UECFG1XData;
			UEIENXTemp  = 0;
		}
		else
		{
			UECFG0XTemp = UECFG0X;
			UECFG1XTemp = UECFG1X;
			UEIENXTemp  = UEIENX;
		}

		if (!(UECFG1XTemp & (1 << ALLOC)))
		  continue;

		Endpoint_DisableEndpoint();
		UECFG1X &= ~(1 << ALLOC);

		Endpoint_EnableEndpoint();
		UECFG0X = UECFG0XTemp;
		UECFG1X = UECFG1XTemp;
		UEIENX  = UEIENXTemp;

		if (!(Endpoint_IsConfigured()))
		  return false;
	}

	Endpoint_SelectEndpoint(Number);
	return true;
}

@ @c
void Endpoint_ClearEndpoints(void)
{
	UEINT = 0;

	for (uint8_t EPNum = 0; EPNum < ENDPOINT_TOTAL_ENDPOINTS; EPNum++)
	{
		Endpoint_SelectEndpoint(EPNum);
		UEIENX  = 0;
		UEINTX  = 0;
		UECFG1X = 0;
		Endpoint_DisableEndpoint();
	}
}

@ @c
void Endpoint_ClearStatusStage(void)
{
	if (USB_ControlRequest.bmRequestType & REQDIR_DEVICETOHOST)
	{
		while (!(Endpoint_IsOUTReceived()))
		{
			if (USB_DeviceState == DEVICE_STATE_Unattached)
			  return;
		}

		Endpoint_ClearOUT();
	}
	else
	{
		while (!(Endpoint_IsINReady()))
		{
			if (USB_DeviceState == DEVICE_STATE_Unattached)
			  return;
		}

		Endpoint_ClearIN();
	}
}

@ @c
uint8_t Endpoint_WaitUntilReady(void)
{
	uint8_t  TimeoutMSRem = USB_STREAM_TIMEOUT_MS;

	uint16_t PreviousFrameNumber = USB_Device_GetFrameNumber();

	for (;;)
	{
		if (Endpoint_GetEndpointDirection() == ENDPOINT_DIR_IN)
		{
			if (Endpoint_IsINReady())
			  return ENDPOINT_READYWAIT_NoError;
		}
		else
		{
			if (Endpoint_IsOUTReceived())
			  return ENDPOINT_READYWAIT_NoError;
		}

		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_READYWAIT_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_READYWAIT_BusSuspended;
		else if (Endpoint_IsStalled())
		  return ENDPOINT_READYWAIT_EndpointStalled;

		uint16_t CurrentFrameNumber = USB_Device_GetFrameNumber();

		if (CurrentFrameNumber != PreviousFrameNumber)
		{
			PreviousFrameNumber = CurrentFrameNumber;

			if (!(TimeoutMSRem--))
			  return ENDPOINT_READYWAIT_Timeout;
		}
	}
}

@* Device mode driver for the library USB CDC Class driver.

@ @c
void CDC_Device_ProcessControlRequest(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if (!(Endpoint_IsSETUPReceived()))
	  return;

	if (USB_ControlRequest.wIndex != CDCInterfaceInfo->Config.ControlInterfaceNumber)
	  return;

	switch (USB_ControlRequest.bRequest)
	{
		case CDC_REQ_GetLineEncoding:
			if (USB_ControlRequest.bmRequestType ==
                            (REQDIR_DEVICETOHOST | REQTYPE_CLASS | REQREC_INTERFACE))
			{
				Endpoint_ClearSETUP();

				while (!(Endpoint_IsINReady()));

                            Endpoint_Write_32_LE(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS);
				Endpoint_Write_8(CDCInterfaceInfo->State.LineEncoding.CharFormat);
				Endpoint_Write_8(CDCInterfaceInfo->State.LineEncoding.ParityType);
				Endpoint_Write_8(CDCInterfaceInfo->State.LineEncoding.DataBits);

				Endpoint_ClearIN();
				Endpoint_ClearStatusStage();
			}

			break;
		case CDC_REQ_SetLineEncoding:
			if (USB_ControlRequest.bmRequestType ==
   (REQDIR_HOSTTODEVICE | REQTYPE_CLASS | REQREC_INTERFACE))
			{
				Endpoint_ClearSETUP();

				while (!(Endpoint_IsOUTReceived()))
				{
					if (USB_DeviceState == DEVICE_STATE_Unattached)
					  return;
				}

				CDCInterfaceInfo->State.LineEncoding.BaudRateBPS
 = Endpoint_Read_32_LE();
				CDCInterfaceInfo->State.LineEncoding.CharFormat
  = Endpoint_Read_8();
				CDCInterfaceInfo->State.LineEncoding.ParityType
  = Endpoint_Read_8();
				CDCInterfaceInfo->State.LineEncoding.DataBits
    = Endpoint_Read_8();

				Endpoint_ClearOUT();
				Endpoint_ClearStatusStage();

				EVENT_CDC_Device_LineEncodingChanged(CDCInterfaceInfo);
			}

			break;
		case CDC_REQ_SetControlLineState:
			if (USB_ControlRequest.bmRequestType ==
 (REQDIR_HOSTTODEVICE | REQTYPE_CLASS | REQREC_INTERFACE))
			{
				Endpoint_ClearSETUP();
				Endpoint_ClearStatusStage();

				CDCInterfaceInfo->State.ControlLineStates.HostToDevice
 = USB_ControlRequest.wValue;

				EVENT_CDC_Device_ControLineStateChanged(CDCInterfaceInfo);
			}

			break;
		case CDC_REQ_SendBreak:
			if (USB_ControlRequest.bmRequestType ==
 (REQDIR_HOSTTODEVICE | REQTYPE_CLASS | REQREC_INTERFACE))
			{
				Endpoint_ClearSETUP();
				Endpoint_ClearStatusStage();

				EVENT_CDC_Device_BreakSent(CDCInterfaceInfo,
 (uint8_t)USB_ControlRequest.wValue);
			}

			break;
	}
}

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

@ @c
void CDC_DeviceTask(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);

	if (Endpoint_IsINReady())
	  CDC_Device_Flush(CDCInterfaceInfo);
}

@ @c
uint8_t CDC_Device_SendString(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                              const char* const String)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);
	return Endpoint_Write_Stream_LE(String, strlen(String), NULL);
}

@ @c
uint8_t CDC_Device_SendString_P(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                              const char* const String)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);
	return Endpoint_Write_PStream_LE(String, strlen_P(String), NULL);
}

@ @c
uint8_t CDC_Device_SendData(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const void* const Buffer,
                            const uint16_t Length)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);
	return Endpoint_Write_Stream_LE(Buffer, Length, NULL);
}

@ @c
uint8_t CDC_Device_SendData_P(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const void* const Buffer,
                            const uint16_t Length)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);
	return Endpoint_Write_PStream_LE(Buffer, Length, NULL);
}

@ @c
uint8_t CDC_Device_SendByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const uint8_t Data)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);

	if (!(Endpoint_IsReadWriteAllowed()))
	{
		Endpoint_ClearIN();

		uint8_t ErrorCode;

		if ((ErrorCode = Endpoint_WaitUntilReady()) != ENDPOINT_READYWAIT_NoError)
		  return ErrorCode;
	}

	Endpoint_Write_8(Data);
	return ENDPOINT_READYWAIT_NoError;
}

@ @c
uint8_t CDC_Device_Flush(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	uint8_t ErrorCode;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);

	if (!(Endpoint_BytesInEndpoint()))
	  return ENDPOINT_READYWAIT_NoError;

	bool BankFull = !(Endpoint_IsReadWriteAllowed());

	Endpoint_ClearIN();

	if (BankFull)
	{
		if ((ErrorCode = Endpoint_WaitUntilReady()) != ENDPOINT_READYWAIT_NoError)
		  return ErrorCode;

		Endpoint_ClearIN();
	}

	return ENDPOINT_READYWAIT_NoError;
}

@ @c
uint16_t CDC_Device_BytesReceived(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return 0;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataOUTEndpoint.Address);

	if (Endpoint_IsOUTReceived())
	{
		if (!(Endpoint_BytesInEndpoint()))
		{
			Endpoint_ClearOUT();
			return 0;
		}
		else
		{
			return Endpoint_BytesInEndpoint();
		}
	}
	else
	{
		return 0;
	}
}

@ @c
int16_t CDC_Device_ReceiveByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return -1;

	int16_t ReceivedByte = -1;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataOUTEndpoint.Address);

	if (Endpoint_IsOUTReceived())
	{
		if (Endpoint_BytesInEndpoint())
		  ReceivedByte = Endpoint_Read_8();

		if (!(Endpoint_BytesInEndpoint()))
		  Endpoint_ClearOUT();
	}

	return ReceivedByte;
}

@ @c
void CDC_Device_SendControlLineStateChange(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.NotificationEndpoint.Address);

	USB_Request_Header_t Notification = (USB_Request_Header_t)
		{
			.bmRequestType = (REQDIR_DEVICETOHOST | REQTYPE_CLASS | REQREC_INTERFACE),
			.bRequest      = CDC_NOTIF_SerialState,
			.wValue        = CPU_TO_LE16(0),
			.wIndex        = CPU_TO_LE16(0),
			.wLength       =
 CPU_TO_LE16(sizeof(CDCInterfaceInfo->State.ControlLineStates.DeviceToHost)),
		};

	Endpoint_Write_Stream_LE(&Notification, sizeof(USB_Request_Header_t), NULL);
	Endpoint_Write_Stream_LE(&CDCInterfaceInfo->State.ControlLineStates.DeviceToHost,
	                         sizeof(CDCInterfaceInfo->State.ControlLineStates.DeviceToHost),
	                         NULL);
	Endpoint_ClearIN();
}

@ @c
void CDC_Device_CreateStream(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                             FILE* const Stream)
{
	*Stream = (FILE)FDEV_SETUP_STREAM(CDC_Device_putchar, CDC_Device_getchar, _FDEV_SETUP_RW);
	fdev_set_udata(Stream, CDCInterfaceInfo);
}

@ @c
void CDC_Device_CreateBlockingStream(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                                     FILE* const Stream)
{
	*Stream = (FILE)FDEV_SETUP_STREAM(CDC_Device_putchar, CDC_Device_getchar_Blocking,
 _FDEV_SETUP_RW);
	fdev_set_udata(Stream, CDCInterfaceInfo);
}

@ @<Function prototypes@>=
int CDC_Device_putchar(char c, FILE* Stream) ATTR_NON_NULL_PTR_ARG(2);

@ @c
int CDC_Device_putchar(char c, FILE* Stream)
{
	return CDC_Device_SendByte((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream), c) ?
 _FDEV_ERR : 0;
}

@ @<Function prototypes@>=
int CDC_Device_getchar(FILE* Stream) ATTR_NON_NULL_PTR_ARG(1);

@ @c
int CDC_Device_getchar(FILE* Stream)
{
	int16_t ReceivedByte =
 CDC_Device_ReceiveByte((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream));

	if (ReceivedByte < 0)
	  return _FDEV_EOF;

	return ReceivedByte;
}

@ @<Function prototypes@>=
int CDC_Device_getchar_Blocking(FILE* Stream) ATTR_NON_NULL_PTR_ARG(1);

@ @c
int CDC_Device_getchar_Blocking(FILE* Stream)
{
	int16_t ReceivedByte;

	while ((ReceivedByte =
 CDC_Device_ReceiveByte((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream))) < 0)
	{
		if (USB_DeviceState == DEVICE_STATE_Unattached)
		  return _FDEV_EOF;

		CDC_DeviceTask((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream));
		USB_DeviceTask();
	}

	return ReceivedByte;
}

@ @c
void EVENT_CDC_Device_ControLineStateChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
}

@ @c
void EVENT_CDC_Device_BreakSent(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
  const uint8_t Duration)
{
}

@* USB device standard request management.

@ @c
void USB_Device_ProcessControlRequest(void)
{
  uint8_t* RequestHeader = (uint8_t*)&USB_ControlRequest;

  for (uint8_t RequestHeaderByte = 0; RequestHeaderByte < sizeof(USB_Request_Header_t);
    RequestHeaderByte++)
	  *(RequestHeader++) = Endpoint_Read_8();

  EVENT_USB_Device_ControlRequest();

  if (Endpoint_IsSETUPReceived()) {
    uint8_t bmRequestType = USB_ControlRequest.bmRequestType;

    switch (USB_ControlRequest.bRequest) {
    case REQ_GetStatus:
	if ((bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE)) ||
		(bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_ENDPOINT)))
			USB_Device_GetStatus();
	
	break;
    case REQ_ClearFeature:
    case REQ_SetFeature:
	if ((bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_DEVICE)) ||
		(bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_ENDPOINT)))
					USB_Device_ClearSetFeature();
	break;
    case REQ_SetAddress:
	if (bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_DEVICE))
		  USB_Device_SetAddress();
	break;
    case REQ_GetDescriptor:
	if ((bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE)) ||
		(bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_INTERFACE)))
					USB_Device_GetDescriptor();
	break;
    case REQ_GetConfiguration:
	if (bmRequestType == (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_DEVICE))
		USB_Device_GetConfiguration();
	break;
    case REQ_SetConfiguration:
	if (bmRequestType == (REQDIR_HOSTTODEVICE | REQTYPE_STANDARD | REQREC_DEVICE))
		USB_Device_SetConfiguration();
	break;
    default:
	break;
    }
  }

  if (Endpoint_IsSETUPReceived()) {
	Endpoint_ClearSETUP();
	Endpoint_StallTransaction();
  }
}

@ @<Function prototypes@>=
void USB_Device_SetAddress(void);

@ @c
void USB_Device_SetAddress(void)
{
	uint8_t DeviceAddress = (USB_ControlRequest.wValue & 0x7F);

  @<Set device address@>@;

	Endpoint_ClearSETUP();

	Endpoint_ClearStatusStage();

	while (!(Endpoint_IsINReady()));

  @<Enable device address@>@;

	USB_DeviceState = (DeviceAddress) ? DEVICE_STATE_Addressed : DEVICE_STATE_Default;
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
  if ((uint8_t)USB_ControlRequest.wValue > FIXED_NUM_CONFIGURATIONS)
	return;

  Endpoint_ClearSETUP();

  USB_Device_ConfigurationNumber = (uint8_t)USB_ControlRequest.wValue;

  Endpoint_ClearStatusStage();

  if (USB_Device_ConfigurationNumber)
    USB_DeviceState = DEVICE_STATE_Configured;
  else
    USB_DeviceState = @<Address of USB Device is set@> ?
      DEVICE_STATE_Configured : DEVICE_STATE_Powered;

  EVENT_USB_Device_ConfigurationChanged();
}

@ @<Function prototypes@>=
void USB_Device_GetConfiguration(void);

@ @c
void USB_Device_GetConfiguration(void)
{
	Endpoint_ClearSETUP();

	Endpoint_Write_8(USB_Device_ConfigurationNumber);
	Endpoint_ClearIN();

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

	SignatureDescriptor.Header.Type = DTYPE_String;
	SignatureDescriptor.Header.Size = USB_STRING_LEN(INTERNAL_SERIAL_LENGTH_BITS / 4);

	USB_Device_GetSerialString(SignatureDescriptor.UnicodeString);

	Endpoint_ClearSETUP();

	Endpoint_Write_Control_Stream_LE(&SignatureDescriptor, sizeof(SignatureDescriptor));
	Endpoint_ClearOUT();
}

@ @<Function prototypes@>=
void USB_Device_GetDescriptor(void);

@ @c
void USB_Device_GetDescriptor(void)
{
	const void* DescriptorPointer;
	uint16_t DescriptorSize;

	if (USB_ControlRequest.wValue == ((DTYPE_String << 8) | USE_INTERNAL_SERIAL))
	{
		USB_Device_GetInternalSerialDescriptor();
		return;
	}

	if ((DescriptorSize = CALLBACK_USB_GetDescriptor(USB_ControlRequest.wValue,
             USB_ControlRequest.wIndex, &DescriptorPointer)) == NO_DESCRIPTOR)
		return;

	Endpoint_ClearSETUP();

	Endpoint_Write_Control_PStream_LE(DescriptorPointer, DescriptorSize);

	Endpoint_ClearOUT();
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
		{
			if (USB_Device_CurrentlySelfPowered)
			  CurrentStatus |= FEATURE_SELFPOWERED_ENABLED;

			if (USB_Device_RemoteWakeupEnabled)
			  CurrentStatus |= FEATURE_REMOTE_WAKEUP_ENABLED;
			break;
		}
		case (REQDIR_DEVICETOHOST | REQTYPE_STANDARD | REQREC_ENDPOINT):
		{
			uint8_t EndpointIndex =
 ((uint8_t)USB_ControlRequest.wIndex & ENDPOINT_EPNUM_MASK);

			if (EndpointIndex >= ENDPOINT_TOTAL_ENDPOINTS)
				return;

			Endpoint_SelectEndpoint(EndpointIndex);

			CurrentStatus = Endpoint_IsStalled();

			Endpoint_SelectEndpoint(ENDPOINT_CONTROLEP);

			break;
		}
		default:
			return;
	}

	Endpoint_ClearSETUP();

	Endpoint_Write_16_LE(CurrentStatus);
	Endpoint_ClearIN();

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
    {
	if ((uint8_t)USB_ControlRequest.wValue == FEATURE_SEL_DeviceRemoteWakeup)
	  USB_Device_RemoteWakeupEnabled = (USB_ControlRequest.bRequest == REQ_SetFeature);
	else return;
	break;
    }
    case REQREC_ENDPOINT:
    {
      if ((uint8_t)USB_ControlRequest.wValue == FEATURE_SEL_EndpointHalt) {
        uint8_t EndpointIndex = ((uint8_t)USB_ControlRequest.wIndex & ENDPOINT_EPNUM_MASK);

        if (EndpointIndex == ENDPOINT_CONTROLEP || EndpointIndex >= ENDPOINT_TOTAL_ENDPOINTS)
		  return;

        Endpoint_SelectEndpoint(EndpointIndex);

        if (Endpoint_IsEnabled()) {
          if (USB_ControlRequest.bRequest == REQ_SetFeature)
            Endpoint_StallTransaction();
          else {
            Endpoint_ClearStall();
            Endpoint_ResetEndpoint(EndpointIndex);
            Endpoint_ResetDataToggle();
          }
        }
      }
      break;
    }
    default:
      return;
  }

  Endpoint_SelectEndpoint(ENDPOINT_CONTROLEP);

  Endpoint_ClearSETUP();

  Endpoint_ClearStatusStage();
}

@* Endpoint data stream transmission and reception management for the AVR8 microcontrollers.

@ @c
uint8_t Endpoint_Discard_Stream(uint16_t Length,
                                uint16_t* const BytesProcessed)
{
	uint8_t  ErrorCode;
	uint16_t BytesInTransfer = 0;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	  Length -= *BytesProcessed;

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Discard_8();

			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Null_Stream(uint16_t Length,
                             uint16_t* const BytesProcessed)
{
	uint8_t  ErrorCode;
	uint16_t BytesInTransfer = 0;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	  Length -= *BytesProcessed;

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(0);

			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Write_Stream_LE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_DeviceTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(*DataStream);
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Write_Stream_BE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_DeviceTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(*DataStream);
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Read_Stream_LE(void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			*DataStream = Endpoint_Read_8();
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Read_Stream_BE(void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_DeviceTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			*DataStream = Endpoint_Read_8();
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Write_PStream_LE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_DeviceTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(pgm_read_byte(DataStream));
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Write_Control_Stream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(*DataStream);
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Write_Control_Stream_BE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + (Length - 1));
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(*DataStream);
				DataStream -= 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Read_Control_Stream_LE(void* const Buffer, uint16_t Length)
{
	uint8_t* DataStream = ((uint8_t*)Buffer + 0);

	if (!(Length))
	  Endpoint_ClearOUT();

	while (Length)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;

		if (Endpoint_IsOUTReceived())
		{
			while (Length && Endpoint_BytesInEndpoint())
			{
				*DataStream = Endpoint_Read_8();
				DataStream += 1;
				Length--;
			}

			Endpoint_ClearOUT();
		}
	}

	while (!(Endpoint_IsINReady()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Read_Control_Stream_BE(void* const Buffer, uint16_t Length)
{
	uint8_t* DataStream = ((uint8_t*)Buffer + (Length - 1));

	if (!(Length))
	  Endpoint_ClearOUT();

	while (Length)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;

		if (Endpoint_IsOUTReceived())
		{
			while (Length && Endpoint_BytesInEndpoint())
			{
				*DataStream = Endpoint_Read_8();
				DataStream -= 1;
				Length--;
			}

			Endpoint_ClearOUT();
		}
	}

	while (!(Endpoint_IsINReady()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

@ @c
uint8_t Endpoint_Write_Control_PStream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(pgm_read_byte(DataStream));
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

@ @<Header files@>=
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
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>
#include <avr/boot.h>
#include <math.h>
#include <util/delay.h>

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

@*2 Device Mode Class Drivers
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
takes in the address of the specific instance you wish to initialize --- in this manner,
multiple separate instances of
the same class type can be initialized like this:

@(/dev/null@>=
void EVENT_USB_Device_ConfigurationChanged(void)
{
      LEDs_SetAllLEDs(LEDMASK_USB_READY);

      if (!(Audio_Device_ConfigureEndpoints(&My_Audio_Interface)))
          LEDs_SetAllLEDs(LEDMASK_USB_ERROR);
}

@ Once initialized, it is important to maintain the class driver's state by repeatedly
calling the Class Driver's
|CDC_DeviceTask| function in the main program loop. The
exact implementation of this
function varies between class drivers, and can be used for any internal class driver
purpose to maintain each
instance. Again, this function uses the address of the instance to operate on, and thus
needs to be called for each
separate instance, just like the main USB maintenance routine |USB_DeviceTask|:

@(/dev/null@>=
int main(void)
{
      SetupHardware();

      LEDs_SetAllLEDs(LEDMASK_USB_NOTREADY);

      for (;;) {
          if (USB_DeviceState != DEVICE_STATE_Configured)
            Create_And_Process_Samples();

          Audio_Device_USBTask(&My_Audio_Interface);
          USB_DeviceTask();
      }
}

@ The final standardized Device Class Driver function is the Control Request handler function
|CDC_Device_ProcessControlRequest|, which should be called when the
|EVENT_USB_Device_ControlRequest| event fires. This function should also be called for
each class driver instance, using the address of the instance to operate on as the function's
parameter. The request handler will abort if it is determined that the current request is not
targeted at the given class driver instance, thus these methods can safely be called
one-after-another in the event handler with no form of error checking:

@(/dev/null@>=
void EVENT_USB_Device_ControlRequest(void)
{
  Audio_Device_ProcessControlRequest(&My_Audio_Interface);
}

@ Class driver also defines a callback function |CALLBACK_USB_GetDescriptor|.
In addition, each class
driver may
also define a set of events (identifiable by their prefix of \\{EVENT\_*} in the
function's name), which
the user application may choose to implement, or ignore if not needed.

The individual Device Mode Class Driver documentation contains more information on the
non-standardized,
class-specific functions which the user application can then use on the driver instances,
such as data
read and write routines. See each driver's individual documentation for more information
on the
class-specific functions.

@* Hardware Architecture defines.
Architecture macros for selecting the desired target microcontroller architecture.
The target architecture is selected in the value of \.{ARCH} via the \.{-D} compiler switch
to GCC.

We use the Atmel 8-bit AVR (AT90USB* and ATMEGA*U* chips) architecture.

@<Header files@>=
#define ARCH_AVR8           0
#define ARCH_           ARCH_AVR8

@* BoardTypes.
@<Header files@>=
/* Board hardware defines.
 *
 *  Board macros for indicating the chosen physical board hardware to the library.
 These macros should be used when
 *  defining the \c BOARD token to the chosen hardware via the \c -D switch in the
 project makefile.
 *
 */

/** Selects the USBKEY specific LED drivers. */
#define BOARD_USBKEY               2

@* ArchitectureSpecific.
@<Header files@>=
/* Architecture specific macros, functions and other definitions, which relate to
 specific architectures.
 */

/** Defines an explicit JTAG break point in the resulting binary via the assembly \c BREAK
 statement. When
 *  a JTAG is used, this causes the program execution to halt when reached until manually resumed.
 */
#define JTAG_DEBUG_BREAK()              __asm__ __volatile__ ("break" ::)
@* CompilerSpecific.
@<Header files@>=
/* Compiler specific definitions for code optimization and correctness.
 *
 *  Compiler specific definitions to expose certain compiler features which may increase
 the level of code optimization
 *  for a specific compiler, or correct certain issues that may be present such as memory
 barriers for use in conjunction
 *  with atomic variable access.
 *
 *  Where possible, on alternative compilers, these macros will either have no effect, or
 default to returning a sane value
 *  so that they can be used in existing code without the need for extra compiler checks in
 the user application code.
 *
 */

/** Forces GCC to use pointer indirection (via the device's pointer register pairs) when
 accessing the given
 *  struct pointer. In some cases GCC will emit non-optimal assembly code when accessing
 a structure through
 *  a pointer, resulting in a larger binary. When this macro is used on a (non \c const)
 structure pointer before
 *  use, it will force GCC to use pointer indirection on the elements rather than direct
 store and load
 *  instructions.
 *
 *  \param[in, out] StructPtr  Pointer to a structure which is to be forced into indirect
 access mode.
 */
#define GCC_FORCE_POINTER_ACCESS(StructPtr) \
  __asm__ __volatile__("" : "=b" (StructPtr) : "0" (StructPtr))

/** Forces GCC to create a memory barrier, ensuring that memory accesses are not reordered
 past the barrier point.
 *  This can be used before ordering-critical operations, to ensure that the compiler does
 not re-order the resulting
 *  assembly output in an unexpected manner on sections of code that are ordering-specific.
 */
#define GCC_MEMORY_BARRIER()                  __asm__ __volatile__("" ::: "memory");

/** Determines if the specified value can be determined at compile-time to be a constant value
 when compiling under GCC.
 *
 *  \param[in] x  Value to check compile-time constantness of.
 *
 *  \return Boolean \c true if the given value is known to be a compile time constant, \c false
 otherwise.
 */
#define GCC_IS_COMPILE_CONST(x)               __builtin_constant_p(x)
@* Attributes.
@<Header files@>=
/* Special function/variable attribute macros.
 *
 *  This module contains macros for applying specific attributes to functions and variables
 to control various
 *  optimizer and code generation features of the compiler. Attributes may be placed in the
 function prototype
 *  or variable declaration in any order, and multiple attributes can be specified for a
 single item via a space
 *  separated list.
 *
 *  On incompatible versions of GCC or on other compilers, these macros evaluate to nothing
 unless they are
 *  critical to the code's function and thus must throw a compile error when used.
 *
 */

/** Indicates to the compiler that the function can not ever return, so that any stack restoring or
 *  return code may be omitted by the compiler in the resulting binary.
 */
#define ATTR_NO_RETURN               __attribute__ ((noreturn))

/** Indicates that the function returns a value which should not be ignored by the user code. When
 *  applied, any ignored return value from calling the function will produce a compiler warning.
 */
#define ATTR_WARN_UNUSED_RESULT      __attribute__ ((warn_unused_result))

/** Indicates that the specified parameters of the function are pointers which should never
 be \c NULL.
 *  When applied as a 1-based comma separated list the compiler will emit a warning if
 the specified
 *  parameters are known at compiler time to be \c NULL at the point of calling the function.
 */
#define ATTR_NON_NULL_PTR_ARG(...)   __attribute__ ((nonnull (__VA_ARGS__)))

/** Removes any preamble or postamble from the function. When used, the function will not have any
 *  register or stack saving code. This should be used with caution, and when used the programmer
 *  is responsible for maintaining stack and register integrity.
 */
#define ATTR_NAKED                   __attribute__ ((naked))

/** Prevents the compiler from considering a specified function for in-lining. When applied,
 the given
 *  function will not be in-lined under any circumstances.
 */
#define ATTR_NO_INLINE               __attribute__ ((noinline))

/** Forces the compiler to inline the specified function. When applied, the given function will be
 *  in-lined under all circumstances.
 */
#define ATTR_ALWAYS_INLINE           __attribute__ ((always_inline))

/** Indicates that the specified function is pure, in that it has no side-effects other than global
 *  or parameter variable access.
 */
#define ATTR_PURE                    __attribute__ ((pure))

/** Indicates that the specified function is constant, in that it has no side effects other than
 *  parameter access.
 */
#define ATTR_CONST                   __attribute__ ((const))

/** Marks a given function as deprecated, which produces a warning if the function is called. */
#define ATTR_DEPRECATED              __attribute__ ((deprecated))

/** Marks a function as a weak reference, which can be overridden by other functions with an
 *  identical name (in which case the weak reference is discarded at link time).
 */
#define ATTR_WEAK                    __attribute__ ((weak))

/** Forces the compiler to not automatically zero the given global variable on startup, so that the
 *  current RAM contents is retained. Under most conditions this value will be random due to the
 *  behavior of volatile memory once power is removed, but may be used in some specific
 circumstances,
 *  like the passing of values back after a system watchdog reset.
 */
#define ATTR_NO_INIT                     __attribute__ ((section (".noinit")))

/** Places the function in one of the initialization sections, which execute before the main
 function
 *  of the application. Refer to the avr-libc manual for more information on the initialization
 sections.
 *
 *  \param[in] SectionIndex  Initialization section number where the function should be placed.
 */
#define ATTR_INIT_SECTION(SectionIndex)  \
  __attribute__ ((used, naked, section (".init" #SectionIndex )))

/** Marks a function as an alias for another function.
 *
 *  \param[in] Func  Name of the function which the given function name should alias.
 */
#define ATTR_ALIAS(Func)                 __attribute__ ((alias( #Func )))

/** Marks a variable or struct element for packing into the smallest space available, omitting any
 *  alignment bytes usually added between fields to optimize field accesses.
 */
#define ATTR_PACKED                      __attribute__ ((packed))

/** Indicates the minimum alignment in bytes for a variable or struct element.
 *
 *  \param[in] Bytes  Minimum number of bytes the item should be aligned to.
 */
#define ATTR_ALIGNED(Bytes)              __attribute__ ((aligned(Bytes)))
@* LUFAConfig.
@<Header files@>=
/** \file
 *  \brief LUFA Library Configuration Header File
 *
 *  This header file is used to configure LUFA's compile time options,
 *  as an alternative to the compile time constants supplied through
 *  a makefile.
 *
 *  For information on what each token does, refer to the LUFA
 *  manual section "Summary of Compile Tokens".
 */

/* USB Device Mode Driver Related Tokens: */
#define USE_FLASH_DESCRIPTORS
#define FIXED_CONTROL_ENDPOINT_SIZE      8
#define DEVICE_STATE_AS_GPIOR            0
#define FIXED_NUM_CONFIGURATIONS         1
#define INTERRUPT_CONTROL_ENDPOINT

@* Endianness.
@<Header files@>=
typedef uint8_t uint_reg_t;
#define ARCH_HAS_EEPROM_ADDRESS_SPACE
#define ARCH_HAS_FLASH_ADDRESS_SPACE
#define ARCH_HAS_MULTI_ADDRESS_SPACE
#define ARCH_LITTLE_ENDIAN

/* Macros and functions for byte (re-)ordering.
 */

/** Swaps the byte ordering of a 16-bit value at compile-time. Do not use this macro for
 swapping byte orderings
 *  of dynamic values computed at runtime, use \ref SwapEndian_16() instead. The result of
 this macro can be used
 *  inside struct or other variable initializers outside of a function, something that
 is not possible with the
 *  inline function variant.
 *
 *  \hideinitializer
 *
 *  \ingroup Group_ByteSwapping
 *
 *  \param[in] x  16-bit value whose byte ordering is to be swapped.
 *
 *  \return Input value with the byte ordering reversed.
 */
#define SWAPENDIAN_16(x)            (uint16_t)((((x) & 0xFF00) >> 8) | (((x) & 0x00FF) << 8))

/** Swaps the byte ordering of a 32-bit value at compile-time. Do not use this macro for
 swapping byte orderings
 *  of dynamic values computed at runtime- use \ref SwapEndian_32() instead. The result of
 this macro can be used
 *  inside struct or other variable initializers outside of a function, something that is
 not possible with the
 *  inline function variant.
 *
 *  \hideinitializer
 *
 *  \ingroup Group_ByteSwapping
 *
 *  \param[in] x  32-bit value whose byte ordering is to be swapped.
 *
 *  \return Input value with the byte ordering reversed.
 */
#define SWAPENDIAN_32(x) \
   (uint32_t)((((x) & 0xFF000000UL) >> 24UL) | (((x) & 0x00FF0000UL) >> 8UL) | \
   (((x) & 0x0000FF00UL) << 8UL)  | (((x) & 0x000000FFUL) << 24UL))

/** \name Run-time endianness conversion */

/** Performs a conversion between a Little Endian encoded 16-bit piece of data and the
 *  Endianness of the currently selected CPU architecture.
 *
 *  On little endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref LE16_TO_CPU instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define le16_to_cpu(x)           (x)

/** Performs a conversion between a Little Endian encoded 32-bit piece of data and the
 *  Endianness of the currently selected CPU architecture.
 *
 *  On little endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref LE32_TO_CPU instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define le32_to_cpu(x)           (x)

/** Performs a conversion between a Big Endian encoded 16-bit piece of data and the
 *  Endianness of the currently selected CPU architecture.
 *
 *  On big endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref BE16_TO_CPU instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define be16_to_cpu(x)           SwapEndian_16(x)

/** Performs a conversion between a Big Endian encoded 32-bit piece of data and the
 *  Endianness of the currently selected CPU architecture.
 *
 *  On big endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref BE32_TO_CPU instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define be32_to_cpu(x)           SwapEndian_32(x)

/** Performs a conversion on a natively encoded 16-bit piece of data to ensure that it
 *  is in Little Endian format regardless of the currently selected CPU architecture.
 *
 *  On little endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref CPU_TO_LE16 instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define cpu_to_le16(x)           (x)

/** Performs a conversion on a natively encoded 32-bit piece of data to ensure that it
 *  is in Little Endian format regardless of the currently selected CPU architecture.
 *
 *  On little endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref CPU_TO_LE32 instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define cpu_to_le32(x)           (x)

/** Performs a conversion on a natively encoded 16-bit piece of data to ensure that it
 *  is in Big Endian format regardless of the currently selected CPU architecture.
 *
 *  On big endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref CPU_TO_BE16 instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define cpu_to_be16(x)           SwapEndian_16(x)

/** Performs a conversion on a natively encoded 32-bit piece of data to ensure that it
 *  is in Big Endian format regardless of the currently selected CPU architecture.
 *
 *  On big endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for run-time conversion of data - for compile-time endianness
 *        conversion, use \ref CPU_TO_BE32 instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define cpu_to_be32(x)           SwapEndian_32(x)

@*4 Compile-time endianness conversion.

@ Performs a conversion between a Little Endian encoded 16-bit piece of data and the
Endianness of the currently selected CPU architecture.

On little endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run time endianness
conversion, use \ref le16_to_cpu instead.

@<Header files@>=
#define LE16_TO_CPU(x)           (x)

@ Performs a conversion between a Little Endian encoded 32-bit piece of data and the
Endianness of the currently selected CPU architecture.

On little endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run time endianness
      conversion, use \ref le32_to_cpu instead.

@<Header files@>=
#define LE32_TO_CPU(x)           (x)

@ Performs a conversion between a Big Endian encoded 16-bit piece of data and the
Endianness of the currently selected CPU architecture.

On big endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run-time endianness
       conversion, use \ref be16_to_cpu instead.

@<Header files@>=
#define BE16_TO_CPU(x)           SWAPENDIAN_16(x)

@ Performs a conversion between a Big Endian encoded 32-bit piece of data and the
Endianness of the currently selected CPU architecture.

On big endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run-time endianness
       conversion, use \ref be32_to_cpu instead.

@<Header files@>=
#define BE32_TO_CPU(x)           SWAPENDIAN_32(x)

@ Performs a conversion on a natively encoded 16-bit piece of data to ensure that it
is in Little Endian format regardless of the currently selected CPU architecture.

On little endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run-time endianness
      conversion, use \ref cpu_to_le16 instead.

@<Header files@>=
#define CPU_TO_LE16(x)           (x)

@ Performs a conversion on a natively encoded 32-bit piece of data to ensure that it
is in Little Endian format regardless of the currently selected CPU architecture.

On little endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run-time endianness
        conversion, use \ref cpu_to_le32 instead.

@<Header files@>=
#define CPU_TO_LE32(x)           (x)

@ Performs a conversion on a natively encoded 16-bit piece of data to ensure that it
is in Big Endian format regardless of the currently selected CPU architecture.

On big endian architectures, this macro does nothing.

\note This macro is designed for compile-time conversion of data - for run-time endianness
       conversion, use \ref cpu_to_be16 instead.

@<Header files@>=
#define CPU_TO_BE16(x)           SWAPENDIAN_16(x)

/** Performs a conversion on a natively encoded 32-bit piece of data to ensure that it
 *  is in Big Endian format regardless of the currently selected CPU architecture.
 *
 *  On big endian architectures, this macro does nothing.
 *
 *  \note This macro is designed for compile-time conversion of data - for run-time endianness
 *        conversion, use \ref cpu_to_be32 instead.
 *
 *  \ingroup Group_EndianConversion
 *
 *  \param[in] x  Data to perform the endianness conversion on.
 *
 *  \return Endian corrected version of the input value.
 */
#define CPU_TO_BE32(x)           SWAPENDIAN_32(x)

/** Function to reverse the byte ordering of the individual bytes in a 16 bit value.
 *
 *  \ingroup Group_ByteSwapping
 *
 *  \param[in] Word  Word of data whose bytes are to be swapped.
 *
 *  \return Input data with the individual bytes reversed.
 */
inline uint16_t SwapEndian_16(const uint16_t Word) ATTR_WARN_UNUSED_RESULT
  ATTR_CONST ATTR_ALWAYS_INLINE;
inline uint16_t SwapEndian_16(const uint16_t Word)
{
	if (GCC_IS_COMPILE_CONST(Word))
	  return SWAPENDIAN_16(Word);

	uint8_t Temp;

	union
	{
		uint16_t Word;
		uint8_t  Bytes[2];
	} Data;

	Data.Word = Word;

	Temp = Data.Bytes[0];
	Data.Bytes[0] = Data.Bytes[1];
	Data.Bytes[1] = Temp;

	return Data.Word;
}

/** Function to reverse the byte ordering of the individual bytes in a 32 bit value.
 *
 *  \ingroup Group_ByteSwapping
 *
 *  \param[in] DWord  Double word of data whose bytes are to be swapped.
 *
 *  \return Input data with the individual bytes reversed.
 */
inline uint32_t SwapEndian_32(const uint32_t DWord) ATTR_WARN_UNUSED_RESULT
  ATTR_CONST ATTR_ALWAYS_INLINE;
inline uint32_t SwapEndian_32(const uint32_t DWord)
{
	if (GCC_IS_COMPILE_CONST(DWord))
	  return SWAPENDIAN_32(DWord);

	uint8_t Temp;

	union
	{
		uint32_t DWord;
		uint8_t  Bytes[4];
	} Data;

	Data.DWord = DWord;

	Temp = Data.Bytes[0];
	Data.Bytes[0] = Data.Bytes[3];
	Data.Bytes[3] = Temp;

	Temp = Data.Bytes[1];
	Data.Bytes[1] = Data.Bytes[2];
	Data.Bytes[2] = Temp;

	return Data.DWord;
}

/** Function to reverse the byte ordering of the individual bytes in a n byte value.
 *
 *  \ingroup Group_ByteSwapping
 *
 *  \param[in,out] Data    Pointer to a number containing an even number of bytes to be reversed.
 *  \param[in]     Length  Length of the data in bytes.
 *
 *  \return Input data with the individual bytes reversed.
 */
inline void SwapEndian_n(void* const Data, uint8_t Length) ATTR_NON_NULL_PTR_ARG(1);
inline void SwapEndian_n(void* const Data, uint8_t Length)
{
	uint8_t* CurrDataPos = (uint8_t*)Data;

	while (Length > 1)
	{
		uint8_t Temp = *CurrDataPos;
		*CurrDataPos = *(CurrDataPos + Length - 1);
		*(CurrDataPos + Length - 1) = Temp;

		CurrDataPos++;
		Length -= 2;
	}
}

@* Common.
@<Header files@>=
/** Convenience macro to determine the larger of two values.
 *
 *  \attention This macro should only be used with operands that do not have side effects
 from being evaluated
 *             multiple times.
 *
 *  \param[in] x  First value to compare
 *  \param[in] y  First value to compare
 *
 *  \return The larger of the two input parameters
 */
#define MAX(x, y)               (((x) > (y)) ? (x) : (y))

/** Convenience macro to determine the smaller of two values.
 *
 *  \attention This macro should only be used with operands that do not have side effects
 from being evaluated
 *             multiple times.
 *
 *  \param[in] x  First value to compare.
 *  \param[in] y  First value to compare.
 *
 *  \return The smaller of the two input parameters
 */
#define MIN(x, y)               (((x) < (y)) ? (x) : (y))

/** Converts the given input into a string, via the C Preprocessor. This macro puts
 literal quotation
 *  marks around the input, converting the source into a string literal.
 *
 *  \param[in] x  Input to convert into a string literal.
 *
 *  \return String version of the input.
 */
#define STRINGIFY(x)            #x

/** Converts the given input into a string after macro expansion, via the C Preprocessor.
 This macro puts
 *  literal quotation marks around the expanded input, converting the source into a string literal.
 *
 *  \param[in] x  Input to expand and convert into a string literal.
 *
 *  \return String version of the expanded input.
 */
#define STRINGIFY_EXPANDED(x)   STRINGIFY(x)

/** Concatenates the given input into a single token, via the C Preprocessor.
 *
 *  \param[in] x  First item to concatenate.
 *  \param[in] y  Second item to concatenate.
 *
 *  \return Concatenated version of the input.
 */
#define CONCAT(x, y)            x ## y

/** CConcatenates the given input into a single token after macro expansion, via the
 C Preprocessor.
 *
 *  \param[in] x  First item to concatenate.
 *  \param[in] y  Second item to concatenate.
 *
 *  \return Concatenated version of the expanded input.
 */
#define CONCAT_EXPANDED(x, y)   CONCAT(x, y)

/** Function to reverse the individual bits in a byte - i.e. bit 7 is moved to bit 0,
 bit 6 to bit 1,
 *  etc.
 *
 *  \param[in] Byte  Byte of data whose bits are to be reversed.
 *
 *  \return Input data with the individual bits reversed (mirrored).
 */
inline uint8_t BitReverse(uint8_t Byte) ATTR_WARN_UNUSED_RESULT ATTR_CONST;
inline uint8_t BitReverse(uint8_t Byte)
{
	Byte = (((Byte & 0xF0) >> 4) | ((Byte & 0x0F) << 4));
	Byte = (((Byte & 0xCC) >> 2) | ((Byte & 0x33) << 2));
	Byte = (((Byte & 0xAA) >> 1) | ((Byte & 0x55) << 1));

	return Byte;
}

/** Retrieves a mask which contains the current state of the global interrupts for the device. This
 *  value can be stored before altering the global interrupt enable state, before restoring the
 *  flag(s) back to their previous values after a critical section using
 \ref SetGlobalInterruptMask().
 *
 *  \ingroup Group_GlobalInt
 *
 *  \return  Mask containing the current Global Interrupt Enable Mask bit(s).
 */
inline uint_reg_t GetGlobalInterruptMask(void) ATTR_ALWAYS_INLINE ATTR_WARN_UNUSED_RESULT;
inline uint_reg_t GetGlobalInterruptMask(void)
{
	GCC_MEMORY_BARRIER();
	return SREG;
}

/** Sets the global interrupt enable state of the microcontroller to the mask passed
 into the function.
 *  This can be combined with \ref GetGlobalInterruptMask() to save and restore the
 Global Interrupt Enable
 *  Mask bit(s) of the device after a critical section has completed.
 *
 *  \ingroup Group_GlobalInt
 *
 *  \param[in] GlobalIntState  Global Interrupt Enable Mask value to use
 */
inline void SetGlobalInterruptMask(const uint_reg_t GlobalIntState) ATTR_ALWAYS_INLINE;
inline void SetGlobalInterruptMask(const uint_reg_t GlobalIntState)
{
	GCC_MEMORY_BARRIER();

	SREG = GlobalIntState;

	GCC_MEMORY_BARRIER();
}

/** Enables global interrupt handling for the device, allowing interrupts to be handled.
 *
 *  \ingroup Group_GlobalInt
 */
inline void GlobalInterruptEnable(void) ATTR_ALWAYS_INLINE;
inline void GlobalInterruptEnable(void)
{
	GCC_MEMORY_BARRIER();

	sei();

	GCC_MEMORY_BARRIER();
}

/** Disabled global interrupt handling for the device, preventing interrupts from being handled.
 *
 *  \ingroup Group_GlobalInt
 */
inline void GlobalInterruptDisable(void) ATTR_ALWAYS_INLINE;
inline void GlobalInterruptDisable(void)
{
	GCC_MEMORY_BARRIER();

	cli();

	GCC_MEMORY_BARRIER();
}
@* USBMode.
@<Header files@>=
/** USB mode and feature support definitions.
 *
 *  This defines macros indicating the type of USB controller, and its
 *  capabilities.
 */


#define USB_SERIES_4_AVR
#define USB_CAN_BE_DEVICE
@* USBInterrupt AVR8.
@<Header files@>=
/** USB Controller Interrupt definitions for the AVR8 microcontrollers.
 *
 *  This file contains definitions required for the correct handling of low level USB
 service routine interrupts
 *  from the USB controller.
 */

enum USB_Interrupts_t
{
	USB_INT_VBUSTI  = 0,
	USB_INT_WAKEUPI = 2,
	USB_INT_SUSPI   = 3,
	USB_INT_EORSTI  = 4,
	USB_INT_SOFI    = 5,
	USB_INT_RXSTPI  = 6,
};

inline void USB_INT_Enable(const uint8_t Interrupt) ATTR_ALWAYS_INLINE;
inline void USB_INT_Enable(const uint8_t Interrupt)
{
	switch (Interrupt)
	{

		case USB_INT_VBUSTI:
			USBCON |= (1 << VBUSTE);
			break;

		case USB_INT_WAKEUPI:
			UDIEN  |= (1 << WAKEUPE);
			break;
		case USB_INT_SUSPI:
			UDIEN  |= (1 << SUSPE);
			break;
		case USB_INT_EORSTI:
			UDIEN  |= (1 << EORSTE);
			break;
		case USB_INT_SOFI:
			UDIEN  |= (1 << SOFE);
			break;
		case USB_INT_RXSTPI:
			UEIENX |= (1 << RXSTPE);
			break;
		default:
			break;
	}
}

inline void USB_INT_Disable(const uint8_t Interrupt) ATTR_ALWAYS_INLINE;
inline void USB_INT_Disable(const uint8_t Interrupt)
{
	switch (Interrupt)
	{
		case USB_INT_VBUSTI:
			USBCON &= ~(1 << VBUSTE);
			break;
		case USB_INT_WAKEUPI:
			UDIEN  &= ~(1 << WAKEUPE);
			break;
		case USB_INT_SUSPI:
			UDIEN  &= ~(1 << SUSPE);
			break;
		case USB_INT_EORSTI:
			UDIEN  &= ~(1 << EORSTE);
			break;
		case USB_INT_SOFI:
			UDIEN  &= ~(1 << SOFE);
			break;
		case USB_INT_RXSTPI:
			UEIENX &= ~(1 << RXSTPE);
			break;
		default:
			break;
	}
}

inline void USB_INT_Clear(const uint8_t Interrupt) ATTR_ALWAYS_INLINE;
inline void USB_INT_Clear(const uint8_t Interrupt)
{
	switch (Interrupt)
	{
		case USB_INT_VBUSTI:
			USBINT &= ~(1 << VBUSTI);
			break;
		case USB_INT_WAKEUPI:
			UDINT  &= ~(1 << WAKEUPI);
			break;
		case USB_INT_SUSPI:
			UDINT  &= ~(1 << SUSPI);
			break;
		case USB_INT_EORSTI:
			UDINT  &= ~(1 << EORSTI);
			break;
		case USB_INT_SOFI:
			UDINT  &= ~(1 << SOFI);
			break;
		case USB_INT_RXSTPI:
			UEINTX &= ~(1 << RXSTPI);
			break;
		default:
			break;
	}
}

inline bool USB_INT_IsEnabled(const uint8_t Interrupt) ATTR_ALWAYS_INLINE ATTR_WARN_UNUSED_RESULT;
inline bool USB_INT_IsEnabled(const uint8_t Interrupt)
{
	switch (Interrupt)
	{
		case USB_INT_VBUSTI:
			return (USBCON & (1 << VBUSTE));
		case USB_INT_WAKEUPI:
			return (UDIEN  & (1 << WAKEUPE));
		case USB_INT_SUSPI:
			return (UDIEN  & (1 << SUSPE));
		case USB_INT_EORSTI:
			return (UDIEN  & (1 << EORSTE));
		case USB_INT_SOFI:
			return (UDIEN  & (1 << SOFE));
		case USB_INT_RXSTPI:
			return (UEIENX & (1 << RXSTPE));
		default:
			return false;
	}
}

inline bool USB_INT_HasOccurred(const uint8_t Interrupt) ATTR_ALWAYS_INLINE
  ATTR_WARN_UNUSED_RESULT;
inline bool USB_INT_HasOccurred(const uint8_t Interrupt)
{
	switch (Interrupt)
	{
		case USB_INT_VBUSTI:
			return (USBINT & (1 << VBUSTI));
		case USB_INT_WAKEUPI:
			return (UDINT  & (1 << WAKEUPI));
		case USB_INT_SUSPI:
			return (UDINT  & (1 << SUSPI));
		case USB_INT_EORSTI:
			return (UDINT  & (1 << EORSTI));
		case USB_INT_SOFI:
			return (UDINT  & (1 << SOFI));
		case USB_INT_RXSTPI:
			return (UEINTX & (1 << RXSTPI));
		default:
			return false;
	}
}

void USB_INT_ClearAllInterrupts(void);
void USB_INT_DisableAllInterrupts(void);
@* USBController.
USB Controller definitions for general USB controller management.
Functions, macros, variables, enums and types related to the setup and management of the USB
 interface.
@*4 Endpoint Direction Masks.

@ Endpoint direction mask, for masking against endpoint addresses to retrieve the endpoint's
direction for comparing with the \c ENDPOINT_DIR_* masks.
@<Header files@>=
#define ENDPOINT_DIR_MASK                  0x80

@ Endpoint address direction mask for an OUT direction (Host to Device) endpoint. This
may be ORed with
the index of the address within a device to obtain the full endpoint address.
@<Header files@>=
#define ENDPOINT_DIR_OUT                   0x00

@ Endpoint address direction mask for an IN direction (Device to Host) endpoint. This may be
ORed with
the index of the address within a device to obtain the full endpoint address.
@<Header files@>=
#define ENDPOINT_DIR_IN                    0x80

@*4 Pipe Direction Masks.

@ Pipe direction mask, for masking against pipe addresses to retrieve the pipe's
direction for comparing with the \c PIPE_DIR_* masks.
@<Header files@>=
#define PIPE_DIR_MASK                      0x80

@ Endpoint address direction mask for an OUT direction (Host to Device) endpoint. This may
be ORed with
the index of the address within a device to obtain the full endpoint address.
@<Header files@>=
#define PIPE_DIR_OUT                       0x00

@ Endpoint address direction mask for an IN direction (Device to Host) endpoint. This may be
ORed with
the index of the address within a device to obtain the full endpoint address.
@<Header files@>=
#define PIPE_DIR_IN                        0x80

@*4 Endpoint/Pipe Type Masks.

@ Mask for determining the type of an endpoint from an endpoint descriptor. This should then
be compared
with the \c EP_TYPE_* masks to determine the exact type of the endpoint.
@<Header files@>=
#define EP_TYPE_MASK                       0x03

@ Mask for a CONTROL type endpoint or pipe.
Note: see |Group_EndpointManagement| and |Group_PipeManagement| for endpoint/pipe functions.
@<Header files@>=
#define EP_TYPE_CONTROL                    0x00

@ Mask for an ISOCHRONOUS type endpoint or pipe.
Note: see |Group_EndpointManagement| and |Group_PipeManagement| for endpoint/pipe functions.
@<Header files@>=
#define EP_TYPE_ISOCHRONOUS                0x01

@ Mask for a BULK type endpoint or pipe.
Note: see |Group_EndpointManagement| and |Group_PipeManagement| for endpoint/pipe functions.
@<Header files@>=
#define EP_TYPE_BULK                       0x02

@ Mask for an INTERRUPT type endpoint or pipe.
Note: see |Group_EndpointManagement| and |Group_PipeManagement| for endpoint/pipe functions.
@<Header files@>=
#define EP_TYPE_INTERRUPT                  0x03
@* USBController AVR8.
@<Header files@>=
/** USB Controller definitions for the AVR8 microcontrollers.
 *  Functions, macros, variables, enums and types related to the setup and management of
 the USB interface.
 */

#define USB_PLL_PSC                (1 << PINDIV)

/** \name USB Controller Option Masks */

/** Manual PLL control option mask for |USB_Init|. This indicates to the library that
 the user application
 *  will take full responsibility for controlling the AVR's PLL (used to generate the high
 frequency clock
 *  that the USB controller requires) and ensuring that it is locked at the correct frequency
 for USB operations.
 */
#define USB_OPT_MANUAL_PLL                 (1 << 2)

/** Automatic PLL control option mask for |USB_Init|. This indicates to the library that
 the library should
 *  take full responsibility for controlling the AVR's PLL (used to generate the high
 frequency clock
 *  that the USB controller requires) and ensuring that it is locked at the correct frequency
 for USB operations.
 */
#define USB_OPT_AUTO_PLL                   (0 << 2)

/** Constant for the maximum software timeout period of the USB data stream transfer functions
 *  (both control and standard) when in either device or host mode. If the next packet of a stream
 *  is not received or acknowledged within this time period, the stream function will fail.
 *
 *  This value may be overridden in the user project makefile as the value of the
 *  \ref USB_STREAM_TIMEOUT_MS token, and passed to the compiler using the -D switch.
 */
#define USB_STREAM_TIMEOUT_MS       100

@ @<Header files@>=
/** Resets the interface, when already initialized. This will re-enumerate the device if
 already connected
 *  to a host, or re-enumerate an already attached device when in host mode.
 */
void USB_ResetInterface(void);

#define USB_Options (USB_DEVICE_OPT_FULLSPEED | USB_OPT_AUTO_PLL)

inline void USB_Controller_Enable(void) ATTR_ALWAYS_INLINE;
inline void USB_Controller_Enable(void)
{
	USBCON |=  (1 << USBE);
}

inline void USB_Controller_Disable(void) ATTR_ALWAYS_INLINE;
inline void USB_Controller_Disable(void)
{
	USBCON &= ~(1 << USBE);
}

inline void USB_Controller_Reset(void) ATTR_ALWAYS_INLINE;
inline void USB_Controller_Reset(void)
{
	USBCON &= ~(1 << USBE);
	USBCON |=  (1 << USBE);
}
@* Endpoint.
@<Header files@>=
/** Endpoint data read/write definitions.
 *
 *  Functions, macros, variables, enums and types related to data reading and writing from and
 to endpoints.
 */

/* USB Endpoint package management definitions.
 *
 *  Functions, macros, variables, enums and types related to packet management of endpoints.
 */

/** Endpoint management definitions.
 *
 *  Functions, macros and enums related to endpoint management when in USB Device mode. This
 *  contains the endpoint management macros, as well as endpoint interrupt and data
 *  send/receive functions for various data types.
 *
 */

/** Type define for a endpoint table entry, used to configure endpoints in groups via
 *  \ref Endpoint_ConfigureEndpointTable().
 */
typedef struct
{
	uint8_t  Address; /**< Address of the endpoint to configure, or zero if the table
 entry is to be unused. */
	uint16_t Size; /**< Size of the endpoint bank, in bytes. */
	uint8_t  Banks; /**< Number of hardware banks to use for the endpoint. */
        uint8_t  Type; /**< Type of the endpoint, a \c EP_TYPE_* mask. */
} USB_Endpoint_Table_t;

/** Endpoint number mask, for masking against endpoint addresses to retrieve the endpoint's
 *  numerical address in the device.
 */
#define ENDPOINT_EPNUM_MASK                     0x0F

/** Endpoint address for the default control endpoint, which always resides in address 0. This is
 *  defined for convenience to give more readable code when used with the endpoint macros.
 */
#define ENDPOINT_CONTROLEP                      0

@* Endpoint AVR8.
USB Endpoint definitions for the AVR8 microcontrollers.
Endpoint data read/write definitions for the Atmel AVR8 architecture.
Functions, macros, variables, enums and types related to data reading and writing from
and to endpoints.
Endpoint primitive read/write definitions for the Atmel AVR8 architecture.
Functions, macros, variables, enums and types related to data reading and writing of
primitive data types from and to endpoints.
Endpoint packet management definitions for the Atmel AVR8 architecture.
Functions, macros, variables, enums and types related to packet management of endpoints.

@*1 Endpoint management definitions for the Atmel AVR8 architecture.

Functions, macros and enums related to endpoint management. This
module contains the endpoint management macros, as well as endpoint interrupt and data
send/receive functions for various data types.

@<Header files@>=
inline uint8_t Endpoint_BytesToEPSizeMask(const uint16_t Bytes) ATTR_WARN_UNUSED_RESULT
  ATTR_CONST ATTR_ALWAYS_INLINE;
inline uint8_t Endpoint_BytesToEPSizeMask(const uint16_t Bytes)
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

@ @<Header files@>=
void Endpoint_ClearEndpoints(void);
bool Endpoint_ConfigureEndpoint_Prv(const uint8_t Number,
                                    const uint8_t UECFG0XData,
                                    const uint8_t UECFG1XData);

@ Total number of endpoints (including the default control endpoint at address 0) which may
be used in the device. Different USB AVR models support different amounts of endpoints,
this value reflects the maximum number of endpoints for the currently selected AVR model.

@<Header files@>=
#define ENDPOINT_TOTAL_ENDPOINTS 7

@ Enum for the possible error return codes of the |Endpoint_WaitUntilReady| function.

@<Header files@>=
enum Endpoint_WaitUntilReady_ErrorCodes_t
{
  ENDPOINT_READYWAIT_NoError = 0, /* Endpoint is ready for next packet, no error. */
  ENDPOINT_READYWAIT_EndpointStalled = 1, /* The endpoint was stalled during the stream
    transfer by the host or device. */
  ENDPOINT_READYWAIT_DeviceDisconnected = 2, /* Device was disconnected from the host while
                                                   waiting for the endpoint to become ready.
                                                */
  ENDPOINT_READYWAIT_BusSuspended = 3, /* The USB bus has been suspended by the host and
                                          no USB endpoint traffic can occur until the bus
                                          has resumed.
                                       */
  ENDPOINT_READYWAIT_Timeout = 4, /* The host failed to accept or send the next packet
                                      within the software timeout period set by the
                                      |USB_STREAM_TIMEOUT_MS| macro.
                                   */
};

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

@<Header files@>=
inline bool Endpoint_ConfigureEndpoint(const uint8_t Address,
                                             const uint8_t Type,
                                             const uint16_t Size,
                                             const uint8_t Banks) ATTR_ALWAYS_INLINE;
inline bool Endpoint_ConfigureEndpoint(const uint8_t Address,
                                              const uint8_t Type,
                                              const uint16_t Size,
                                              const uint8_t Banks)
{
	uint8_t Number = (Address & ENDPOINT_EPNUM_MASK);

	if (Number >= ENDPOINT_TOTAL_ENDPOINTS)
	  return false;

	return Endpoint_ConfigureEndpoint_Prv(Number,
           ((Type << EPTYPE0) | ((Address & ENDPOINT_DIR_IN) ? (1 << EPDIR) : 0)),
           ((1 << ALLOC) | ((Banks > 1) ? (1 << EPBK0) : 0) | Endpoint_BytesToEPSizeMask(Size)));
}

@ Indicates the number of bytes currently stored in the current endpoint's selected bank.
Returns total number of bytes in the currently selected Endpoint's FIFO buffer.

@<Header files@>=
inline uint16_t Endpoint_BytesInEndpoint(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint16_t Endpoint_BytesInEndpoint(void)
{
		return (((uint16_t)UEBCHX << 8) | UEBCLX);
}

@ Determines the currently selected endpoint's direction.
Returns the currently selected endpoint's direction, as a \.{ENDPOINT\_DIR\_*} mask.

@<Header files@>=
inline uint8_t Endpoint_GetEndpointDirection(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint8_t Endpoint_GetEndpointDirection(void)
{
	return (UECFG0X & (1 << EPDIR)) ? ENDPOINT_DIR_IN : ENDPOINT_DIR_OUT;
}

@ Get the endpoint address of the currently selected endpoint. This is typically used to save
the currently selected endpoint so that it can be restored after another endpoint has been
manipulated.

Returns index of the currently selected endpoint.

@<Header files@>=
inline uint8_t Endpoint_GetCurrentEndpoint(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint8_t Endpoint_GetCurrentEndpoint(void)
{
	return ((UENUM & ENDPOINT_EPNUM_MASK) | Endpoint_GetEndpointDirection());
}

@ Selects the given endpoint address.

Any endpoint operations which do not require the endpoint address to be indicated will
operate on the currently selected endpoint.

|Address| is endpoint address to select.

@<Header files@>=
inline void Endpoint_SelectEndpoint(const uint8_t Address) ATTR_ALWAYS_INLINE;
inline void Endpoint_SelectEndpoint(const uint8_t Address)
{
		UENUM = (Address & ENDPOINT_EPNUM_MASK);
}

@ Resets the endpoint bank FIFO. This clears all the endpoint banks and resets the USB
controller's data In and Out pointers to the bank's contents.

|Address| is endpoint address whose FIFO buffers are to be reset.

@<Header files@>=
inline void Endpoint_ResetEndpoint(const uint8_t Address) ATTR_ALWAYS_INLINE;
inline void Endpoint_ResetEndpoint(const uint8_t Address)
{
	UERST = (1 << (Address & ENDPOINT_EPNUM_MASK));
	UERST = 0;
}

@ Enables the currently selected endpoint so that data can be sent and received through it to
and from a host.

Note, that endpoints must first be configured properly via |Endpoint_ConfigureEndpoint|.

@<Header files@>=
inline void Endpoint_EnableEndpoint(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_EnableEndpoint(void)
{
	UECONX |= (1 << EPEN);
}

@ Disables the currently selected endpoint so that data cannot be sent and received through it
to and from a host.

@<Header files@>=
inline void Endpoint_DisableEndpoint(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_DisableEndpoint(void)
{
	UECONX &= ~(1 << EPEN);
}

@ Determines if the currently selected endpoint is enabled, but not necessarily configured.

Returns true if the currently selected endpoint is enabled, false otherwise.

@<Header files@>=
inline bool Endpoint_IsEnabled(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsEnabled(void)
{
	return ((UECONX & (1 << EPEN)) ? true : false);
}

/** Retrieves the number of busy banks in the currently selected endpoint, which have been
 queued for
 *  transmission via the \ref Endpoint_ClearIN() command, or are awaiting acknowledgment via the
 *  \ref Endpoint_ClearOUT() command.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \return Total number of busy banks in the selected endpoint.
 */
inline uint8_t Endpoint_GetBusyBanks(void) ATTR_ALWAYS_INLINE ATTR_WARN_UNUSED_RESULT;
inline uint8_t Endpoint_GetBusyBanks(void)
{
	return (UESTA0X & (0x03 << NBUSYBK0));
}

/** Aborts all pending IN transactions on the currently selected endpoint, once the bank
 *  has been queued for transmission to the host via \ref Endpoint_ClearIN(). This function
 *  will terminate all queued transactions, resetting the endpoint banks ready for a new
 *  packet.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 */
inline void Endpoint_AbortPendingIN(void)
{
	while (Endpoint_GetBusyBanks() != 0)
	{
		UEINTX |= (1 << RXOUTI);
		while (UEINTX & (1 << RXOUTI));
	}
}

/** Determines if the currently selected endpoint may be read from (if data is waiting in
 the endpoint
 *  bank and the endpoint is an OUT direction, or if the bank is not yet full if the endpoint
 is an IN
 *  direction). This function will return false if an error has occurred in the endpoint, if
 the endpoint
 *  is an OUT direction and no packet (or an empty packet) has been received, or if the endpoint
 is an IN
 *  direction and the endpoint bank is full.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \return Boolean \c true if the currently selected endpoint may be read from or written to,
 depending
 *          on its direction.
 */
inline bool Endpoint_IsReadWriteAllowed(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsReadWriteAllowed(void)
{
	return ((UEINTX & (1 << RWAL)) ? true : false);
}

/** Determines if the currently selected endpoint is configured.
 *
 *  \return Boolean \c true if the currently selected endpoint has been configured, \c false
 otherwise.
 */
inline bool Endpoint_IsConfigured(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsConfigured(void)
{
	return ((UESTA0X & (1 << CFGOK)) ? true : false);
}

/** Returns a mask indicating which INTERRUPT type endpoints have interrupted - i.e. their
 *  interrupt duration has elapsed. Which endpoints have interrupted can be determined by
 *  masking the return value against <tt>(1 << <i>{Endpoint Number}</i>)</tt>.
 *
 *  \return Mask whose bits indicate which endpoints have interrupted.
 */
inline uint8_t Endpoint_GetEndpointInterrupts(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint8_t Endpoint_GetEndpointInterrupts(void)
{
	return UEINT;
}

/** Determines if the specified endpoint number has interrupted (valid only for INTERRUPT type
 *  endpoints).
 *
 *  \param[in] Address  Address of the endpoint whose interrupt flag should be tested.
 *
 *  \return Boolean \c true if the specified endpoint has interrupted, \c false otherwise.
 */
inline bool Endpoint_HasEndpointInterrupted(const uint8_t Address) ATTR_WARN_UNUSED_RESULT
  ATTR_ALWAYS_INLINE;
inline bool Endpoint_HasEndpointInterrupted(const uint8_t Address)
{
  return ((Endpoint_GetEndpointInterrupts() & (1 << (Address & ENDPOINT_EPNUM_MASK))) ?
    true : false);
}

/** Determines if the selected IN endpoint is ready for a new packet to be sent to the host.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \return Boolean \c true if the current endpoint is ready for an IN packet, \c false otherwise.
 */
inline bool Endpoint_IsINReady(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsINReady(void)
{
	return ((UEINTX & (1 << TXINI)) ? true : false);
}

/** Determines if the selected OUT endpoint has received new packet from the host.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \return Boolean \c true if current endpoint is has received an OUT packet, \c false otherwise.
 */
inline bool Endpoint_IsOUTReceived(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsOUTReceived(void)
{
	return ((UEINTX & (1 << RXOUTI)) ? true : false);
}

/** Determines if the current CONTROL type endpoint has received a SETUP packet.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \return Boolean \c true if the selected endpoint has received a SETUP packet, \c false
 otherwise.
 */
inline bool Endpoint_IsSETUPReceived(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsSETUPReceived(void)
{
	return ((UEINTX & (1 << RXSTPI)) ? true : false);
}

/** Clears a received SETUP packet on the currently selected CONTROL type endpoint, freeing up the
 *  endpoint for the next packet.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \note This is not applicable for non CONTROL type endpoints.
 */
inline void Endpoint_ClearSETUP(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_ClearSETUP(void)
{
	UEINTX &= ~(1 << RXSTPI);
}

/** Sends an IN packet to the host on the currently selected endpoint, freeing up the endpoint
 for the
 *  next packet and switching to the alternative endpoint bank if double banked.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 */
inline void Endpoint_ClearIN(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_ClearIN(void)
{
	UEINTX &= ~((1 << TXINI) | (1 << FIFOCON));
}

/** Acknowledges an OUT packet to the host on the currently selected endpoint, freeing up
 the endpoint
 *  for the next packet and switching to the alternative endpoint bank if double banked.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 */
inline void Endpoint_ClearOUT(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_ClearOUT(void)
{
		UEINTX &= ~((1 << RXOUTI) | (1 << FIFOCON));
}

/** Stalls the current endpoint, indicating to the host that a logical problem occurred with the
 *  indicated endpoint and that the current transfer sequence should be aborted. This provides a
 *  way for devices to indicate invalid commands to the host so that the current transfer can be
 *  aborted and the host can begin its own recovery sequence.
 *
 *  The currently selected endpoint remains stalled until either the \ref Endpoint_ClearStall()
 macro
 *  is called, or the host issues a CLEAR FEATURE request to the device for the currently selected
 *  endpoint.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 */
inline void Endpoint_StallTransaction(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_StallTransaction(void)
{
	UECONX |= (1 << STALLRQ);
}

/** Clears the STALL condition on the currently selected endpoint.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 */
inline void Endpoint_ClearStall(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_ClearStall(void)
{
	UECONX |= (1 << STALLRQC);
}

/** Determines if the currently selected endpoint is stalled, \c false otherwise.
 *
 *  \ingroup Group_EndpointPacketManagement_AVR8
 *
 *  \return Boolean \c true if the currently selected endpoint is stalled, \c false otherwise.
 */
inline bool Endpoint_IsStalled(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool Endpoint_IsStalled(void)
{
	return ((UECONX & (1 << STALLRQ)) ? true : false);
}

/** Resets the data toggle of the currently selected endpoint. */
inline void Endpoint_ResetDataToggle(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_ResetDataToggle(void)
{
	UECONX |= (1 << RSTDT);
}

/** Sets the direction of the currently selected endpoint.
 *
 *  \param[in] DirectionMask  New endpoint direction, as a \c ENDPOINT_DIR_* mask.
 */
inline void Endpoint_SetEndpointDirection(const uint8_t DirectionMask) ATTR_ALWAYS_INLINE;
inline void Endpoint_SetEndpointDirection(const uint8_t DirectionMask)
{
	UECFG0X = ((UECFG0X & ~(1 << EPDIR)) | (DirectionMask ? (1 << EPDIR) : 0));
}

/** Reads one byte from the currently selected endpoint's bank, for OUT direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \return Next byte in the currently selected endpoint's FIFO buffer.
 */
inline uint8_t Endpoint_Read_8(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint8_t Endpoint_Read_8(void)
{
	return UEDATX;
}

/** Writes one byte to the currently selected endpoint's bank, for IN direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \param[in] Data  Data to write into the the currently selected endpoint's FIFO buffer.
 */
inline void Endpoint_Write_8(const uint8_t Data) ATTR_ALWAYS_INLINE;
inline void Endpoint_Write_8(const uint8_t Data)
{
	UEDATX = Data;
}

/** Discards one byte from the currently selected endpoint's bank, for OUT direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 */
inline void Endpoint_Discard_8(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_Discard_8(void)
{
	uint8_t Dummy;

	Dummy = UEDATX;

	(void)Dummy;
}

/** Reads two bytes from the currently selected endpoint's bank in little endian format, for OUT
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \return Next two bytes in the currently selected endpoint's FIFO buffer.
 */
inline uint16_t Endpoint_Read_16_LE(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint16_t Endpoint_Read_16_LE(void)
{
	union
	{
		uint16_t Value;
		uint8_t  Bytes[2];
	} Data;

	Data.Bytes[0] = UEDATX;
	Data.Bytes[1] = UEDATX;

	return Data.Value;
}

/** Reads two bytes from the currently selected endpoint's bank in big endian format, for OUT
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \return Next two bytes in the currently selected endpoint's FIFO buffer.
 */
inline uint16_t Endpoint_Read_16_BE(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint16_t Endpoint_Read_16_BE(void)
{
	union
	{
		uint16_t Value;
		uint8_t  Bytes[2];
	} Data;

	Data.Bytes[1] = UEDATX;
	Data.Bytes[0] = UEDATX;

	return Data.Value;
}

/** Writes two bytes to the currently selected endpoint's bank in little endian format, for IN
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \param[in] Data  Data to write to the currently selected endpoint's FIFO buffer.
 */
inline void Endpoint_Write_16_LE(const uint16_t Data) ATTR_ALWAYS_INLINE;
inline void Endpoint_Write_16_LE(const uint16_t Data)
{
	UEDATX = (Data & 0xFF);
	UEDATX = (Data >> 8);
}

/** Writes two bytes to the currently selected endpoint's bank in big endian format, for IN
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \param[in] Data  Data to write to the currently selected endpoint's FIFO buffer.
 */
inline void Endpoint_Write_16_BE(const uint16_t Data) ATTR_ALWAYS_INLINE;
inline void Endpoint_Write_16_BE(const uint16_t Data)
{
	UEDATX = (Data >> 8);
	UEDATX = (Data & 0xFF);
}

/** Discards two bytes from the currently selected endpoint's bank, for OUT direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 */
inline void Endpoint_Discard_16(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_Discard_16(void)
{
	uint8_t Dummy;

	Dummy = UEDATX;
	Dummy = UEDATX;

	(void)Dummy;
}

/** Reads four bytes from the currently selected endpoint's bank in little endian format, for OUT
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \return Next four bytes in the currently selected endpoint's FIFO buffer.
 */
inline uint32_t Endpoint_Read_32_LE(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint32_t Endpoint_Read_32_LE(void)
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

/** Reads four bytes from the currently selected endpoint's bank in big endian format, for OUT
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \return Next four bytes in the currently selected endpoint's FIFO buffer.
 */
inline uint32_t Endpoint_Read_32_BE(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline uint32_t Endpoint_Read_32_BE(void)
{
	union
	{
		uint32_t Value;
		uint8_t  Bytes[4];
	} Data;

	Data.Bytes[3] = UEDATX;
	Data.Bytes[2] = UEDATX;
	Data.Bytes[1] = UEDATX;
	Data.Bytes[0] = UEDATX;

	return Data.Value;
}

/** Writes four bytes to the currently selected endpoint's bank in little endian format, for IN
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \param[in] Data  Data to write to the currently selected endpoint's FIFO buffer.
 */
inline void Endpoint_Write_32_LE(const uint32_t Data) ATTR_ALWAYS_INLINE;
inline void Endpoint_Write_32_LE(const uint32_t Data)
{
	UEDATX = (Data &  0xFF);
	UEDATX = (Data >> 8);
	UEDATX = (Data >> 16);
	UEDATX = (Data >> 24);
}

/** Writes four bytes to the currently selected endpoint's bank in big endian format, for IN
 *  direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 *
 *  \param[in] Data  Data to write to the currently selected endpoint's FIFO buffer.
 */
inline void Endpoint_Write_32_BE(const uint32_t Data) ATTR_ALWAYS_INLINE;
inline void Endpoint_Write_32_BE(const uint32_t Data)
{
	UEDATX = (Data >> 24);
	UEDATX = (Data >> 16);
	UEDATX = (Data >> 8);
	UEDATX = (Data &  0xFF);
}

/** Discards four bytes from the currently selected endpoint's bank, for OUT direction endpoints.
 *
 *  \ingroup Group_EndpointPrimitiveRW_AVR8
 */
inline void Endpoint_Discard_32(void) ATTR_ALWAYS_INLINE;
inline void Endpoint_Discard_32(void)
{
	uint8_t Dummy;

	Dummy = UEDATX;
	Dummy = UEDATX;
	Dummy = UEDATX;
	Dummy = UEDATX;

	(void)Dummy;
}

/** Global indicating the maximum packet size of the default control endpoint located at address
 *  0 in the device. This value is set to the value indicated in the device descriptor in the user
 *  project once the USB interface is initialized into device mode.
 *
 *  If space is an issue, it is possible to fix this to a static value by defining the control
 *  endpoint size in the \c FIXED_CONTROL_ENDPOINT_SIZE token passed to the compiler in the
 makefile
 *  via the -D switch. When a fixed control endpoint size is used, the size is no longer
 dynamically
 *  read from the descriptors at runtime and instead fixed to the given value. When used, it is
 *  important that the descriptor control endpoint size value matches the size given as the
 *  \c FIXED_CONTROL_ENDPOINT_SIZE token - it is recommended that the
 \c FIXED_CONTROL_ENDPOINT_SIZE token
 *  be used in the device descriptors to ensure this.
 *
 *  \attention This variable should be treated as read-only in the user application, and never
 manually
 *             changed in value.
 */

#define USB_Device_ControlEndpointSize FIXED_CONTROL_ENDPOINT_SIZE

/** Configures a table of endpoint descriptions, in sequence. This function can be used to
 configure multiple
 *  endpoints at the same time.
 *
 *  \note Endpoints with a zero address will be ignored, thus this function cannot be used
 to configure the
 *        control endpoint.
 *
 *  \param[in] Table    Pointer to a table of endpoint descriptions.
 *  \param[in] Entries  Number of entries in the endpoint table to configure.
 *
 *  \return Boolean \c true if all endpoints configured successfully, \c false otherwise.
 */
bool Endpoint_ConfigureEndpointTable(const USB_Endpoint_Table_t* const Table,
                                     const uint8_t Entries);

/** Completes the status stage of a control transfer on a CONTROL type endpoint automatically,
 *  with respect to the data direction. This is a convenience function which can be used to
 *  simplify user control request handling.
 *
 *  \note This routine should not be called on non CONTROL type endpoints.
 */
void Endpoint_ClearStatusStage(void);

/** Spin-loops until the currently selected non-control endpoint is ready for the next packet
 of data
 *  to be read or written to it.
 *
 *  \note This routine should not be called on CONTROL type endpoints.
 *
 *  \ingroup Group_EndpointRW_AVR8
 *
 *  \return A value from the \ref Endpoint_WaitUntilReady_ErrorCodes_t enum.
 */
uint8_t Endpoint_WaitUntilReady(void);

@* Device.
@<Header files@>=
/** Common USB Device definitions for all architectures.
 */

/** USB Device management definitions for USB device mode.
 *
 *  USB Device mode related definitions common to all architectures. This contains
 definitions which
 *  are used when the USB controller is initialized in device mode.
 *
 */

/** Enum for the various states of the USB Device state machine. Only some states are
 *  implemented in the LUFA library - other states are left to the user to implement.
 *
 *  For information on each possible USB device state, refer to the USB 2.0 specification.
 *
 *  \see \ref USB_DeviceState, which stores the current device state machine state.
 */
enum USB_Device_States_t
{
  DEVICE_STATE_Unattached = 0, /* Internally implemented by the library. This state indicates
                                *   that the device is not currently connected to a host.
                                */
  DEVICE_STATE_Powered = 1, /* Internally implemented by the library. This state indicates
                       *   that the device is connected to a host, but enumeration has not
                        *   yet begun.
                          */
  DEVICE_STATE_Default = 2, /* Internally implemented by the library. This state indicates
                             *   that the device's USB bus has been reset by the host and it is
                             *   now waiting for the host to begin the enumeration process.
                             */
  DEVICE_STATE_Addressed = 3, /* Internally implemented by the library. This state indicates
                      *   that the device has been addressed by the USB Host, but is not
                      *   yet configured.
                      */
  DEVICE_STATE_Configured = 4, /* May be implemented by the user project. This state indicates
                                *   that the device has been enumerated by the host and is ready
                                *   for USB communications to begin.
                                */
  DEVICE_STATE_Suspended = 5, /* May be implemented by the user project. This state indicates
                              *   that the USB bus has been suspended by the host, and the device
                              *   should power down to a minimal power level until the bus is
                              *   resumed.
                              */
};

/** Function to retrieve a given descriptor's size and memory location from the given
 descriptor type value,
 *  index and language ID. This function MUST be overridden in the user application
 (added with full, identical
 *  prototype and name so that the library can call it to retrieve descriptor data.
 *
 *  \param[in] wValue                  The type of the descriptor to retrieve in the upper
 byte, and the index in the
 *                                     lower byte (when more than one descriptor of the given
 type exists, such as the
 *                                     case of string descriptors). The type may be one of
 the standard types defined
 *                                     in the DescriptorTypes_t enum, or may be a
 class-specific descriptor type value.
 *  \param[in] wIndex                  The language ID of the string to return if the
 \c wValue type indicates
 *                                     \ref DTYPE_String, otherwise zero for standard
 descriptors, or as defined in a
 *                                     class-specific standards.
 *  \param[out] DescriptorAddress      Pointer to the descriptor in memory. This should be
 set by the routine to
 *                                     the address of the descriptor.
 *  \param[out] DescriptorMemorySpace  A value from the
 \ref USB_DescriptorMemorySpaces_t enum to indicate the memory
 *                                     space in which the descriptor is stored.
 This parameter does not exist when one
 *                                     of the \c USE_*_DESCRIPTORS compile time options is used,
 or on architectures which
 *                                     use a unified address space.
 *
 *  \note By default, the library expects all descriptors to be located in flash memory via
 the \c PROGMEM attribute.
 *        If descriptors should be located in RAM or EEPROM instead (to speed up access in
 the case of RAM, or to
 *        allow the descriptors to be changed dynamically at runtime) either the
 \c USE_RAM_DESCRIPTORS or the
 *        \c USE_EEPROM_DESCRIPTORS tokens may be defined in the project makefile and
 passed to the compiler by the -D
 *        switch.
 *
 *  \return Size in bytes of the descriptor if it exists, zero or \ref NO_DESCRIPTOR otherwise.
 */
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
                                    const uint16_t wIndex,
                                    const void** const DescriptorAddress
                                    ) ATTR_WARN_UNUSED_RESULT ATTR_NON_NULL_PTR_ARG(3);
@* Device AVR8.
@<Header files@>=
/** USB Device definitions for the AVR8 microcontrollers.
 */

/** USB Device definitions for the AVR8 microcontrollers.
 *
 *  Architecture specific USB Device definitions for the Atmel 8-bit AVR microcontrollers.
 *
 */

@*4 USB Device Mode Option Masks.

@ Mask for the Options parameter of the |USB_Init| function. This indicates that the
USB interface should be initialized in low speed (1.5Mb/s) mode.

\note Low Speed mode is not available on all USB AVR models.
        \n

\note Restrictions apply on the number, size and type of endpoints which can be used
        when running in low speed mode - please refer to the USB 2.0 specification.

@<Header files@>=
#define USB_DEVICE_OPT_LOWSPEED            (1 << 0)

@ Mask for the Options parameter of the |USB_Init| function. This indicates that the
USB interface should be initialized in full speed (12Mb/s) mode.
@<Header files@>=
#define USB_DEVICE_OPT_FULLSPEED               (0 << 0)

@ String descriptor index for the device's unique serial number string descriptor within
 the device.
This unique serial number is used by the host to associate resources to the device (such as
 drivers or COM port
number allocations) to a device regardless of the port it is plugged in to on the host. Some
 microcontrollers contain
a unique serial number internally, and setting the device descriptors serial number string index
 to this value
will cause it to use the internal serial number.

On unsupported devices, this will evaluate to \ref NO_DESCRIPTOR and so will force the host to
 create a pseudo-serial
number for the device.

@<Header files@>=
#define USE_INTERNAL_SERIAL            0xDC

@ Length of the device's unique internal serial number, in bits, if present on the selected
 microcontroller
model.

@<Header files@>=
#define INTERNAL_SERIAL_LENGTH_BITS    80

@ Start address of the internal serial number, in the appropriate address space, if present on
 the selected microcontroller
model.

@<Header files@>=
#define INTERNAL_SERIAL_START_ADDRESS  0x0E

@ Returns the current USB frame number, when in device mode. Every millisecond the USB bus
 is active (i.e. enumerated to a host)
the frame number is incremented by one.

\return Current USB frame number from the USB controller.

@<Header files@>=
inline uint16_t USB_Device_GetFrameNumber(void) ATTR_ALWAYS_INLINE ATTR_WARN_UNUSED_RESULT;
inline uint16_t USB_Device_GetFrameNumber(void)
{
	return UDFNUM;
}

/* Enables the device mode Start Of Frame events. When enabled, this causes the
  \ref EVENT_USB_Device_StartOfFrame() event to fire once per millisecond, synchronized to the
 USB bus,
  at the start of each USB frame when enumerated in device mode.

  \note This function is not available when the \c NO_SOF_EVENTS compile time token is defined.
*/
inline void USB_Device_EnableSOFEvents(void) ATTR_ALWAYS_INLINE;
inline void USB_Device_EnableSOFEvents(void)
{
	USB_INT_Enable(USB_INT_SOFI);
}

/* Disables the device mode Start Of Frame events. When disabled, this stops the firing of the
  \ref EVENT_USB_Device_StartOfFrame() event when enumerated in device mode.

  \note This function is not available when the \c NO_SOF_EVENTS compile time token is defined.
*/
inline void USB_Device_DisableSOFEvents(void) ATTR_ALWAYS_INLINE;
inline void USB_Device_DisableSOFEvents(void)
{
	USB_INT_Disable(USB_INT_SOFI);
}

inline void USB_Device_GetSerialString(uint16_t* const UnicodeString) ATTR_NON_NULL_PTR_ARG(1);
inline void USB_Device_GetSerialString(uint16_t* const UnicodeString)
{
	uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
	GlobalInterruptDisable();

	uint8_t SigReadAddress = INTERNAL_SERIAL_START_ADDRESS;

  for (uint8_t SerialCharNum = 0; SerialCharNum < (INTERNAL_SERIAL_LENGTH_BITS / 4);
    SerialCharNum++) {
		uint8_t SerialByte = boot_signature_byte_get(SigReadAddress);

		if (SerialCharNum & 0x01) {
			SerialByte >>= 4;
			SigReadAddress++;
		}

		SerialByte &= 0x0F;

		UnicodeString[SerialCharNum] = cpu_to_le16((SerialByte >= 10) ?
		   (('A' - 10) + SerialByte) : ('0' + SerialByte));
	}

	SetGlobalInterruptMask(CurrentGlobalInt);
}
@* StdRequestType.
@<Header files@>=
/** USB control endpoint request definitions.
 */

/** USB control endpoint request definitions.
 *
 *  This module contains definitions for the various control request parameters, so that
 the request
 *  details (such as data direction, request recipient, etc.) can be extracted via masking.
 */

/** Mask for the request type parameter, to indicate the direction of the request data
 (Host to Device
 *  or Device to Host). The result of this mask should then be compared to the request
 direction masks.
 *
 *  \see \c REQDIR_* macros for masks indicating the request data direction.
 */
#define CONTROL_REQTYPE_DIRECTION  0x80

/** Mask for the request type parameter, to indicate the type of request (Device, Class or Vendor
 *  Specific). The result of this mask should then be compared to the request type masks.
 *
 *  \see \c REQTYPE_* macros for masks indicating the request type.
 */
#define CONTROL_REQTYPE_TYPE       0x60

/** Mask for the request type parameter, to indicate the recipient of the request (Device,
 Interface
 *  Endpoint or Other). The result of this mask should then be compared to the request recipient
 *  masks.
 *
 *  \see \c REQREC_* macros for masks indicating the request recipient.
 */
#define CONTROL_REQTYPE_RECIPIENT  0x1F

/** \name Control Request Data Direction Masks */

/** Request data direction mask, indicating that the request data will flow from host to device.
 *
 *  \see \ref CONTROL_REQTYPE_DIRECTION macro.
 */
#define REQDIR_HOSTTODEVICE        (0 << 7)

/** Request data direction mask, indicating that the request data will flow from device to host.
 *
 *  \see \ref CONTROL_REQTYPE_DIRECTION macro.
 */
#define REQDIR_DEVICETOHOST        (1 << 7)

/** \name Control Request Type Masks */

/** Request type mask, indicating that the request is a standard request.
 *
 *  \see \ref CONTROL_REQTYPE_TYPE macro.
 */
#define REQTYPE_STANDARD           (0 << 5)

/** Request type mask, indicating that the request is a class-specific request.
 *
 *  \see \ref CONTROL_REQTYPE_TYPE macro.
 */
#define REQTYPE_CLASS              (1 << 5)

/** Request type mask, indicating that the request is a vendor specific request.
 *
 *  \see \ref CONTROL_REQTYPE_TYPE macro.
 */
#define REQTYPE_VENDOR             (2 << 5)

/** \name Control Request Recipient Masks */

/** Request recipient mask, indicating that the request is to be issued to the device as a whole.
 *
 *  \see \ref CONTROL_REQTYPE_RECIPIENT macro.
 */
#define REQREC_DEVICE              (0 << 0)

/** Request recipient mask, indicating that the request is to be issued to an interface in the
 *  currently selected configuration.
 *
 *  \see \ref CONTROL_REQTYPE_RECIPIENT macro.
 */
#define REQREC_INTERFACE           (1 << 0)

/** Request recipient mask, indicating that the request is to be issued to an endpoint in the
 *  currently selected configuration.
 *
 *  \see \ref CONTROL_REQTYPE_RECIPIENT macro.
 */
#define REQREC_ENDPOINT            (2 << 0)

/** Request recipient mask, indicating that the request is to be issued to an unspecified element
 *  in the currently selected configuration.
 *
 *  \see \ref CONTROL_REQTYPE_RECIPIENT macro.
 */
#define REQREC_OTHER               (3 << 0)

/** \brief Standard USB Control Request
 *
 *  Type define for a standard USB control request.
 *
 *  \see The USB 2.0 specification for more information on standard control requests.
 */
typedef struct
{
	uint8_t  bmRequestType; /**< Type of the request. */
	uint8_t  bRequest; /**< Request command code. */
	uint16_t wValue; /**< wValue parameter of the request. */
	uint16_t wIndex; /**< wIndex parameter of the request. */
	uint16_t wLength; /**< Length of the data to transfer in bytes. */
} ATTR_PACKED USB_Request_Header_t;

/** Enumeration for the various standard request commands. These commands are applicable when the
 *  request type is \ref REQTYPE_STANDARD (with the exception of \ref REQ_GetDescriptor, which is
 always
 *  handled regardless of the request type value).
 *
 *  \see Chapter 9 of the USB 2.0 Specification.
 */
enum USB_Control_Request_t
{
  REQ_GetStatus = 0, /* Implemented in the library for device and endpoint recipients. Passed
	             *   to the user application for other recipients via the
	             *   \ref EVENT_USB_Device_ControlRequest() event when received in
	             *   device mode. */
  REQ_ClearFeature = 1, /* Implemented in the library for device and endpoint recipients. Passed
                          *   to the user application for other recipients via the
                         *   \ref EVENT_USB_Device_ControlRequest() event when received in
                         *   device mode. */
  REQ_SetFeature = 3, /**< Implemented in the library for device and endpoint recipients. Passed
                        *   to the user application for other recipients via the
                        *   \ref EVENT_USB_Device_ControlRequest() event when received in
                        *   device mode. */
  REQ_SetAddress = 5, /* Implemented in the library for the device recipient. Passed
                       *   to the user application for other recipients via the
                       *   \ref EVENT_USB_Device_ControlRequest() event when received in
                       *   device mode. */
  REQ_GetDescriptor = 6, /* Implemented in the library for device and interface recipients.
 Passed to the
                          *   user application for other recipients via the
                          *   \ref EVENT_USB_Device_ControlRequest() event when received in
                          *   device mode. */
  REQ_SetDescriptor = 7, /**< Not implemented in the library, passed to the user application
                         *   via the \ref EVENT_USB_Device_ControlRequest() event when received in
                        *   device mode. */
  REQ_GetConfiguration = 8, /**< Implemented in the library for the device recipient. Passed
                             *   to the user application for other recipients via the
                             *   \ref EVENT_USB_Device_ControlRequest() event when received in
                             *   device mode. */
  REQ_SetConfiguration = 9, /**< Implemented in the library for the device recipient. Passed
                             *   to the user application for other recipients via the
                             *   \ref EVENT_USB_Device_ControlRequest() event when received in
                             *   device mode. */
  REQ_GetInterface = 10, /**< Not implemented in the library, passed to the user application
                         *   via the \ref EVENT_USB_Device_ControlRequest() event when received in
                         *   device mode. */
  REQ_SetInterface = 11, /* Not implemented in the library, passed to the user application
                          *   via the \ref EVENT_USB_Device_ControlRequest() event when received in
                          *   device mode. */
  REQ_SynchFrame = 12, /* Not implemented in the library, passed to the user application
                       *   via the \ref EVENT_USB_Device_ControlRequest() event when received in
                       *   device mode. */
};

/** Feature Selector values for Set Feature and Clear Feature standard control requests
 directed to the device, interface
 *  and endpoint recipients.
 */
enum USB_Feature_Selectors_t
{
  FEATURE_SEL_EndpointHalt = 0x00, /* Feature selector for Clear Feature or Set Feature
 commands. When
                       *   used in a Set Feature or Clear Feature request this indicates that an
                      *   endpoint (whose address is given elsewhere in the request) should have
                      *   its stall condition changed.
                      */
  FEATURE_SEL_DeviceRemoteWakeup = 0x01, /* Feature selector for Device level Remote Wakeup
 enable set or clear.
                     *   This feature can be controlled by the host on devices which indicate
                     *   remote wakeup support in their descriptors to selectively disable or
                     *   enable remote wakeup.
                     */
  FEATURE_SEL_TestMode = 0x02, /* Feature selector for Test Mode features, used to test
 the USB controller
                                *   to check for incorrect operation.
                               */
};

#define FEATURE_SELFPOWERED_ENABLED     (1 << 0)
#define FEATURE_REMOTE_WAKEUP_ENABLED   (1 << 1)
@* DeviceStandardReq.
@<Header files@>=
/** USB device standard request management.
 *
This contains the function prototypes necessary for the processing of incoming standard
 control requests
 *  when the library is in USB device mode.
 */

/** Enum for the possible descriptor memory spaces, for the \c MemoryAddressSpace parameter of the
 *  \ref CALLBACK_USB_GetDescriptor() function. This can be used when none of the
 \c USE_*_DESCRIPTORS
 *  compile time options are used, to indicate in which memory space the descriptor is stored.
 *
 *  \ingroup Group_Device
 */
enum USB_DescriptorMemorySpaces_t
{
  MEMSPACE_FLASH    = 0, /**< Indicates the requested descriptor is located in FLASH memory. */
  MEMSPACE_EEPROM   = 1, /**< Indicates the requested descriptor is located in EEPROM memory. */
  MEMSPACE_RAM      = 2, /**< Indicates the requested descriptor is located in RAM memory. */
};

/** Indicates the currently set configuration number of the device. USB devices may have several
 *  different configurations which the host can select between; this indicates the currently
 selected
 *  value, or 0 if no configuration has been selected.
 *
 *  \attention This variable should be treated as read-only in the user application, and never
 manually
 *             changed in value.
 *
 *  \ingroup Group_Device
 */
uint8_t USB_Device_ConfigurationNumber;

/** Indicates if the host is currently allowing the device to issue remote wakeup events. If this
 *  flag is cleared, the device should not issue remote wakeup events to the host.
 *
 *  \attention This variable should be treated as read-only in the user application, and never
 manually
 *             changed in value.
 *
 *  \ingroup Group_Device
 */
bool USB_Device_RemoteWakeupEnabled;

/** Indicates if the device is currently being powered by its own power supply, rather than being
 *  powered by the host's USB supply. This flag should remain cleared if the device does not
 *  support self powered mode, as indicated in the device descriptors.
 *
 *  \ingroup Group_Device
 */
bool USB_Device_CurrentlySelfPowered;

void USB_Device_ProcessControlRequest(void);
@* EndpointStream.
@<Header files@>=
/** Endpoint data stream transmission and reception management.
 */

/** Endpoint data stream transmission and reception management.
 *
 *  Functions, macros, variables, enums and types related to data reading and writing of
 data streams from
 *  and to endpoints.
 */

/** Enum for the possible error return codes of the \c Endpoint_*_Stream_* functions. */
enum Endpoint_Stream_RW_ErrorCodes_t
{
  ENDPOINT_RWSTREAM_NoError = 0, /* Command completed successfully, no error. */
  ENDPOINT_RWSTREAM_EndpointStalled = 1, /* The endpoint was stalled during the stream
                                          *   transfer by the host or device.
                                          */
  ENDPOINT_RWSTREAM_DeviceDisconnected = 2, /* Device was disconnected from the host during
                                             *   the transfer.
	                                     */
  ENDPOINT_RWSTREAM_BusSuspended = 3, /* The USB bus has been suspended by the host and
                                       *   no USB endpoint traffic can occur until the bus
                                       *   has resumed.
                                       */
  ENDPOINT_RWSTREAM_Timeout = 4, /* The host failed to accept or send the next packet
                                  *   within the software timeout period set by the
                                  *   \ref USB_STREAM_TIMEOUT_MS macro.
                                  */
  ENDPOINT_RWSTREAM_IncompleteTransfer = 5, /* Indicates that the endpoint bank became
 full or empty before
                                         *   the complete contents of the current stream could be
                                   *   transferred. The endpoint stream function should be called
                                  *   again to process the next chunk of data in the transfer.
                                  */
};

/** Enum for the possible error return codes of the \c Endpoint_*_Control_Stream_* functions. */
enum Endpoint_ControlStream_RW_ErrorCodes_t
{
  ENDPOINT_RWCSTREAM_NoError = 0, /**< Command completed successfully, no error. */
  ENDPOINT_RWCSTREAM_HostAborted        = 1, /**< The aborted the transfer prematurely. */
  ENDPOINT_RWCSTREAM_DeviceDisconnected = 2, /**< Device was disconnected from the host during
                                          *   the transfer.
                                           */
  ENDPOINT_RWCSTREAM_BusSuspended       = 3, /**< The USB bus has been suspended by the host and
		                             *   no USB endpoint traffic can occur until the bus
		                            *   has resumed.
		                            */
};
@* EndpointStream AVR8.
@<Header files@>=
/** Endpoint data stream transmission and reception management for the AVR8 microcontrollers.
 */

/** Endpoint data stream transmission and reception management for the Atmel AVR8 architecture.
 *
 *  Functions, macros, variables, enums and types related to data reading and writing of
 data streams from
 *  and to endpoints.
 */

@*4 Stream functions for null data.

@ Reads and discards the given number of bytes from the currently selected endpoint's bank,
discarding fully read packets from the host as needed. The last packet is not automatically
discarded once the remaining bytes has been read; the user is responsible for manually
discarding the last packet from the host via the \ref Endpoint_ClearOUT() macro.

If the BytesProcessed parameter is \c NULL, the entire stream transfer is attempted at once,
failing or succeeding as a single unit. If the BytesProcessed parameter points to a valid
storage location, the transfer will instead be performed as a series of chunks. Each time
the endpoint bank becomes empty while there is still data to process (and after the current
packet has been acknowledged) the BytesProcessed location will be updated with the total number
of bytes processed in the stream, and the function will exit with an error code of
\ref ENDPOINT_RWSTREAM_IncompleteTransfer. This allows for any abort checking to be performed
in the user code - to continue the transfer, call the function again with identical parameters
and it will resume until the BytesProcessed value reaches the total transfer length.

 *  <b>Single Stream Transfer Example:</b>
 *  \code
 *  uint8_t ErrorCode;
 *
 *  if ((ErrorCode = Endpoint_Discard_Stream(512, NULL)) != ENDPOINT_RWSTREAM_NoError)
 *  {
 *       // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  <b>Partial Stream Transfers Example:</b>
 *  \code
 *  uint8_t  ErrorCode;
 *  uint16_t BytesProcessed;
 *
 *  BytesProcessed = 0;
 *  while ((ErrorCode = Endpoint_Discard_Stream(512, &BytesProcessed)) ==
 ENDPOINT_RWSTREAM_IncompleteTransfer)
 *  {
 *      // Stream not yet complete - do other actions here, abort if required
 *  }
 *
 *  if (ErrorCode != ENDPOINT_RWSTREAM_NoError)
 *  {
 *      // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  \note This routine should not be used on CONTROL type endpoints.
 *
 *  \param[in] Length          Number of bytes to discard via the currently selected endpoint.
 *  \param[in] BytesProcessed  Pointer to a location where the total number of bytes processed
 in the current
 *                             transaction should be updated, \c NULL if the entire stream
 should be read at once.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.
@<Header files@>=
uint8_t Endpoint_Discard_Stream(uint16_t Length, uint16_t* const BytesProcessed);

@ Writes a given number of zeroed bytes to the currently selected endpoint's bank, sending
full packets to the host as needed. The last packet is not automatically sent once the
remaining bytes have been written; the user is responsible for manually sending the last
packet to the host via the \ref Endpoint_ClearIN() macro.

If the BytesProcessed parameter is \c NULL, the entire stream transfer is attempted at once,
failing or succeeding as a single unit. If the BytesProcessed parameter points to a valid
storage location, the transfer will instead be performed as a series of chunks. Each time
the endpoint bank becomes full while there is still data to process (and after the current
packet transmission has been initiated) the BytesProcessed location will be updated with the
total number of bytes processed in the stream, and the function will exit with an error code of
\ref ENDPOINT_RWSTREAM_IncompleteTransfer. This allows for any abort checking to be performed
in the user code - to continue the transfer, call the function again with identical parameters
and it will resume until the BytesProcessed value reaches the total transfer length.

 * <b>Single Stream Transfer Example:</b>
 *  \code
 *  uint8_t ErrorCode;
 *
 *  if ((ErrorCode = Endpoint_Null_Stream(512, NULL)) != ENDPOINT_RWSTREAM_NoError)
 *  {
 *       // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  <b>Partial Stream Transfers Example:</b>
 *  \code
 *  uint8_t  ErrorCode;
 *  uint16_t BytesProcessed;
 *
 *  BytesProcessed = 0;
 *  while ((ErrorCode = Endpoint_Null_Stream(512, &BytesProcessed)) ==
 ENDPOINT_RWSTREAM_IncompleteTransfer)
 *  {
 *      // Stream not yet complete - do other actions here, abort if required
 *  }
 *
 *  if (ErrorCode != ENDPOINT_RWSTREAM_NoError)
 *  {
 *      // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  \note This routine should not be used on CONTROL type endpoints.
 *
 *  \param[in] Length          Number of zero bytes to send via the currently selected endpoint.
 *  \param[in] BytesProcessed  Pointer to a location where the total number of bytes processed
 in the current
 *                             transaction should be updated, \c NULL if the entire stream
 should be read at once.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.
@<Header files@>=
uint8_t Endpoint_Null_Stream(uint16_t Length, uint16_t* const BytesProcessed);

@*4 Stream functions for RAM source/destination data.

@ Writes the given number of bytes to the endpoint from the given buffer in little endian,
sending full packets to the host as needed. The last packet filled is not automatically sent;
the user is responsible for manually sending the last written packet to the host via the
\ref Endpoint_ClearIN() macro.

If the BytesProcessed parameter is \c NULL, the entire stream transfer is attempted at once,
failing or succeeding as a single unit. If the BytesProcessed parameter points to a valid
storage location, the transfer will instead be performed as a series of chunks. Each time
the endpoint bank becomes full while there is still data to process (and after the current
packet transmission has been initiated) the BytesProcessed location will be updated with the
total number of bytes processed in the stream, and the function will exit with an error code of
\ref ENDPOINT_RWSTREAM_IncompleteTransfer. This allows for any abort checking to be performed
in the user code - to continue the transfer, call the function again with identical parameters
and it will resume until the BytesProcessed value reaches the total transfer length.

 *  <b>Single Stream Transfer Example:</b>
 *  \code
 *  uint8_t DataStream[512];
 *  uint8_t ErrorCode;
 *
 *  if ((ErrorCode = Endpoint_Write_Stream_LE(DataStream, sizeof(DataStream),
 *                                            NULL)) != ENDPOINT_RWSTREAM_NoError)
 *  {
 *       // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  <b>Partial Stream Transfers Example:</b>
 *  \code
 *  uint8_t  DataStream[512];
 *  uint8_t  ErrorCode;
 *  uint16_t BytesProcessed;
 *
 *  BytesProcessed = 0;
 *  while ((ErrorCode = Endpoint_Write_Stream_LE(DataStream, sizeof(DataStream),
 *                                 &BytesProcessed)) == ENDPOINT_RWSTREAM_IncompleteTransfer)
 *  {
 *      // Stream not yet complete - do other actions here, abort if required
 *  }
 *
 *  if (ErrorCode != ENDPOINT_RWSTREAM_NoError)
 *  {
 *      // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  \note This routine should not be used on CONTROL type endpoints.
 *
 *  \param[in] Buffer          Pointer to the source data buffer to read from.
 *  \param[in] Length          Number of bytes to read for the currently selected endpoint
 into the buffer.
 *  \param[in] BytesProcessed  Pointer to a location where the total number of bytes processed
 in the current
 *                             transaction should be updated, \c NULL if the entire stream
 should be written at once.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Write_Stream_LE(const void* const Buffer, uint16_t Length,
                            uint16_t* const BytesProcessed) ATTR_NON_NULL_PTR_ARG(1);

@ Writes the given number of bytes to the endpoint from the given buffer in big endian,
sending full packets to the host as needed. The last packet filled is not automatically sent;
the user is responsible for manually sending the last written packet to the host via the
\ref Endpoint_ClearIN() macro.

\note This routine should not be used on CONTROL type endpoints.

\param[in] Buffer          Pointer to the source data buffer to read from.
\param[in] Length          Number of bytes to read for the currently selected endpoint into
 the buffer.
\param[in] BytesProcessed  Pointer to a location where the total number of bytes processed
 in the current
           transaction should be updated, \c NULL if the entire stream should be written at once.

\return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Write_Stream_BE(const void* const Buffer,
                                 uint16_t Length,
                                 uint16_t* const BytesProcessed) ATTR_NON_NULL_PTR_ARG(1);

@ Reads the given number of bytes from the endpoint from the given buffer in little endian,
discarding fully read packets from the host as needed. The last packet is not automatically
discarded once the remaining bytes has been read; the user is responsible for manually
discarding the last packet from the host via the \ref Endpoint_ClearOUT() macro.

If the BytesProcessed parameter is \c NULL, the entire stream transfer is attempted at once,
failing or succeeding as a single unit. If the BytesProcessed parameter points to a valid
storage location, the transfer will instead be performed as a series of chunks. Each time
the endpoint bank becomes empty while there is still data to process (and after the current
packet has been acknowledged) the BytesProcessed location will be updated with the total number
of bytes processed in the stream, and the function will exit with an error code of
\ref ENDPOINT_RWSTREAM_IncompleteTransfer. This allows for any abort checking to be performed
in the user code - to continue the transfer, call the function again with identical parameters
and it will resume until the BytesProcessed value reaches the total transfer length.

 *  <b>Single Stream Transfer Example:</b>
 *  \code
 *  uint8_t DataStream[512];
 *  uint8_t ErrorCode;
 *
 *  if ((ErrorCode = Endpoint_Read_Stream_LE(DataStream, sizeof(DataStream),
 *                                           NULL)) != ENDPOINT_RWSTREAM_NoError)
 *  {
 *       // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  <b>Partial Stream Transfers Example:</b>
 *  \code
 *  uint8_t  DataStream[512];
 *  uint8_t  ErrorCode;
 *  uint16_t BytesProcessed;
 *
 *  BytesProcessed = 0;
 *  while ((ErrorCode = Endpoint_Read_Stream_LE(DataStream, sizeof(DataStream),
 *                                  &BytesProcessed)) == ENDPOINT_RWSTREAM_IncompleteTransfer)
 *  {
 *      // Stream not yet complete - do other actions here, abort if required
 *  }
 *
 *  if (ErrorCode != ENDPOINT_RWSTREAM_NoError)
 *  {
 *      // Stream failed to complete - check ErrorCode here
 *  }
 *  \endcode
 *
 *  \note This routine should not be used on CONTROL type endpoints.
 *
 *  \param[out] Buffer          Pointer to the destination data buffer to write to.
 *  \param[in]  Length          Number of bytes to send via the currently selected endpoint.
 *  \param[in]  BytesProcessed  Pointer to a location where the total number of bytes
 processed in the current
 *                              transaction should be updated, \c NULL if the entire stream
 should be read at once.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Read_Stream_LE(void* const Buffer,
                                uint16_t Length,
                                uint16_t* const BytesProcessed) ATTR_NON_NULL_PTR_ARG(1);

@ Reads the given number of bytes from the endpoint from the given buffer in big endian,
discarding fully read packets from the host as needed. The last packet is not automatically
discarded once the remaining bytes has been read; the user is responsible for manually
discarding the last packet from the host via the \ref Endpoint_ClearOUT() macro.

\note This routine should not be used on CONTROL type endpoints.

\param[out] Buffer          Pointer to the destination data buffer to write to.
\param[in]  Length          Number of bytes to send via the currently selected endpoint.
\param[in]  BytesProcessed  Pointer to a location where the total number of bytes processed in
 the current
             transaction should be updated, \c NULL if the entire stream should be read at once.

\return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Read_Stream_BE(void* const Buffer,
                                uint16_t Length,
                                uint16_t* const BytesProcessed) ATTR_NON_NULL_PTR_ARG(1);

@ Writes the given number of bytes to the CONTROL type endpoint from the given buffer in
 little endian,
sending full packets to the host as needed. The host OUT acknowledgement is not automatically
 cleared
in both failure and success states; the user is responsible for manually clearing the status
 OUT packet
to finalize the transfer's status stage via the \ref Endpoint_ClearOUT() macro.

\note This function automatically sends the last packet in the data stage of the transaction;
 when the
function returns, the user is responsible for clearing the <b>status</b> stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.
        \n\n

\note This routine should only be used on CONTROL type endpoints.

\warning Unlike the standard stream read/write commands, the control stream commands cannot
 be chained
         together; i.e. the entire stream data must be read or written at the one time.

\param[in] Buffer  Pointer to the source data buffer to read from.
\param[in] Length  Number of bytes to read for the currently selected endpoint into the buffer.

\return A value from the \ref Endpoint_ControlStream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Write_Control_Stream_LE(const void* const Buffer,
                                         uint16_t Length) ATTR_NON_NULL_PTR_ARG(1);

@ Writes the given number of bytes to the CONTROL type endpoint from the given buffer in big
 endian,
sending full packets to the host as needed. The host OUT acknowledgement is not automatically
 cleared
in both failure and success states; the user is responsible for manually clearing the status
 OUT packet
to finalize the transfer's status stage via the \ref Endpoint_ClearOUT() macro.

\note This function automatically sends the last packet in the data stage of the transaction;
 when the
function returns, the user is responsible for clearing the <b>status</b> stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.
        \n\n

\note This routine should only be used on CONTROL type endpoints.

\warning Unlike the standard stream read/write commands, the control stream commands cannot
 be chained
          together; i.e. the entire stream data must be read or written at the one time.

\param[in] Buffer  Pointer to the source data buffer to read from.
\param[in] Length  Number of bytes to read for the currently selected endpoint into the buffer.

\return A value from the \ref Endpoint_ControlStream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Write_Control_Stream_BE(const void* const Buffer,
                                         uint16_t Length) ATTR_NON_NULL_PTR_ARG(1);

@ Reads the given number of bytes from the CONTROL endpoint from the given buffer in little endian,
discarding fully read packets from the host as needed. The device IN acknowledgement is not
automatically sent after success or failure states; the user is responsible for manually
 sending the
status IN packet to finalize the transfer's status stage via the \ref Endpoint_ClearIN() macro.

\note This function automatically sends the last packet in the data stage of the transaction;
 when the
function returns, the user is responsible for clearing the <b>status</b> stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.
        \n\n

\note This routine should only be used on CONTROL type endpoints.

\warning Unlike the standard stream read/write commands, the control stream commands cannot be
 chained
         together; i.e. the entire stream data must be read or written at the one time.

\param[out] Buffer  Pointer to the destination data buffer to write to.
\param[in]  Length  Number of bytes to send via the currently selected endpoint.

\return A value from the \ref Endpoint_ControlStream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Read_Control_Stream_LE(void* const Buffer,
                                        uint16_t Length) ATTR_NON_NULL_PTR_ARG(1);

@ Reads the given number of bytes from the CONTROL endpoint from the given buffer in big endian,
discarding fully read packets from the host as needed. The device IN acknowledgement is not
automatically sent after success or failure states; the user is responsible for manually sending
 the
status IN packet to finalize the transfer's status stage via the \ref Endpoint_ClearIN() macro.

\note This function automatically sends the last packet in the data stage of the transaction;
 when the
function returns, the user is responsible for clearing the <b>status</b> stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.
        \n\n

\note This routine should only be used on CONTROL type endpoints.

\warning Unlike the standard stream read/write commands, the control stream commands cannot
 be chained
        together; i.e. the entire stream data must be read or written at the one time.

\param[out] Buffer  Pointer to the destination data buffer to write to.
\param[in]  Length  Number of bytes to send via the currently selected endpoint.

\return A value from the \ref Endpoint_ControlStream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Read_Control_Stream_BE(void* const Buffer,
                                       uint16_t Length) ATTR_NON_NULL_PTR_ARG(1);

@*4 Stream functions for PROGMEM source/destination data.

@ FLASH buffer source version of \ref Endpoint_Write_Stream_LE().

\pre The FLASH data must be located in the first 64KB of FLASH for this function to work correctly.

\param[in] Buffer          Pointer to the source data buffer to read from.
\param[in] Length          Number of bytes to read for the currently selected endpoint into
 the buffer.
\param[in] BytesProcessed  Pointer to a location where the total number of bytes processed
 in the current
          transaction should be updated, \c NULL if the entire stream should be written at once.

\return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Write_PStream_LE(const void* const Buffer,
                                 uint16_t Length,
                                 uint16_t* const BytesProcessed) ATTR_NON_NULL_PTR_ARG(1);

@ FLASH buffer source version of \ref Endpoint_Write_Control_Stream_LE().

\pre The FLASH data must be located in the first 64KB of FLASH for this function to work correctly.

\note This function automatically sends the last packet in the data stage of the transaction;
 when the
function returns, the user is responsible for clearing the <b>status</b> stage of the transaction.
Note that the status stage packet is sent or received in the opposite direction of the data flow.
        \n\n

\note This routine should only be used on CONTROL type endpoints.
       \n\n

\warning Unlike the standard stream read/write commands, the control stream commands cannot be
 chained
      together; i.e. the entire stream data must be read or written at the one time.

\param[in] Buffer  Pointer to the source data buffer to read from.
\param[in] Length  Number of bytes to read for the currently selected endpoint into the buffer.

\return A value from the \ref Endpoint_ControlStream_RW_ErrorCodes_t enum.

@<Header files@>=
uint8_t Endpoint_Write_Control_PStream_LE(const void* const Buffer,
                                          uint16_t Length) ATTR_NON_NULL_PTR_ARG(1);
@* USBTask.
@<Header files@>=
/** Main USB service task management.
 *
 *  This contains the function definitions required for the main USB service task,
 which must be called
 *  to ensure that the USB connection to or from a connected USB device is maintained.
 */

/** Indicates if the USB interface is currently initialized but not necessarily connected to a host
 *  or device (i.e. if |USB_Init| has been run). If this is false, all other library
 globals related
 *  to the USB driver are invalid.
 *
 *  \attention This variable should be treated as read-only in the user application, and
 never manually
 *             changed in value.
 *
 *  \ingroup Group_USBManagement
 */
 volatile bool USB_IsInitialized;

/** Structure containing the last received Control request when in Device mode (for use in
 user-applications
 *  inside of the \ref EVENT_USB_Device_ControlRequest() event, or for filling up with a
 control request to
 *  issue when in Host mode before calling \ref USB_Host_SendControlRequest().
 *
 *  \note The contents of this structure is automatically endian-corrected for the current
 CPU architecture.
 *
 *  \ingroup Group_USBManagement
 */
 USB_Request_Header_t USB_ControlRequest;

#define USB_DeviceState            CONCAT_EXPANDED(GPIOR, DEVICE_STATE_AS_GPIOR)

/** This is the main USB management task. The USB driver requires this task to be executed
 *  continuously when the USB system is active (attached to a host)
 *  in order to manage USB communications. This task may be executed inside an RTOS,
 *  fast timer ISR or the main user application loop.
 *
 *  The USB task must be serviced within 30ms.
 *  The task may be serviced at all times, or (for minimum CPU consumption)
 *   it may be disabled at start-up, enabled on the firing of the \ref EVENT_USB_Device_Connect()
 *      event and disabled again on the firing of the \ref EVENT_USB_Device_Disconnect() event.
 *
 *  The control endpoint can instead be managed via interrupts entirely by the library
 *  by defining the INTERRUPT_CONTROL_ENDPOINT token and passing it to the compiler via
 the -D switch.
 *
 *  \see \ref Group_Events for more information on the USB events.
 *
 *  \ingroup Group_USBManagement
 */
void USB_DeviceTask(void);
@* Events.
@<Header files@>=
/** \file
 *  \brief USB Event management definitions.
 *  \copydetails Group_Events
 *
 */

/** \ingroup Group_USB
 *  \defgroup Group_Events USB Events
 *  \brief USB Event management definitions.
 *
 *  This contains macros and functions relating to the management of library events, which
 are small
 *  pieces of code similar to ISRs which are run when a given condition is met. Each event
 can be fired from
 *  multiple places in the user or library code, which may or may not be inside an ISR, thus
 each handler
 *  should be written to be as small and fast as possible to prevent possible problems.
 *
 *  Events can be hooked by the user application by declaring a handler function with the
 same name and parameters
 *  listed here. If an event with no user-associated handler is fired within the library,
 it by default maps to an
 *  internal empty stub function.
 *
 *  Each event must only have one associated event handler, but can be raised by multiple
 sources by calling the
 *  event handler function (with any required event parameters).
 *
 */

/** Event for USB device connection. This event fires when the microcontroller is in USB
 Device mode
 *  and the device is connected to a USB host, beginning the enumeration process measured
 by a rising
 *  level on the microcontroller's VBUS sense pin.
 *
 *  This event is time-critical; exceeding OS-specific delays within this event handler
 (typically of around
 *  two seconds) will prevent the device from enumerating correctly.
 *
 *  \attention This event may fire multiple times during device enumeration on the
 microcontrollers with limited USB controllers
 *             if \c NO_LIMITED_CONTROLLER_CONNECT is not defined.
 *
 *  \note For the microcontrollers with limited USB controller functionality, VBUS sensing
 is not available.
 *        this means that the current connection state is derived from the bus suspension
 and wake up events by default,
 *        which is not always accurate (host may suspend the bus while still connected).
 If the actual connection state
 *        needs to be determined, VBUS should be routed to an external pin, and the
 auto-detect behavior turned off by
 *        passing the \c NO_LIMITED_CONTROLLER_CONNECT token to the compiler via the -D
 switch at compile time. The connection
 *        and disconnection events may be manually fired, and the \ref USB_DeviceState
 global changed manually.
 *        \n\n
 *
 *  \see \ref Group_USBManagement for more information on the USB management task and
 reducing CPU usage.
 */
void EVENT_USB_Device_Connect(void);

/** Event for USB device disconnection. This event fires when the microcontroller is in
 USB Device mode and the device is
 *  disconnected from a host, measured by a falling level on the microcontroller's VBUS
 sense pin.
 *
 *  \attention This event may fire multiple times during device enumeration on the
 microcontrollers with limited USB controllers
 *             if \c NO_LIMITED_CONTROLLER_CONNECT is not defined.
 *
 *  \note For the microcontrollers with limited USB controllers, VBUS sense is not
 available to the USB controller.
 *        this means that the current connection state is derived from the bus suspension
 and wake up events by default,
 *        which is not always accurate (host may suspend the bus while still connected).
 If the actual connection state
 *        needs to be determined, VBUS should be routed to an external pin, and the
 auto-detect behavior turned off by
 *        passing the \c NO_LIMITED_CONTROLLER_CONNECT token to the compiler via the -D
 switch at compile time. The connection
 *        and disconnection events may be manually fired, and the \ref USB_DeviceState
 global changed manually.
 *        \n\n
 *
 *  \see \ref Group_USBManagement for more information on the USB management task and
 reducing CPU usage.
 */
void EVENT_USB_Device_Disconnect(void);

/** Event for control requests. This event fires when a the USB host issues a control request
 *  to the mandatory device control endpoint (of address 0). This may either be a standard
 *  request that the library may have a handler code for internally, or a class specific request
 *  issued to the device which must be handled appropriately. If a request is not processed in the
 *  user application via this event, it will be passed to the library for processing internally
 *  if a suitable handler exists.
 *
 *  This event is time-critical; each packet within the request transaction must be acknowledged or
 *  sent within 50ms or the host will abort the transfer.
 *
 *  The library internally handles all standard control requests with the exceptions of SYNC FRAME,
 *  SET DESCRIPTOR and SET INTERFACE. These and all other non-standard control requests
 will be left
 *  for the user to process via this event if desired. If not handled in the user application or by
 *  the library internally, unknown requests are automatically STALLed.
 *
 *  \note This event does not exist if the \c USB_HOST_ONLY token is supplied to the compiler (see
 *        \ref Group_USBManagement documentation).
 *        \n\n
 *
 *  \note Requests should be handled in the same manner as described in the USB 2.0 Specification,
 *        or appropriate class specification. In all instances, the library has already read the
 *        request SETUP parameters into the \ref USB_ControlRequest structure which should then
 be used
 *        by the application to determine how to handle the issued request.
 */
void EVENT_USB_Device_ControlRequest(void);

/** Event for USB configuration number changed. This event fires when a the USB host changes the
 *  selected configuration number while in device mode. This event should be hooked in device
 *  applications to create the endpoints and configure the device for the selected configuration.
 *
 *  This event is time-critical; exceeding OS-specific delays within this event handler
 (typically of around
 *  one second) will prevent the device from enumerating correctly.
 *
 *  This event fires after the value of \ref USB_Device_ConfigurationNumber has been changed.
 *
 *  \note This event does not exist if the \c USB_HOST_ONLY token is supplied to the compiler (see
 *        \ref Group_USBManagement documentation).
 */
void EVENT_USB_Device_ConfigurationChanged(void);

/** Event for USB suspend. This event fires when a the USB host suspends the device by halting its
 *  transmission of Start Of Frame pulses to the device. This is generally hooked in order to move
 *  the device over to a low power state until the host wakes up the device. If the USB interface
 is
 *  enumerated with the \ref USB_OPT_AUTO_PLL option set, the library will automatically suspend
 the
 *  USB PLL before the event is fired to save power.
 *
 *  \note This event does not exist if the \c USB_HOST_ONLY token is supplied to the compiler (see
 *        \ref Group_USBManagement documentation).
 *        \n\n
 *
 *  \note This event does not exist on the microcontrollers with limited USB VBUS sensing abilities
 *        when the \c NO_LIMITED_CONTROLLER_CONNECT compile time token is not set - see
 *        \ref EVENT_USB_Device_Disconnect.
 *
 *  \see \ref EVENT_USB_Device_WakeUp() event for accompanying Wake Up event.
 */
void EVENT_USB_Device_Suspend(void) ATTR_CONST;

/** Event for USB wake up. This event fires when a the USB interface is suspended while in device
 *  mode, and the host wakes up the device by supplying Start Of Frame pulses. This is generally
 *  hooked to pull the user application out of a low power state and back into normal operating
 *  mode. If the USB interface is enumerated with the \ref USB_OPT_AUTO_PLL option set, the library
 *  will automatically restart the USB PLL before the event is fired.
 *
 *  \note This event does not exist if the \c USB_HOST_ONLY token is supplied to the compiler (see
 *        \ref Group_USBManagement documentation).
 *        \n\n
 *
 *  \note This event does not exist on the microcontrollers with limited USB VBUS sensing abilities
 *        when the \c NO_LIMITED_CONTROLLER_CONNECT compile time token is not set - see
 *        \ref EVENT_USB_Device_Disconnect.
 *
 *  \see \ref EVENT_USB_Device_Suspend() event for accompanying Suspend event.
 */
void EVENT_USB_Device_WakeUp(void) ATTR_CONST;

/** Event for USB interface reset. This event fires when the USB interface is in device mode, and
 *  a the USB host requests that the device reset its interface. This event fires after the control
 *  endpoint has been automatically configured by the library.
 *
 *  This event is time-critical; exceeding OS-specific delays within this event handler
 (typically of around
 *  two seconds) will prevent the device from enumerating correctly.
 *
 *  \note This event does not exist if the \c USB_HOST_ONLY token is supplied to the compiler (see
 *        \ref Group_USBManagement documentation).
 */
void EVENT_USB_Device_Reset(void) ATTR_CONST;

/** Event for USB Start Of Frame detection, when enabled. This event fires at the start of each USB
 *  frame, once per millisecond, and is synchronized to the USB bus. This can be used as an
 accurate
 *  millisecond timer source when the USB bus is enumerated in device mode to a USB host.
 *
 *  This event is time-critical; it is run once per millisecond and thus long handlers will
 significantly
 *  degrade device performance. This event should only be enabled when needed to reduce
 device wake-ups.
 *
 *  \pre This event is not normally active - it must be manually enabled and disabled via the
 *       \ref USB_Device_EnableSOFEvents() and \ref USB_Device_DisableSOFEvents() commands
 after enumeration.
 *       \n\n
 *
 *  \note This event does not exist if the \c USB_HOST_ONLY token is supplied to the compiler (see
 *        \ref Group_USBManagement documentation).
 */
void EVENT_USB_Device_StartOfFrame(void) ATTR_CONST;
@* StdDescriptors.
Common standard USB Descriptor definitions.
Standard USB device descriptor defines and retrieval routines. This contains
structures and macros for the easy creation of standard USB descriptors.

@ Indicates that a given descriptor does not exist in the device. This can be used inside
descriptors for string descriptor indexes, or may be use as a return value for
|CALLBACK_USB_GetDescriptor| when
the specified descriptor does not exist.

@<Header files@>=
#define NO_DESCRIPTOR 0

@ Macro to calculate the power value for the configuration descriptor, from a given number
of milliamperes.
Parameter is maximum number of milliamps the device consumes when the given
configuration is selected.

@<Header files@>=
#define USB_CONFIG_POWER_MA(mA) ((mA) >> 1)

@ Macro to calculate the Unicode length of a string with a given number of Unicode characters.
Should be used in string descriptor's headers for giving the string descriptor's byte length.

Parameter is number of Unicode characters in the string text.

@<Header files@>=
#define USB_STRING_LEN(UnicodeChars) (sizeof (USB_Descriptor_Header_t) + ((UnicodeChars) << 1))

@ Convenience macro to easily create |USB_Descriptor_String_t| instances from a wide
character string.

Parameter is string to initialize a USB String Descriptor structure with.

@<Header files@>=
#define USB_STRING_DESCRIPTOR(String) { \
  { \
    sizeof (USB_Descriptor_Header_t) + ( sizeof (String) - 2 ), \
    DTYPE_String \
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

@<Header files@>=
#define VERSION_BCD(Major, Minor, Revision) \
                                          CPU_TO_LE16( ((Major & 0xFF) << 8) | \
                                                       ((Minor & 0x0F) << 4) | \
                                                       (Revision & 0x0F) )

@*1 USB Configuration Descriptor Attribute Masks.

@ Mask for the reserved bit in the Configuration Descriptor's |ConfigAttributes| field,
which must be set on all devices for historical purposes.

@<Header files@>=
#define USB_CONFIG_ATTR_RESERVED          0x80

@ Can be masked with other configuration descriptor attributes for a
|USB_Descriptor_Config_Header_t|
descriptor's |ConfigAttributes| value to indicate that the specified configuration
can draw its power from the device's own power source.

@<Header files@>=
#define USB_CONFIG_ATTR_SELFPOWERED 0x40

@*1 Endpoint Descriptor Attribute Masks.

@ Can be masked with other endpoint descriptor attributes for a
|USB_Descriptor_Endpoint_t| descriptor's
|Attributes| value to indicate that the specified endpoint is not synchronized.

See the USB specification for more details on the possible Endpoint attributes.

@<Header files@>=
#define ENDPOINT_ATTR_NO_SYNC (0 << 2)

@*1 Endpoint Descriptor Usage Masks.

@ Can be masked with other endpoint descriptor attributes for a
|USB_Descriptor_Endpoint_t| descriptor's
|Attributes| value to indicate that the specified endpoint is used for data transfers.

See the USB specification for more details on the possible Endpoint usage attributes.

@<Header files@>=
#define ENDPOINT_USAGE_DATA               (0 << 4)

/** Enum for the possible standard descriptor types, as given in each descriptor's header. */
enum USB_DescriptorTypes_t
{
  DTYPE_Device = 0x01, /**< Indicates that the descriptor is a device descriptor. */
  DTYPE_Configuration = 0x02, /**< Indicates that the descriptor is a configuration descriptor. */
  DTYPE_String = 0x03, /**< Indicates that the descriptor is a string descriptor. */
  DTYPE_Interface = 0x04, /**< Indicates that the descriptor is an interface descriptor. */
  DTYPE_Endpoint = 0x05, /**< Indicates that the descriptor is an endpoint descriptor. */
  DTYPE_DeviceQualifier = 0x06, /**< Indicates that the descriptor is a device qualifier
 descriptor. */
  DTYPE_Other = 0x07, /**< Indicates that the descriptor is of other type. */
  DTYPE_InterfacePower = 0x08, /**< Indicates that the descriptor is an interface power
 descriptor. */
  DTYPE_InterfaceAssociation = 0x0B, /**< Indicates that the descriptor is an interface
 association descriptor. */
  DTYPE_CSInterface = 0x24, /**< Indicates that the descriptor is a class specific interface
 descriptor. */
  DTYPE_CSEndpoint = 0x25, /**< Indicates that the descriptor is a class specific endpoint
 descriptor. */
};

/** Enum for possible Class, Subclass and Protocol values of device and interface descriptors. */
enum USB_Descriptor_ClassSubclassProtocol_t
{
  USB_CSCP_NoDeviceClass = 0x00, /**< Descriptor Class value indicating that the device does
 not belong
                                   *   to a particular class at the device level.
                                   */
  USB_CSCP_NoDeviceSubclass = 0x00, /**< Descriptor Subclass value indicating that the device
 does not belong
                                     *   to a particular subclass at the device level.
                                     */
  USB_CSCP_NoDeviceProtocol = 0x00, /**< Descriptor Protocol value indicating that the device
 does not belong
                                      *   to a particular protocol at the device level.
                                      */
  USB_CSCP_VendorSpecificClass = 0xFF, /**< Descriptor Class value indicating that the
 device/interface belongs
                                        *   to a vendor specific class.
                                        */
  USB_CSCP_VendorSpecificSubclass = 0xFF, /**< Descriptor Subclass value indicating that the
 device/interface belongs
	                                   *   to a vendor specific subclass.
	                                   */
  USB_CSCP_VendorSpecificProtocol = 0xFF, /**< Descriptor Protocol value indicating that the
 device/interface belongs
                                        *   to a vendor specific protocol.
                                        */
  USB_CSCP_IADDeviceClass = 0xEF, /**< Descriptor Class value indicating that the device
 belongs to the
				    *   Interface Association Descriptor class.
				    */
  USB_CSCP_IADDeviceSubclass = 0x02, /**< Descriptor Subclass value indicating that the
 device belongs to the
                                      *   Interface Association Descriptor subclass.
                                      */
  USB_CSCP_IADDeviceProtocol = 0x01, /**< Descriptor Protocol value indicating that the device
 belongs to the
	                              *   Interface Association Descriptor protocol.
	                              */
};

/** \brief Standard USB Descriptor Header (LUFA naming conventions).
 *
 *  Type define for all descriptors' standard header, indicating the descriptor's length
 and type. This structure
 *  uses LUFA-specific element names to make each element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_Header_t for the version of this type with standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
  uint8_t Size; /**< Size of the descriptor, in bytes. */
  uint8_t Type; /**< Type of the descriptor, either a value in \ref USB_DescriptorTypes_t or
 a value
	         *   given by the specific class.
	         */
} ATTR_PACKED USB_Descriptor_Header_t;

/** \brief Standard USB Descriptor Header (USB-IF naming conventions).
 *
 *  Type define for all descriptors' standard header, indicating the descriptor's length and
 type. This structure
 *  uses the relevant standard's given element names to ensure compatibility with the standard.
 *
 *  \see \ref USB_Descriptor_Header_t for the version of this type with non-standard LUFA
 specific element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
  uint8_t bLength; /**< Size of the descriptor, in bytes. */
  uint8_t bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
                         *   given by the specific class.
                         */
} ATTR_PACKED USB_StdDescriptor_Header_t;

/** \brief Standard USB Device Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard Device Descriptor. This structure uses LUFA-specific
 element names to make each
 *  element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_Device_t for the version of this type with standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	uint16_t USBSpecification; /**< BCD of the supported USB specification.
	                            *
	                            *   \see \ref VERSION_BCD() utility macro.
	                            */
	uint8_t  Class; /**< USB device class. */
	uint8_t  SubClass; /**< USB device subclass. */
	uint8_t  Protocol; /**< USB device protocol. */

	uint8_t  Endpoint0Size; /**< Size of the control (address 0) endpoint's bank in bytes. */

	uint16_t VendorID; /**< Vendor ID for the USB product. */
	uint16_t ProductID; /**< Unique product ID for the USB product. */
	uint16_t ReleaseNumber; /**< Product release (version) number.
	                         *
	                         *   \see \ref VERSION_BCD() utility macro.
	                         */
	uint8_t  ManufacturerStrIndex; /**< String index for the manufacturer's name. The
	                                *   host will request this string via a separate
	                                *   control request for the string descriptor.
	                                *
	                                *   \note If no string supplied, use \ref NO_DESCRIPTOR.
	                                */
	uint8_t  ProductStrIndex; /**< String index for the product name/details.
	                           *
	                           *  \see ManufacturerStrIndex structure entry.
	                           */
	uint8_t  SerialNumStrIndex; /**< String index for the product's globally unique hexadecimal
	                             *   serial number, in uppercase Unicode ASCII.
	                             *
                      *  \note On some microcontroller models, there is an embedded serial number
                    *        in the chip which can be used for the device serial number.
                    *        To use this serial number, set this to \c USE_INTERNAL_SERIAL.
                    *        On unsupported devices, this will evaluate to \ref NO_DESCRIPTOR
                    *        and will cause the host to generate a pseudo-unique value for the
	                             *        device upon insertion.
	                             *
	                             *  \see \c ManufacturerStrIndex structure entry.
	                             */
	uint8_t  NumberOfConfigurations; /**< Total number of configurations supported by
	                                  *   the device.
	                                  */
} ATTR_PACKED USB_Descriptor_Device_t;

/** \brief Standard USB Device Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard Device Descriptor. This structure uses the relevant
 standard's given element names
 *  to ensure compatibility with the standard.
 *
 *  \see \ref USB_Descriptor_Device_t for the version of this type with non-standard
 LUFA specific element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t  bLength; /**< Size of the descriptor, in bytes. */
	uint8_t  bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
                              *   given by the specific class.
                              */
	uint16_t bcdUSB; /**< BCD of the supported USB specification.
	                  *
	                  *   \see \ref VERSION_BCD() utility macro.
	                  */
	uint8_t  bDeviceClass; /**< USB device class. */
	uint8_t  bDeviceSubClass; /**< USB device subclass. */
	uint8_t  bDeviceProtocol; /**< USB device protocol. */
	uint8_t  bMaxPacketSize0; /**< Size of the control (address 0) endpoint's bank in bytes. */
	uint16_t idVendor; /**< Vendor ID for the USB product. */
	uint16_t idProduct; /**< Unique product ID for the USB product. */
	uint16_t bcdDevice; /**< Product release (version) number.
	                     *
	                     *   \see \ref VERSION_BCD() utility macro.
	                     */
	uint8_t  iManufacturer; /**< String index for the manufacturer's name. The
	                         *   host will request this string via a separate
	                         *   control request for the string descriptor.
	                         *
	                         *   \note If no string supplied, use \ref NO_DESCRIPTOR.
	                         */
	uint8_t  iProduct; /**< String index for the product name/details.
	                    *
	                    *  \see ManufacturerStrIndex structure entry.
	                    */
	uint8_t iSerialNumber; /**< String index for the product's globally unique hexadecimal
	                        *   serial number, in uppercase Unicode ASCII.
	                        *
                     *  \note On some microcontroller models, there is an embedded serial number
                        *        in the chip which can be used for the device serial number.
                        *        To use this serial number, set this to \c USE_INTERNAL_SERIAL.
                      *        On unsupported devices, this will evaluate to \ref NO_DESCRIPTOR
                      *        and will cause the host to generate a pseudo-unique value for the
                        *        device upon insertion.
                        *
                        *  \see \c ManufacturerStrIndex structure entry.
                       */
	uint8_t  bNumConfigurations; /**< Total number of configurations supported by
	                              *   the device.
	                              */
} ATTR_PACKED USB_StdDescriptor_Device_t;

/** \brief Standard USB Device Qualifier Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard Device Qualifier Descriptor. This structure uses LUFA-specific
 element names
 *  to make each element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_DeviceQualifier_t for the version of this type with standard
 element names.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	uint16_t USBSpecification; /**< BCD of the supported USB specification.
	                            *
	                            *   \see \ref VERSION_BCD() utility macro.
	                            */
	uint8_t  Class; /**< USB device class. */
	uint8_t  SubClass; /**< USB device subclass. */
	uint8_t  Protocol; /**< USB device protocol. */

	uint8_t  Endpoint0Size; /**< Size of the control (address 0) endpoint's bank in bytes. */
	uint8_t  NumberOfConfigurations; /**< Total number of configurations supported by
	                                  *   the device.
                                */
	uint8_t  Reserved; /**< Reserved for future use, must be 0. */
} ATTR_PACKED USB_Descriptor_DeviceQualifier_t;

/** \brief Standard USB Device Qualifier Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard Device Qualifier Descriptor. This structure uses the relevant
 standard's given element names
 *  to ensure compatibility with the standard.
 *
 *  \see \ref USB_Descriptor_DeviceQualifier_t for the version of this type with
 non-standard LUFA specific element names.
 */
typedef struct
{
	uint8_t  bLength; /**< Size of the descriptor, in bytes. */
	uint8_t  bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
	                           *   given by the specific class.
	                           */
	uint16_t bcdUSB; /**< BCD of the supported USB specification.
	                  *
	                  *   \see \ref VERSION_BCD() utility macro.
	                  */
	uint8_t  bDeviceClass; /**< USB device class. */
	uint8_t  bDeviceSubClass; /**< USB device subclass. */
	uint8_t  bDeviceProtocol; /**< USB device protocol. */
	uint8_t  bMaxPacketSize0; /**< Size of the control (address 0) endpoint's bank in bytes. */
	uint8_t  bNumConfigurations; /**< Total number of configurations supported by
	                              *   the device.
	                              */
	uint8_t  bReserved; /**< Reserved for future use, must be 0. */
} ATTR_PACKED USB_StdDescriptor_DeviceQualifier_t;

/** \brief Standard USB Configuration Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard Configuration Descriptor header. This structure uses
 LUFA-specific element names
 *  to make each element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_Config_Header_t for the version of this type with standard
 element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	uint16_t TotalConfigurationSize; /**< Size of the configuration descriptor header,
	                                  *   and all sub descriptors inside the configuration.
	                                  */
	uint8_t  TotalInterfaces; /**< Total number of interfaces in the configuration. */

	uint8_t  ConfigurationNumber; /**< Configuration index of the current configuration. */
	uint8_t  ConfigurationStrIndex; /**< Index of a string descriptor describing the configuration. */

	uint8_t  ConfigAttributes; /**< Configuration attributes, comprised of a mask of
 \c USB_CONFIG_ATTR_* masks.
	                            *   On all devices, this should include
 USB_CONFIG_ATTR_RESERVED at a minimum.
	                            */

	uint8_t  MaxPowerConsumption; /**< Maximum power consumption of the device while in the
	                               *   current configuration, calculated by the
 \ref USB_CONFIG_POWER_MA()
	                               *   macro.
	                               */
} ATTR_PACKED USB_Descriptor_Config_Header_t;

/** \brief Standard USB Configuration Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard Configuration Descriptor header. This structure uses the
 relevant standard's given element names
 *  to ensure compatibility with the standard.
 *
 *  \see \ref USB_Descriptor_Device_t for the version of this type with non-standard LUFA
 specific element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t  bLength; /**< Size of the descriptor, in bytes. */
	uint8_t  bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
	                           *   given by the specific class.
	                           */
	uint16_t wTotalLength; /**< Size of the configuration descriptor header,
                           *   and all sub descriptors inside the configuration.
                           */
	uint8_t  bNumInterfaces; /**< Total number of interfaces in the configuration. */
	uint8_t  bConfigurationValue; /**< Configuration index of the current configuration. */
	uint8_t  iConfiguration; /**< Index of a string descriptor describing the configuration. */
	uint8_t  bmAttributes; /**< Configuration attributes, comprised of a mask of
 \c USB_CONFIG_ATTR_* masks.
	                        *   On all devices, this should include
 USB_CONFIG_ATTR_RESERVED at a minimum.
	                        */
	uint8_t  bMaxPower; /**< Maximum power consumption of the device while in the
	                     *   current configuration, calculated by the \ref USB_CONFIG_POWER_MA()
	                     *   macro.
	                     */
} ATTR_PACKED USB_StdDescriptor_Config_Header_t;

/** \brief Standard USB Interface Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard Interface Descriptor. This structure uses LUFA-specific element
 names
 *  to make each element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_Interface_t for the version of this type with standard element
 names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	uint8_t InterfaceNumber; /**< Index of the interface in the current configuration. */
	uint8_t AlternateSetting; /**< Alternate setting for the interface number. The same
	                           *   interface number can have multiple alternate settings
	                           *   with different endpoint configurations, which can be
	                           *   selected by the host.
	                           */
	uint8_t TotalEndpoints; /**< Total number of endpoints in the interface. */

	uint8_t Class; /**< Interface class ID. */
	uint8_t SubClass; /**< Interface subclass ID. */
	uint8_t Protocol; /**< Interface protocol ID. */

	uint8_t InterfaceStrIndex; /**< Index of the string descriptor describing the interface. */
} ATTR_PACKED USB_Descriptor_Interface_t;

/** \brief Standard USB Interface Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard Interface Descriptor. This structure uses the relevant
 standard's given element names
 *  to ensure compatibility with the standard.
 *
 *  \see \ref USB_Descriptor_Interface_t for the version of this type with non-standard LUFA
 specific element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t bLength; /**< Size of the descriptor, in bytes. */
	uint8_t bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
	                          *   given by the specific class.
	                          */
	uint8_t bInterfaceNumber; /**< Index of the interface in the current configuration. */
	uint8_t bAlternateSetting; /**< Alternate setting for the interface number. The same
	                            *   interface number can have multiple alternate settings
	                            *   with different endpoint configurations, which can be
	                            *   selected by the host.
	                            */
	uint8_t bNumEndpoints; /**< Total number of endpoints in the interface. */
	uint8_t bInterfaceClass; /**< Interface class ID. */
	uint8_t bInterfaceSubClass; /**< Interface subclass ID. */
	uint8_t bInterfaceProtocol; /**< Interface protocol ID. */
	uint8_t iInterface; /**< Index of the string descriptor describing the
	                     *   interface.
	                     */
} ATTR_PACKED USB_StdDescriptor_Interface_t;

/** \brief Standard USB Interface Association Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard Interface Association Descriptor. This structure uses
 LUFA-specific element names
 *  to make each element's purpose clearer.
 *
 *  This descriptor has been added as a supplement to the USB2.0 standard, in the ECN located at
 *  <a>http://www.usb.org/developers/docs/InterfaceAssociationDescriptor_ecn.pdf</a>. It
 allows composite
 *  devices with multiple interfaces related to the same function to have the multiple
 interfaces bound
 *  together at the point of enumeration, loading one generic driver for all the interfaces in
 the single
 *  function. Read the ECN for more information.
 *
 *  \see \ref USB_StdDescriptor_Interface_Association_t for the version of this type with
 standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	uint8_t FirstInterfaceIndex; /**< Index of the first associated interface. */
	uint8_t TotalInterfaces; /**< Total number of associated interfaces. */

	uint8_t Class; /**< Interface class ID. */
	uint8_t SubClass; /**< Interface subclass ID. */
	uint8_t Protocol; /**< Interface protocol ID. */

	uint8_t IADStrIndex; /**< Index of the string descriptor describing the
	                      *   interface association.
	                      */
} ATTR_PACKED USB_Descriptor_Interface_Association_t;

/** \brief Standard USB Interface Association Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard Interface Association Descriptor. This structure uses
 the relevant standard's given
 *  element names to ensure compatibility with the standard.
 *
 *  This descriptor has been added as a supplement to the USB2.0 standard, in the ECN located at
 *  <a>http://www.usb.org/developers/docs/InterfaceAssociationDescriptor_ecn.pdf</a>. It
 allows composite
 *  devices with multiple interfaces related to the same function to have the multiple
 interfaces bound
 *  together at the point of enumeration, loading one generic driver for all the
 interfaces in the single
 *  function. Read the ECN for more information.
 *
 *  \see \ref USB_Descriptor_Interface_Association_t for the version of this type with
 non-standard LUFA specific
 *       element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t bLength; /**< Size of the descriptor, in bytes. */
	uint8_t bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
	                          *   given by the specific class.
	                          */
	uint8_t bFirstInterface; /**< Index of the first associated interface. */
	uint8_t bInterfaceCount; /**< Total number of associated interfaces. */
	uint8_t bFunctionClass; /**< Interface class ID. */
	uint8_t bFunctionSubClass; /**< Interface subclass ID. */
	uint8_t bFunctionProtocol; /**< Interface protocol ID. */
	uint8_t iFunction; /**< Index of the string descriptor describing the
	                    *   interface association.
	                    */
} ATTR_PACKED USB_StdDescriptor_Interface_Association_t;

/** \brief Standard USB Endpoint Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard Endpoint Descriptor. This structure uses LUFA-specific element names
 *  to make each element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_Endpoint_t for the version of this type with standard element
 names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	uint8_t  EndpointAddress; /**< Logical address of the endpoint within the device for
 the current
	                           *   configuration, including direction mask.
	                           */
	uint8_t  Attributes; /**< Endpoint attributes, comprised of a mask of the endpoint
 type (EP_TYPE_*)
	                      *   and attributes (ENDPOINT_ATTR_*) masks.
	                      */
	uint16_t EndpointSize; /**< Size of the endpoint bank, in bytes. This indicates the
 maximum packet
	                        *   size that the endpoint can receive at a time.
	                        */
	uint8_t  PollingIntervalMS; /**< Polling interval in milliseconds for the endpoint
 if it is an INTERRUPT
	                             *   or ISOCHRONOUS type.
	                             */
} ATTR_PACKED USB_Descriptor_Endpoint_t;

/** \brief Standard USB Endpoint Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard Endpoint Descriptor. This structure uses the relevant
 standard's given
 *  element names to ensure compatibility with the standard.
 *
 *  \see \ref USB_Descriptor_Endpoint_t for the version of this type with non-standard LUFA
 specific
 *       element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t  bLength; /**< Size of the descriptor, in bytes. */
	uint8_t  bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a
	                           *   value given by the specific class.
	                           */
	uint8_t  bEndpointAddress; /**< Logical address of the endpoint within the
 device for the current
	                            *   configuration, including direction mask.
	                            */
	uint8_t  bmAttributes; /**< Endpoint attributes, comprised of a mask of the
 endpoint type (EP_TYPE_*)
	                        *   and attributes (ENDPOINT_ATTR_*) masks.
	                        */
	uint16_t wMaxPacketSize; /**< Size of the endpoint bank, in bytes. This indicates
 the maximum packet size
	                          *   that the endpoint can receive at a time.
	                          */
	uint8_t  bInterval; /**< Polling interval in milliseconds for the endpoint if it is
 an INTERRUPT or
	                     *   ISOCHRONOUS type.
	                     */
} ATTR_PACKED USB_StdDescriptor_Endpoint_t;

/** \brief Standard USB String Descriptor (LUFA naming conventions).
 *
 *  Type define for a standard string descriptor. Unlike other standard descriptors, the length
 *  of the descriptor for placement in the descriptor header must be determined by the
 \ref USB_STRING_LEN()
 *  macro rather than by the size of the descriptor structure, as the length is not fixed.
 *
 *  This structure should also be used for string index 0, which contains the supported
 language IDs for
 *  the device as an array.
 *
 *  This structure uses LUFA-specific element names to make each element's purpose clearer.
 *
 *  \see \ref USB_StdDescriptor_String_t for the version of this type with standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Descriptor header, including type and size. */

	wchar_t  UnicodeString[];
} ATTR_PACKED USB_Descriptor_String_t;

/** \brief Standard USB String Descriptor (USB-IF naming conventions).
 *
 *  Type define for a standard string descriptor. Unlike other standard descriptors, the length
 *  of the descriptor for placement in the descriptor header must be determined by the
 \ref USB_STRING_LEN()
 *  macro rather than by the size of the descriptor structure, as the length is not fixed.
 *
 *  This structure should also be used for string index 0, which contains the supported
 language IDs for
 *  the device as an array.
 *
 *  This structure uses the relevant standard's given element names to ensure compatibility
 with the standard.
 *
 *  \see \ref USB_Descriptor_String_t for the version of this type with with non-standard
 LUFA specific
 *       element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t bLength; /**< Size of the descriptor, in bytes. */
	uint8_t bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t
	                          *   or a value given by the specific class.
	                          */
	uint16_t bString[]; /**< String data, as unicode characters (alternatively, string
 language IDs).
	                     *   If normal ASCII characters are to be used, they must be
 added as an array
	                     *   of characters rather than a normal C string so that they
 are widened to
	                     *   Unicode size.
	                     *
	                     *   Under GCC, strings prefixed with the "L" character (before
 the opening string
	                     *   quotation mark) are considered to be Unicode strings, and may
 be used instead
	                     *   of an explicit array of ASCII characters.
	                     */
} ATTR_PACKED USB_StdDescriptor_String_t;
@* ConfigDescriptors.
@<Header files@>=
/** USB Configuration Descriptor definitions.
 *
 *  This section of the library gives a friendly API which can be used in host
 applications to easily
 *  parse an attached device's configuration descriptor so that endpoint, interface and
 other descriptor
 *  data can be extracted and used as needed.
 */

/** Casts a pointer to a descriptor inside the configuration descriptor into a pointer to the given
 *  descriptor type.
 *
 *  Usage Example:
 *  \code
 *  uint8_t* CurrDescriptor = &ConfigDescriptor[0]; // Pointing to the configuration header
 *  USB_Descriptor_Config_Header_t* ConfigHeaderPtr = DESCRIPTOR_PCAST(CurrDescriptor,
 *                                                           USB_Descriptor_Config_Header_t);
 *
 *  // Can now access elements of the configuration header struct using the -> indirection operator
 *  \endcode
 */
#define DESCRIPTOR_PCAST(DescriptorPtr, Type) ((Type*)(DescriptorPtr))

/** Casts a pointer to a descriptor inside the configuration descriptor into the given descriptor
 *  type (as an actual struct instance rather than a pointer to a struct).
 *
 *  Usage Example:
 *  \code
 *  uint8_t* CurrDescriptor = &ConfigDescriptor[0]; // Pointing to the configuration header
 *  USB_Descriptor_Config_Header_t ConfigHeader = DESCRIPTOR_CAST(CurrDescriptor,
 *                                                       USB_Descriptor_Config_Header_t);
 *
 *  // Can now access elements of the configuration header struct using the . operator
 *  \endcode
 */
#define DESCRIPTOR_CAST(DescriptorPtr, Type)  (*DESCRIPTOR_PCAST(DescriptorPtr, Type))

/** Returns the descriptor's type, expressed as the 8-bit type value in the header of the
 descriptor.
 *  This value's meaning depends on the descriptor's placement in the descriptor, but standard type
 *  values can be accessed in the \ref USB_DescriptorTypes_t enum.
 */
#define DESCRIPTOR_TYPE(DescriptorPtr) \
  DESCRIPTOR_PCAST(DescriptorPtr, USB_Descriptor_Header_t)->Type
/** Returns the descriptor's size, expressed as the 8-bit value indicating the number of bytes. */
#define DESCRIPTOR_SIZE(DescriptorPtr) \
  DESCRIPTOR_PCAST(DescriptorPtr, USB_Descriptor_Header_t)->Size
/** Type define for a Configuration Descriptor comparator function (function taking a pointer
 to an array
 *  of type void, returning a uint8_t value).
 *
 *  \see \ref USB_GetNextDescriptorComp function for more details.
 */
typedef uint8_t (* ConfigComparatorPtr_t)(void*);

/** Enum for the possible return codes of the \ref USB_Host_GetDeviceConfigDescriptor()
 function. */
enum USB_Host_GetConfigDescriptor_ErrorCodes_t
{
  HOST_GETCONFIG_Successful = 0, /**< No error occurred while retrieving the configuration
 descriptor. */
  HOST_GETCONFIG_DeviceDisconnect = 1, /**< The attached device was disconnected while
 retrieving the configuration
	                                 *   descriptor.
	                                 */
  HOST_GETCONFIG_PipeError = 2, /**< An error occurred in the pipe while sending the request. */
  HOST_GETCONFIG_SetupStalled = 3, /**< The attached device stalled the request to retrieve
 the configuration
	                            *   descriptor.
	                            */
  HOST_GETCONFIG_SoftwareTimeOut = 4, /**< The request or data transfer timed out. */
  HOST_GETCONFIG_BuffOverflow = 5, /**< The device's configuration descriptor is too large to
 fit into the allocated
		                     *   buffer.
		                     */
  HOST_GETCONFIG_InvalidData = 6, /**< The device returned invalid configuration descriptor
 data. */
};

/** Enum for return values of a descriptor comparator function. */
enum DSearch_Return_ErrorCodes_t
{
  DESCRIPTOR_SEARCH_Found = 0, /**< Current descriptor matches comparator criteria. */
  DESCRIPTOR_SEARCH_Fail  = 1, /**< No further descriptor could possibly match criteria,
 fail the search. */
  DESCRIPTOR_SEARCH_NotFound = 2, /**< Current descriptor does not match comparator criteria. */
};

/** Enum for return values of \ref USB_GetNextDescriptorComp(). */
enum DSearch_Comp_Return_ErrorCodes_t
{
  DESCRIPTOR_SEARCH_COMP_Found = 0, /**< Configuration descriptor now points to descriptor
 which matches
                                     *   search criteria of the given comparator function. */
  DESCRIPTOR_SEARCH_COMP_Fail = 1, /**< Comparator function returned
 \ref DESCRIPTOR_SEARCH_Fail. */
  DESCRIPTOR_SEARCH_COMP_EndOfDescriptor = 2, /**< End of configuration descriptor reached
 before match found. */
};

@** CDC Class Driver module. This module contains an
implementation of the USB CDC-ACM class Virtual Serial
Ports, for Device USB mode.
Note: the CDC class can instead be implemented manually via the low-level LUFA APIs.
@* CDCClassCommon.
@<Header files@>=
/** Common definitions and declarations for the library USB CDC Class driver.
 *  Constants, Types and Enum definitions that are common to both Device and Host modes for the USB
 *  CDC Class.
 */

/** \name Virtual Control Line Masks */

/** Mask for the DTR handshake line for use with the \ref CDC_REQ_SetControlLineState
 class-specific request
 *  from the host, to indicate that the DTR line state should be high.
 */
#define CDC_CONTROL_LINE_OUT_DTR         (1 << 0)

/** Mask for the RTS handshake line for use with the \ref CDC_REQ_SetControlLineState
 class-specific request
 *  from the host, to indicate that the RTS line state should be high.
 */
#define CDC_CONTROL_LINE_OUT_RTS         (1 << 1)

/** Mask for the DCD handshake line for use with the \ref CDC_NOTIF_SerialState class-specific
 notification
 *  from the device to the host, to indicate that the DCD line state is currently high.
 */
#define CDC_CONTROL_LINE_IN_DCD          (1 << 0)

/** Mask for the DSR handshake line for use with the \ref CDC_NOTIF_SerialState class-specific
 notification
 *  from the device to the host, to indicate that the DSR line state is currently high.
 */
#define CDC_CONTROL_LINE_IN_DSR          (1 << 1)

/** Mask for the BREAK handshake line for use with the \ref CDC_NOTIF_SerialState class-specific
 notification
 *  from the device to the host, to indicate that the BREAK line state is currently high.
 */
#define CDC_CONTROL_LINE_IN_BREAK        (1 << 2)

/** Mask for the RING handshake line for use with the \ref CDC_NOTIF_SerialState class-specific
 notification
 *  from the device to the host, to indicate that the RING line state is currently high.
 */
#define CDC_CONTROL_LINE_IN_RING         (1 << 3)

/** Mask for use with the \ref CDC_NOTIF_SerialState class-specific notification from the device
 to the host,
 *  to indicate that a framing error has occurred on the virtual serial port.
 */
#define CDC_CONTROL_LINE_IN_FRAMEERROR   (1 << 4)

/** Mask for use with the \ref CDC_NOTIF_SerialState class-specific notification from the device
 to the host,
 *  to indicate that a parity error has occurred on the virtual serial port.
 */
#define CDC_CONTROL_LINE_IN_PARITYERROR  (1 << 5)

/** Mask for use with the \ref CDC_NOTIF_SerialState class-specific notification from the device
 to the host,
 *  to indicate that a data overrun error has occurred on the virtual serial port.
 */
#define CDC_CONTROL_LINE_IN_OVERRUNERROR (1 << 6)

/** Macro to define a CDC class-specific functional descriptor. CDC functional descriptors have a
 *  uniform structure but variable sized data payloads, thus cannot be represented accurately by
 *  a single \c typedef \c struct. A macro is used instead so that functional descriptors
 can be created
 *  easily by specifying the size of the payload. This allows \c sizeof() to work correctly.
 *
 *  \param[in] DataSize  Size in bytes of the CDC functional descriptor's data payload.
 */
#define CDC_FUNCTIONAL_DESCRIPTOR(DataSize)        \
     struct                                        \
     {                                             \
          USB_Descriptor_Header_t Header;          \
	      uint8_t                 SubType;         \
          uint8_t                 Data[DataSize];  \
     }

/** Enum for possible Class, Subclass and Protocol values of device and interface descriptors
 relating to the CDC
 *  device class.
 */
enum CDC_Descriptor_ClassSubclassProtocol_t
{
  CDC_CSCP_CDCClass = 0x02, /**< Descriptor Class value indicating that the device or interface
	                                         *   belongs to the CDC class.
	                                         */
  CDC_CSCP_NoSpecificSubclass = 0x00, /**< Descriptor Subclass value indicating that the
 device or interface
	                                *   belongs to no specific subclass of the CDC class.
	                                */
  CDC_CSCP_ACMSubclass = 0x02, /**< Descriptor Subclass value indicating that the device or
 interface
			        *   belongs to the Abstract Control Model CDC subclass.
			        */
  CDC_CSCP_ATCommandProtocol = 0x01, /**< Descriptor Protocol value indicating that the device
 or interface
	                              *   belongs to the AT Command protocol of the CDC class.
	                              */
  CDC_CSCP_NoSpecificProtocol = 0x00, /**< Descriptor Protocol value indicating that the device
 or interface
	                               *   belongs to no specific protocol of the CDC class.
	                               */
  CDC_CSCP_VendorSpecificProtocol = 0xFF, /**< Descriptor Protocol value indicating that the
 device or interface
	                                   *   belongs to a vendor-specific protocol of the CDC class.
	                                   */
  CDC_CSCP_CDCDataClass = 0x0A, /**< Descriptor Class value indicating that the device or interface
			         *   belongs to the CDC Data class.
			         */
  CDC_CSCP_NoDataSubclass = 0x00, /**< Descriptor Subclass value indicating that the device or
 interface
                                   *   belongs to no specific subclass of the CDC data class.
                                   */
  CDC_CSCP_NoDataProtocol = 0x00, /**< Descriptor Protocol value indicating that the device
 or interface
                                  *   belongs to no specific protocol of the CDC data class.
                                  */
};

/** Enum for the CDC class specific control requests that can be issued by the USB bus host. */
enum CDC_ClassRequests_t
{
  CDC_REQ_SendEncapsulatedCommand = 0x00, /**< CDC class-specific request to send an
 encapsulated command to the device. */
  CDC_REQ_GetEncapsulatedResponse = 0x01, /**< CDC class-specific request to retrieve an
 encapsulated command response from the device. */
  CDC_REQ_SetLineEncoding = 0x20, /**< CDC class-specific request to set the current virtual
 serial port configuration settings. */
  CDC_REQ_GetLineEncoding = 0x21, /**< CDC class-specific request to get the current virtual
 serial port configuration settings. */
  CDC_REQ_SetControlLineState = 0x22, /**< CDC class-specific request to set the current
 virtual serial port handshake line states. */
  CDC_REQ_SendBreak = 0x23, /**< CDC class-specific request to send a break to the receiver
 via the carrier channel. */
};

/** Enum for the CDC class specific notification requests that can be issued by a CDC device
 to a host. */
enum CDC_ClassNotifications_t
{
  CDC_NOTIF_SerialState = 0x20, /**< Notification type constant for a change in the virtual
 serial port
                     *   handshake line states, for use with a \ref USB_Request_Header_t
                     *   notification structure when sent to the host via the CDC notification
	                         *   endpoint.
	                         */
};

/** Enum for the CDC class specific interface descriptor subtypes. */
enum CDC_DescriptorSubtypes_t
{
  CDC_DSUBTYPE_CSInterface_Header = 0x00, /**< CDC class-specific Header functional descriptor. */
  CDC_DSUBTYPE_CSInterface_CallManagement = 0x01, /**< CDC class-specific Call Management
 functional descriptor. */
  CDC_DSUBTYPE_CSInterface_ACM = 0x02, /**< CDC class-specific Abstract Control Model functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_DirectLine = 0x03, /**< CDC class-specific Direct Line functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_TelephoneRinger = 0x04, /**< CDC class-specific Telephone Ringer
 functional descriptor. */
  CDC_DSUBTYPE_CSInterface_TelephoneCall = 0x05, /**< CDC class-specific Telephone Call
 functional descriptor. */
  CDC_DSUBTYPE_CSInterface_Union = 0x06, /**< CDC class-specific Union functional descriptor. */
  CDC_DSUBTYPE_CSInterface_CountrySelection = 0x07, /**< CDC class-specific Country Selection
 functional descriptor. */
  CDC_DSUBTYPE_CSInterface_TelephoneOpModes = 0x08, /**< CDC class-specific Telephone Operation
 Modes functional descriptor. */
  CDC_DSUBTYPE_CSInterface_USBTerminal = 0x09, /**< CDC class-specific USB Terminal functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_NetworkChannel = 0x0A, /**< CDC class-specific Network Channel
 functional descriptor. */
  CDC_DSUBTYPE_CSInterface_ProtocolUnit = 0x0B, /**< CDC class-specific Protocol Unit functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_ExtensionUnit = 0x0C, /**< CDC class-specific Extension Unit functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_MultiChannel = 0x0D, /**< CDC class-specific Multi-Channel Management
 functional descriptor. */
  CDC_DSUBTYPE_CSInterface_CAPI = 0x0E, /**< CDC class-specific Common ISDN API functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_Ethernet = 0x0F, /**< CDC class-specific Ethernet functional
 descriptor. */
  CDC_DSUBTYPE_CSInterface_ATM = 0x10, /**< CDC class-specific Asynchronous Transfer Mode
 functional descriptor. */
};

/** Enum for the possible line encoding formats of a virtual serial port. */
enum CDC_LineEncodingFormats_t
{
  CDC_LINEENCODING_OneStopBit          = 0, /**< Each frame contains one stop bit. */
  CDC_LINEENCODING_OneAndAHalfStopBits = 1, /**< Each frame contains one and a half stop bits. */
  CDC_LINEENCODING_TwoStopBits         = 2, /**< Each frame contains two stop bits. */
};

/** Enum for the possible line encoding parity settings of a virtual serial port. */
enum CDC_LineEncodingParity_t
{
	CDC_PARITY_None  = 0, /**< No parity bit mode on each frame. */
	CDC_PARITY_Odd   = 1, /**< Odd parity bit mode on each frame. */
	CDC_PARITY_Even  = 2, /**< Even parity bit mode on each frame. */
	CDC_PARITY_Mark  = 3, /**< Mark parity bit mode on each frame. */
	CDC_PARITY_Space = 4, /**< Space parity bit mode on each frame. */
};

/** \brief CDC class-specific Functional Header Descriptor (LUFA naming conventions).
 *
 *  Type define for a CDC class-specific functional header descriptor. This indicates to the
 host that the device
 *  contains one or more CDC functional data descriptors, which give the CDC interface's
 capabilities and configuration.
 *  See the CDC class specification for more details.
 *
 *  \see \ref USB_CDC_StdDescriptor_FunctionalHeader_t for the version of this type with
 standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
  USB_Descriptor_Header_t Header; /**< Regular descriptor header containing the descriptor's
 type and length. */
  uint8_t Subtype; /**< Sub type value used to distinguish between CDC class-specific descriptors,
                    *   must be \ref CDC_DSUBTYPE_CSInterface_Header.
                    */
  uint16_t CDCSpecification; /**< Version number of the CDC specification implemented by the
 device,
                             *   encoded in BCD format.
                             *
                             *   \see \ref VERSION_BCD() utility macro.
                             */
} ATTR_PACKED USB_CDC_Descriptor_Func_Header_t;

/** \brief CDC class-specific Functional Header Descriptor (USB-IF naming conventions).
 *
 *  Type define for a CDC class-specific functional header descriptor. This indicates to the host
 that the device
 *  contains one or more CDC functional data descriptors, which give the CDC interface's
 capabilities and configuration.
 *  See the CDC class specification for more details.
 *
 *  \see \ref USB_CDC_Descriptor_Func_Header_t for the version of this type with non-standard
 LUFA specific
 *       element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
  uint8_t  bFunctionLength; /**< Size of the descriptor, in bytes. */
  uint8_t  bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
                           *   given by the specific class.
                           */
  uint8_t  bDescriptorSubType; /**< Sub type value used to distinguish between CDC
 class-specific descriptors,
	                        *   must be \ref CDC_DSUBTYPE_CSInterface_Header.
	                        */
  uint16_t bcdCDC; /**< Version number of the CDC specification implemented by the device,
 encoded in BCD format.
	            *
	            *   \see \ref VERSION_BCD() utility macro.
	            */
} ATTR_PACKED USB_CDC_StdDescriptor_FunctionalHeader_t;

/** \brief CDC class-specific Functional ACM Descriptor (LUFA naming conventions).
 *
 *  Type define for a CDC class-specific functional ACM descriptor. This indicates to the
 host that the CDC interface
 *  supports the CDC ACM subclass of the CDC specification. See the CDC class specification
 for more details.
 *
 *  \see \ref USB_CDC_StdDescriptor_FunctionalACM_t for the version of this type with
 standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
  USB_Descriptor_Header_t Header; /**< Regular descriptor header containing the descriptor's
 type and length. */
  uint8_t                 Subtype; /**< Sub type value used to distinguish between CDC
 class-specific descriptors,
	                             *   must be \ref CDC_DSUBTYPE_CSInterface_ACM.
	                             */
  uint8_t                 Capabilities; /**< Capabilities of the ACM interface, given as a bit
 mask. For most devices,
	                             *   this should be set to a fixed value of \c 0x06 - for
 other capabilities, refer
	                             *   to the CDC ACM specification.
	                             */
} ATTR_PACKED USB_CDC_Descriptor_Func_ACM_t;

/** \brief CDC class-specific Functional ACM Descriptor (USB-IF naming conventions).
 *
 *  Type define for a CDC class-specific functional ACM descriptor. This indicates to the host
 that the CDC interface
 *  supports the CDC ACM subclass of the CDC specification. See the CDC class specification for
 more details.
 *
 *  \see \ref USB_CDC_Descriptor_Func_ACM_t for the version of this type with non-standard
 LUFA specific
 *       element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t bFunctionLength; /**< Size of the descriptor, in bytes. */
	uint8_t bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
	                          *   given by the specific class.
	                          */
	uint8_t bDescriptorSubType; /**< Sub type value used to distinguish between CDC
 class-specific descriptors,
	                             *   must be \ref CDC_DSUBTYPE_CSInterface_ACM.
	                             */
	uint8_t bmCapabilities; /**< Capabilities of the ACM interface, given as a bit mask.
 For most devices,
	                         *   this should be set to a fixed value of 0x06 - for other
 capabilities, refer
	                         *   to the CDC ACM specification.
	                         */
} ATTR_PACKED USB_CDC_StdDescriptor_FunctionalACM_t;

/** \brief CDC class-specific Functional Union Descriptor (LUFA naming conventions).
 *
 *  Type define for a CDC class-specific functional Union descriptor. This indicates to the
 host that specific
 *  CDC control and data interfaces are related. See the CDC class specification for more details.
 *
 *  \see \ref USB_CDC_StdDescriptor_FunctionalUnion_t for the version of this type with
 standard element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	USB_Descriptor_Header_t Header; /**< Regular descriptor header containing the
 descriptor's type and length. */
	uint8_t                 Subtype; /**< Sub type value used to distinguish between CDC
 class-specific descriptors,
	                                  *   must be \ref CDC_DSUBTYPE_CSInterface_Union.
	                                  */
	uint8_t                 MasterInterfaceNumber; /**< Interface number of the CDC
 Control interface. */
	uint8_t                 SlaveInterfaceNumber; /**< Interface number of the CDC Data
 interface. */
} ATTR_PACKED USB_CDC_Descriptor_Func_Union_t;

/** \brief CDC class-specific Functional Union Descriptor (USB-IF naming conventions).
 *
 *  Type define for a CDC class-specific functional Union descriptor. This indicates to the
 host that specific
 *  CDC control and data interfaces are related. See the CDC class specification for more details.
 *
 *  \see \ref USB_CDC_Descriptor_Func_Union_t for the version of this type with non-standard
 LUFA specific
 *       element names.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint8_t bFunctionLength; /**< Size of the descriptor, in bytes. */
	uint8_t bDescriptorType; /**< Type of the descriptor, either a value in
 \ref USB_DescriptorTypes_t or a value
	                          *   given by the specific class.
	                          */
	uint8_t bDescriptorSubType; /**< Sub type value used to distinguish between CDC
 class-specific descriptors,
	                             *   must be \ref CDC_DSUBTYPE_CSInterface_Union.
	                             */
	uint8_t bMasterInterface; /**< Interface number of the CDC Control interface. */
	uint8_t bSlaveInterface0; /**< Interface number of the CDC Data interface. */
} ATTR_PACKED USB_CDC_StdDescriptor_FunctionalUnion_t;

/** \brief CDC Virtual Serial Port Line Encoding Settings Structure.
 *
 *  Type define for a CDC Line Encoding structure, used to hold the various encoding
 parameters for a virtual
 *  serial port.
 *
 *  \note Regardless of CPU architecture, these values should be stored as little endian.
 */
typedef struct
{
	uint32_t BaudRateBPS; /**< Baud rate of the virtual serial port, in bits per second. */
	uint8_t  CharFormat; /**< Character format of the virtual serial port, a value from the
			  *   \ref CDC_LineEncodingFormats_t enum.
		  */
	uint8_t  ParityType; /**< Parity setting of the virtual serial port, a value from the
		  *   \ref CDC_LineEncodingParity_t enum.
		  */
	uint8_t  DataBits; /**< Bits of data per character of the virtual serial port. */
} ATTR_PACKED CDC_LineEncoding_t;
@* CDCClassDevice.
@<Header files@>=
/** Device mode driver for the library USB CDC Class driver.
 *
 *  Device mode driver for the library USB CDC Class driver.
 *
 */

/** \section Sec_USBClassCDCDevice_ModDescription Module Description
 *  Device Mode USB Class driver framework interface, for the CDC USB Class driver.
 *
 *  \note There are several major drawbacks to the CDC-ACM standard USB class, however
 *        it is very standardized and thus usually available as a built-in driver on
 *        most platforms, and so is a better choice than a proprietary serial class.
 *
 *        One major issue with CDC-ACM is that it requires two Interface descriptors,
 *        which will upset most hosts when part of a multi-function "Composite" USB
 *        device. This is because each interface will be loaded into a separate driver
 *        instance, causing the two interfaces be become unlinked. To prevent this, you
 *        should use the "Interface Association Descriptor" addendum to the USB 2.0 standard
 *        which is available on most OSes when creating Composite devices.
 *
 *        Another major oversight is that there is no mechanism for the host to notify the
 *        device that there is a data sink on the host side ready to accept data. This
 *        means that the device may try to send data while the host isn't listening, causing
 *        lengthy blocking timeouts in the transmission routines. It is thus highly recommended
 *        that the virtual serial line DTR (Data Terminal Ready) signal be used where possible
 *        to determine if a host application is ready for data.
 *
 *   http://www.recursion.jp/prose/avrcdc/
 */

/** \brief CDC Class Device Mode Configuration and State Structure.
 *
 *  Class state structure. An instance of this structure should be made for each CDC interface
 *  within the user application, and passed to each of the CDC class driver functions as the
 *  CDCInterfaceInfo parameter. This stores each CDC interface's configuration and state
 information.
 */
typedef struct
{
  struct
  {
    uint8_t ControlInterfaceNumber; /**< Interface number of the CDC control interface within
 the device. */

    USB_Endpoint_Table_t DataINEndpoint; /**< Data IN endpoint configuration table. */
    USB_Endpoint_Table_t DataOUTEndpoint; /**< Data OUT endpoint configuration table. */
    USB_Endpoint_Table_t NotificationEndpoint; /**< Notification IN Endpoint configuration
 table. */
  } Config; /**< Config data for the USB class interface within the device. All elements in
 this section
           *   <b>must</b> be set or the interface will fail to enumerate and operate correctly.
           */
  struct
  {
    struct
    {
      uint16_t HostToDevice; /**< Control line states from the host to device, as a set of
 \c CDC_CONTROL_LINE_OUT_*
			    *   masks. This value is updated each time
 \ref CDC_DeviceTask() is called.
			    */
    uint16_t DeviceToHost; /**< Control line states from the device to host, as a set of
 \c CDC_CONTROL_LINE_IN_*
		    *   masks - to notify the host of changes to these values, call the
		    *   \ref CDC_Device_SendControlLineStateChange() function.
		    */
  } ControlLineStates; /**< Current states of the virtual serial port's control lines between
 the device and host. */

  CDC_LineEncoding_t LineEncoding; /**< Line encoding used in the virtual serial port, for the
 device's information.
                         *   This is generally only used if the virtual serial port data is to be
                                  *   reconstructed on a physical UART.
                                  */
  } State; /**< State data for the USB class interface within the device. All elements in this
 section
	          *   are reset to their defaults when the interface is enumerated.
	          */
} USB_ClassInfo_CDC_Device_t;

/** Configures the endpoints of a given CDC interface, ready for use. This should be linked to
 the library
 *  \ref EVENT_USB_Device_ConfigurationChanged() event so that the endpoints are configured when
 the configuration containing
 *  the given CDC interface is selected.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 *
 *  \return Boolean \c true if the endpoints were successfully configured, \c false otherwise.
 */
bool CDC_Device_ConfigureEndpoints(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** Processes incoming control requests from the host, that are directed to the given CDC
 class interface. This should be
 *  linked to the library \ref EVENT_USB_Device_ControlRequest() event.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 */
void CDC_Device_ProcessControlRequest(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** General management task for a given CDC class interface, required for the correct operation
 of the interface. This should
 *  be called frequently in the main program loop, before the master USB management task
|USB_DeviceTask|.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 */
void CDC_DeviceTask(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** CDC class driver event for a line encoding change on a CDC interface. This event fires each
 time the host requests a
 *  line encoding change (containing the serial parity, baud and other configuration information)
 and may be hooked in the
 *  user program by declaring a handler function with the same name and parameters listed here.
 The new line encoding
 *  settings are available in the \c LineEncoding structure inside the CDC interface structure
 passed as a parameter.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 */
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** CDC class driver event for a control line state change on a CDC interface. This event fires
 each time the host requests a
 *  control line state change (containing the virtual serial control line states, such as DTR)
 and may be hooked in the
 *  user program by declaring a handler function with the same name and parameters listed here.
 The new control line states
 *  are available in the \c ControlLineStates.HostToDevice value inside the CDC interface
 structure passed as a parameter, set as
 *  a mask of \c CDC_CONTROL_LINE_OUT_* masks.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 */
void EVENT_CDC_Device_ControLineStateChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_CONST ATTR_NON_NULL_PTR_ARG(1);

/** CDC class driver event for a send break request sent to the device from the host. This is
 generally used to separate
 *  data or to indicate a special condition to the receiving device.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 *  \param[in]     Duration          Duration of the break that has been sent by the host,
 in milliseconds.
 */
void EVENT_CDC_Device_BreakSent(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                               const uint8_t Duration) ATTR_CONST ATTR_NON_NULL_PTR_ARG(1);

/** Sends a given data buffer to the attached USB host, if connected. If a host is not connected
 when the function is
 *  called, the string is discarded. Bytes will be queued for transmission to the host until
 either the endpoint bank
 *  becomes full, or the \ref CDC_Device_Flush() function is called to flush the pending data
 to the host. This allows
 *  for multiple bytes to be packed into a single endpoint packet, increasing data throughput.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *  \param[in]     Buffer            Pointer to a buffer containing the data to send to the device.
 *  \param[in]     Length            Length of the data to send to the host.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.
 */
uint8_t CDC_Device_SendData(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const void* const Buffer,
                       const uint16_t Length) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);

/** Sends a given data buffer from PROGMEM space to the attached USB host, if connected. If a
 host is not connected when the
 *  function is called, the string is discarded. Bytes will be queued for transmission to the
 host until either the endpoint
 *  bank becomes full, or the \ref CDC_Device_Flush() function is called to flush the pending
 data to the host. This allows
 *  for multiple bytes to be packed into a single endpoint packet, increasing data throughput.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *  \param[in]     Buffer            Pointer to a buffer containing the data to send to the device.
 *  \param[in]     Length            Length of the data to send to the host.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.
 */
uint8_t CDC_Device_SendData_P(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const void* const Buffer,
                       const uint16_t Length) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);

/** Sends a given null terminated string to the attached USB host, if connected. If a host is
 not connected when
 *  the function is called, the string is discarded. Bytes will be queued for transmission
 to the host until either
 *  the endpoint bank becomes full, or the \ref CDC_Device_Flush() function is called to
 flush the pending data to
 *  the host. This allows for multiple bytes to be packed into a single endpoint packet,
 increasing data throughput.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 *  \param[in]     String            Pointer to the null terminated string to send to the host.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.
 */
uint8_t CDC_Device_SendString(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                      const char* const String) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);

/** Sends a given null terminated string from PROGMEM space to the attached USB host, if
 connected. If a host is not connected
 *  when the function is called, the string is discarded. Bytes will be queued for
 transmission to the host until either
 *  the endpoint bank becomes full, or the \ref CDC_Device_Flush() function is called to
 flush the pending data to
 *  the host. This allows for multiple bytes to be packed into a single endpoint packet,
 increasing data throughput.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *  \param[in]     String            Pointer to the null terminated string to send to the host.
 *
 *  \return A value from the \ref Endpoint_Stream_RW_ErrorCodes_t enum.
 */
uint8_t CDC_Device_SendString_P(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                   const char* const String) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);

/** Sends a given byte to the attached USB host, if connected. If a host is not connected
 when the function is called, the
 *  byte is discarded. Bytes will be queued for transmission to the host until either the
 endpoint bank becomes full, or the
 *  \ref CDC_Device_Flush() function is called to flush the pending data to the host. This
 allows for multiple bytes to be
 *  packed into a single endpoint packet, increasing data throughput.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *  \param[in]     Data              Byte of data to send to the host.
 *
 *  \return A value from the \ref Endpoint_WaitUntilReady_ErrorCodes_t enum.
 */
uint8_t CDC_Device_SendByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                            const uint8_t Data) ATTR_NON_NULL_PTR_ARG(1);

/** Determines the number of bytes received by the CDC interface from the host, waiting
 to be read. This indicates the number
 *  of bytes in the OUT endpoint bank only, and thus the number of calls to
 \ref CDC_Device_ReceiveByte() which are guaranteed to
 *  succeed immediately. If multiple bytes are to be received, they should be buffered by
 the user application, as the endpoint
 *  bank will not be released back to the USB controller until all bytes are read.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *
 *  \return Total number of buffered bytes received from the host.
 */
uint16_t CDC_Device_BytesReceived(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** Reads a byte of data from the host. If no data is waiting to be read of if a USB host is
 not connected, the function
 *  returns a negative value. The \ref CDC_Device_BytesReceived() function may be queried in
 advance to determine how many
 *  bytes are currently buffered in the CDC interface's data receive endpoint bank, and thus how
 many repeated calls to this
 *  function which are guaranteed to succeed.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *
 *  \return Next received byte from the host, or a negative value if no data received.
 */
int16_t CDC_Device_ReceiveByte(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** Flushes any data waiting to be sent, ensuring that the send buffer is cleared.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class configuration
 and state.
 *
 *  \return A value from the \ref Endpoint_WaitUntilReady_ErrorCodes_t enum.
 */
uint8_t CDC_Device_Flush(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** Sends a Serial Control Line State Change notification to the host. This should be called
 when the virtual serial
 *  control lines (DCD, DSR, etc.) have changed states, or to give BREAK notifications to
 the host. Line states persist
 *  until they are cleared via a second notification. This should be called each time the CDC
 class driver's
 *  \c ControlLineStates.DeviceToHost value is updated to push the new states to the USB host.
 *
 *  \pre This function must only be called when the Device state machine is in the
 \ref DEVICE_STATE_Configured state or
 *       the call will fail.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 */
void CDC_Device_SendControlLineStateChange(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
 ATTR_NON_NULL_PTR_ARG(1);

/** Creates a standard character stream for the given CDC Device instance so that it can be
 used with all the regular
 *  functions in the standard <stdio.h> library that accept a \c FILE stream as a destination
 (e.g. \c fprintf()). The created
 *  stream is bidirectional and can be used for both input and output functions.
 *
 *  Reading data from this stream is non-blocking, i.e. in most instances, complete strings
 cannot be read in by a single
 *  fetch, as the endpoint will not be ready at some point in the transmission, aborting the
 transfer. However, this may
 *  be used when the read data is processed byte-per-bye (via \c getc()) or when the user
 application will implement its own
 *  line buffering.
 *
 *  \note The created stream can be given as \c stdout if desired to direct the standard
 output from all \c <stdio.h> functions
 *        to the given CDC interface.
 *        \n\n
 *
 *  \note This function is not available on all microcontroller architectures.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *  \param[in,out] Stream            Pointer to a FILE structure where the created stream
 should be placed.
 */
void CDC_Device_CreateStream(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                         FILE* const Stream) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);

/** Identical to \ref CDC_Device_CreateStream(), except that reads are blocking until the
 calling stream function terminates
 *  the transfer. While blocking, the USB and CDC service tasks are called repeatedly to
 maintain USB communications.
 *
 *  \note This function is not available on all microcontroller architectures.
 *
 *  \param[in,out] CDCInterfaceInfo  Pointer to a structure containing a CDC Class
 configuration and state.
 *  \param[in,out] Stream            Pointer to a FILE structure where the created stream
 should be placed.
 */
void CDC_Device_CreateBlockingStream(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                           FILE* const Stream) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);

@** LEDs.
LED board hardware driver for user controllable LEDs.

Hardware LEDs driver. This provides an easy to use driver for the hardware LEDs. It
provides an interface to configure, test and change the status of all the board LEDs.

It will include the appropriate built-in board driver header file.

Following is an example of how this module may be used within a typical
application.

@(/dev/null@>=
// Initialize the board LED driver before first use
LEDs_Init();

// Turn on each of the four LEDs in turn
LEDs_SetAllLEDs(LEDS_LED1);
LEDs_SetAllLEDs(LEDS_LED2);
LEDs_SetAllLEDs(LEDS_LED3);
LEDs_SetAllLEDs(LEDS_LED4);

// Turn on all LEDs
LEDs_SetAllLEDs(LEDS_ALL_LEDS);

// Turn on LED 1, turn off LED 2, leaving LEDs 3 and 4 in their current state
LEDs_ChangeLEDs((LEDS_LED1 | LEDS_LED2), LEDS_LED1);

@* USBKEY LEDs.
@<Header files@>=
/** Board specific LED driver header for the Atmel USBKEY.

<table>
 <tr><th>Name</th><th>Color</th><th>Info</th><th>Active Level</th><th>Port Pin</th></tr>
 <tr><td>LEDS_LED1</td><td>Red</td><td>Bicolor Indicator 1</td><td>High</td><td>PORTD.4</td></tr>
 <tr><td>LEDS_LED2</td><td>Green</td><td>Bicolor Indicator 1</td><td>High</td><td>PORTD.5</td></tr>
 <tr><td>LEDS_LED3</td><td>Red</td><td>Bicolor Indicator 2</td><td>High</td><td>PORTD.6</td></tr>
 <tr><td>LEDS_LED4</td><td>Green</td><td>Bicolor Indicator 2</td><td>High</td><td>PORTD.7</td></tr>
</table>

 */

/** LED mask for the first LED on the board. */
#define LEDS_LED1        (1 << 4)

/** LED mask for the second LED on the board. */
#define LEDS_LED2        (1 << 5)

/** LED mask for the third LED on the board. */
#define LEDS_LED3        (1 << 7)

/** LED mask for the fourth LED on the board. */
#define LEDS_LED4        (1 << 6)

/** LED mask for all the LEDs on the board. */
#define LEDS_ALL_LEDS    (LEDS_LED1 | LEDS_LED2 | LEDS_LED3 | LEDS_LED4)

/** LED mask for none of the board LEDs. */
#define LEDS_NO_LEDS     0

inline void LEDs_Init(void)
{
	DDRD  |=  LEDS_ALL_LEDS;
	PORTD &= ~LEDS_ALL_LEDS;
}

inline void LEDs_Disable(void)
{
	DDRD  &= ~LEDS_ALL_LEDS;
	PORTD &= ~LEDS_ALL_LEDS;
}

inline void LEDs_TurnOnLEDs(const uint8_t LEDMask)
{
	PORTD |= LEDMask;
}

inline void LEDs_TurnOffLEDs(const uint8_t LEDMask)
{
	PORTD &= ~LEDMask;
}

inline void LEDs_SetAllLEDs(const uint8_t LEDMask)
{
	PORTD = ((PORTD & ~LEDS_ALL_LEDS) | LEDMask);
}

inline void LEDs_ChangeLEDs(const uint8_t LEDMask, const uint8_t ActiveMask)
{
	PORTD = ((PORTD & ~LEDMask) | ActiveMask);
}

inline void LEDs_ToggleLEDs(const uint8_t LEDMask)
{
	PIND  = LEDMask;
}

inline uint8_t LEDs_GetLEDs(void) ATTR_WARN_UNUSED_RESULT;
inline uint8_t LEDs_GetLEDs(void)
{
	return (PORTD & LEDS_ALL_LEDS);
}

@** RingBuffer.
Lightweight ring (circular) buffer, for fast insertion/deletion of bytes.

Lightweight ring buffer, for fast insertion/deletion. Multiple buffers can be created of
different sizes to suit different needs.

Note that for each buffer, insertion and removal operations may occur at the same time (via
a multi-threaded ISR based system) however the same kind of operation (two or more insertions
or deletions) must not overlap. If there is possibility of two or more of the same kind of
operating occurring at the same point in time, atomic (mutex) locking should be used.

@* Generic Byte Ring Buffer.
Lightweight ring buffer, for fast insertion/deletion of bytes.
Multiple buffers can be created of
different sizes to suit different needs.

Note that for each buffer, insertion and removal operations may occur at the same time (via
a multi-threaded ISR based system) however the same kind of operation (two or more insertions
or deletions) must not overlap. If there is possibility of two or more of the same kind of
operating occurring at the same point in time, atomic (mutex) locking should be used.

@ The following snippet is an example of how this module may be used within a typical
application.

@(/dev/null@>=
// Create the buffer structure and its underlying storage array
RingBuffer_t Buffer;
uint8_t      BufferData[128];

// Initialize the buffer with the created storage array
RingBuffer_InitBuffer(&Buffer, BufferData, sizeof(BufferData));

// Insert some data into the buffer
RingBuffer_Insert(&Buffer, 'H');
RingBuffer_Insert(&Buffer, 'E');
RingBuffer_Insert(&Buffer, 'L');
RingBuffer_Insert(&Buffer, 'L');
RingBuffer_Insert(&Buffer, 'O');

// Cache the number of stored bytes in the buffer
uint16_t BufferCount = RingBuffer_GetCount(&Buffer);

// Printer stored data length
printf("Buffer Length: %d, Buffer Data: \r\n", BufferCount);

// Print contents of the buffer one character at a time
while (BufferCount--)
  putc(RingBuffer_Remove(&Buffer));

@ Ring Buffer Management Structure.

Type define for a new ring buffer object. Buffers should be initialized via a call to
|RingBuffer_InitBuffer| before use.

@<Header files@>=
typedef struct {
	uint8_t* In; /**< Current storage location in the circular buffer. */
	uint8_t* Out; /**< Current retrieval location in the circular buffer. */
	uint8_t* Start; /**< Pointer to the start of the buffer's underlying storage array. */
	uint8_t* End; /**< Pointer to the end of the buffer's underlying storage array. */
	uint16_t Size; /**< Size of the buffer's underlying storage array. */
	uint16_t Count; /**< Number of bytes currently stored in the buffer. */
} RingBuffer_t;

@ Initializes a ring buffer ready for use. Buffers must be initialized via this function
before any operations are called upon them. Already initialized buffers may be reset
by re-initializing them using this function.

|Buffer| is a pointer to a ring buffer structure to initialize. \par
|DataPtr| is a pointer to a global array that will hold the data stored into the ring buffer. \par
|Size| is a maximum number of bytes that can be stored in the underlying data array. \par

@<Header files@>=
inline void RingBuffer_InitBuffer(RingBuffer_t* Buffer, uint8_t* const DataPtr,
                     const uint16_t Size) ATTR_NON_NULL_PTR_ARG(1) ATTR_NON_NULL_PTR_ARG(2);
inline void RingBuffer_InitBuffer(RingBuffer_t* Buffer,
                                        uint8_t* const DataPtr,
                                        const uint16_t Size)
{
	GCC_FORCE_POINTER_ACCESS(Buffer);

	uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
	GlobalInterruptDisable();

	Buffer->In     = DataPtr;
	Buffer->Out    = DataPtr;
	Buffer->Start  = &DataPtr[0];
	Buffer->End    = &DataPtr[Size];
	Buffer->Size   = Size;
	Buffer->Count  = 0;

	SetGlobalInterruptMask(CurrentGlobalInt);
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

@<Header files@>=
inline uint16_t RingBuffer_GetCount(RingBuffer_t* const Buffer) ATTR_WARN_UNUSED_RESULT
  ATTR_NON_NULL_PTR_ARG(1);
inline uint16_t RingBuffer_GetCount(RingBuffer_t* const Buffer)
{
	uint16_t Count;

	uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
	GlobalInterruptDisable();

	Count = Buffer->Count;

	SetGlobalInterruptMask(CurrentGlobalInt);
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

@<Header files@>=
inline uint16_t RingBuffer_GetFreeCount(RingBuffer_t* const Buffer) ATTR_WARN_UNUSED_RESULT
  ATTR_NON_NULL_PTR_ARG(1);
inline uint16_t RingBuffer_GetFreeCount(RingBuffer_t* const Buffer)
{
	return (Buffer->Size - RingBuffer_GetCount(Buffer));
}

@ Atomically determines if the specified ring buffer contains any data. This should
be tested before removing data from the buffer, to ensure that the buffer does not
underflow.

If the data is to be removed in a loop, store the total number of bytes stored in the
buffer (via a call to the \ref RingBuffer_GetCount() function) in a temporary variable
to reduce the time spent in atomicity locks.

|Buffer| is a pointer to a ring buffer structure to insert into.

Returns true if the buffer contains no free space, false otherwise.

@<Header files@>=
inline bool RingBuffer_IsEmpty(RingBuffer_t* const Buffer) ATTR_WARN_UNUSED_RESULT
  ATTR_NON_NULL_PTR_ARG(1);
inline bool RingBuffer_IsEmpty(RingBuffer_t* const Buffer)
{
	return (RingBuffer_GetCount(Buffer) == 0);
}

@ Atomically determines if the specified ring buffer contains any free space. This should
be tested before storing data to the buffer, to ensure that no data is lost due to a
buffer overrun.

|Buffer| is a pointer to a ring buffer structure to insert into.

Returns true if the buffer contains no free space, false otherwise.

@<Header files@>=
inline bool RingBuffer_IsFull(RingBuffer_t* const Buffer) ATTR_WARN_UNUSED_RESULT
  ATTR_NON_NULL_PTR_ARG(1);
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

@<Header files@>=
inline void RingBuffer_Insert(RingBuffer_t* Buffer, const uint8_t Data) ATTR_NON_NULL_PTR_ARG(1);
inline void RingBuffer_Insert(RingBuffer_t* Buffer, const uint8_t Data)
{
	GCC_FORCE_POINTER_ACCESS(Buffer);

	*Buffer->In = Data;

	if (++Buffer->In == Buffer->End)
	  Buffer->In = Buffer->Start;

	uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
	GlobalInterruptDisable();

	Buffer->Count++;

	SetGlobalInterruptMask(CurrentGlobalInt);
}

@ Removes an element from the ring buffer.

Only one execution thread (main program thread or an ISR) may remove from a single
buffer otherwise data corruption may occur. Insertion and removal may occur from different
execution threads.

|Buffer| is a pointer to a ring buffer structure to retrieve from.

Returns next data element stored in the buffer.

@<Header files@>=
inline uint8_t RingBuffer_Remove(RingBuffer_t* Buffer) ATTR_NON_NULL_PTR_ARG(1);
inline uint8_t RingBuffer_Remove(RingBuffer_t* Buffer)
{
	GCC_FORCE_POINTER_ACCESS(Buffer);

	uint8_t Data = *Buffer->Out;

	if (++Buffer->Out == Buffer->End)
	  Buffer->Out = Buffer->Start;

	uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
	GlobalInterruptDisable();

	Buffer->Count--;

	SetGlobalInterruptMask(CurrentGlobalInt);

	return Data;
}

@ Returns the next element stored in the ring buffer, without removing it.

|Buffer| is a pointer to a ring buffer structure to retrieve from.

Returns next data element stored in the buffer.

@<Header files@>=
inline uint8_t RingBuffer_Peek(RingBuffer_t* const Buffer) ATTR_WARN_UNUSED_RESULT
  ATTR_NON_NULL_PTR_ARG(1);
inline uint8_t RingBuffer_Peek(RingBuffer_t* const Buffer)
{
	return *Buffer->Out;
}

@h
