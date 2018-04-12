/** \file
 *  \brief USB Configuration Descriptor definitions.
 *  \copydetails Group_ConfigDescriptorParser
 *
 *  \note This file should not be included directly. It is automatically included as needed by the USB driver
 *        dispatch header located in LUFA/Drivers/USB/USB.h.
 */

/** \ingroup Group_StdDescriptors
 *  \defgroup Group_ConfigDescriptorParser Configuration Descriptor Parser
 *  \brief USB Configuration Descriptor definitions.
 *
 *  This section of the library gives a friendly API which can be used in host applications to easily
 *  parse an attached device's configuration descriptor so that endpoint, interface and other descriptor
 *  data can be extracted and used as needed.
 *
 *  @{
 */

			/** Casts a pointer to a descriptor inside the configuration descriptor into a pointer to the given
			 *  descriptor type.
			 *
			 *  Usage Example:
			 *  \code
			 *  uint8_t* CurrDescriptor = &ConfigDescriptor[0]; // Pointing to the configuration header
			 *  USB_Descriptor_Config_Header_t* ConfigHeaderPtr = DESCRIPTOR_PCAST(CurrDescriptor,
			 *                                                           USB_Descriptor_Config_Header_t);
			 *
			 *  // Can now access elements of the configuration header struct using the -> indirection operator
			 *  \endcode
			 */
			#define DESCRIPTOR_PCAST(DescriptorPtr, Type) ((Type*)(DescriptorPtr))

			/** Casts a pointer to a descriptor inside the configuration descriptor into the given descriptor
			 *  type (as an actual struct instance rather than a pointer to a struct).
			 *
			 *  Usage Example:
			 *  \code
			 *  uint8_t* CurrDescriptor = &ConfigDescriptor[0]; // Pointing to the configuration header
			 *  USB_Descriptor_Config_Header_t ConfigHeader = DESCRIPTOR_CAST(CurrDescriptor,
			 *                                                       USB_Descriptor_Config_Header_t);
			 *
			 *  // Can now access elements of the configuration header struct using the . operator
			 *  \endcode
			 */
			#define DESCRIPTOR_CAST(DescriptorPtr, Type)  (*DESCRIPTOR_PCAST(DescriptorPtr, Type))

			/** Returns the descriptor's type, expressed as the 8-bit type value in the header of the descriptor.
			 *  This value's meaning depends on the descriptor's placement in the descriptor, but standard type
			 *  values can be accessed in the \ref USB_DescriptorTypes_t enum.
			 */
			#define DESCRIPTOR_TYPE(DescriptorPtr)    DESCRIPTOR_PCAST(DescriptorPtr, USB_Descriptor_Header_t)->Type

			/** Returns the descriptor's size, expressed as the 8-bit value indicating the number of bytes. */
			#define DESCRIPTOR_SIZE(DescriptorPtr)    DESCRIPTOR_PCAST(DescriptorPtr, USB_Descriptor_Header_t)->Size

		/* Type Defines: */
			/** Type define for a Configuration Descriptor comparator function (function taking a pointer to an array
			 *  of type void, returning a uint8_t value).
			 *
			 *  \see \ref USB_GetNextDescriptorComp function for more details.
			 */
			typedef uint8_t (* ConfigComparatorPtr_t)(void*);

		/* Enums: */
			/** Enum for the possible return codes of the \ref USB_Host_GetDeviceConfigDescriptor() function. */
			enum USB_Host_GetConfigDescriptor_ErrorCodes_t
			{
				HOST_GETCONFIG_Successful       = 0, /**< No error occurred while retrieving the configuration descriptor. */
				HOST_GETCONFIG_DeviceDisconnect = 1, /**< The attached device was disconnected while retrieving the configuration
				                                      *   descriptor.
				                                      */
				HOST_GETCONFIG_PipeError        = 2, /**< An error occurred in the pipe while sending the request. */
				HOST_GETCONFIG_SetupStalled     = 3, /**< The attached device stalled the request to retrieve the configuration
				                                      *   descriptor.
				                                      */
				HOST_GETCONFIG_SoftwareTimeOut  = 4, /**< The request or data transfer timed out. */
				HOST_GETCONFIG_BuffOverflow     = 5, /**< The device's configuration descriptor is too large to fit into the allocated
				                                      *   buffer.
				                                      */
				HOST_GETCONFIG_InvalidData      = 6, /**< The device returned invalid configuration descriptor data. */
			};

			/** Enum for return values of a descriptor comparator function. */
			enum DSearch_Return_ErrorCodes_t
			{
				DESCRIPTOR_SEARCH_Found                = 0, /**< Current descriptor matches comparator criteria. */
				DESCRIPTOR_SEARCH_Fail                 = 1, /**< No further descriptor could possibly match criteria, fail the search. */
				DESCRIPTOR_SEARCH_NotFound             = 2, /**< Current descriptor does not match comparator criteria. */
			};

			/** Enum for return values of \ref USB_GetNextDescriptorComp(). */
			enum DSearch_Comp_Return_ErrorCodes_t
			{
				DESCRIPTOR_SEARCH_COMP_Found           = 0, /**< Configuration descriptor now points to descriptor which matches
				                                             *   search criteria of the given comparator function. */
				DESCRIPTOR_SEARCH_COMP_Fail            = 1, /**< Comparator function returned \ref DESCRIPTOR_SEARCH_Fail. */
				DESCRIPTOR_SEARCH_COMP_EndOfDescriptor = 2, /**< End of configuration descriptor reached before match found. */
			};
