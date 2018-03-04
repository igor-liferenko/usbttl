%TODO: add /dev/null sections for the following:
% USB_Descriptor_Interface_t
% USB_CDC_Descriptor_FunctionalHeader_t
% USB_CDC_Descriptor_FunctionalACM_t
% USB_CDC_Descriptor_FunctionalUnion_t
% USB_Descriptor_Header_t

%NOTE: do not do via
% USB_StdDescriptor_Configuration_Header_t
%and
% USB_StdDescriptor_Endpoint_t
%until you do everything in one file (even when you do all in one file, think if doing via USB_StdDescriptor_Configuration_Header_t is better than default)

% TODO: make DTR work (see arduino's modification of this firmware at
% https://github.com/arduino/Arduino/tree/master/hardware/arduino/%
%   avr/firmwares/atmegaxxu2)

%TODO put here info from "The PC audio driver writes playback data to USB as chunks..." at
% http://imi.aau.dk/~sd/phd/index.php?title=AudioArduino

% TODO add here info from
% http://www.ftdichip.com/Support/Documents/AppNotes/%
%   AN232B-04_DataLatencyFlow.pdf

\let\lheader\rheader
@s uint8_t int
@s int16_t int
@s uint16_t int
@s USB_Descriptor_String_t int

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

  @<Disconnect USB device@>@;
  GlobalInterruptEnable();

  while (1) {
    @<Only try to read in bytes from the CDC interface if the transmit buffer...@>@;
    uint16_t BufferCount = RingBuffer_GetCount(&USARTtoUSB_Buffer);
    if (BufferCount) {
      Endpoint_SelectEndpoint(VirtualSerial_CDC_Interface.Config.DataINEndpoint.Address);
      @<Check if a packet is already enqueued to the host@>@;
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

@ Check if a packet is already enqueued to the host - if so, we shouldn't try to send
more data
until it completes as there is a chance nothing is listening and a lengthy timeout could
occur.

@<Check if a packet is already enqueued to the host@>=
if (Endpoint_IsINReady()) {
  @<Calculate bytes to send@>@;
  @<Read bytes from the USART receive buffer into the USB IN endpoint@>@;
}

@ @<Load the next byte from the USART transmit buffer into the USART if transmit buffer
    space is available@>=
if (Serial_IsSendReady() && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
  Serial_SendByte(RingBuffer_Remove(&USBtoUSART_Buffer));

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

@ @<Try to send the next byte of data to the host, abort if there is an error without
    dequeuing@>=
if (CDC_Device_SendByte(&VirtualSerial_CDC_Interface,
    RingBuffer_Peek(&USARTtoUSB_Buffer)) != ENDPOINT_READYWAIT_NoError) break;

@ @<Dequeue the already sent byte from the buffer now we have confirmed that no
    transmission error occurred@>=
RingBuffer_Remove(&USARTtoUSB_Buffer);

@ @<Store received byte into the USART transmit buffer@>=
if (!(ReceivedByte < 0))
  RingBuffer_Insert(&USBtoUSART_Buffer, ReceivedByte);

@ LED mask for the library LED driver, to indicate that the USB interface is not ready.

@<Disconnect USB device@>=
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

@ Class state structure. An instance of this structure should be made for each CDC interface
within the user application, and passed to each of the CDC class driver functions as the
CDCInterfaceInfo parameter. This stores each CDC interface's configuration and state
information.

@s USB_ClassInfo_CDC_Device_t int
@s CDC_LineEncoding_t int
@s USB_Endpoint_Table_t int
@s uint8_t int
@s uint16_t int

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
  /* skipped code which is not used in next section */
} USB_ClassInfo_CDC_Device_t;

@ LUFA CDC Class driver interface configuration and state information.
This structure is
passed to all CDC Class driver functions, so that multiple instances of the same class
within a device can be differentiated from one another.

@<Global...@>=
USB_ClassInfo_CDC_Device_t VirtualSerial_CDC_Interface = {{@|
  INTERFACE_ID_CDC_CCI,@|
  {CDC_TX_EPADDR, CDC_TXRX_EPSIZE, .Banks=1},@|
  {CDC_RX_EPADDR, CDC_TXRX_EPSIZE, .Banks=1},@|
  {CDC_NOTIFICATION_EPADDR, CDC_NOTIFICATION_EPSIZE, .Banks=1}}};

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
  @<Disconnect USB device@>@;
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

@c
ISR(USART1_RX_vect, ISR_BLOCK)
{
	uint8_t ReceivedByte = UDR1;

	if ((USB_DeviceState == DEVICE_STATE_Configured) &&
 !(RingBuffer_IsFull(&USARTtoUSB_Buffer)))
	  RingBuffer_Insert(&USARTtoUSB_Buffer, ReceivedByte);
}

@ Event handler for the CDC Class driver Line Encoding Changed event.

@<Function prototypes@>=
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const
 CDCInterfaceInfo);

@ @c
void EVENT_CDC_Device_LineEncodingChanged(CDCInterfaceInfo)
USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo; /* pointer to the CDC
                          class interface configuration structure being referenced */
{
	uint8_t ConfigMask = 0;

	switch (CDCInterfaceInfo->State.LineEncoding.ParityType)
	{
		case CDC_PARITY_Odd:
			ConfigMask = ((1 << UPM11) | (1 << UPM10)); @+
			break;
		case CDC_PARITY_Even:
			ConfigMask = (1 << UPM11); @+
			break;
	}

  if (CDCInterfaceInfo->State.LineEncoding.CharFormat == CDC_LINEENCODING_TwoStopBits)
	  ConfigMask |= (1 << USBS1);

	switch (CDCInterfaceInfo->State.LineEncoding.DataBits)
	{
		case 6:
			ConfigMask |= (1 << UCSZ10); @+
			break;
		case 7:
			ConfigMask |= (1 << UCSZ11); @+
			break;
		case 8:
			ConfigMask |= ((1 << UCSZ11) | (1 << UCSZ10)); @+
			break;
	}

  PORTD |= (1 << 3); /* keep the TX line held high (idle) while the USART is
                        reconfigured */

        @<Turn off USART before reconfiguring it@>@;
	@<Set the new baud rate before configuring the USART@>@;
  @<Reconfigure the USART in double speed mode for a wider baud rate range...@>@;
	@<Release the TX line after the USART has been reconfigured@>@;
}

@ Must turn off USART before reconfiguring it, otherwise incorrect operation may occur.

@<Turn off USART before reconfiguring it@>=
UCSR1B = 0;
UCSR1A = 0;
UCSR1C = 0;

@ @<Set the new baud rate before configuring the USART@>=
UBRR1  = SERIAL_2X_UBBRVAL(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS);

@ @<Reconfigure the USART in double speed mode for a wider baud rate range at the
    expense of accuracy@>=
UCSR1C = ConfigMask;
UCSR1A = (1 << U2X1);
UCSR1B = ((1 << RXCIE1) | (1 << TXEN1) | (1 << RXEN1));

@ @<Release the TX line after the USART has been reconfigured@>=
PORTD &= ~(1 << 3);

@* USB Device Descriptors. Used in USB device mode. Descriptors are special
computer-readable structures which the host requests upon device enumeration, to determine
the device's capabilities and functions.

@ Type define for a standard Device Descriptor. This structure uses LUFA-specific element
names to make each
element's purpose clearer.

See |USB_StdDescriptor_Device_t| for the version of this type with standard element
names.

Note, that egardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Device_t int
@s USB_Descriptor_Header_t int
@s uint8_t int
@s uint16_t int

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

@<Global...@>=
const USB_Descriptor_Device_t PROGMEM DeviceDescriptor = {@|
{sizeof @[@](USB_Descriptor_Device_t), DTYPE_Device},@|
VERSION_BCD(1,1,0),@|
CDC_CSCP_CDCClass,@|
CDC_CSCP_NoSpecificSubclass,@|
CDC_CSCP_NoSpecificProtocol,@|
FIXED_CONTROL_ENDPOINT_SIZE,@|
0x03EB,@|
0x204B,@|
VERSION_BCD(0,0,1),@|
STRING_ID_Manufacturer,@|
STRING_ID_Product,@|
USE_INTERNAL_SERIAL,@|
FIXED_NUM_CONFIGURATIONS};

@ Standard USB Configuration Descriptor.

Type define for a standard Configuration Descriptor header. This structure uses LUFA-specific
element names
to make each element's purpose clearer.

See |USB_StdDescriptor_Configuration_Header_t| for the version of this type with standard
element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Configuration_Header_t int
@s USB_Descriptor_Header_t int
@s uint16_t int
@s uint8_t int

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
} ATTR_PACKED USB_Descriptor_Configuration_Header_t;

@ Standard USB Endpoint Descriptor.

Type define for a standard Endpoint Descriptor. This structure uses LUFA-specific element names
to make each element's purpose clearer.

See |USB_StdDescriptor_Endpoint_t| for the version of this type with standard element names.

Note, that regardless of CPU architecture, these values should be stored as little endian.

@s USB_Descriptor_Header_t int
@s USB_Descriptor_Endpoint_t int
@s uint8_t int
@s uint16_t int

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
@s USB_Descriptor_Configuration_t int

@<Global...@>=
const USB_Descriptor_Configuration_t PROGMEM ConfigurationDescriptor = {@|
  @<Initialize |Config|@>,@|
  @<Initialize |CDC_CCI_Interface|@>,@|
  @<Initialize |CDC_Functional_Header|@>,@|
  @<Initialize |CDC_Functional_ACM|@>,@|
  @<Initialize |CDC_Functional_Union|@>,@|
  @<Initialize |CDC_Notification_Endpoint|@>,@|
  @<Initialize |CDC_DCI_Interface|@>,@|
  @<Initialize |CDC_DataOutEndpoint|@>,@|
  @<Initialize |CDC_DataInEndpoint|@>};

@ @<Initialize |Config|@>= {@|
  {@,@, sizeof @[@](USB_Descriptor_Configuration_Header_t), @,@, DTYPE_Configuration @,@,},@|
  sizeof @[@](USB_Descriptor_Configuration_t),@|
  2,@|
  1,@|
  NO_DESCRIPTOR,@|
  (USB_CONFIG_ATTR_RESERVED | USB_CONFIG_ATTR_SELFPOWERED),@|
  USB_CONFIG_POWER_MA(100)@/
}

@ @<Initialize |CDC_CCI_Interface|@>= {@|
  {sizeof (USB_Descriptor_Interface_t), DTYPE_Interface},@|
  INTERFACE_ID_CDC_CCI,@|
  0,@|
  1,@|
  CDC_CSCP_CDCClass,@|
  CDC_CSCP_ACMSubclass,@|
  CDC_CSCP_ATCommandProtocol,@|
  NO_DESCRIPTOR}

@ @<Initialize |CDC_Functional_Header|@>= {@|
  {sizeof (USB_CDC_Descriptor_FunctionalHeader_t), DTYPE_CSInterface},@|
  CDC_DSUBTYPE_CSInterface_Header,@|
  VERSION_BCD(1,1,0)}

@ @<Initialize |CDC_Functional_ACM|@>= {@|
  {sizeof (USB_CDC_Descriptor_FunctionalACM_t), DTYPE_CSInterface},@|
  CDC_DSUBTYPE_CSInterface_ACM,@|
  0x06}

@ @<Initialize |CDC_Functional_Union|@>= {@|
  {sizeof (USB_CDC_Descriptor_FunctionalUnion_t), DTYPE_CSInterface},@|
  CDC_DSUBTYPE_CSInterface_Union,@|
  INTERFACE_ID_CDC_CCI,@|
  INTERFACE_ID_CDC_DCI}

@ @<Initialize |CDC_Notification_Endpoint|@>= {@|
  {sizeof (USB_Descriptor_Endpoint_t), DTYPE_Endpoint},@|
  CDC_NOTIFICATION_EPADDR,@|
  (EP_TYPE_INTERRUPT | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_NOTIFICATION_EPSIZE,@|
  0xFF}

@ @<Initialize |CDC_DCI_Interface|@>= {@|
  {sizeof (USB_Descriptor_Interface_t), DTYPE_Interface},@|
  INTERFACE_ID_CDC_DCI,@|
  0,@|
  2,@|
  CDC_CSCP_CDCDataClass,@|
  CDC_CSCP_NoDataSubclass,@|
  CDC_CSCP_NoDataProtocol,@|
  NO_DESCRIPTOR}

@ @<Initialize |CDC_DataOutEndpoint|@>= {@|
  {sizeof (USB_Descriptor_Endpoint_t), DTYPE_Endpoint},@|
  CDC_RX_EPADDR,@|
  (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_TXRX_EPSIZE,@|
  0x05}

@ @<Initialize |CDC_DataInEndpoint|@>= {@|
  {sizeof (USB_Descriptor_Endpoint_t), DTYPE_Endpoint},@|
  CDC_TX_EPADDR,@|
  (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),@|
  CDC_TXRX_EPSIZE,@|
  0x05}

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

@ @c
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
		case DTYPE_Device: @/
			Address = &DeviceDescriptor;
			Size    = sizeof (USB_Descriptor_Device_t);
			break;
		case DTYPE_Configuration: @/
			Address = &ConfigurationDescriptor;
			Size    = sizeof (USB_Descriptor_Configuration_t);
			break;
		case DTYPE_String: @/
			switch (DescriptorNumber)
			{
				case STRING_ID_Language: @/
					Address = &LanguageString;
				Size    = pgm_read_byte(&LanguageString.Header.Size);
					break;
				case STRING_ID_Manufacturer: @/
					Address = &ManufacturerString;
				Size    = pgm_read_byte(&ManufacturerString.Header.Size);
					break;
				case STRING_ID_Product: @/
					Address = &ProductString;
				Size    = pgm_read_byte(&ProductString.Header.Size);
					break;
			}

			break;
	}

	*DescriptorAddress = Address;
	return Size;
}

@ Type define for the device configuration descriptor structure. This must be defined in
the
application code, as the configuration descriptor contains several sub-descriptors which
vary between devices, and which describe the device's usage to the host.

@s USB_Descriptor_Configuration_Header_t int
@s USB_Descriptor_Interface_t int
@s USB_CDC_Descriptor_FunctionalHeader_t int
@s USB_CDC_Descriptor_FunctionalACM_t int
@s USB_CDC_Descriptor_FunctionalUnion_t int
@s USB_Descriptor_Endpoint_t int

@<Type definitions@>=
typedef struct {
	USB_Descriptor_Configuration_Header_t Config; @+@t}\6{@>
	@<CDC Command Interface@>@;
	@<CDC Data Interface@>@;
} USB_Descriptor_Configuration_t;

@ @<CDC Command Interface@>=
        USB_Descriptor_Interface_t               CDC_CCI_Interface;
        USB_CDC_Descriptor_FunctionalHeader_t    CDC_Functional_Header;
        USB_CDC_Descriptor_FunctionalACM_t       CDC_Functional_ACM;
        USB_CDC_Descriptor_FunctionalUnion_t     CDC_Functional_Union;
        USB_Descriptor_Endpoint_t                CDC_NotificationEndpoint;

@ @<CDC Data Interface@>=
        USB_Descriptor_Interface_t               CDC_DCI_Interface;
        USB_Descriptor_Endpoint_t                CDC_DataOutEndpoint;
        USB_Descriptor_Endpoint_t                CDC_DataInEndpoint;

@ Enum for the device interface descriptor IDs within the device. Each interface
descriptor
should have a unique ID index associated with it, which can be used to refer to the
interface from other descriptors.

@<Type definitions@>=
enum InterfaceDescriptors_t
{@|
	INTERFACE_ID_CDC_CCI = 0, /* CDC CCI interface descriptor ID */
	INTERFACE_ID_CDC_DCI = 1, /* CDC DCI interface descriptor ID */
};

@ Enum for the device string descriptor IDs within the device. Each string descriptor
should
have a unique ID index associated with it, which can be used to refer to the string from
other descriptors.

@<Type definitions@>=
enum StringDescriptors_t
{@|
  STRING_ID_Language     = 0, /* Supported Languages string descriptor ID (must be zero) */
	STRING_ID_Manufacturer = 1, /* Manufacturer string ID */
	STRING_ID_Product      = 2, /* Product string ID */
};

@ @<Header files@>=
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/pgmspace.h>
#include <LUFA/Drivers/USB/USB.h>
#include <LUFA/Drivers/Board/LEDs.h>
#include <LUFA/Drivers/Peripheral/Serial.h>
#include <LUFA/Drivers/Misc/RingBuffer.h>
#include <LUFA/Drivers/USB/USB.h>
#include <LUFA/Platform/Platform.h>
