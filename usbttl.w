@* Main program entry point. This routine contains the overall program flow, including initial
setup of all components and the main program loop.

@c
@<Includes@>@;
@<Function prototypes@>@;
@<Global variables@>@;
@<XXX structure@>@;

int main(void)
{
	SetupHardware();

	RingBuffer_InitBuffer(&USBtoUSART_Buffer, USBtoUSART_Buffer_Data, sizeof(USBtoUSART_Buffer_Data));
	RingBuffer_InitBuffer(&USARTtoUSB_Buffer, USARTtoUSB_Buffer_Data, sizeof(USARTtoUSB_Buffer_Data));

	@<Disconnect USB device@>@;
	GlobalInterruptEnable();

	for (;;)
	{
		/* Only try to read in bytes from the CDC interface if the transmit buffer is not full */
		if (!(RingBuffer_IsFull(&USBtoUSART_Buffer)))
		{
			int16_t ReceivedByte = CDC_Device_ReceiveByte(&VirtualSerial_CDC_Interface);

			/* Store received byte into the USART transmit buffer */
			if (!(ReceivedByte < 0))
			  RingBuffer_Insert(&USBtoUSART_Buffer, ReceivedByte);
		}

		uint16_t BufferCount = RingBuffer_GetCount(&USARTtoUSB_Buffer);
		if (BufferCount)
		{
			Endpoint_SelectEndpoint(VirtualSerial_CDC_Interface.Config.DataINEndpoint.Address);

			/* Check if a packet is already enqueued to the host - if so, we shouldn't try to send more data
			 * until it completes as there is a chance nothing is listening and a lengthy timeout could occur */
			if (Endpoint_IsINReady())
			{
				/* Never send more than one bank size less one byte to the host at a time, so that we don't block
				 * while a Zero Length Packet (ZLP) to terminate the transfer is sent if the host isn't listening */
				uint8_t BytesToSend = MIN(BufferCount, (CDC_TXRX_EPSIZE - 1));

				/* Read bytes from the USART receive buffer into the USB IN endpoint */
				while (BytesToSend--)
				{
					/* Try to send the next byte of data to the host, abort if there is an error without dequeuing */
					if (CDC_Device_SendByte(&VirtualSerial_CDC_Interface,
											RingBuffer_Peek(&USARTtoUSB_Buffer)) != ENDPOINT_READYWAIT_NoError)
					{
						break;
					}

					/* Dequeue the already sent byte from the buffer now we have confirmed that no transmission error occurred */
					RingBuffer_Remove(&USARTtoUSB_Buffer);
				}
			}
		}

		/* Load the next byte from the USART transmit buffer into the USART if transmit buffer space is available */
		if (Serial_IsSendReady() && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
		  Serial_SendByte(RingBuffer_Remove(&USBtoUSART_Buffer));

		CDC_Device_USBTask(&VirtualSerial_CDC_Interface);
		USB_USBTask();
	}
}

@ @d LEDMASK_USB_NOTREADY LEDS_LED1 /* LED mask for the library LED driver, to indicate that the USB interface is no
t ready */

@<Disconnect USB device@>=
LEDs_SetAllLEDs(LEDMASK_USB_NOTREADY);

@ @<Global...@>=
RingBuffer_t USBtoUSART_Buffer; /* circular buffer to hold data from the host before it is sent to the device via the serial port */
uint8_t      USBtoUSART_Buffer_Data[128]; /* underlying data buffer for |USBtoUSART_Buffer|, where the stored bytes are located */
RingBuffer_t USARTtoUSB_Buffer; /* circular buffer to hold data from the serial port before it is sent to the host */
uint8_t      USARTtoUSB_Buffer_Data[128]; /* underlying data buffer for |USARTtoUSB_Buffer|, where the stored bytes are located */

@ LUFA CDC Class driver interface configuration and state information. This structure is
passed to all CDC Class driver functions, so that multiple instances of the same class
within a device can be differentiated from one another.

@<XXX structure@>=
USB_ClassInfo_CDC_Device_t VirtualSerial_CDC_Interface =
{
	.Config =
		{
			.ControlInterfaceNumber         = INTERFACE_ID_CDC_CCI,
			.DataINEndpoint                 =
				{
					.Address                = CDC_TX_EPADDR,
					.Size                   = CDC_TXRX_EPSIZE,
					.Banks                  = 1,
				},
			.DataOUTEndpoint                =
				{
					.Address                = CDC_RX_EPADDR,
					.Size                   = CDC_TXRX_EPSIZE,
					.Banks                  = 1,
				},
			.NotificationEndpoint           =
				{
					.Address                = CDC_NOTIFICATION_EPADDR,
					.Size                   = CDC_NOTIFICATION_EPSIZE,
					.Banks                  = 1,
				},
		},
};


@ Configures the board hardware and chip peripherals for the demo's functionality.

@<Function Prototypes@>=
void SetupHardware(void);

@ @c
void SetupHardware(void)
{
#if (ARCH == ARCH_AVR8)
	// disable watchdog if enabled by bootloader/fuses
	MCUSR &= ~(1 << WDRF);
	wdt_disable();

	clock_prescale_set(clock_div_1); /* disable clock division */
#endif

	// hardware initialization
	LEDs_Init();
	USB_Init();
}

@ Event handler for the library USB Connection event.

@<Function Prototypes@>=
void EVENT_USB_Device_Connect(void);

@ @d LEDMASK_USB_ENUMERATING  (LEDS_LED2 | LEDS_LED3) /* LED mask for the library LED driver, to indicate that the USB interface is enumerating */

@c
void EVENT_USB_Device_Connect(void)
{
	LEDs_SetAllLEDs(LEDMASK_USB_ENUMERATING);
}

@ Event handler for the library USB Disconnection event.
@<Function Prototypes@>=
void EVENT_USB_Device_Disconnect(void);

@ @c
void EVENT_USB_Device_Disconnect(void)
{
  @<Disconnect USB device@>@;
}

@ Event handler for the library USB Configuration Changed event.
@<Function Prototypes@>=
void EVENT_USB_Device_ConfigurationChanged(void);

@ @d LEDMASK_USB_READY (LEDS_LED2 | LEDS_LED4) /* LED mask for the library LED driver, to indicate that the USB inte
rface is ready */
@d LEDMASK_USB_ERROR (LEDS_LED1 | LEDS_LED3) /* LED mask for the library LED driver, to indicate that an error has occurred in the USB interface */

@c
void EVENT_USB_Device_ConfigurationChanged(void)
{
	bool ConfigSuccess = true;

	ConfigSuccess &= CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface);

	LEDs_SetAllLEDs(ConfigSuccess ? LEDMASK_USB_READY : LEDMASK_USB_ERROR);
}

@ Event handler for the library USB Control Request reception event.

@<Function Prototypes@>=
void EVENT_USB_Device_ControlRequest(void);

@ @c
void EVENT_USB_Device_ControlRequest(void)
{
	CDC_Device_ProcessControlRequest(&VirtualSerial_CDC_Interface);
}

@ ISR to manage the reception of data from the serial port, placing received bytes into a circular buffer
for later transmission to the host.

@c
ISR(USART1_RX_vect, ISR_BLOCK)
{
	uint8_t ReceivedByte = UDR1;

	if ((USB_DeviceState == DEVICE_STATE_Configured) && !(RingBuffer_IsFull(&USARTtoUSB_Buffer)))
	  RingBuffer_Insert(&USARTtoUSB_Buffer, ReceivedByte);
}

@ Event handler for the CDC Class driver Line Encoding Changed event.

@<Function Prototypes@>=
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo);

@ @c
void EVENT_CDC_Device_LineEncodingChanged(const CDCInterfaceInfo)
USB_ClassInfo_CDC_Device_t* const CDCInterfaceInfo; /* pointer to the CDC class interface configuration structure being referenced */
{
	uint8_t ConfigMask = 0;

	switch (CDCInterfaceInfo->State.LineEncoding.ParityType)
	{
		case CDC_PARITY_Odd:
			ConfigMask = ((1 << UPM11) | (1 << UPM10));
			break;
		case CDC_PARITY_Even:
			ConfigMask = (1 << UPM11);
			break;
	}

	if (CDCInterfaceInfo->State.LineEncoding.CharFormat == CDC_LINEENCODING_TwoStopBits)
	  ConfigMask |= (1 << USBS1);

	switch (CDCInterfaceInfo->State.LineEncoding.DataBits)
	{
		case 6:
			ConfigMask |= (1 << UCSZ10);
			break;
		case 7:
			ConfigMask |= (1 << UCSZ11);
			break;
		case 8:
			ConfigMask |= ((1 << UCSZ11) | (1 << UCSZ10));
			break;
	}

	/* Keep the TX line held high (idle) while the USART is reconfigured */
	PORTD |= (1 << 3);

	/* Must turn off USART before reconfiguring it, otherwise incorrect operation may occur */
	UCSR1B = 0;
	UCSR1A = 0;
	UCSR1C = 0;

	/* Set the new baud rate before configuring the USART */
	UBRR1  = SERIAL_2X_UBBRVAL(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS);

	/* Reconfigure the USART in double speed mode for a wider baud rate range at the expense of accuracy */
	UCSR1C = ConfigMask;
	UCSR1A = (1 << U2X1);
	UCSR1B = ((1 << RXCIE1) | (1 << TXEN1) | (1 << RXEN1));

	/* Release the TX line after the USART has been reconfigured */
	PORTD &= ~(1 << 3);
}

@ @<Includes@>=
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/power.h>

		#include "Descriptors.h"

#include <LUFA/Drivers/Board/LEDs.h>
#include <LUFA/Drivers/Peripheral/Serial.h>
#include <LUFA/Drivers/Misc/RingBuffer.h>
#include <LUFA/Drivers/USB/USB.h>
#include <LUFA/Platform/Platform.h>
