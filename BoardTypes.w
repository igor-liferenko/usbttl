/* Board hardware defines.
 *
 *  Board macros for indicating the chosen physical board hardware to the library.
 These macros should be used when
 *  defining the \c BOARD token to the chosen hardware via the \c -D switch in the
 project makefile. If a custom
 *  board is used, the \ref BOARD_NONE or \ref BOARD_USER values should be selected.
 *
 */

/** Selects the user-defined board drivers, which should be placed in the user project's folder
 *  under a directory named \c /Board/. Each board driver should be named identically to the LUFA
 *  master board driver (i.e., driver in the \c LUFA/Drivers/Board directory) so that the library
 *  can correctly identify it.
 */
#define BOARD_USER                 0

/** Disables board drivers when operation will not be adversely affected (e.g. LEDs) - use
 of board drivers
 *  such as the Joystick driver, where the removal would adversely affect the code's
 operation is still disallowed. */
#define BOARD_NONE                 1

/** Selects the USBKEY specific board drivers, including Temperature, Button, Dataflash,
 Joystick and LED drivers. */
#define BOARD_USBKEY               2

#define BOARD_                 BOARD_NONE
