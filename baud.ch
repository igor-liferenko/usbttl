Via green led check if baud is set before acmterm is opened:

Answer: yes, it is

@x
        CDCInterfaceInfo->State.LineEncoding.BaudRateBPS = Endpoint_Read_32_LE();
@y
        PORTC |= 1 << 7;
        CDCInterfaceInfo->State.LineEncoding.BaudRateBPS = Endpoint_Read_32_LE();
@z

@x
  DDRD |= 1 << 7;
@y
  DDRC |= 1 << 7;
  DDRD |= 1 << 7;
@z
