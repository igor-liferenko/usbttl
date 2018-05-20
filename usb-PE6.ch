Fix failure: pin 7 on board is PE6 - pin 6 is PD7:

@x
  PORTD &= ~(1 << 7); /* |DTR| pin low */
@y
  PORTE &= ~(1 << PE6); /* |DTR| pin low */
@z

@x
  PORTD |= 1 << 7; /* |DTR| pin high */
@y
  PORTE |= 1 << PE6; /* |DTR| pin high */
@z

@x
  DDRD |= 1 << 7;
  PORTD |= 1 << 7; /* |DTR| pin high */
@y
  DDRE |= 1 << PE6;
  PORTE |= 1 << PE6; /* |DTR| pin high */
@z
