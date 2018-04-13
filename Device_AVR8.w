/** USB Device definitions for the AVR8 microcontrollers.
 */

/** USB Device definitions for the AVR8 microcontrollers.
 *
 *  Architecture specific USB Device definitions for the Atmel 8-bit AVR microcontrollers.
 *
 */

@*4 USB Device Mode Option Masks.

@ Mask for the Options parameter of the \ref USB_Init() function. This indicates that the
USB interface should be initialized in low speed (1.5Mb/s) mode.

\note Low Speed mode is not available on all USB AVR models.
        \n

\note Restrictions apply on the number, size and type of endpoints which can be used
        when running in low speed mode - please refer to the USB 2.0 specification.

@<Header files@>=
#define USB_DEVICE_OPT_LOWSPEED            (1 << 0)

@ Mask for the Options parameter of the \ref USB_Init() function. This indicates that the
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

inline bool USB_Device_IsAddressSet(void) ATTR_ALWAYS_INLINE;
inline bool USB_Device_IsAddressSet(void)
{
  return (UDADDR & (1 << ADDEN));
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
