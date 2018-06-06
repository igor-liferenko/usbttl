Use three pins.


Pin low: first disable which goes to ordinary dtr detection,
then which goes to relay, and then which goes to interrupt detection.
@x
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
@y
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
  PORTB &= ~(1 << PB4); /* relay */
  PORTB &= ~(1 << PB5); /* interrupt */
@z

Pin high: first ordinary dtr, then relay, then interrupt.
@x
  PORTE |= 1 << PE6; /* |DTR| pin high */
@y
  PORTE |= 1 << PE6; /* |DTR| pin high */
  PORTB |= 1 << PB4; /* relay */
  PORTB |= 1 << PB5; /* interrupt */
@z
