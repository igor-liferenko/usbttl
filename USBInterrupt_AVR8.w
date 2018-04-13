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
