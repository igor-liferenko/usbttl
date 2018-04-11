/** \file
 *  \brief Hardware Serial USART driver.
 *
 *  This file is the master dispatch header file for the device-specific USART driver, for microcontrollers
 *  containing a hardware USART.
 *
 *  User code should include this file, which will in turn include the correct ADC driver header file for the
 *  currently selected architecture and microcontroller model.
 */

/** \ingroup Group_PeripheralDrivers
 *  \defgroup Group_Serial Serial USART Driver - LUFA/Drivers/Peripheral/Serial.h
 *  \brief Hardware Serial USART driver.
 *
 *  \section Sec_Serial_Dependencies Module Source Dependencies
 *  The following files must be built with any user project that uses this module:
 *    - LUFA/Drivers/Peripheral/<i>ARCH</i>/Serial_<i>ARCH</i>.c <i>(Makefile source module name: LUFA_SRC_SERIAL)</i>
 *
 *  \section Sec_Serial_ModDescription Module Description
 *  Hardware serial USART driver. This module provides an easy to use driver for the setup and transfer
 *  of data over the selected architecture and microcontroller model's USART port.
 *
 *  \note The exact API for this driver may vary depending on the target used - see
 *        individual target module documentation for the API specific to your target processor.
 */

@i Serial_AVR8.w
