/** \file
 *  \brief Supported library architecture defines.
 *
 *  \copydetails Group_Architectures
 *
 *  \note Do not include this file directly, rather include the Common.h header file instead to gain this file's
 *        functionality.
 */

/** \ingroup Group_Common
 *  \defgroup Group_Architectures Hardware Architectures
 *  \brief Supported library architecture defines.
 *
 *  Architecture macros for selecting the desired target microcontroller architecture. One of these values should be
 *  defined as the value of \c ARCH in the user project makefile via the \c -D compiler switch to GCC, to select the
 *  target architecture.
 *
 *  The selected architecture should remain consistent with the makefile \c ARCH value, which is used to select the
 *  underlying driver source files for each architecture.
 *
 *  @{
 */

			/** Selects the Atmel 8-bit AVR (AT90USB* and ATMEGA*U* chips) architecture. */
			#define ARCH_AVR8           0

			/** Selects the Atmel 32-bit UC3 AVR (AT32UC3* chips) architecture. */
			#define ARCH_UC3            1

			/** Selects the Atmel XMEGA AVR (ATXMEGA* chips) architecture. */
			#define ARCH_XMEGA          2

				#define ARCH_           ARCH_AVR8
