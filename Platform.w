/** \file
 *  \brief Architecture Specific Hardware Platform Drivers.
 *
 *  This file is the master dispatch header file for the device-specific hardware platform drivers, for low level
 *  hardware configuration and management. The platform drivers are a set of drivers which are designed to provide
 *  a high level management layer for the various low level system functions such as clock control and interrupt
 *  management.
 *
 *  User code may choose to either include this master dispatch header file to include all available platform
 *  driver header files for the current architecture, or may choose to only include the specific platform driver
 *  modules required for a particular application.
 */

/** \defgroup Group_PlatformDrivers System Platform Drivers - LUFA/Platform/Platform.h
 *  \brief Hardware platform drivers.
 *
 *  \section Sec_PlatformDrivers_Dependencies Module Source Dependencies
 *  The following files must be built with any user project that uses this module:
 *    - <b>UC3 Architecture Only:</b> LUFA/Platform/UC3/InterruptManagement.c <i>(Makefile source module name: LUFA_SRC_PLATFORM)</i>
 *    - <b>UC3 Architecture Only:</b> LUFA/Platform/UC3/Exception.S <i>(Makefile source module name: LUFA_SRC_PLATFORM)</i>
 *
 *  \section Sec_PlatformDrivers_ModDescription Module Description
 *  Device-specific hardware platform drivers, for low level hardware configuration and management. The platform
 *  drivers are a set of drivers which are designed to provide a high level management layer for the various low level
 *  system functions such as clock control and interrupt management.
 *
 *  User code may choose to either include this master dispatch header file to include all available platform
 *  driver header files for the current architecture, or may choose to only include the specific platform driver
 *  modules required for a particular application.
 *
 *  \note The exact APIs and availability of sub-modules within the platform driver group may vary depending on the
 *        target used - see individual target module documentation for the API specific to your target processor.
 */
