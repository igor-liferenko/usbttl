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
 *  \note To reduce FLASH usage of the compiled applications where Remote Wakeup is not supported,
 *        this global and the underlying management code can be disabled by defining the
 *        \c NO_DEVICE_REMOTE_WAKEUP token in the project makefile and passing it to the
 compiler via
 *        the -D switch.
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
