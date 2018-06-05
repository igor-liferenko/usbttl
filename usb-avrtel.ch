Use three pins - first disable which goes to ordinary dtr detection,
then which goes to relay, and then which goes to interrupt detection:

@x
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
@y
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
  PORTB &= ~(1 << PB4); /* relay */
  PORTB &= ~(1 << PB5); /* interrupt */
@z

...
