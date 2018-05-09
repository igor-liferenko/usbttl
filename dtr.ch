For debugging, use green led for DTR instead of PD7 pin:

@x
  PORTD &= ~(1 << 7); /* |DTR| pin low */
@y
  PORTC &= ~(1 << 7); /* |DTR| pin low */
@z

@x
  PORTD |= 1 << 7; /* |DTR| pin high */
@y
  PORTC |= 1 << 7; /* |DTR| pin high */
@z

@x
  DDRD |= 1 << 7;
  PORTD |= 1 << 7; /* |DTR| pin high */
@y
  DDRC |= 1 << 7;
  PORTC |= 1 << 7; /* |DTR| pin high */
@z
