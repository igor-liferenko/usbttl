/** \file
 *  \brief Main USB service task management.
 *
 *  This file contains the function definitions required for the main USB service task, which must be called
 *  from the user application to ensure that the USB connection to or from a connected USB device is maintained.
 *
 *  \note This file should not be included directly. It is automatically included as needed by the USB driver
 *        dispatch header located in LUFA/Drivers/USB/USB.h.
 */

#ifndef __USBTASK_H__
#define __USBTASK_H__

	/* Includes: */
		#include "../../../Common/Common.h"
		#include "USBMode.h"
		#include "USBController.h"
		#include "Events.h"
		#include "StdRequestType.h"
		#include "StdDescriptors.h"

		#if defined(USB_CAN_BE_DEVICE)
			#include "DeviceStandardReq.h"
		#endif

	/* Preprocessor Checks: */
		#if !defined(__INCLUDE_FROM_USB_DRIVER)
			#error Do not include this file directly. Include LUFA/Drivers/USB/USB.h instead.
		#endif

	/* Public Interface - May be used in end-application: */
		/* Global Variables: */
			/** Indicates if the USB interface is currently initialized but not necessarily connected to a host
			 *  or device (i.e. if \ref USB_Init() has been run). If this is false, all other library globals related
			 *  to the USB driver are invalid.
			 *
			 *  \attention This variable should be treated as read-only in the user application, and never manually
			 *             changed in value.
			 *
			 *  \ingroup Group_USBManagement
			 */
			 volatile bool USB_IsInitialized;

			/** Structure containing the last received Control request when in Device mode (for use in user-applications
			 *  inside of the \ref EVENT_USB_Device_ControlRequest() event, or for filling up with a control request to
			 *  issue when in Host mode before calling \ref USB_Host_SendControlRequest().
			 *
			 *  \note The contents of this structure is automatically endian-corrected for the current CPU architecture.
			 *
			 *  \ingroup Group_USBManagement
			 */
			 USB_Request_Header_t USB_ControlRequest;

			#if defined(USB_CAN_BE_DEVICE) || defined(__DOXYGEN__)
				#define USB_DeviceState            CONCAT_EXPANDED(GPIOR, DEVICE_STATE_AS_GPIOR)
			#endif

		/* Function Prototypes: */
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
			 *  by defining the INTERRUPT_CONTROL_ENDPOINT token and passing it to the compiler via the -D switch.
			 *
			 *  \see \ref Group_Events for more information on the USB events.
			 *
			 *  \ingroup Group_USBManagement
			 */
			void USB_DeviceTask(void);
#endif

