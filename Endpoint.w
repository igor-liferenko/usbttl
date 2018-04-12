/** \file
 *  \brief USB Endpoint definitions for all architectures.
 *  \copydetails Group_EndpointManagement
 *
 *  \note This file should not be included directly. It is automatically included as needed by the USB driver
 *        dispatch header located in LUFA/Drivers/USB/USB.h.
 */

/** \ingroup Group_EndpointManagement
 *  \defgroup Group_EndpointRW Endpoint Data Reading and Writing
 *  \brief Endpoint data read/write definitions.
 *
 *  Functions, macros, variables, enums and types related to data reading and writing from and to endpoints.
 */

/** \ingroup Group_EndpointRW
 *  \defgroup Group_EndpointPrimitiveRW Read/Write of Primitive Data Types
 *  \brief Endpoint data primitive read/write definitions.
 *
 *  Functions, macros, variables, enums and types related to data reading and writing of primitive data types
 *  from and to endpoints.
 */

/** \ingroup Group_EndpointManagement
 *  \defgroup Group_EndpointPacketManagement Endpoint Packet Management
 *  \brief USB Endpoint package management definitions.
 *
 *  Functions, macros, variables, enums and types related to packet management of endpoints.
 */

/** \ingroup Group_USB
 *  \defgroup Group_EndpointManagement Endpoint Management
 *  \brief Endpoint management definitions.
 *
 *  Functions, macros and enums related to endpoint management when in USB Device mode. This
 *  module contains the endpoint management macros, as well as endpoint interrupt and data
 *  send/receive functions for various data types.
 *
 *  @{
 */

		/* Type Defines: */
			/** Type define for a endpoint table entry, used to configure endpoints in groups via
			 *  \ref Endpoint_ConfigureEndpointTable().
			 */
			typedef struct
			{
				uint8_t  Address; /**< Address of the endpoint to configure, or zero if the table entry is to be unused. */
				uint16_t Size; /**< Size of the endpoint bank, in bytes. */
				uint8_t  Type; /**< Type of the endpoint, a \c EP_TYPE_* mask. */
				uint8_t  Banks; /**< Number of hardware banks to use for the endpoint. */
			} USB_Endpoint_Table_t;

		/* Macros: */
			/** Endpoint number mask, for masking against endpoint addresses to retrieve the endpoint's
			 *  numerical address in the device.
			 */
			#define ENDPOINT_EPNUM_MASK                     0x0F

			/** Endpoint address for the default control endpoint, which always resides in address 0. This is
			 *  defined for convenience to give more readable code when used with the endpoint macros.
			 */
			#define ENDPOINT_CONTROLEP                      0

@i Endpoint_AVR8.w
