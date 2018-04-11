/** \file
 *  \brief Board specific LED driver header for the Atmel USBKEY.
 *  \copydetails Group_LEDs_USBKEY
 *
 *  \note This file should not be included directly. It is automatically included as needed by the LEDs driver
 *        dispatch header located in LUFA/Drivers/Board/LEDs.h.
 */

/** \ingroup Group_LEDs
 *  \defgroup Group_LEDs_USBKEY USBKEY
 *  \brief Board specific LED driver header for the Atmel USBKEY.
 *
 *  Board specific LED driver header for the Atmel USBKEY.
 *
 *  <table>
 *    <tr><th>Name</th><th>Color</th><th>Info</th><th>Active Level</th><th>Port Pin</th></tr>
 *    <tr><td>LEDS_LED1</td><td>Red</td><td>Bicolor Indicator 1</td><td>High</td><td>PORTD.4</td></tr>
 *    <tr><td>LEDS_LED2</td><td>Green</td><td>Bicolor Indicator 1</td><td>High</td><td>PORTD.5</td></tr>
 *    <tr><td>LEDS_LED3</td><td>Red</td><td>Bicolor Indicator 2</td><td>High</td><td>PORTD.6</td></tr>
 *    <tr><td>LEDS_LED4</td><td>Green</td><td>Bicolor Indicator 2</td><td>High</td><td>PORTD.7</td></tr>
 *  </table>
 *
 *  @{
 */

/** LED mask for the first LED on the board. */
#define LEDS_LED1        (1 << 4)

/** LED mask for the second LED on the board. */
#define LEDS_LED2        (1 << 5)

/** LED mask for the third LED on the board. */
#define LEDS_LED3        (1 << 7)

/** LED mask for the fourth LED on the board. */
#define LEDS_LED4        (1 << 6)

/** LED mask for all the LEDs on the board. */
#define LEDS_ALL_LEDS    (LEDS_LED1 | LEDS_LED2 | LEDS_LED3 | LEDS_LED4)

/** LED mask for none of the board LEDs. */
#define LEDS_NO_LEDS     0

		/* Inline Functions: */
		#if !defined(__DOXYGEN__)
			static inline void LEDs_Init(void)
			{
				DDRD  |=  LEDS_ALL_LEDS;
				PORTD &= ~LEDS_ALL_LEDS;
			}

			static inline void LEDs_Disable(void)
			{
				DDRD  &= ~LEDS_ALL_LEDS;
				PORTD &= ~LEDS_ALL_LEDS;
			}

			static inline void LEDs_TurnOnLEDs(const uint8_t LEDMask)
			{
				PORTD |= LEDMask;
			}

			static inline void LEDs_TurnOffLEDs(const uint8_t LEDMask)
			{
				PORTD &= ~LEDMask;
			}

			static inline void LEDs_SetAllLEDs(const uint8_t LEDMask)
			{
				PORTD = ((PORTD & ~LEDS_ALL_LEDS) | LEDMask);
			}

			static inline void LEDs_ChangeLEDs(const uint8_t LEDMask,
			                                   const uint8_t ActiveMask)
			{
				PORTD = ((PORTD & ~LEDMask) | ActiveMask);
			}

			static inline void LEDs_ToggleLEDs(const uint8_t LEDMask)
			{
				PIND  = LEDMask;
			}

			static inline uint8_t LEDs_GetLEDs(void) ATTR_WARN_UNUSED_RESULT;
			static inline uint8_t LEDs_GetLEDs(void)
			{
				return (PORTD & LEDS_ALL_LEDS);
			}
		#endif
