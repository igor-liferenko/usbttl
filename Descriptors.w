@* USB Device Descriptors. Used in USB device mode. Descriptors are special
computer-readable structures which the host requests upon device enumeration, to determine
the device's capabilities and functions.

@c
@<Includes@>@;
@<Type definitions@>@;
@<Function prototypes@>@;

@ Device descriptor structure. This descriptor, located in FLASH memory, describes the overall
device characteristics, including the supported USB version, control endpoint size and the
number of device configurations. The descriptor is read out by the USB host when the enumeration
process begins.

@c
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

@c
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

@c
const USB_Descriptor_String_t PROGMEM LanguageString = USB_STRING_DESCRIPTOR_ARRAY(LANGUAGE_ID_ENG);

@ Manufacturer descriptor string. This is a Unicode string containing the manufacturer's details in human readable
form, and is read out upon request by the host when the appropriate string ID is requested, listed in the Device
Descriptor.

@c
const USB_Descriptor_String_t PROGMEM ManufacturerString = USB_STRING_DESCRIPTOR(L"Dean Camera");

@ Product descriptor string. This is a Unicode string containing the product's details in human readable form,
and is read out upon request by the host when the appropriate string ID is requested, listed in the Device
Descriptor.

@c
const USB_Descriptor_String_t PROGMEM ProductString = USB_STRING_DESCRIPTOR(L"LUFA USB-RS232 Adapter");

@ This function is called by the library when in device mode, and must be overridden (see library "USB Descriptors"
documentation) by the application code so that the address and size of a requested descriptor can be given
to the USB library. When the device receives a Get Descriptor request on the control endpoint, this function
is called so that the descriptor details can be passed back and the appropriate descriptor sent back to the
USB host.

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

@ @<Function prototypes@>=
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
                                    const uint16_t wIndex,
                                    const void** const DescriptorAddress)
                                    ATTR_WARN_UNUSED_RESULT ATTR_NON_NULL_PTR_ARG(3);
