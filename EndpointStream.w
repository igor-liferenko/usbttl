/** Endpoint data stream transmission and reception management.
 */

/** Endpoint data stream transmission and reception management.
 *
 *  Functions, macros, variables, enums and types related to data reading and writing of
 data streams from
 *  and to endpoints.
 */

/** Enum for the possible error return codes of the \c Endpoint_*_Stream_* functions. */
enum Endpoint_Stream_RW_ErrorCodes_t
{
  ENDPOINT_RWSTREAM_NoError = 0, /* Command completed successfully, no error. */
  ENDPOINT_RWSTREAM_EndpointStalled = 1, /* The endpoint was stalled during the stream
                                          *   transfer by the host or device.
                                          */
  ENDPOINT_RWSTREAM_DeviceDisconnected = 2, /* Device was disconnected from the host during
                                             *   the transfer.
	                                     */
  ENDPOINT_RWSTREAM_BusSuspended = 3, /* The USB bus has been suspended by the host and
                                       *   no USB endpoint traffic can occur until the bus
                                       *   has resumed.
                                       */
  ENDPOINT_RWSTREAM_Timeout = 4, /* The host failed to accept or send the next packet
                                  *   within the software timeout period set by the
                                  *   \ref USB_STREAM_TIMEOUT_MS macro.
                                  */
  ENDPOINT_RWSTREAM_IncompleteTransfer = 5, /* Indicates that the endpoint bank became
 full or empty before
                                         *   the complete contents of the current stream could be
                                   *   transferred. The endpoint stream function should be called
                                  *   again to process the next chunk of data in the transfer.
                                  */
};

/** Enum for the possible error return codes of the \c Endpoint_*_Control_Stream_* functions. */
enum Endpoint_ControlStream_RW_ErrorCodes_t
{
  ENDPOINT_RWCSTREAM_NoError = 0, /**< Command completed successfully, no error. */
  ENDPOINT_RWCSTREAM_HostAborted        = 1, /**< The aborted the transfer prematurely. */
  ENDPOINT_RWCSTREAM_DeviceDisconnected = 2, /**< Device was disconnected from the host during
                                          *   the transfer.
                                           */
  ENDPOINT_RWCSTREAM_BusSuspended       = 3, /**< The USB bus has been suspended by the host and
		                             *   no USB endpoint traffic can occur until the bus
		                            *   has resumed.
		                            */
};
