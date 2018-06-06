For devices that do not use DTR (e.g., router):
commit fa456ce531b75e2dd3c7c0ecb971e3ede36f5d35
Author: Dean Camera <dean@fourwalledcubicle.com>
Date:   Mon Feb 23 09:30:29 2009 +0000

    USBtoSerial demo now discards all Rx data when not connected to a USB host, rather than buffering characters for transmission next time the device is attached to a host.

diff --git a/Demos/USBtoSerial/USBtoSerial.c b/Demos/USBtoSerial/USBtoSerial.c
index 7c06007a3..0cef8d193 100644
--- a/Demos/USBtoSerial/USBtoSerial.c
+++ b/Demos/USBtoSerial/USBtoSerial.c
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
diff --git a/LUFA/ChangeLog.txt b/LUFA/ChangeLog.txt
index 830e31eef..fd21b3f10 100644
--- a/LUFA/ChangeLog.txt
+++ b/LUFA/ChangeLog.txt
@@ -19,6 +19,8 @@
   *    slowed down the enumeration of HID devices too much
   *  - Increased the number of bits per track which can be read in the MagStripe project to 20480 when compiled for the AT90USBXXX6/7
   *  - Fixed KeyboardMouse demo discarding the wIndex value in the REQ_GetReport request
+  *  - USBtoSerial demo now discards all Rx data when not connected to a USB host, rather than buffering characters for transmission
+  *    next time the device is attached to a host.
   *
   *  \section Sec_ChangeLog090209 Version 090209
   *
