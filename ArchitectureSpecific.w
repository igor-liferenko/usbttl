/* Architecture specific macros, functions and other definitions, which relate to
 specific architectures.
 */

/** Defines an explicit JTAG break point in the resulting binary via the assembly \c BREAK
 statement. When
 *  a JTAG is used, this causes the program execution to halt when reached until manually resumed.
 */
#define JTAG_DEBUG_BREAK()              __asm__ __volatile__ ("break" ::)
