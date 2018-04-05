#include "../../../../Common/Common.h"
#if (ARCH == ARCH_AVR8)

#define  __INCLUDE_FROM_USB_DRIVER
#include "../USBMode.h"

#if defined(USB_CAN_BE_DEVICE)

#include "EndpointStream_AVR8.h"

#if !defined(CONTROL_ONLY_DEVICE)
uint8_t Endpoint_Discard_Stream(uint16_t Length,
                                uint16_t* const BytesProcessed)
{
	uint8_t  ErrorCode;
	uint16_t BytesInTransfer = 0;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	  Length -= *BytesProcessed;

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Discard_8();

			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Null_Stream(uint16_t Length,
                             uint16_t* const BytesProcessed)
{
	uint8_t  ErrorCode;
	uint16_t BytesInTransfer = 0;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	  Length -= *BytesProcessed;

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(0);

			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_Stream_LE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(*DataStream);
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_Stream_BE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(*DataStream);
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_Stream_LE(void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			*DataStream = Endpoint_Read_8();
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_Stream_BE(void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			*DataStream = Endpoint_Read_8();
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

#if defined(ARCH_HAS_FLASH_ADDRESS_SPACE)
uint8_t Endpoint_Write_PStream_LE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(pgm_read_byte(DataStream));
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_PStream_BE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(pgm_read_byte(DataStream));
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

#endif

#if defined(ARCH_HAS_EEPROM_ADDRESS_SPACE)
uint8_t Endpoint_Write_EStream_LE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(eeprom_read_byte(DataStream));
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_EStream_BE(const void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			Endpoint_Write_8(eeprom_read_byte(DataStream));
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_EStream_LE(void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + 0);
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream += *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			eeprom_update_byte(DataStream, Endpoint_Read_8());
			DataStream += 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_EStream_BE(void* const Buffer,
                            uint16_t Length,
                            uint16_t* const BytesProcessed)
{
	uint8_t* DataStream      = ((uint8_t*)Buffer + (Length - 1));
	uint16_t BytesInTransfer = 0;
	uint8_t  ErrorCode;

	if ((ErrorCode = Endpoint_WaitUntilReady()))
	  return ErrorCode;

	if (BytesProcessed != NULL)
	{
		Length -= *BytesProcessed;
		DataStream -= *BytesProcessed;
	}

	while (Length)
	{
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearOUT();

			#if !defined(INTERRUPT_CONTROL_ENDPOINT)
			USB_USBTask();
			#endif

			if (BytesProcessed != NULL)
			{
				*BytesProcessed += BytesInTransfer;
				return ENDPOINT_RWSTREAM_IncompleteTransfer;
			}

			if ((ErrorCode = Endpoint_WaitUntilReady()))
			  return ErrorCode;
		}
		else
		{
			eeprom_update_byte(DataStream, Endpoint_Read_8());
			DataStream -= 1;
			Length--;
			BytesInTransfer++;
		}
	}

	return ENDPOINT_RWSTREAM_NoError;
}

#endif

#endif

uint8_t Endpoint_Write_Control_Stream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(*DataStream);
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_Stream_BE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + (Length - 1));
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(*DataStream);
				DataStream -= 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_Stream_LE(void* const Buffer, uint16_t Length)
{
	uint8_t* DataStream = ((uint8_t*)Buffer + 0);

	if (!(Length))
	  Endpoint_ClearOUT();

	while (Length)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;

		if (Endpoint_IsOUTReceived())
		{
			while (Length && Endpoint_BytesInEndpoint())
			{
				*DataStream = Endpoint_Read_8();
				DataStream += 1;
				Length--;
			}

			Endpoint_ClearOUT();
		}
	}

	while (!(Endpoint_IsINReady()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_Stream_BE(void* const Buffer, uint16_t Length)
{
	uint8_t* DataStream = ((uint8_t*)Buffer + (Length - 1));

	if (!(Length))
	  Endpoint_ClearOUT();

	while (Length)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;

		if (Endpoint_IsOUTReceived())
		{
			while (Length && Endpoint_BytesInEndpoint())
			{
				*DataStream = Endpoint_Read_8();
				DataStream -= 1;
				Length--;
			}

			Endpoint_ClearOUT();
		}
	}

	while (!(Endpoint_IsINReady()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

#if defined(ARCH_HAS_FLASH_ADDRESS_SPACE)
uint8_t Endpoint_Write_Control_PStream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(pgm_read_byte(DataStream));
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_PStream_BE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + (Length - 1));
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(pgm_read_byte(DataStream));
				DataStream -= 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

#endif

#if defined(ARCH_HAS_EEPROM_ADDRESS_SPACE)
uint8_t Endpoint_Write_Control_EStream_LE(const void* const Buffer,
                            uint16_t Length)
{
	uint8_t* DataStream     = ((uint8_t*)Buffer + 0);
	bool     LastPacketFull = false;

	if (Length > USB_ControlRequest.wLength)
	  Length = USB_ControlRequest.wLength;
	else if (!(Length))
	  Endpoint_ClearIN();

	while (Length || LastPacketFull)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
		else if (Endpoint_IsOUTReceived())
		  break;

		if (Endpoint_IsINReady())
		{
			uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

			while (Length && (BytesInEndpoint < USB_Device_ControlEndpointSize))
			{
				Endpoint_Write_8(eeprom_read_byte(DataStream));
				DataStream += 1;
				Length--;
				BytesInEndpoint++;
			}

			LastPacketFull = (BytesInEndpoint == USB_Device_ControlEndpointSize);
			Endpoint_ClearIN();
		}
	}

	while (!(Endpoint_IsOUTReceived()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

	#define  TEMPLATE_FUNC_NAME                        Endpoint_Write_Control_EStream_BE
	#define  TEMPLATE_BUFFER_OFFSET(Length)            (Length - 1)
	#define  TEMPLATE_BUFFER_MOVE(BufferPtr, Amount)   BufferPtr -= Amount
	#define  TEMPLATE_TRANSFER_BYTE(BufferPtr)         Endpoint_Write_8(eeprom_read_byte(BufferPtr))
	#include "Template/Template_Endpoint_Control_W.c"

uint8_t Endpoint_Read_Control_EStream_LE(void* const Buffer, uint16_t Length)
{
	uint8_t* DataStream = ((uint8_t*)Buffer + 0);

	if (!(Length))
	  Endpoint_ClearOUT();

	while (Length)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;

		if (Endpoint_IsOUTReceived())
		{
			while (Length && Endpoint_BytesInEndpoint())
			{
				eeprom_update_byte(DataStream, Endpoint_Read_8());
				DataStream += 1;
				Length--;
			}

			Endpoint_ClearOUT();
		}
	}

	while (!(Endpoint_IsINReady()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_EStream_BE(void* const Buffer, uint16_t Length)
{
	uint8_t* DataStream = ((uint8_t*)Buffer + (Length - 1));

	if (!(Length))
	  Endpoint_ClearOUT();

	while (Length)
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
		else if (Endpoint_IsSETUPReceived())
		  return ENDPOINT_RWCSTREAM_HostAborted;

		if (Endpoint_IsOUTReceived())
		{
			while (Length && Endpoint_BytesInEndpoint())
			{
				eeprom_update_byte(DataStream, Endpoint_Read_8());
				DataStream -= 1;
				Length--;
			}

			Endpoint_ClearOUT();
		}
	}

	while (!(Endpoint_IsINReady()))
	{
		uint8_t USB_DeviceState_LCL = USB_DeviceState;

		if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
		  return ENDPOINT_RWCSTREAM_DeviceDisconnected;
		else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
		  return ENDPOINT_RWCSTREAM_BusSuspended;
	}

	return ENDPOINT_RWCSTREAM_NoError;
}
#endif

#endif

#endif
