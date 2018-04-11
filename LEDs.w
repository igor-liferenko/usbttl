/** \file
 *  \brief LED board hardware driver.
 *
 *  This file is the master dispatch header file for the board-specific LED driver, for boards containing user
 *  controllable LEDs.
 *
 *  User code should include this file, which will in turn include the correct LED driver header file for the
 *  currently selected board.
 *
 *  If the \c BOARD value is set to \c BOARD_USER, this will include the \c /Board/LEDs.h file in the user project
 *  directory.
 *
 *  For possible \c BOARD makefile values, see \ref Group_BoardTypes.
 */

/** \ingroup Group_BoardDrivers
 *  \defgroup Group_LEDs LEDs Driver - LUFA/Drivers/Board/LEDs.h
 *  \brief LED board hardware driver.
 *
 *  \section Sec_LEDs_Dependencies Module Source Dependencies
 *  The following files must be built with any user project that uses this module:
 *    - None
 *
 *  \section Sec_LEDs_ModDescription Module Description
 *  Hardware LEDs driver. This provides an easy to use driver for the hardware LEDs present on many boards. It
 *  provides an interface to configure, test and change the status of all the board LEDs.
 *
 *  If the \c BOARD value is set to \c BOARD_USER, this will include the \c /Board/LEDs.h file in the user project
 *  directory. Otherwise, it will include the appropriate built-in board driver header file. If the BOARD value
 *  is set to \c BOARD_NONE, this driver is silently disabled.
 *
 *  For possible \c BOARD makefile values, see \ref Group_BoardTypes.
 *
 *  \note To make code as compatible as possible, it is assumed that all boards carry a minimum of four LEDs. If
 *        a board contains less than four LEDs, the remaining LED masks are defined to 0 so as to have no effect.
 *        If other behavior is desired, either alias the remaining LED masks to existing LED masks via the -D
 *        switch in the project makefile, or alias them to nothing in the makefile to cause compilation errors when
 *        a non-existing LED is referenced in application code. Note that this means that it is possible to make
 *        compatible code for a board with no LEDs by making a board LED driver (see \ref Page_WritingBoardDrivers)
 *        which contains only stub functions and defines no LEDs.
 *
 *  \section Sec_LEDs_ExampleUsage Example Usage
 *  The following snippet is an example of how this module may be used within a typical
 *  application.
 *
 *  \code
 *      // Initialize the board LED driver before first use
 *      LEDs_Init();
 *
 *      // Turn on each of the four LEDs in turn
 *      LEDs_SetAllLEDs(LEDS_LED1);
 *      Delay_MS(500);
 *      LEDs_SetAllLEDs(LEDS_LED2);
 *      Delay_MS(500);
 *      LEDs_SetAllLEDs(LEDS_LED3);
 *      Delay_MS(500);
 *      LEDs_SetAllLEDs(LEDS_LED4);
 *      Delay_MS(500);
 *
 *      // Turn on all LEDs
 *      LEDs_SetAllLEDs(LEDS_ALL_LEDS);
 *      Delay_MS(1000);
 *
 *      // Turn on LED 1, turn off LED 2, leaving LEDs 3 and 4 in their current state
 *      LEDs_ChangeLEDs((LEDS_LED1 | LEDS_LED2), LEDS_LED1);
 *  \endcode
 *
 *  @{
 */

@i USBKEY-LEDs.w
