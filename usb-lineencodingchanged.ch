@x
	@<Configure UART@>@;
@y
        @<Configure UART@>@;
        if (acmterm_started) PORTC |= 1 << 7;
@z

@x
  PORTD &= ~(1 << 7); /* |DTR| pin low */
@y
{
  PORTD &= ~(1 << 7); /* |DTR| pin low */
  acmterm_started=1;
}
@z

@x
  DDRD |= 1 << 7;
@y
  DDRD |= 1 << 7;
  DDRC |= 1 << 7;
@z

@x
@<Global var...@>=
@y
@<Global var...@>=
int acmterm_started=0;
@z

