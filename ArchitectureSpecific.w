/* Architecture specific macros, functions and other definitions, which relate to
 specific architectures.
 */

/** Re-enables the AVR's JTAG bus in software, until a system reset. This will re-enable JTAG debugging
 *  interface after is has been disabled in software via \ref JTAG_DISABLE().
 *
 *  \note This macro is not available for all architectures.
 */
#define JTAG_ENABLE()               do {                                     \
                                        __asm__ __volatile__ (               \
                                        "in __tmp_reg__,__SREG__" "\n\t"     \
                                        "cli" "\n\t"                         \
                                        "out %1, %0" "\n\t"                  \
                                        "out __SREG__, __tmp_reg__" "\n\t"   \
                                        "out %1, %0" "\n\t"                  \
                                        :                                    \
                                        : "r" (MCUCR & ~(1 << JTD)),         \
                                          "M" (_SFR_IO_ADDR(MCUCR))          \
                                        : "r0");                             \
                                    } while (0)

					/** Disables the AVR's JTAG bus in software, until a system reset. This will override the current JTAG
					 *  status as set by the JTAGEN fuse, disabling JTAG debugging and reverting the JTAG pins back to GPIO
					 *  mode.
					 *
					 *  \note This macro is not available for all architectures.
					 */
					#define JTAG_DISABLE()              do {                                     \
					                                        __asm__ __volatile__ (               \
					                                        "in __tmp_reg__,__SREG__" "\n\t"     \
					                                        "cli" "\n\t"                         \
					                                        "out %1, %0" "\n\t"                  \
					                                        "out __SREG__, __tmp_reg__" "\n\t"   \
					                                        "out %1, %0" "\n\t"                  \
					                                        :                                    \
					                                        : "r" (MCUCR | (1 << JTD)),          \
					                                          "M" (_SFR_IO_ADDR(MCUCR))          \
					                                        : "r0");                             \
					                                    } while (0)

				/** Defines a volatile \c NOP statement which cannot be optimized out by the compiler, and thus can always
				 *  be set as a breakpoint in the resulting code. Useful for debugging purposes, where the optimizer
				 *  removes/reorders code to the point where break points cannot reliably be set.
				 *
				 *  \note This macro is not available for all architectures.
				 */
				#define JTAG_DEBUG_POINT()              __asm__ __volatile__ ("nop" ::)

				/** Defines an explicit JTAG break point in the resulting binary via the assembly \c BREAK statement. When
				 *  a JTAG is used, this causes the program execution to halt when reached until manually resumed.
				 *
				 *  \note This macro is not available for all architectures.
				 */
				#define JTAG_DEBUG_BREAK()              __asm__ __volatile__ ("break" ::)

				/** Macro for testing condition "x" and breaking via \ref JTAG_DEBUG_BREAK() if the condition is false.
				 *
				 *  \note This macro is not available for all architectures.
				 *
				 *  \param[in] Condition  Condition that will be evaluated.
				*/
				#define JTAG_ASSERT(Condition)          do {                       \
				                                            if (!(Condition))      \
				                                              JTAG_DEBUG_BREAK();  \
				                                        } while (0)

				/** Macro for testing condition \c "x" and writing debug data to the stdout stream if \c false. The stdout stream
				 *  must be pre-initialized before this macro is run and linked to an output device, such as the microcontroller's
				 *  USART peripheral.
				 *
				 *  The output takes the form "{FILENAME}: Function {FUNCTION NAME}, Line {LINE NUMBER}: Assertion {Condition} failed."
				 *
				 *  \note This macro is not available for all architectures.
				 *
				 *  \param[in] Condition  Condition that will be evaluated,
				 */
				#define STDOUT_ASSERT(Condition)        do {                                                           \
				                                            if (!(Condition))                                          \
				                                              printf_P(PSTR("%s: Function \"%s\", Line %d: "           \
				                                                            "Assertion \"%s\" failed.\r\n"),           \
				                                                            __FILE__, __func__, __LINE__, #Condition); \
				                                        } while (0)

