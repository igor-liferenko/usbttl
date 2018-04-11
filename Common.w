/** \dir
 *  \brief Common library header files.
 *
 *  This folder contains header files which are common to all parts of the LUFA library. They may be used freely in
 *  user applications.
 */

/** \file
 *  \brief Common library convenience headers, macros and functions.
 *
 *  \copydetails Group_Common
 */

/** \defgroup Group_Common Common Utility Headers - LUFA/Drivers/Common/Common.h
 *  \brief Common library convenience headers, macros and functions.
 *
 *  Common utility headers containing macros, functions, enums and types which are common to all
 *  aspects of the library.
 *
 *  @{
 */

/** \defgroup Group_GlobalInt Global Interrupt Macros
 *  \brief Convenience macros for the management of interrupts globally within the device.
 *
 *  Macros and functions to create and control global interrupts within the device.
 */

	/* Macros: */
		#define __INCLUDE_FROM_COMMON_H

	/* Includes: */
		#include <stdint.h>
		#include <stdbool.h>
		#include <string.h>
		#include <stddef.h>

		#include "LUFA/Common/Architectures.h"
		#include "LUFA/Common/BoardTypes.h"
		#include "LUFA/Common/ArchitectureSpecific.h"
		#include "LUFA/Common/CompilerSpecific.h"
		#include "LUFA/Common/Attributes.h"

		#include "Config/LUFAConfig.h"

	/* Architecture specific utility includes: */

			#include <avr/io.h>
			#include <avr/interrupt.h>
			#include <avr/pgmspace.h>
			#include <avr/eeprom.h>
			#include <avr/boot.h>
			#include <math.h>
			#include <util/delay.h>

			typedef uint8_t uint_reg_t;

			#define ARCH_HAS_EEPROM_ADDRESS_SPACE
			#define ARCH_HAS_FLASH_ADDRESS_SPACE
			#define ARCH_HAS_MULTI_ADDRESS_SPACE
			#define ARCH_LITTLE_ENDIAN

			#include "LUFA/Common/Endianness.h"

			/** Convenience macro to determine the larger of two values.
			 *
			 *  \attention This macro should only be used with operands that do not have side effects from being evaluated
			 *             multiple times.
			 *
			 *  \param[in] x  First value to compare
			 *  \param[in] y  First value to compare
			 *
			 *  \return The larger of the two input parameters
			 */
				#define MAX(x, y)               (((x) > (y)) ? (x) : (y))

			/** Convenience macro to determine the smaller of two values.
			 *
			 *  \attention This macro should only be used with operands that do not have side effects from being evaluated
			 *             multiple times.
			 *
			 *  \param[in] x  First value to compare.
			 *  \param[in] y  First value to compare.
			 *
			 *  \return The smaller of the two input parameters
			 */
				#define MIN(x, y)               (((x) < (y)) ? (x) : (y))

				/** Converts the given input into a string, via the C Preprocessor. This macro puts literal quotation
				 *  marks around the input, converting the source into a string literal.
				 *
				 *  \param[in] x  Input to convert into a string literal.
				 *
				 *  \return String version of the input.
				 */
				#define STRINGIFY(x)            #x

				/** Converts the given input into a string after macro expansion, via the C Preprocessor. This macro puts
				 *  literal quotation marks around the expanded input, converting the source into a string literal.
				 *
				 *  \param[in] x  Input to expand and convert into a string literal.
				 *
				 *  \return String version of the expanded input.
				 */
				#define STRINGIFY_EXPANDED(x)   STRINGIFY(x)

				/** Concatenates the given input into a single token, via the C Preprocessor.
				 *
				 *  \param[in] x  First item to concatenate.
				 *  \param[in] y  Second item to concatenate.
				 *
				 *  \return Concatenated version of the input.
				 */
				#define CONCAT(x, y)            x ## y

				/** CConcatenates the given input into a single token after macro expansion, via the C Preprocessor.
				 *
				 *  \param[in] x  First item to concatenate.
				 *  \param[in] y  Second item to concatenate.
				 *
				 *  \return Concatenated version of the expanded input.
				 */
				#define CONCAT_EXPANDED(x, y)   CONCAT(x, y)

		/* Inline Functions: */
			/** Function to reverse the individual bits in a byte - i.e. bit 7 is moved to bit 0, bit 6 to bit 1,
			 *  etc.
			 *
			 *  \param[in] Byte  Byte of data whose bits are to be reversed.
			 *
			 *  \return Input data with the individual bits reversed (mirrored).
			 */
			static inline uint8_t BitReverse(uint8_t Byte) ATTR_WARN_UNUSED_RESULT ATTR_CONST;
			static inline uint8_t BitReverse(uint8_t Byte)
			{
				Byte = (((Byte & 0xF0) >> 4) | ((Byte & 0x0F) << 4));
				Byte = (((Byte & 0xCC) >> 2) | ((Byte & 0x33) << 2));
				Byte = (((Byte & 0xAA) >> 1) | ((Byte & 0x55) << 1));

				return Byte;
			}

			/** Function to perform a blocking delay for a specified number of milliseconds. The actual delay will be
			 *  at a minimum the specified number of milliseconds, however due to loop overhead and internal calculations
			 *  may be slightly higher.
			 *
			 *  \param[in] Milliseconds  Number of milliseconds to delay
			 */
			static inline void Delay_MS(uint16_t Milliseconds) ATTR_ALWAYS_INLINE;
			static inline void Delay_MS(uint16_t Milliseconds)
			{
				if (GCC_IS_COMPILE_CONST(Milliseconds))
				{
					_delay_ms(Milliseconds);
				}
				else
				{
					while (Milliseconds--)
					  _delay_ms(1);
				}
			}

			/** Retrieves a mask which contains the current state of the global interrupts for the device. This
			 *  value can be stored before altering the global interrupt enable state, before restoring the
			 *  flag(s) back to their previous values after a critical section using \ref SetGlobalInterruptMask().
			 *
			 *  \ingroup Group_GlobalInt
			 *
			 *  \return  Mask containing the current Global Interrupt Enable Mask bit(s).
			 */
			static inline uint_reg_t GetGlobalInterruptMask(void) ATTR_ALWAYS_INLINE ATTR_WARN_UNUSED_RESULT;
			static inline uint_reg_t GetGlobalInterruptMask(void)
			{
				GCC_MEMORY_BARRIER();
				return SREG;
			}

			/** Sets the global interrupt enable state of the microcontroller to the mask passed into the function.
			 *  This can be combined with \ref GetGlobalInterruptMask() to save and restore the Global Interrupt Enable
			 *  Mask bit(s) of the device after a critical section has completed.
			 *
			 *  \ingroup Group_GlobalInt
			 *
			 *  \param[in] GlobalIntState  Global Interrupt Enable Mask value to use
			 */
			static inline void SetGlobalInterruptMask(const uint_reg_t GlobalIntState) ATTR_ALWAYS_INLINE;
			static inline void SetGlobalInterruptMask(const uint_reg_t GlobalIntState)
			{
				GCC_MEMORY_BARRIER();

				SREG = GlobalIntState;

				GCC_MEMORY_BARRIER();
			}

			/** Enables global interrupt handling for the device, allowing interrupts to be handled.
			 *
			 *  \ingroup Group_GlobalInt
			 */
			static inline void GlobalInterruptEnable(void) ATTR_ALWAYS_INLINE;
			static inline void GlobalInterruptEnable(void)
			{
				GCC_MEMORY_BARRIER();

				sei();

				GCC_MEMORY_BARRIER();
			}

			/** Disabled global interrupt handling for the device, preventing interrupts from being handled.
			 *
			 *  \ingroup Group_GlobalInt
			 */
			static inline void GlobalInterruptDisable(void) ATTR_ALWAYS_INLINE;
			static inline void GlobalInterruptDisable(void)
			{
				GCC_MEMORY_BARRIER();

				cli();

				GCC_MEMORY_BARRIER();
			}