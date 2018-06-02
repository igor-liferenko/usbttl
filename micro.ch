Invert leds.

@x
@<Indicate that USB device is disconnected@>=
PORTD &= ~(1 << PD5);
@y
@<Indicate that USB device is disconnected@>=
PORTD |= 1 << PD5;
@z

@x
void EVENT_USB_Device_Connect(void)
{
  PORTD |= 1 << PD5;
@y
void EVENT_USB_Device_Connect(void)
{
  PORTD &= ~(1 << PD5);
@z

@x
if (CDCInterfaceInfo->State.ControlLineStates.HostToDevice & CDC_CONTROL_LINE_OUT_DTR) {
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
  PORTB &= ~(1 << PB0); /* led off */
@y
if (CDCInterfaceInfo->State.ControlLineStates.HostToDevice & CDC_CONTROL_LINE_OUT_DTR) {
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
  PORTB |= 1 << PB0; /* led off */
@z

@x
else {
  PORTE |= 1 << PE6; /* |DTR| pin high */
  PORTB |= 1 << PB0; /* led on */
@y
else {
  PORTE |= 1 << PE6; /* |DTR| pin high */
  PORTB &= ~(1 << PB0); /* led on */
@z

@x
  if (CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface)) /* USB interface is ready */
    PORTD &= ~(1 << PD5);
@y
  if (CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface)) /* USB interface is ready */
    PORTD |= 1 << PD5;
@z

@x
  else /* an error has occurred in the USB interface */
    PORTD |= 1 << PD5;
@y
  else /* an error has occurred in the USB interface */
    PORTD &= ~(1 << PD5);
@z

@x
  DDRB |= 1 << PB0;
  PORTB |= 1 << PB0; /* led on */
@y
  DDRB |= 1 << PB0; /* led on by default */
@z

@x
  DDRD |= 1 << PD5; /* led off by default */
@y
  PORTD |= 1 << PD5; /* led off */
  DDRD |= 1 << PD5;
@z
