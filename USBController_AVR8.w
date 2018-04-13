/** USB Controller definitions for the AVR8 microcontrollers.
 *  Functions, macros, variables, enums and types related to the setup and management of
 the USB interface.
 */

#define USB_PLL_PSC                (1 << PINDIV)

/** \name USB Controller Option Masks */

/** Regulator disable option mask for \ref USB_Init(). This indicates that the internal
 3.3V USB data pad
 *  regulator should be disabled and the AVR's VCC level used for the data pads.
 *
 *  \note See USB AVR data sheet for more information on the internal pad regulator.
 */
#define USB_OPT_REG_DISABLED               (1 << 1)

/** Regulator enable option mask for \ref USB_Init(). This indicates that the internal
 3.3V USB data pad
 *  regulator should be enabled to regulate the data pin voltages from the VBUS level down
 to a level within
 *  the range allowable by the USB standard.
 *
 *  \note See USB AVR data sheet for more information on the internal pad regulator.
 */
#define USB_OPT_REG_ENABLED                (0 << 1)

/** Option mask for \ref USB_Init() to keep regulator enabled at all times. Indicates that
 \ref USB_Disable()
 *  should not disable the regulator as it would otherwise. Has no effect if regulator is
 disabled using
 *  \ref USB_OPT_REG_DISABLED.
 *
 *  \note See USB AVR data sheet for more information on the internal pad regulator.
 */
#define USB_OPT_REG_KEEP_ENABLED           (1 << 3)

/** Manual PLL control option mask for \ref USB_Init(). This indicates to the library that
 the user application
 *  will take full responsibility for controlling the AVR's PLL (used to generate the high
 frequency clock
 *  that the USB controller requires) and ensuring that it is locked at the correct frequency
 for USB operations.
 */
#define USB_OPT_MANUAL_PLL                 (1 << 2)

/** Automatic PLL control option mask for \ref USB_Init(). This indicates to the library that
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

/** Determines if the VBUS line is currently high (i.e. the USB host is supplying power).
 *
 *  \note This function is not available on some AVR models which do not support hardware
 VBUS monitoring.
 *
 *  \return Boolean \c true if the VBUS line is currently detecting power from a host,
 \c false otherwise.
 */
inline bool USB_VBUS_GetStatus(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool USB_VBUS_GetStatus(void)
{
	return ((USBSTA & (1 << VBUS)) ? true : false);
}

/** Detaches the device from the USB bus. This has the effect of removing the device from any
 *  attached host, ceasing USB communications. If no host is present, this prevents any host from
 *  enumerating the device once attached until \ref USB_Attach() is called.
 */
inline void USB_Detach(void) ATTR_ALWAYS_INLINE;
inline void USB_Detach(void)
{
	UDCON  |=  (1 << DETACH);
}

/** Attaches the device to the USB bus. This announces the device's presence to any attached
 *  USB host, starting the enumeration process. If no host is present, attaching the device
 *  will allow for enumeration once a host is connected to the device.
 *
 *  This is inexplicably also required for proper operation while in host mode, to enable the
 *  attachment of a device to the host. This is despite the bit being located in the device-mode
 *  register and despite the datasheet making no mention of its requirement in host mode.
 */
inline void USB_Attach(void) ATTR_ALWAYS_INLINE;
inline void USB_Attach(void)
{
	UDCON  &= ~(1 << DETACH);
}

/** Main function to initialize and start the USB interface. Once active, the USB interface will
 *  allow for device connection to a host when in device mode, or for device enumeration while in
 *  host mode.
 *
 *  As the USB library relies on interrupts for the device and host mode enumeration processes,
 *  the user must enable global interrupts before or shortly after this function is called. In
 *  device mode, interrupts must be enabled within 500ms of this function being called to ensure
 *  that the host does not time out whilst enumerating the device. In host mode, interrupts may be
 *  enabled at the application's leisure however enumeration will not begin of an attached device
 *  until after this has occurred.
 *
 *  Calling this function when the USB interface is already initialized will cause a complete USB
 *  interface reset and re-enumeration.
 *
 *  \param[in] Mode     Mask indicating what mode the USB interface is to be initialized to,
 a value
 *                      from the \ref USB_Modes_t enum.
 *                      \note This parameter does not exist on devices with only one supported USB
 *                            mode (device or host).
 *
 *  \param[in] Options  Mask indicating the options which should be used when initializing the USB
 *                      interface to control the USB interface's behavior. This should be
 comprised of
 *                      a \c USB_OPT_REG_* mask to control the regulator, a \c USB_OPT_*_PLL
 mask to control the
 *                      PLL, and a \c USB_DEVICE_OPT_* mask (when the device mode is enabled)
 to set the device
 *                      mode speed.
 *
 *  \note To reduce the FLASH requirements of the library if only device or host mode is required,
 *        the mode can be statically set in the project makefile by defining the token
 \c USB_DEVICE_ONLY
 *        (for device mode) or \c USB_HOST_ONLY (for host mode), passing the token to the compiler
 *        via the -D switch. If the mode is statically set, this parameter does not exist in the
 *        function prototype.
 *        \n\n
 *
 *  \note To reduce the FLASH requirements of the library if only fixed settings are required,
 *        the options may be set statically in the same manner as the mode (see the Mode
 parameter of
 *        this function). To statically set the USB options, pass in the \c USE_STATIC_OPTIONS
 token,
 *        defined to the appropriate options masks. When the options are statically set, this
 *        parameter does not exist in the function prototype.
 *        \n\n
 *
 *  \note The mode parameter does not exist on devices where only one mode is possible, such as USB
 *        AVR models which only implement the USB device mode in hardware.
 *
 *  \see \ref Group_Device for the \c USB_DEVICE_OPT_* masks.
 */
void USB_Init(void);

/** Shuts down the USB interface. This turns off the USB interface after deallocating all USB FIFO
 *  memory, endpoints and pipes. When turned off, no USB functionality can be used until the
 interface
 *  is restarted with the \ref USB_Init() function.
 */
void USB_Disable(void);

/** Resets the interface, when already initialized. This will re-enumerate the device if
 already connected
 *  to a host, or re-enumerate an already attached device when in host mode.
 */
void USB_ResetInterface(void);

#define USB_Options USE_STATIC_OPTIONS

inline void USB_PLL_On(void) ATTR_ALWAYS_INLINE;
inline void USB_PLL_On(void)
{
	PLLCSR = USB_PLL_PSC;
	PLLCSR = (USB_PLL_PSC | (1 << PLLE));
}

inline void USB_PLL_Off(void) ATTR_ALWAYS_INLINE;
inline void USB_PLL_Off(void)
{
	PLLCSR = 0;
}

inline bool USB_PLL_IsReady(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
inline bool USB_PLL_IsReady(void)
{
	return ((PLLCSR & (1 << PLOCK)) ? true : false);
}

inline void USB_REG_On(void) ATTR_ALWAYS_INLINE;
inline void USB_REG_On(void)
{
	UHWCON |=  (1 << UVREGE);
}

inline void USB_REG_Off(void) ATTR_ALWAYS_INLINE;
inline void USB_REG_Off(void)
{
	UHWCON &= ~(1 << UVREGE);
}

inline void USB_OTGPAD_On(void) ATTR_ALWAYS_INLINE;
inline void USB_OTGPAD_On(void)
{
	USBCON |=  (1 << OTGPADE);
}

inline void USB_OTGPAD_Off(void) ATTR_ALWAYS_INLINE;
inline void USB_OTGPAD_Off(void)
{
	USBCON &= ~(1 << OTGPADE);
}

inline void USB_CLK_Freeze(void) ATTR_ALWAYS_INLINE;
inline void USB_CLK_Freeze(void)
{
	USBCON |=  (1 << FRZCLK);
}

inline void USB_CLK_Unfreeze(void) ATTR_ALWAYS_INLINE;
inline void USB_CLK_Unfreeze(void)
{
	USBCON &= ~(1 << FRZCLK);
}

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
