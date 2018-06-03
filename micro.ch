Invert leds.

@x
  PORTB &= ~(1 << PB0); /* led off */
@y
  PORTB |= 1 << PB0;
@z

@x
  PORTB |= 1 << PB0; /* led on */
@y
  PORTB &= ~(1 << PB0);
@z

@x
    PORTD &= ~(1 << PD5); /* led off */
@y
    PORTD |= 1 << PD5;
@z

@x
  DDRB |= 1 << PB0;
  PORTB |= 1 << PB0; /* led on */
@y
  DDRB |= 1 << PB0;
@z

@x
  DDRD |= 1 << PD5;
  PORTD |= 1 << PD5; /* led on */
@y
  DDRD |= 1 << PD5;
@z
