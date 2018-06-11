For devices that do not use DTR (e.g., router):

Discard all Rx data when not connected to a USB host, rather than buffering characters
for transmission next time the device is attached to a host.

@@ -116,6 +116,10 @@ EVENT_HANDLER(USB_Disconnect)
 	/* Stop running CDC and USB management tasks */
 	Scheduler_SetTaskMode(CDC_Task, TASK_STOP);
 	Scheduler_SetTaskMode(USB_USBTask, TASK_STOP);
+	
+	/* Reset Tx and Rx buffers, device disconnected */
+	Buffer_Initialize(&Rx_Buffer);
+	Buffer_Initialize(&Tx_Buffer);
 
 	/* Indicate USB not ready */
 	UpdateStatus(Status_USBNotReady);
@@ -322,8 +326,12 @@ ISR(USART1_TX_vect, ISR_BLOCK)
  */
 ISR(USART1_RX_vect, ISR_BLOCK)
 {
-	/* Character received, store it into the buffer */
-	Buffer_StoreElement(&Tx_Buffer, UDR1);
+	/* Only store received characters if the USB interface is connected */
+	if (USB_IsConnected)
+	{
+		/* Character received, store it into the buffer */
+		Buffer_StoreElement(&Tx_Buffer, UDR1);
+	}
 }
 
 /** Function to manage status updates to the user. This is done via LEDs on the given board, if available, but may be changed to
