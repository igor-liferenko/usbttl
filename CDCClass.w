/** \file
 *  \brief Master include file for the library USB CDC-ACM Class driver.
 *
 *  Master include file for the library USB CDC Class driver, for both host and device modes, where available.
 *
 *  This file should be included in all user projects making use of this optional class driver, instead of
 *  including any headers in the USB/ClassDriver/Device, USB/ClassDriver/Host or USB/ClassDriver/Common subdirectories.
 */

/** \ingroup Group_USBClassDrivers
 *  \defgroup Group_USBClassCDC CDC-ACM (Virtual Serial) Class Driver
 *  \brief USB class driver for the USB-IF CDC-ACM (Virtual Serial) class standard.
 *
 *  \section Sec_USBClassCDC_Dependencies Module Source Dependencies
 *  The following files must be built with any user project that uses this module:
 *    - LUFA/Drivers/USB/Class/Device/CDCClassDevice.c <i>(Makefile source module name: LUFA_SRC_USBCLASS)</i>
 *    - LUFA/Drivers/USB/Class/Host/CDCClassHost.c <i>(Makefile source module name: LUFA_SRC_USBCLASS)</i>
 *
 *  \section Sec_USBClassCDC_ModDescription Module Description
 *  CDC Class Driver module. This module contains an internal implementation of the USB CDC-ACM class Virtual Serial
 *  Ports, for both Device and Host USB modes. User applications can use this class driver instead of implementing the
 *  CDC class manually via the low-level LUFA APIs.
 *
 *  This module is designed to simplify the user code by exposing only the required interface needed to interface with
 *  Hosts or Devices using the USB CDC Class.
 *
 */

#include "LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
