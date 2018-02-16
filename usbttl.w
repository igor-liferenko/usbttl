@* Main program entry point. This routine contains the overall program flow, including initial
setup of all components and the main program loop.

@c
@<Includes@>@;
@<Type definitions@>@;
@<Function prototypes@>@;
@<Global variables@>@;
@<XXX structure@>@;
@<YYY structure@>@;
@<ZZZ structure@>@;

int main(void)
{
	SetupHardware();

	RingBuffer_InitBuffer(&USBtoUSART_Buffer, USBtoUSART_Buffer_Data, sizeof(USBtoUSART_Buffer_Data));
	RingBuffer_InitBuffer(&USARTtoUSB_Buffer, USARTtoUSB_Buffer_Data, sizeof(USARTtoUSB_Buffer_Data));

	@<Disconnect USB device@>@;
	GlobalInterruptEnable();

	for (;;)
	{
		/* Only try to read in bytes from the CDC interface if the transmit buffer is not full */
		if (!(RingBuffer_IsFull(&USBtoUSART_Buffer)))
		{
			int16_t ReceivedByte = CDC_Device_ReceiveByte(&VirtualSerial_CDC_Interface);

			/* Store received byte into the USART transmit buffer */
			if (!(ReceivedByte < 0))
			  RingBuffer_Insert(&USBtoUSART_Buffer, ReceivedByte);
		}

		uint16_t BufferCount = RingBuffer_GetCount(&USARTtoUSB_Buffer);
		if (BufferCount)
		{
			Endpoint_SelectEndpoint(VirtualSerial_CDC_Interface.Config.DataINEndpoint.Address);

			/* Check if a packet is already enqueued to the host - if so, we shouldn't try to send more data
			 * until it completes as there is a chance nothing is listening and a lengthy timeout could occur */
			if (Endpoint_IsINReady())
			{
				/* Never send more than one bank size less one byte to the host at a time, so that we don't block
				 * while a Zero Length Packet (ZLP) to terminate the transfer is sent if the host isn't listening */
				uint8_t BytesToSend = MIN(BufferCount, (CDC_TXRX_EPSIZE - 1));

				/* Read bytes from the USART receive buffer into the USB IN endpoint */
				while (BytesToSend--)
				{
					/* Try to send the next byte of data to the host, abort if there is an error without dequeuing */
					if (CDC_Device_SendByte(&VirtualSerial_CDC_Interface,
											RingBuffer_Peek(&USARTtoUSB_Buffer)) != ENDPOINT_READYWAIT_NoError)
					{
						break;
					}

					/* Dequeue the already sent byte from the buffer now we have confirmed that no transmission error occurred */
					RingBuffer_Remove(&USARTtoUSB_Buffer);
				}
			}
		}

		/* Load the next byte from the USART transmit buffer into the USART if transmit buffer space is available */
		if (Serial_IsSendReady() && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
		  Serial_SendByte(RingBuffer_Remove(&USBtoUSART_Buffer));

		CDC_Device_USBTask(&VirtualSerial_CDC_Interface);
		USB_USBTask();
	}
}

@ @d LEDMASK_USB_NOTREADY LEDS_LED1 /* LED mask for the library LED driver, to indicate that the USB interface is no
t ready */

@<Disconnect USB device@>=
LEDs_SetAllLEDs(LEDMASK_USB_NOTREADY);

@ @<Global...@>=
RingBuffer_t USBtoUSART_Buffer; /* circular buffer to hold data from the host before it is sent to the device via the serial port */
uint8_t      USBtoUSART_Buffer_Data[128]; /* underlying data buffer for |USBtoUSART_Buffer|, where the stored bytes are located */
RingBuffer_t USARTtoUSB_Buffer; /* circular buffer to hold data from the serial port before it is sent to the host */
uint8_t      USARTtoUSB_Buffer_Data[128]; /* underlying data buffer for |USARTtoUSB_Buffer|, where the stored bytes are located */

@ LUFA CDC Class driver interface configuration and state information. This structure is
passed to all CDC Class driver functions, so that multiple instances of the same class
within a device can be differentiated from one another.

@<XXX structure@>=
USB_ClassInfo_CDC_Device_t VirtualSerial_CDC_Interface =
{
	.Config =
		{
			.ControlInterfaceNumber         = INTERFACE_ID_CDC_CCI,
			.DataINEndpoint                 =
				{
					.Address                = CDC_TX_EPADDR,
					.Size                   = CDC_TXRX_EPSIZE,
					.Banks                  = 1,
				},
			.DataOUTEndpoint                =
				{
					.Address                = CDC_RX_EPADDR,
					.Size                   = CDC_TXRX_EPSIZE,
					.Banks                  = 1,
				},
			.NotificationEndpoint           =
				{
					.Address                = CDC_NOTIFICATION_EPADDR,
					.Size                   = CDC_NOTIFICATION_EPSIZE,
					.Banks                  = 1,
				},
		},
};


@ Configures the board hardware and chip peripherals for the demo's functionality.

@<Function Prototypes@>=
void SetupHardware(void);

@ @c
void SetupHardware(void)
{
#if (ARCH == ARCH_AVR8)
	// disable watchdog if enabled by bootloader/fuses
	MCUSR &= ~(1 << WDRF);
	wdt_disable();

	clock_prescale_set(clock_div_1); /* disable clock division */
#endif

	// hardware initialization
	LEDs_Init();
	USB_Init();
}

@ Event handler for the library USB Connection event.

@<Function Prototypes@>=
void EVENT_USB_Device_Connect(void);

@ @d LEDMASK_USB_ENUMERATING  (LEDS_LED2 | LEDS_LED3) /* LED mask for the library LED driver, to indicate that the USB interface is enumerating */

@c
void EVENT_USB_Device_Connect(void)
{
	LEDs_SetAllLEDs(LEDMASK_USB_ENUMERATING);
}

@ Event handler for the library USB Disconnection event.
@<Function Prototypes@>=
void EVENT_USB_Device_Disconnect(void);

@ @c
void EVENT_USB_Device_Disconnect(void)
{
  @<Disconnect USB device@>@;
}

@ Event handler for the library USB Configuration Changed event.
@<Function Prototypes@>=
void EVENT_USB_Device_ConfigurationChanged(void);

@ @d LEDMASK_USB_READY (LEDS_LED2 | LEDS_LED4) /* LED mask for the library LED driver, to indicate that the USB inte
rface is ready */
@d LEDMASK_USB_ERROR (LEDS_LED1 | LEDS_LED3) /* LED mask for the library LED driver, to indicate that an error has occurred in the USB interface */

@c
void EVENT_USB_Device_ConfigurationChanged(void)
{
	bool ConfigSuccess = true;

	ConfigSuccess &= CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface);

	LEDs_SetAllLEDs(ConfigSuccess ? LEDMASK_USB_READY : LEDMASK_USB_ERROR);
}

@ Event handler for the library USB Control Request reception event.

@<Function Prototypes@>=
void EVENT_USB_Device_ControlRequest(void);

@ @c
void EVENT_USB_Device_ControlRequest(void)
{
	CDC_Device_ProcessControlRequest(&VirtualSerial_CDC_Interface);
}

@ ISR to manage the reception of data from the serial port, placing received bytes into a circular buffer
for later transmission to the host.

@c
ISR(USART1_RX_vect, ISR_BLOCK)
{
	uint8_t ReceivedByte = UDR1;

	if ((USB_DeviceState == DEVICE_STATE_Configured) && !(RingBuffer_IsFull(&USARTtoUSB_Buffer)))
	  RingBuffer_Insert(&USARTtoUSB_Buffer, ReceivedByte);
}

@ Event handler for the CDC Class driver Line Encoding Changed event.

@<Function Prototypes@>=
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo);

@ @c
void EVENT_CDC_Device_LineEncodingChanged(const CDCInterfaceInfo)
USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo; /* pointer to the CDC class interface configuration structure being referenced */
{
	uint8_t ConfigMask = 0;

	switch (CDCInterfaceInfo->State.LineEncoding.ParityType)
	{
		case CDC_PARITY_Odd:
			ConfigMask = ((1 << UPM11) | (1 << UPM10));
			break;
		case CDC_PARITY_Even:
			ConfigMask = (1 << UPM11);
			break;
	}

	if (CDCInterfaceInfo->State.LineEncoding.CharFormat == CDC_LINEENCODING_TwoStopBits)
	  ConfigMask |= (1 << USBS1);

	switch (CDCInterfaceInfo->State.LineEncoding.DataBits)
	{
		case 6:
			ConfigMask |= (1 << UCSZ10);
			break;
		case 7:
			ConfigMask |= (1 << UCSZ11);
			break;
		case 8:
			ConfigMask |= ((1 << UCSZ11) | (1 << UCSZ10));
			break;
	}

	/* Keep the TX line held high (idle) while the USART is reconfigured */
	PORTD |= (1 << 3);

	/* Must turn off USART before reconfiguring it, otherwise incorrect operation may occur */
	UCSR1B = 0;
	UCSR1A = 0;
	UCSR1C = 0;

	/* Set the new baud rate before configuring the USART */
	UBRR1  = SERIAL_2X_UBBRVAL(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS);

	/* Reconfigure the USART in double speed mode for a wider baud rate range at the expense of accuracy */
	UCSR1C = ConfigMask;
	UCSR1A = (1 << U2X1);
	UCSR1B = ((1 << RXCIE1) | (1 << TXEN1) | (1 << RXEN1));

	/* Release the TX line after the USART has been reconfigured */
	PORTD &= ~(1 << 3);
}

@ @<Includes@>=
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/power.h>

		#include "Descriptors.h"

#include <LUFA/Drivers/Board/LEDs.h>
#include <LUFA/Drivers/Peripheral/Serial.h>
#include <LUFA/Drivers/Misc/RingBuffer.h>
#include <LUFA/Drivers/USB/USB.h>
#include <LUFA/Platform/Platform.h>
@* USB Device Descriptors. Used in USB device mode. Descriptors are special
computer-readable structures which the host requests upon device enumeration, to determine
the device's capabilities and functions.

@ Device descriptor structure. This descriptor, located in FLASH memory, describes the overall
device characteristics, including the supported USB version, control endpoint size and the
number of device configurations. The descriptor is read out by the USB host when the enumeration
process begins.

@<YYY structure@>=
const USB_Descriptor_Device_t PROGMEM DeviceDescriptor =
{
	.Header                 = {.Size = sizeof(USB_Descriptor_Device_t), .Type = DTYPE_Device},

	.USBSpecification       = VERSION_BCD(1,1,0),
	.Class                  = CDC_CSCP_CDCClass,
	.SubClass               = CDC_CSCP_NoSpecificSubclass,
	.Protocol               = CDC_CSCP_NoSpecificProtocol,

	.Endpoint0Size          = FIXED_CONTROL_ENDPOINT_SIZE,

	.VendorID               = 0x03EB,
	.ProductID              = 0x204B,
	.ReleaseNumber          = VERSION_BCD(0,0,1),

	.ManufacturerStrIndex   = STRING_ID_Manufacturer,
	.ProductStrIndex        = STRING_ID_Product,
	.SerialNumStrIndex      = USE_INTERNAL_SERIAL,

	.NumberOfConfigurations = FIXED_NUM_CONFIGURATIONS
};

@ Configuration descriptor structure. This descriptor, located in FLASH memory, describes the usage
of the device in one of its supported configurations, including information about any device interfaces
and endpoints. The descriptor is read out by the USB host during the enumeration process when selecting
a configuration so that the host may correctly communicate with the USB device.

@d CDC_NOTIFICATION_EPADDR (ENDPOINT_DIR_IN  | 2) /* endpoint address of the CDC device-to-host notification IN en
dpoint */
@d CDC_TX_EPADDR (ENDPOINT_DIR_IN  | 3) /* endpoint address of the CDC device-to-host data IN endpoint */
@d CDC_RX_EPADDR (ENDPOINT_DIR_OUT | 4) /* endpoint address of the CDC host-to-device data OUT endpoint */
@d CDC_NOTIFICATION_EPSIZE 8 /* size in bytes of the CDC device-to-host notification IN endpoint */
@d CDC_TXRX_EPSIZE 16 /* size in bytes of the CDC data IN and OUT endpoints */

@<ZZZ structure@>=
const USB_Descriptor_Configuration_t PROGMEM ConfigurationDescriptor =
{
  .Config =
	{
		.Header = {.Size = sizeof(USB_Descriptor_Configuration_Header_t), .Type = DTYPE_Configuration},

		.TotalConfigurationSize = sizeof(USB_Descriptor_Configuration_t),
		.TotalInterfaces        = 2,

		.ConfigurationNumber    = 1,
		.ConfigurationStrIndex  = NO_DESCRIPTOR,

		.ConfigAttributes       = (USB_CONFIG_ATTR_RESERVED | USB_CONFIG_ATTR_SELFPOWERED),

		.MaxPowerConsumption    = USB_CONFIG_POWER_MA(100)
	},

  .CDC_CCI_Interface =
	{
		.Header                 = {.Size = sizeof(USB_Descriptor_Interface_t), .Type = DTYPE_Interface},

		.InterfaceNumber        = INTERFACE_ID_CDC_CCI,
		.AlternateSetting       = 0,

		.TotalEndpoints         = 1,

		.Class                  = CDC_CSCP_CDCClass,
		.SubClass               = CDC_CSCP_ACMSubclass,
		.Protocol               = CDC_CSCP_ATCommandProtocol,

		.InterfaceStrIndex      = NO_DESCRIPTOR
	},

  .CDC_Functional_Header =
	{
		.Header = {.Size = sizeof(USB_CDC_Descriptor_FunctionalHeader_t), .Type = DTYPE_CSInterface},
		.Subtype                = CDC_DSUBTYPE_CSInterface_Header,

		.CDCSpecification       = VERSION_BCD(1,1,0),
	},

  .CDC_Functional_ACM =
	{
		.Header = {.Size = sizeof(USB_CDC_Descriptor_FunctionalACM_t), .Type = DTYPE_CSInterface},
		.Subtype                = CDC_DSUBTYPE_CSInterface_ACM,

		.Capabilities           = 0x06,
	},

  .CDC_Functional_Union =
	{
		.Header = {.Size = sizeof(USB_CDC_Descriptor_FunctionalUnion_t), .Type = DTYPE_CSInterface},
		.Subtype                = CDC_DSUBTYPE_CSInterface_Union,

		.MasterInterfaceNumber  = INTERFACE_ID_CDC_CCI,
		.SlaveInterfaceNumber   = INTERFACE_ID_CDC_DCI,
	},

  .CDC_NotificationEndpoint =
	{
		.Header                 = {.Size = sizeof(USB_Descriptor_Endpoint_t), .Type = DTYPE_Endpoint},

		.EndpointAddress        = CDC_NOTIFICATION_EPADDR,
		.Attributes             = (EP_TYPE_INTERRUPT | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),
		.EndpointSize           = CDC_NOTIFICATION_EPSIZE,
		.PollingIntervalMS      = 0xFF
	},

  .CDC_DCI_Interface =
	{
		.Header                 = {.Size = sizeof(USB_Descriptor_Interface_t), .Type = DTYPE_Interface},

		.InterfaceNumber        = INTERFACE_ID_CDC_DCI,
		.AlternateSetting       = 0,

		.TotalEndpoints         = 2,

		.Class                  = CDC_CSCP_CDCDataClass,
		.SubClass               = CDC_CSCP_NoDataSubclass,
		.Protocol               = CDC_CSCP_NoDataProtocol,

		.InterfaceStrIndex      = NO_DESCRIPTOR
	},

  .CDC_DataOutEndpoint =
	{
		.Header                 = {.Size = sizeof(USB_Descriptor_Endpoint_t), .Type = DTYPE_Endpoint},

		.EndpointAddress        = CDC_RX_EPADDR,
		.Attributes             = (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),
		.EndpointSize           = CDC_TXRX_EPSIZE,
		.PollingIntervalMS      = 0x05
	},

  .CDC_DataInEndpoint =
	{
		.Header                 = {.Size = sizeof(USB_Descriptor_Endpoint_t), .Type = DTYPE_Endpoint},

		.EndpointAddress        = CDC_TX_EPADDR,
		.Attributes             = (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),
		.EndpointSize           = CDC_TXRX_EPSIZE,
		.PollingIntervalMS      = 0x05
	}
};

@ Language descriptor structure. This descriptor, located in FLASH memory, is returned when the host requests
the string descriptor with index 0 (the first index). It is actually an array of 16-bit integers, which indicate
via the language ID table available at USB.org what languages the device supports for its string descriptors.

@<Global...@>=
const USB_Descriptor_String_t PROGMEM LanguageString = USB_STRING_DESCRIPTOR_ARRAY(LANGUAGE_ID_ENG);

@ Manufacturer descriptor string. This is a Unicode string containing the manufacturer's details in human readable
form, and is read out upon request by the host when the appropriate string ID is requested, listed in the Device
Descriptor.

@<Global...@>=
const USB_Descriptor_String_t PROGMEM ManufacturerString = USB_STRING_DESCRIPTOR(L"Dean Camera");

@ Product descriptor string. This is a Unicode string containing the product's details in human readable form,
and is read out upon request by the host when the appropriate string ID is requested, listed in the Device
Descriptor.

@<Global...@>=
const USB_Descriptor_String_t PROGMEM ProductString = USB_STRING_DESCRIPTOR(L"LUFA USB-RS232 Adapter");

@ This function is called by the library when in device mode, and must be overridden (see library "USB Descriptors"
documentation) by the application code so that the address and size of a requested descriptor can be given
to the USB library. When the device receives a Get Descriptor request on the control endpoint, this function
is called so that the descriptor details can be passed back and the appropriate descriptor sent back to the
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
		case DTYPE_Device:
			Address = &DeviceDescriptor;
			Size    = sizeof(USB_Descriptor_Device_t);
			break;
		case DTYPE_Configuration:
			Address = &ConfigurationDescriptor;
			Size    = sizeof(USB_Descriptor_Configuration_t);
			break;
		case DTYPE_String:
			switch (DescriptorNumber)
			{
				case STRING_ID_Language:
					Address = &LanguageString;
					Size    = pgm_read_byte(&LanguageString.Header.Size);
					break;
				case STRING_ID_Manufacturer:
					Address = &ManufacturerString;
					Size    = pgm_read_byte(&ManufacturerString.Header.Size);
					break;
				case STRING_ID_Product:
					Address = &ProductString;
					Size    = pgm_read_byte(&ProductString.Header.Size);
					break;
			}

			break;
	}

	*DescriptorAddress = Address;
	return Size;
}

@ @<Includes@>=
#include <avr/pgmspace.h>
#include <LUFA/Drivers/USB/USB.h>

@ Type define for the device configuration descriptor structure. This must be defined in the
application code, as the configuration descriptor contains several sub-descriptors which
vary between devices, and which describe the device's usage to the host.

@<Type definitions@>= 
typedef struct
{
	USB_Descriptor_Configuration_Header_t    Config;

	// CDC Command Interface
	USB_Descriptor_Interface_t               CDC_CCI_Interface;
	USB_CDC_Descriptor_FunctionalHeader_t    CDC_Functional_Header;
	USB_CDC_Descriptor_FunctionalACM_t       CDC_Functional_ACM;
	USB_CDC_Descriptor_FunctionalUnion_t     CDC_Functional_Union;
	USB_Descriptor_Endpoint_t                CDC_NotificationEndpoint;

	// CDC Data Interface
	USB_Descriptor_Interface_t               CDC_DCI_Interface;
	USB_Descriptor_Endpoint_t                CDC_DataOutEndpoint;
	USB_Descriptor_Endpoint_t                CDC_DataInEndpoint;
} USB_Descriptor_Configuration_t;

@ Enum for the device interface descriptor IDs within the device. Each interface descriptor
should have a unique ID index associated with it, which can be used to refer to the
interface from other descriptors.

@<Type definitions@>=
enum InterfaceDescriptors_t
{
	INTERFACE_ID_CDC_CCI = 0, /* CDC CCI interface descriptor ID */
	INTERFACE_ID_CDC_DCI = 1, /* CDC DCI interface descriptor ID */
};

@ Enum for the device string descriptor IDs within the device. Each string descriptor should
have a unique ID index associated with it, which can be used to refer to the string from
other descriptors.

@<Type definitions@>=
enum StringDescriptors_t
{
	STRING_ID_Language     = 0, /* Supported Languages string descriptor ID (must be zero) */
	STRING_ID_Manufacturer = 1, /* Manufacturer string ID */
	STRING_ID_Product      = 2, /* Product string ID */
};
