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
@s USB_Descriptor_String_t int

\secpagedepth=1

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
    CDC_Device_USBTask(&VirtualSerial_CDC_Interface);
    USB_USBTask();
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
if (Serial_IsSendReady() && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
  Serial_SendByte(RingBuffer_Remove(&USBtoUSART_Buffer));

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

@ There are several major drawbacks to the CDC-ACM standard USB class, however
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

% http://www.recursion.jp/prose/avrcdc/

@ LUFA CDC Class driver interface configuration and state information.
This structure is
passed to all CDC Class driver functions, so that multiple instances of the same class
within a device can be differentiated from one another.

@<Global...@>=
USB_ClassInfo_CDC_Device_t VirtualSerial_CDC_Interface = {@|
@<Initialize header of |USB_ClassInfo_CDC_Device_t|@>@/
};

@ Class state structure. An instance of this structure should be made for each CDC interface
within the user application, and passed to each of the CDC class driver functions as the
|CDCInterfaceInfo| parameter. This stores each CDC interface's configuration and state
information.

@s USB_ClassInfo_CDC_Device_t int
@s CDC_LineEncoding_t int
@s USB_Endpoint_Table_t int

@(/dev/null@>=
typedef struct {
  struct {
    uint8_t ControlInterfaceNumber;
      /* Interface number of the CDC control interface within the device. */

    USB_Endpoint_Table_t DataINEndpoint; /* Data IN endpoint configuration table. */
    USB_Endpoint_Table_t DataOUTEndpoint; /* Data OUT endpoint configuration table. */
    USB_Endpoint_Table_t NotificationEndpoint;
      /* Notification IN Endpoint configuration table. */
  } Config; /* Config data for the USB class interface within the device.
               All elements in this section must be set or the
               interface will fail to enumerate and operate correctly. */
  struct {
    struct {
      uint16_t HostToDevice; /* control line states from the host to device, as a set
        of \.{CDC\_CONTROL\_LINE\_OUT\_*} masks. This value is updated each time
        |CDC_Device_USBTask| is called */
      uint16_t DeviceToHost; /* control line states from the device to host, as a set of
        \.{CDC\_CONTROL\_LINE\_IN\_*} masks ---~to notify the host of changes to these values,
        call the |CDC_Device_SendControlLineStateChange| function */
    } ControlLineStates; /* current states of the virtual serial port's control lines
      between the device and host */
    CDC_LineEncoding_t LineEncoding; /* line encoding used in the virtual serial port, for
      the device's information; this is generally only used if the virtual serial port data
      is to be reconstructed on a physical UART */
  } State; /* state data for the USB class interface within the device; all elements in this
    section are reset to their defaults when the interface is enumerated */
} USB_ClassInfo_CDC_Device_t;

@ Type define for an endpoint table entry, used to configure endpoints in groups via
\hfil\break \\{Endpoint\_ConfigureEndpointTable}.

@(/dev/null@>=
typedef struct {
  uint8_t  Address; /* address of the endpoint to configure, or zero if
     the table entry is to be unused */
  uint16_t Size; /* size of the endpoint bank, in bytes */
  uint8_t Type; /* type of the endpoint, a \.{EP\_TYPE\_*} mask */
  uint8_t Banks; /* number of hardware banks to use for the endpoint */
} USB_Endpoint_Table_t;

@ TODO: change order of elements and remove .Banks
@^TODO@>

@<Initialize header of |USB_ClassInfo_CDC_Device_t|@>= {@|
  INTERFACE_ID_CDC_CCI, @|
  {@, CDC_TX_EPADDR, CDC_TXRX_EPSIZE, @=.Banks@>=1 @,}, @|
  {@, CDC_RX_EPADDR, CDC_TXRX_EPSIZE, @=.Banks@>=1 @,}, @|
  {@, CDC_NOTIFICATION_EPADDR, CDC_NOTIFICATION_EPSIZE, @=.Banks@>=1 @,} @/
}

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

@<Function prototypes@>=
void EVENT_USB_Device_Connect(void);

@ LED mask for the library LED driver, to indicate that the USB interface is enumerating.

@c
void EVENT_USB_Device_Connect(void)
{
	LEDs_SetAllLEDs(LEDS_LED2 | LEDS_LED3);
}

@ Event handler for the library USB Disconnection event.

@<Function prototypes@>=
void EVENT_USB_Device_Disconnect(void);

@ @c
void EVENT_USB_Device_Disconnect(void)
{
  @<Indicate that USB device is disconnected@>@;
}

@ Event handler for the library USB Configuration Changed event.

@<Function prototypes@>=
void EVENT_USB_Device_ConfigurationChanged(void);

@ @d LEDMASK_USB_READY (LEDS_LED2 | LEDS_LED4)
@d LEDMASK_USB_ERROR (LEDS_LED1 | LEDS_LED3)

@c
void EVENT_USB_Device_ConfigurationChanged(void)
{
	bool ConfigSuccess = true;
	ConfigSuccess &= CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface);
	LEDs_SetAllLEDs(ConfigSuccess ? LEDMASK_USB_READY : LEDMASK_USB_ERROR);
}

@ Event handler for the library USB Control Request reception event.

@<Function prototypes@>=
void EVENT_USB_Device_ControlRequest(void);

@ @c
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

@<Function prototypes@>=
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const
 CDCInterfaceInfo);

@ @d CDC_LINEENCODING_TWO_STOP_BITS 2 /* each frame contains two stop bits */
@d CDC_PARITY_EVEN 2
@d CDC_PARITY_ODD 1

@c
void EVENT_CDC_Device_LineEncodingChanged(CDCInterfaceInfo)
USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo; /* pointer to the CDC
                          class interface configuration structure being referenced */
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

@ @<Set the new baud rate before configuring the USART@>=
UBRR1  = SERIAL_2X_UBBRVAL(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS);

@ @<Reconfigure the USART in double speed mode for a wider baud rate range at the
    expense of accuracy@>=
UCSR1C = ConfigMask;
UCSR1A = (1 << U2X1);
UCSR1B = ((1 << RXCIE1) | (1 << TXEN1) | (1 << RXEN1));
@^see datasheet@>

@* USB Device Descriptors. Used in USB device mode. Descriptors are special
computer-readable structures which the host requests upon device enumeration, to determine
the device's capabilities and functions.

@ Type define for all standard USB descriptors' header, indicating the descriptor's
length and type. This structure
uses LUFA-specific element names to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Header\_t} for the version of this type
with standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@(/dev/null@>=
typedef struct {
  uint8_t Size; /* size of the descriptor, in bytes */
  uint8_t Type; /* type of the descriptor, either a value of \.{DTYPE\_*} or a value
    given by the specific class */
} ATTR_PACKED USB_Descriptor_Header_t;

@ Type define for a standard Device Descriptor. This structure uses LUFA-specific element
names to make each
element's purpose clearer.

See \&{USB\_StdDescriptor\_Device\_t} for the version of this type with standard element
names.

Note, that egardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Device_t int
@s USB_Descriptor_Header_t int

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* Descriptor header, including type and size. */
  uint16_t USBSpecification; /* BCD of the supported USB specification;
		                see |VERSION_BCD| utility macro */
  uint8_t  Class; /* USB device class. */
  uint8_t  SubClass; /* USB device subclass. */
  uint8_t  Protocol; /* USB device protocol. */

  uint8_t  Endpoint0Size; /* Size of the control (address 0) endpoint's bank in bytes. */

  uint16_t VendorID; /* Vendor ID for the USB product. */
  uint16_t ProductID; /* Unique product ID for the USB product. */
  uint16_t ReleaseNumber; /* Product release (version) number.
                            see |VERSION_BCD| utility macro. */
  uint8_t  ManufacturerStrIndex; /* String index for the manufacturer's name. The
                                          host will request this string via a separate
                                           control request for the string descriptor.
                                  Note: If no string supplied, use |NO_DESCRIPTOR|.
                                                                */
  uint8_t  ProductStrIndex; /* String index for the product name/details.
                             see ManufacturerStrIndex structure entry. */
  uint8_t  SerialNumStrIndex; /* String index for the product's globally unique hexadecimal
                                        serial number, in uppercase Unicode ASCII.
                note On some microcontroller models, there is an embedded serial number
                              in the chip which can be used for the device serial number.
                             To use this serial number, set this to |USE_INTERNAL_SERIAL|.
                            On unsupported devices, this will evaluate to |NO_DESCRIPTOR|
                        and will cause the host to generate a pseudo-unique value for the
                                   device upon insertion.
                                                             
                            see ManufacturerStrIndex structure entry.
                                                             */
  uint8_t  NumberOfConfigurations; /* Total number of configurations supported by
                                      the device. */
} ATTR_PACKED USB_Descriptor_Device_t;

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

@ Standard USB Configuration Descriptor.

Done as a type define instead of putting directly to |USB_Descriptor_Config_t|
(as it is for header of |USB_ClassInfo_CDC_Device_t|) because it is used to calculate
header size of standard Configuration Descriptor (via |sizeof|).

This structure uses LUFA-specific
element names
to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Config\_Header\_t} for the version of this type with standard
element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Config_Header_t int
@s USB_Descriptor_Header_t int

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* Descriptor header, including type and size. */
  uint16_t TotalConfigurationSize; /* Size of the configuration descriptor header,
                                     and all sub descriptors inside the configuration. */
  uint8_t  TotalInterfaces; /* Total number of interfaces in the configuration. */
  uint8_t  ConfigurationNumber; /* Configuration index of the current configuration. */
  uint8_t  ConfigurationStrIndex; /* Index of a string descriptor describing the configuration. */
  uint8_t  ConfigAttributes; /* Configuration attributes, comprised of a mask of
                                \.{USB\_CONFIG\_ATTR\_*}
                                masks. On all devices, this should include
                                |USB_CONFIG_ATTR_RESERVED|
                                at a minimum. */
  uint8_t  MaxPowerConsumption; /* Maximum power consumption of the device while in the
                                   current configuration, calculated by the |USB_CONFIG_POWER_MA|
                                   macro. */
} ATTR_PACKED USB_Descriptor_Config_Header_t;

@ Type define for a standard USB Interface Descriptor.

This structure uses
LUFA-specific element names to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Interface\_t} for the version of this type with standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* descriptor header, including type and size */
  uint8_t InterfaceNumber; /* index of the interface in the current configuration */
  uint8_t AlternateSetting; /* alternate setting for the interface number. The same
    interface number can have multiple alternate settings
    with different endpoint configurations, which can be
    selected by the host */
  uint8_t TotalEndpoints; /* total number of endpoints in the interface */
  uint8_t Class; /* interface class ID */
  uint8_t SubClass; /* interface subclass ID */
  uint8_t Protocol; /* interface protocol ID */
  uint8_t InterfaceStrIndex; /* index of the string descriptor describing the interface */
} ATTR_PACKED USB_Descriptor_Interface_t;

@ Type define for a CDC class-specific functional header descriptor.
This indicates to the host that the device contains one or more CDC functional
data descriptors, which give the CDC interface's capabilities and configuration.
See the CDC class specification for more details.

See \&{USB\_CDC\_StdDescriptor\_FunctionalHeader\_t} for the version of this type
with standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* regular descriptor header containing the
    descriptor's type and length */
  uint8_t Subtype; /* Subtype value used to distinguish between CDC class-specific descriptors,
    must be |CDC_DSUBTYPE_CS_INTERFACE_HEADER| */
  uint16_t CDCSpecification; /* version number of the CDC specification implemented by the device,
    encoded in BCD format; see |VERSION_BCD| utility macro */
} ATTR_PACKED USB_CDC_Descriptor_Func_Header_t;

@ Type define for a CDC class-specific functional ACM descriptor. This indicates to the host
that the CDC interface supports the CDC ACM subclass of the CDC specification.
See the CDC class specification for more details.

See \&{USB\_CDC\_StdDescriptor\_FunctionalACM\_t} for the version of this type with
standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* regular descriptor header containing the
    descriptor's type and length */
  uint8_t Subtype; /* Subtype value used to distinguish between CDC class-specific descriptors,
    must be |CDC_DSUBTYPE_CS_INTERFACE_ACM| */
  uint8_t Capabilities; /* capabilities of the ACM interface, given as a bit mask;
    refer to the CDC ACM specification */
} ATTR_PACKED USB_CDC_Descriptor_Func_ACM_t;

@ Type define for a CDC class-specific functional Union descriptor. This indicates to the
host that specific CDC control and data interfaces are related. See the CDC class
specification for more details.

See \&{USB\_CDC\_StdDescriptor\_FunctionalUnion\_t} for the version of this type with
standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* regular descriptor header containing the
    descriptor's type and length */
  uint8_t Subtype; /* Subtype value used to distinguish between CDC class-specific descriptors,
    must be |CDC_DSUBTYPE_CS_INTERFACE_UNION| */
  uint8_t MasterInterfaceNumber; /* interface number of the CDC Control interface */
  uint8_t SlaveInterfaceNumber; /* interface number of the CDC Data interface */
} ATTR_PACKED USB_CDC_Descriptor_Func_Union_t;

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

@ Standard USB Endpoint Descriptor.

Type define for a standard Endpoint Descriptor. This structure uses LUFA-specific element names
to make each element's purpose clearer.

See \&{USB\_StdDescriptor\_Endpoint\_t} for the version of this type with standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Header_t int
@s USB_Descriptor_Endpoint_t int

@(/dev/null@>=
typedef struct {
  USB_Descriptor_Header_t Header; /* Descriptor header, including type and size. */

  uint8_t  EndpointAddress; /* Logical address of the endpoint within the device for the current
                               configuration, including direction mask. */
  uint8_t  Attributes; /* Endpoint attributes, comprised of a mask of the endpoint type
                          (\.{EP\_TYPE\_*})
                          and attributes (\.{ENDPOINT\_ATTR\_*}) masks. */
  uint16_t EndpointSize; /* Size of the endpoint bank, in bytes. This indicates the maximum packet
                            size that the endpoint can receive at a time. */
  uint8_t  PollingIntervalMS; /* Polling interval in milliseconds for the endpoint if it is an
                                 \.{INTERRUPT}
                                 or \.{ISOCHRONOUS} type. */
} ATTR_PACKED USB_Descriptor_Endpoint_t;

@ @d DTYPE_ENDPOINT 0x05 /* indicates that the descriptor is an endpoint descriptor */
@d ENDPOINT_ATTR_NO_SYNCXXX (0 << 2) /* indicate that the specified endpoint is not
  synchronized */

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

@<Global...@>=
const USB_Descriptor_String_t PROGMEM LanguageString =
  USB_STRING_DESCRIPTOR_ARRAY(LANGUAGE_ID_ENG);

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

@ @<Function prototypes@>=
void USB_Event_Stub(void) ATTR_CONST;
void EVENT_USB_Device_Suspend(void) ATTR_WEAK ATTR_ALIAS(USB_Event_Stub);
void EVENT_USB_Device_WakeUp(void) ATTR_WEAK ATTR_ALIAS(USB_Event_Stub);
void EVENT_USB_Device_Reset(void) ATTR_WEAK ATTR_ALIAS(USB_Event_Stub);
void EVENT_USB_Device_StartOfFrame(void) ATTR_WEAK ATTR_ALIAS(USB_Event_Stub);

@ @c
void USB_Event_Stub(void)
{

}

@* Main USB service task management.

@ @<Global...@>=
volatile bool USB_IsInitialized;
USB_Request_Header_t USB_ControlRequest;

@ @c
void USB_USBTask(void)
{
		USB_DeviceTask();
}

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

@* USB Configuration Descriptor definitions.

@ @c
void USB_GetNextDescriptorOfType(uint16_t* const BytesRem,
                                 void** const CurrConfigLoc,
                                 const uint8_t Type)
{
	while (*BytesRem)
	{
		USB_GetNextDescriptor(BytesRem, CurrConfigLoc);

		if (DESCRIPTOR_TYPE(*CurrConfigLoc) == Type)
		  return;
	}
}

void USB_GetNextDescriptorOfTypeBefore(uint16_t* const BytesRem,
                                       void** const CurrConfigLoc,
                                       const uint8_t Type,
                                       const uint8_t BeforeType)
{
	while (*BytesRem)
	{
		USB_GetNextDescriptor(BytesRem, CurrConfigLoc);

		if (DESCRIPTOR_TYPE(*CurrConfigLoc) == Type)
		{
			return;
		}
		else if (DESCRIPTOR_TYPE(*CurrConfigLoc) == BeforeType)
		{
			*BytesRem = 0;
			return;
		}
	}
}

void USB_GetNextDescriptorOfTypeAfter(uint16_t* const BytesRem,
                                      void** const CurrConfigLoc,
                                      const uint8_t Type,
                                      const uint8_t AfterType)
{
	USB_GetNextDescriptorOfType(BytesRem, CurrConfigLoc, AfterType);

	if (*BytesRem)
	  USB_GetNextDescriptorOfType(BytesRem, CurrConfigLoc, Type);
}

uint8_t USB_GetNextDescriptorComp(uint16_t* const BytesRem,
                                  void** const CurrConfigLoc,
                                  ConfigComparatorPtr_t const ComparatorRoutine)
{
	uint8_t ErrorCode;

	while (*BytesRem)
	{
		uint8_t* PrevDescLoc  = *CurrConfigLoc;
		uint16_t PrevBytesRem = *BytesRem;

		USB_GetNextDescriptor(BytesRem, CurrConfigLoc);

		if ((ErrorCode = ComparatorRoutine(*CurrConfigLoc)) != DESCRIPTOR_SEARCH_NotFound)
		{
			if (ErrorCode == DESCRIPTOR_SEARCH_Fail)
			{
				*CurrConfigLoc = PrevDescLoc;
				*BytesRem      = PrevBytesRem;
			}

			return ErrorCode;
		}
	}

	return DESCRIPTOR_SEARCH_COMP_EndOfDescriptor;
}

@* USB controller interrupt service routine management.

@ @c
void USB_INT_DisableAllInterrupts(void)
{
	#if defined(USB_SERIES_6_AVR) || defined(USB_SERIES_7_AVR)
	USBCON &= ~((1 << VBUSTE) | (1 << IDTE));
	#elif defined(USB_SERIES_4_AVR)
	USBCON &= ~(1 << VBUSTE);
	#endif

	#if defined(USB_CAN_BE_DEVICE)
	UDIEN   = 0;
	#endif
}

void USB_INT_ClearAllInterrupts(void)
{
	#if defined(USB_SERIES_4_AVR) || defined(USB_SERIES_6_AVR) || defined(USB_SERIES_7_AVR)
	USBINT = 0;
	#endif

	#if defined(USB_CAN_BE_DEVICE)
	UDINT  = 0;
	#endif
}

ISR(USB_GEN_vect, ISR_BLOCK)
{
	#if defined(USB_CAN_BE_DEVICE)
	#if !defined(NO_SOF_EVENTS)
	if (USB_INT_HasOccurred(USB_INT_SOFI) && USB_INT_IsEnabled(USB_INT_SOFI))
	{
		USB_INT_Clear(USB_INT_SOFI);

		EVENT_USB_Device_StartOfFrame();
	}
	#endif

	#if defined(USB_SERIES_4_AVR) || defined(USB_SERIES_6_AVR) || defined(USB_SERIES_7_AVR)
	if (USB_INT_HasOccurred(USB_INT_VBUSTI) && USB_INT_IsEnabled(USB_INT_VBUSTI))
	{
		USB_INT_Clear(USB_INT_VBUSTI);

		if (USB_VBUS_GetStatus())
		{
			if (!(USB_Options & USB_OPT_MANUAL_PLL))
			{
				USB_PLL_On();
				while (!(USB_PLL_IsReady()));
			}

			USB_DeviceState = DEVICE_STATE_Powered;
			EVENT_USB_Device_Connect();
		}
		else
		{
			if (!(USB_Options & USB_OPT_MANUAL_PLL))
			  USB_PLL_Off();

			USB_DeviceState = DEVICE_STATE_Unattached;
			EVENT_USB_Device_Disconnect();
		}
	}
	#endif

	if (USB_INT_HasOccurred(USB_INT_SUSPI) && USB_INT_IsEnabled(USB_INT_SUSPI))
	{
		USB_INT_Disable(USB_INT_SUSPI);
		USB_INT_Enable(USB_INT_WAKEUPI);

		USB_CLK_Freeze();

		if (!(USB_Options & USB_OPT_MANUAL_PLL))
		  USB_PLL_Off();

		#if defined(USB_SERIES_2_AVR) && !defined(NO_LIMITED_CONTROLLER_CONNECT)
		USB_DeviceState = DEVICE_STATE_Unattached;
		EVENT_USB_Device_Disconnect();
		#else
		USB_DeviceState = DEVICE_STATE_Suspended;
		EVENT_USB_Device_Suspend();
		#endif
	}

	if (USB_INT_HasOccurred(USB_INT_WAKEUPI) && USB_INT_IsEnabled(USB_INT_WAKEUPI))
	{
		if (!(USB_Options & USB_OPT_MANUAL_PLL))
		{
			USB_PLL_On();
			while (!(USB_PLL_IsReady()));
		}

		USB_CLK_Unfreeze();

		USB_INT_Clear(USB_INT_WAKEUPI);

		USB_INT_Disable(USB_INT_WAKEUPI);
		USB_INT_Enable(USB_INT_SUSPI);

		if (USB_Device_ConfigurationNumber)
		  USB_DeviceState = DEVICE_STATE_Configured;
		else
		  USB_DeviceState = (USB_Device_IsAddressSet()) ? DEVICE_STATE_Addressed : DEVICE_STATE_Powered;

		#if defined(USB_SERIES_2_AVR) && !defined(NO_LIMITED_CONTROLLER_CONNECT)
		EVENT_USB_Device_Connect();
		#else
		EVENT_USB_Device_WakeUp();
		#endif
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

		#if defined(INTERRUPT_CONTROL_ENDPOINT)
		USB_INT_Enable(USB_INT_RXSTPI);
		#endif

		EVENT_USB_Device_Reset();
	}
	#endif
}

#if defined(INTERRUPT_CONTROL_ENDPOINT) && defined(USB_CAN_BE_DEVICE)
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
#endif

@* USB Controller definitions for the AVR8 microcontrollers.

@ @<Function prototypes@>=
static void USB_Init_Device(void);

@ @c
void USB_Init(void)
{
	/* Workaround for AVR8 bootloaders that fail to turn off the OTG pad before running
	 * the loaded application. This causes VBUS detection to fail unless we first force
	 * it off to reset it. */
	USB_OTGPAD_Off();

	if (!(USB_Options & USB_OPT_REG_DISABLED))
	  USB_REG_On();
	else
	  USB_REG_Off();

	if (!(USB_Options & USB_OPT_MANUAL_PLL))
		PLLFRQ = (1 << PDIV2);

	USB_IsInitialized = true;

	USB_ResetInterface();
}

void USB_Disable(void)
{
	USB_INT_DisableAllInterrupts();
	USB_INT_ClearAllInterrupts();

	USB_Detach();
	USB_Controller_Disable();

	if (!(USB_Options & USB_OPT_MANUAL_PLL))
	  USB_PLL_Off();

	if (!(USB_Options & USB_OPT_REG_KEEP_ENABLED))
	  USB_REG_Off();

	USB_OTGPAD_Off();

	USB_IsInitialized = false;
}

void USB_ResetInterface(void)
{
	USB_INT_DisableAllInterrupts();
	USB_INT_ClearAllInterrupts();

	USB_Controller_Reset();

	USB_CLK_Unfreeze();

	if (!(USB_Options & USB_OPT_MANUAL_PLL))
		USB_PLL_Off();

	USB_Init_Device();

	USB_OTGPAD_On();
}

static void USB_Init_Device(void)
{
	USB_DeviceState                 = DEVICE_STATE_Unattached;
	USB_Device_ConfigurationNumber  = 0;

	USB_Device_RemoteWakeupEnabled  = false;

	USB_Device_CurrentlySelfPowered = false;

	if (USB_Options & USB_DEVICE_OPT_LOWSPEED)
	  USB_Device_SetLowSpeed();
	else
	  USB_Device_SetFullSpeed();

	USB_INT_Enable(USB_INT_VBUSTI);

	Endpoint_ConfigureEndpoint(ENDPOINT_CONTROLEP, EP_TYPE_CONTROL,
							   USB_Device_ControlEndpointSize, 1);

	USB_INT_Clear(USB_INT_SUSPI);
	USB_INT_Enable(USB_INT_SUSPI);
	USB_INT_Enable(USB_INT_EORSTI);

	USB_Attach();
}

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

@ @<Function prototypes@>=
static int CDC_Device_putchar(char c, FILE* Stream) ATTR_NON_NULL_PTR_ARG(2);
static int CDC_Device_getchar(FILE* Stream) ATTR_NON_NULL_PTR_ARG(1);
static int CDC_Device_getchar_Blocking(FILE* Stream) ATTR_NON_NULL_PTR_ARG(1);

void CDC_Device_Event_Stub(void) ATTR_CONST;

#if 1==0
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
  ATTR_WEAK ATTR_NON_NULL_PTR_ARG(1) ATTR_ALIAS(CDC_Device_Event_Stub);
#endif
void EVENT_CDC_Device_ControLineStateChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
  ATTR_WEAK ATTR_NON_NULL_PTR_ARG(1) ATTR_ALIAS(CDC_Device_Event_Stub);
void EVENT_CDC_Device_BreakSent(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
  const uint8_t Duration) ATTR_WEAK ATTR_NON_NULL_PTR_ARG(1) ATTR_ALIAS(CDC_Device_Event_Stub);

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

void CDC_Device_USBTask(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);

	if (Endpoint_IsINReady())
	  CDC_Device_Flush(CDCInterfaceInfo);
}

uint8_t CDC_Device_SendString(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                              const char* const String)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);
	return Endpoint_Write_Stream_LE(String, strlen(String), NULL);
}

uint8_t CDC_Device_SendString_P(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                              const char* const String)
{
	if ((USB_DeviceState != DEVICE_STATE_Configured) ||
 !(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	  return ENDPOINT_RWSTREAM_DeviceDisconnected;

	Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.Address);
	return Endpoint_Write_PStream_LE(String, strlen_P(String), NULL);
}

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

void CDC_Device_CreateStream(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                             FILE* const Stream)
{
	*Stream = (FILE)FDEV_SETUP_STREAM(CDC_Device_putchar, CDC_Device_getchar, _FDEV_SETUP_RW);
	fdev_set_udata(Stream, CDCInterfaceInfo);
}

void CDC_Device_CreateBlockingStream(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo,
                                     FILE* const Stream)
{
	*Stream = (FILE)FDEV_SETUP_STREAM(CDC_Device_putchar, CDC_Device_getchar_Blocking,
 _FDEV_SETUP_RW);
	fdev_set_udata(Stream, CDCInterfaceInfo);
}

static int CDC_Device_putchar(char c,
                              FILE* Stream)
{
	return CDC_Device_SendByte((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream), c) ?
 _FDEV_ERR : 0;
}

static int CDC_Device_getchar(FILE* Stream)
{
	int16_t ReceivedByte =
 CDC_Device_ReceiveByte((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream));

	if (ReceivedByte < 0)
	  return _FDEV_EOF;

	return ReceivedByte;
}

static int CDC_Device_getchar_Blocking(FILE* Stream)
{
	int16_t ReceivedByte;

	while ((ReceivedByte =
 CDC_Device_ReceiveByte((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream))) < 0)
	{
		if (USB_DeviceState == DEVICE_STATE_Unattached)
		  return _FDEV_EOF;

		CDC_Device_USBTask((USB_ClassInfo_CDC_Device_t*)fdev_get_udata(Stream));
		USB_USBTask();
	}

	return ReceivedByte;
}

void CDC_Device_Event_Stub(void)
{

}

@* USB device standard request management.

@ @<Function prototypes@>=
                                static void USB_Device_SetAddress(void);
                                static void USB_Device_SetConfiguration(void);
                                static void USB_Device_GetConfiguration(void);
                                static void USB_Device_GetDescriptor(void);
                                static void USB_Device_GetStatus(void);
                                static void USB_Device_ClearSetFeature(void);
                                static void USB_Device_GetInternalSerialDescriptor(void);

@ @c
uint8_t USB_Device_ConfigurationNumber;

bool    USB_Device_CurrentlySelfPowered;

bool    USB_Device_RemoteWakeupEnabled;

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

static void USB_Device_SetAddress(void)
{
	uint8_t DeviceAddress = (USB_ControlRequest.wValue & 0x7F);

	USB_Device_SetDeviceAddress(DeviceAddress);

	Endpoint_ClearSETUP();

	Endpoint_ClearStatusStage();

	while (!(Endpoint_IsINReady()));

	USB_Device_EnableDeviceAddress(DeviceAddress);

	USB_DeviceState = (DeviceAddress) ? DEVICE_STATE_Addressed : DEVICE_STATE_Default;
}

static void USB_Device_SetConfiguration(void)
{
  if ((uint8_t)USB_ControlRequest.wValue > FIXED_NUM_CONFIGURATIONS)
	return;

  Endpoint_ClearSETUP();

  USB_Device_ConfigurationNumber = (uint8_t)USB_ControlRequest.wValue;

  Endpoint_ClearStatusStage();

  if (USB_Device_ConfigurationNumber)
    USB_DeviceState = DEVICE_STATE_Configured;
  else
    USB_DeviceState = (USB_Device_IsAddressSet()) ? DEVICE_STATE_Configured : DEVICE_STATE_Powered;

  EVENT_USB_Device_ConfigurationChanged();
}

static void USB_Device_GetConfiguration(void)
{
	Endpoint_ClearSETUP();

	Endpoint_Write_8(USB_Device_ConfigurationNumber);
	Endpoint_ClearIN();

	Endpoint_ClearStatusStage();
}

static void USB_Device_GetInternalSerialDescriptor(void)
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

static void USB_Device_GetDescriptor(void)
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

static void USB_Device_GetStatus(void)
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

static void USB_Device_ClearSetFeature(void)
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
			USB_USBTask();
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
			USB_USBTask();
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

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
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
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

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
			USB_USBTask();
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
			USB_USBTask();
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

uint8_t Endpoint_Write_PStream_BE(const void* const Buffer,
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
			USB_USBTask();
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
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_EStream_LE(const void* const Buffer,
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
			USB_USBTask();
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
			Endpoint_Write_8(eeprom_read_byte(DataStream));
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_EStream_BE(const void* const Buffer,
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
			USB_USBTask();
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
			Endpoint_Write_8(eeprom_read_byte(DataStream));
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_EStream_LE(void* const Buffer,
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

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
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
			eeprom_update_byte(DataStream, Endpoint_Read_8());
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_EStream_BE(void* const Buffer,
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
			USB_USBTask();
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
			eeprom_update_byte(DataStream, Endpoint_Read_8());
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

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

uint8_t Endpoint_Write_Control_PStream_BE(const void* const Buffer,
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
				Endpoint_Write_8(pgm_read_byte(DataStream));
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

uint8_t Endpoint_Write_Control_EStream_LE(const void* const Buffer,
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
				Endpoint_Write_8(eeprom_read_byte(DataStream));
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

uint8_t Endpoint_Write_Control_EStream_BE(const void* const Buffer,
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
				Endpoint_Write_8(eeprom_read_byte(DataStream));
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

uint8_t Endpoint_Read_Control_EStream_LE(void* const Buffer, uint16_t Length)
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
				eeprom_update_byte(DataStream, Endpoint_Read_8());
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

uint8_t Endpoint_Read_Control_EStream_BE(void* const Buffer, uint16_t Length)
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
				eeprom_update_byte(DataStream, Endpoint_Read_8());
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


@ @<Header files@>=
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/power.h> /* |clock_prescale_set|, |clock_div_1| */
#include <avr/pgmspace.h>

@<Get rid of this@>@;

@ TODO: Do everything as one self-contained program.
And then remove /dev/null sections.
And remove "@s ..." from /dev/null sections.
HINT: use gcc-E.c to merge header files + read
https://gcc.gnu.org/onlinedocs/cpp/Preprocessor-Output.html
@^TODO@>

@<Get rid of this@>=
#include <LUFA/Drivers/USB/USB.h>
#include <LUFA/Drivers/Board/LEDs.h>
#include <LUFA/Drivers/Peripheral/Serial.h>
#include <LUFA/Drivers/Misc/RingBuffer.h>
#include <LUFA/Drivers/USB/USB.h>
#include <LUFA/Platform/Platform.h>
