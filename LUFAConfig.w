/** \file
 *  \brief LUFA Library Configuration Header File
 *
 *  This header file is used to configure LUFA's compile time options,
 *  as an alternative to the compile time constants supplied through
 *  a makefile.
 *
 *  For information on what each token does, refer to the LUFA
 *  manual section "Summary of Compile Tokens".
 */

/* General USB Driver Related Tokens: */
#define USE_STATIC_OPTIONS (USB_DEVICE_OPT_FULLSPEED | USB_OPT_REG_ENABLED | USB_OPT_AUTO_PLL)
#define USB_DEVICE_ONLY

/* USB Device Mode Driver Related Tokens: */
#define USE_FLASH_DESCRIPTORS
#define FIXED_CONTROL_ENDPOINT_SIZE      8
#define DEVICE_STATE_AS_GPIOR            0
#define FIXED_NUM_CONFIGURATIONS         1
#define INTERRUPT_CONTROL_ENDPOINT
