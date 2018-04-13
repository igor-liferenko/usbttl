/** \file
 *  \brief Serial USART Peripheral Driver (AVR8)
 *
 *  On-chip serial USART driver for the 8-bit AVR microcontrollers.
 *
 *  \note This file should not be included directly. It is automatically included as needed by the USART driver
 *        dispatch header located in LUFA/Drivers/Peripheral/Serial.h.
 */

/** \ingroup Group_Serial
 *  \defgroup Group_Serial_AVR8 Serial USART Peripheral Driver (AVR8)
 *
 *  \section Sec_Serial_AVR8_ModDescription Module Description
 *  On-chip serial USART driver for the 8-bit AVR microcontrollers.
 *
 *  \note This file should not be included directly. It is automatically included as needed by the USART driver
 *        dispatch header located in LUFA/Drivers/Peripheral/Serial.h.
 *
 *  \section Sec_Serial_AVR8_ExampleUsage Example Usage
 *  The following snippet is an example of how this module may be used within a typical
 *  application.
 *
 *  \code
 *      // Initialize the serial USART driver before first use, with 9600 baud (and no double-speed mode)
 *      Serial_Init(9600, false);
 *
 *      // Send a string through the USART
 *      Serial_SendString("Test String\r\n");
 *
 *      // Send a raw byte through the USART
 *      Serial_SendByte(0xDC);
 *
 *      // Receive a byte through the USART (or -1 if no data received)
 *      int16_t DataByte = Serial_ReceiveByte();
 *  \endcode
 *
 *  @{
 */

	/* Private Interface - For use in library only: */
		/* External Variables: */
			extern FILE USARTSerialStream;

		/* Function Prototypes: */
			int Serial_putchar(char DataByte,
			                   FILE *Stream);
			int Serial_getchar(FILE *Stream);
			int Serial_getchar_Blocking(FILE *Stream);

	/* Public Interface - May be used in end-application: */
		/* Macros: */
			/** Macro for calculating the baud value from a given baud rate when the \c U2X (double speed) bit is
			 *  not set.
			 *
			 *  \param[in] Baud  Target serial UART baud rate.
			 *
			 *  \return Closest UBRR register value for the given UART frequency.
			 */
			#define SERIAL_UBBRVAL(Baud)    ((((F_CPU / 16) + (Baud / 2)) / (Baud)) - 1)

			/** Macro for calculating the baud value from a given baud rate when the \c U2X (double speed) bit is
			 *  set.
			 *
			 *  \param[in] Baud  Target serial UART baud rate.
			 *
			 *  \return Closest UBRR register value for the given UART frequency.
			 */
			#define SERIAL_2X_UBBRVAL(Baud) ((((F_CPU / 8) + (Baud / 2)) / (Baud)) - 1)

		/* Function Prototypes: */
			/** Transmits a given NUL terminated string located in program space (FLASH) through the USART.
			 *
			 *  \param[in] FlashStringPtr  Pointer to a string located in program space.
			 */
			void Serial_SendString_P(const char* FlashStringPtr) ATTR_NON_NULL_PTR_ARG(1);

			/** Transmits a given NUL terminated string located in SRAM memory through the USART.
			 *
			 *  \param[in] StringPtr  Pointer to a string located in SRAM space.
			 */
			void Serial_SendString(const char* StringPtr) ATTR_NON_NULL_PTR_ARG(1);

			/** Transmits a given buffer located in SRAM memory through the USART.
			 *
			 *  \param[in] Buffer  Pointer to a buffer containing the data to send.
			 *  \param[in] Length  Length of the data to send, in bytes.
			 */
			void Serial_SendData(const void* Buffer, uint16_t Length) ATTR_NON_NULL_PTR_ARG(1);

			/** Creates a standard character stream from the USART so that it can be used with all the regular functions
			 *  in the avr-libc \c <stdio.h> library that accept a \c FILE stream as a destination (e.g. \c fprintf). The created
			 *  stream is bidirectional and can be used for both input and output functions.
			 *
			 *  Reading data from this stream is non-blocking, i.e. in most instances, complete strings cannot be read in by a single
			 *  fetch, as the endpoint will not be ready at some point in the transmission, aborting the transfer. However, this may
			 *  be used when the read data is processed byte-per-bye (via \c getc()) or when the user application will implement its own
			 *  line buffering.
			 *
			 *  \param[in,out] Stream  Pointer to a FILE structure where the created stream should be placed, if \c NULL, \c stdout
			 *                         and \c stdin will be configured to use the USART.
			 *
			 *  \pre The USART must first be configured via a call to \ref Serial_Init() before the stream is used.
			 */
			void Serial_CreateStream(FILE* Stream);

			/** Identical to \ref Serial_CreateStream(), except that reads are blocking until the calling stream function terminates
			 *  the transfer.
			 *
			 *  \param[in,out] Stream  Pointer to a FILE structure where the created stream should be placed, if \c NULL, \c stdout
			 *                         and \c stdin will be configured to use the USART.
			 *
			 *  \pre The USART must first be configured via a call to \ref Serial_Init() before the stream is used.
			 */
			void Serial_CreateBlockingStream(FILE* Stream);

		/* Inline Functions: */
			/** Initializes the USART, ready for serial data transmission and reception. This initializes the interface to
			 *  standard 8-bit, no parity, 1 stop bit settings suitable for most applications.
			 *
			 *  \param[in] BaudRate     Serial baud rate, in bits per second. This should be the target baud rate regardless of the
			 *                          \c DoubleSpeed parameter's value.
			 *  \param[in] DoubleSpeed  Enables double speed mode when set, halving the sample time to double the baud rate.
			 */
			static inline void Serial_Init(const uint32_t BaudRate,
			                               const bool DoubleSpeed);
			static inline void Serial_Init(const uint32_t BaudRate,
			                               const bool DoubleSpeed)
			{
				UBRR1  = (DoubleSpeed ? SERIAL_2X_UBBRVAL(BaudRate) : SERIAL_UBBRVAL(BaudRate));

				UCSR1C = ((1 << UCSZ11) | (1 << UCSZ10));
				UCSR1A = (DoubleSpeed ? (1 << U2X1) : 0);
				UCSR1B = ((1 << TXEN1)  | (1 << RXEN1));

				DDRD  |= (1 << 3);
				PORTD |= (1 << 2);
			}

			/** Turns off the USART driver, disabling and returning used hardware to their default configuration. */
			static inline void Serial_Disable(void);
			static inline void Serial_Disable(void)
			{
				UCSR1B = 0;
				UCSR1A = 0;
				UCSR1C = 0;

				UBRR1  = 0;

				DDRD  &= ~(1 << 3);
				PORTD &= ~(1 << 2);
			}

			/** Indicates whether a character has been received through the USART.
			 *
			 *  \return Boolean \c true if a character has been received, \c false otherwise.
			 */
			static inline bool Serial_IsCharReceived(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
			static inline bool Serial_IsCharReceived(void)
			{
				return ((UCSR1A & (1 << RXC1)) ? true : false);
			}

			/** Indicates whether there is hardware buffer space for a new transmit on the USART. This
			 *  function can be used to determine if a call to \ref Serial_SendByte() will block in advance.
			 *
			 *  \return Boolean \c true if a character can be queued for transmission immediately, \c false otherwise.
			 */
			static inline bool Serial_IsSendReady(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
			static inline bool Serial_IsSendReady(void)
			{
				return ((UCSR1A & (1 << UDRE1)) ? true : false);
			}

			/** Indicates whether the hardware USART transmit buffer is completely empty, indicating all
			 *  pending transmissions have completed.
			 *
			 *  \return Boolean \c true if no characters are buffered for transmission, \c false otherwise.
			 */
			static inline bool Serial_IsSendComplete(void) ATTR_WARN_UNUSED_RESULT ATTR_ALWAYS_INLINE;
			static inline bool Serial_IsSendComplete(void)
			{
				return ((UCSR1A & (1 << TXC1)) ? true : false);
			}

			/** Transmits a given byte through the USART.
			 *
			 *  \note If no buffer space is available in the hardware USART, this function will block. To check if
			 *        space is available before calling this function, see \ref Serial_IsSendReady().
			 *
			 *  \param[in] DataByte  Byte to transmit through the USART.
			 */
			static inline void Serial_SendByte(const char DataByte) ATTR_ALWAYS_INLINE;
			static inline void Serial_SendByte(const char DataByte)
			{
				while (!(Serial_IsSendReady()));
				UDR1 = DataByte;
			}

			/** Receives the next byte from the USART.
			 *
			 *  \return Next byte received from the USART, or a negative value if no byte has been received.
			 */
			static inline int16_t Serial_ReceiveByte(void) ATTR_ALWAYS_INLINE;
			static inline int16_t Serial_ReceiveByte(void)
			{
				if (!(Serial_IsCharReceived()))
				  return -1;

				return UDR1;
			}
