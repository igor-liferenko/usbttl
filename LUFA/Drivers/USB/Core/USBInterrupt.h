/** \file
 *  \brief USB controller interrupt service routine management.
 *
 *  This file contains definitions required for the correct handling of low level USB service routine interrupts
 *  from the USB controller.
 *
 *  \note This file should not be included directly. It is automatically included as needed by the USB driver
 *        dispatch header located in LUFA/Drivers/USB/USB.h.
 */

#ifndef __USBINTERRUPT_H__
#define __USBINTERRUPT_H__

	/* Includes: */
		#include "../../../Common/Common.h"
		#include "USBMode.h"

	/* Architecture Includes: */
			#include "AVR8/USBInterrupt_AVR8.h"
#endif

