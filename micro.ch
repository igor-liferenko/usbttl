Invert leds.

@x
PORTD &= ~(1 << PD5);
@y
PORTD |= 1 << PD5;
@z

@x
  PORTD |= 1 << PD5;
@y
  PORTD &= ~(1 << PD5);
@z

@x
  PORTB &= ~(1 << PB0); /* led off */
@y
  PORTB |= 1 << PB0; /* led off */
@z

@x
  PORTB |= 1 << PB0; /* led on */
@y
  PORTB &= ~(1 << PB0); /* led on */
@z

@x
    PORTD &= ~(1 << PD5);
@y
    PORTD |= 1 << PD5;
@z

@x
    PORTD |= 1 << PD5;
@y
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
