/*
 * ntiologc.h
 *
 * This file is part of the ReactOS PSDK package.
 *
 * Contributors:
 *   Created by Amine Khaldi.
 *
 * THIS SOFTWARE IS NOT COPYRIGHTED
 *
 * This source code is offered for use in the public domain. You may
 * use, modify or distribute it freely.
 *
 * This code is distributed in the hope that it will be useful but
 * WITHOUT ANY WARRANTY. ALL WARRANTIES, EXPRESS OR IMPLIED ARE HEREBY
 * DISCLAIMED. This includes but is not limited to warranties of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#pragma once

#define FACILITY_RPC_RUNTIME                                       0x2
#define FACILITY_RPC_STUBS                                         0x3
#define FACILITY_IO_ERROR_CODE                        0x4
#define FACILITY_MCA_ERROR_CODE                       0x5

#define IO_ERR_RETRY_SUCCEEDED                        ((NTSTATUS)0x00040001)
#define IO_ERR_INSUFFICIENT_RESOURCES    ((NTSTATUS)0xC0040002)
#define IO_ERR_CONFIGURATION_ERROR                    ((NTSTATUS)0xC0040003)
#define IO_ERR_DRIVER_ERROR                                        ((NTSTATUS)0xC0040004)
#define IO_ERR_PARITY                                                           ((NTSTATUS)0xC0040005)
#define IO_ERR_SEEK_ERROR                                          ((NTSTATUS)0xC0040006)
#define IO_ERR_BAD_BLOCK                                           ((NTSTATUS)0xC0040007)
#define IO_ERR_OVERRUN_ERROR                                       ((NTSTATUS)0xC0040008)
#define IO_ERR_TIMEOUT                                                          ((NTSTATUS)0xC0040009)
#define IO_ERR_SEQUENCE                                                         ((NTSTATUS)0xC004000A)
#define IO_ERR_CONTROLLER_ERROR                       ((NTSTATUS)0xC004000B)
#define IO_ERR_INTERNAL_ERROR                                      ((NTSTATUS)0xC004000C)
#define IO_ERR_INCORRECT_IRQL                                      ((NTSTATUS)0xC004000D)
#define IO_ERR_INVALID_IOBASE                                      ((NTSTATUS)0xC004000E)
#define IO_ERR_NOT_READY                                           ((NTSTATUS)0xC004000F)
#define IO_ERR_INVALID_REQUEST                        ((NTSTATUS)0xC0040010)
#define IO_ERR_VERSION                                                          ((NTSTATUS)0xC0040011)
#define IO_ERR_LAYERED_FAILURE                        ((NTSTATUS)0xC0040012)
#define IO_ERR_RESET                                                            ((NTSTATUS)0xC0040013)
#define IO_ERR_PROTOCOL                                                         ((NTSTATUS)0xC0040014)
#define IO_ERR_MEMORY_CONFLICT_DETECTED  ((NTSTATUS)0xC0040015)
#define IO_ERR_PORT_CONFLICT_DETECTED    ((NTSTATUS)0xC0040016)
#define IO_ERR_DMA_CONFLICT_DETECTED     ((NTSTATUS)0xC0040017)
#define IO_ERR_IRQ_CONFLICT_DETECTED     ((NTSTATUS)0xC0040018)
#define IO_ERR_BAD_FIRMWARE                                        ((NTSTATUS)0xC0040019)
#define IO_WRN_BAD_FIRMWARE                                        ((NTSTATUS)0x8004001A)
#define IO_ERR_DMA_RESOURCE_CONFLICT     ((NTSTATUS)0xC004001B)
#define IO_ERR_INTERRUPT_RESOURCE_CONFLICT ((NTSTATUS)0xC004001C)
#define IO_ERR_MEMORY_RESOURCE_CONFLICT  ((NTSTATUS)0xC004001D)
#define IO_ERR_PORT_RESOURCE_CONFLICT    ((NTSTATUS)0xC004001E)
#define IO_BAD_BLOCK_WITH_NAME                        ((NTSTATUS)0xC004001F)
#define IO_WRITE_CACHE_ENABLED                        ((NTSTATUS)0x80040020)
#define IO_RECOVERED_VIA_ECC                                       ((NTSTATUS)0x80040021)
#define IO_WRITE_CACHE_DISABLED                       ((NTSTATUS)0x80040022)
#define IO_FILE_QUOTA_THRESHOLD                       ((NTSTATUS)0x40040024)
#define IO_FILE_QUOTA_LIMIT                                        ((NTSTATUS)0x40040025)
#define IO_FILE_QUOTA_STARTED                                      ((NTSTATUS)0x40040026)
#define IO_FILE_QUOTA_SUCCEEDED                       ((NTSTATUS)0x40040027)
#define IO_FILE_QUOTA_FAILED                                       ((NTSTATUS)0x80040028)
#define IO_FILE_SYSTEM_CORRUPT                        ((NTSTATUS)0xC0040029)
#define IO_FILE_QUOTA_CORRUPT                                      ((NTSTATUS)0xC004002A)
#define IO_SYSTEM_SLEEP_FAILED                        ((NTSTATUS)0xC004002B)
#define IO_DUMP_POINTER_FAILURE                       ((NTSTATUS)0xC004002C)
#define IO_DUMP_DRIVER_LOAD_FAILURE                   ((NTSTATUS)0xC004002D)
#define IO_DUMP_INITIALIZATION_FAILURE   ((NTSTATUS)0xC004002E)
#define IO_DUMP_DUMPFILE_CONFLICT                     ((NTSTATUS)0xC004002F)
#define IO_DUMP_DIRECT_CONFIG_FAILED     ((NTSTATUS)0xC0040030)
#define IO_DUMP_PAGE_CONFIG_FAILED                    ((NTSTATUS)0xC0040031)
#define IO_LOST_DELAYED_WRITE                                      ((NTSTATUS)0x80040032)
#define IO_WARNING_PAGING_FAILURE                     ((NTSTATUS)0x80040033)
#define IO_WRN_FAILURE_PREDICTED                      ((NTSTATUS)0x80040034)
#define IO_WARNING_INTERRUPT_STILL_PENDING ((NTSTATUS)0x80040035)
#define IO_DRIVER_CANCEL_TIMEOUT                      ((NTSTATUS)0x80040036)
#define IO_FILE_SYSTEM_CORRUPT_WITH_NAME ((NTSTATUS)0xC0040037)
#define IO_WARNING_ALLOCATION_FAILED     ((NTSTATUS)0x80040038)
#define IO_WARNING_LOG_FLUSH_FAILED                   ((NTSTATUS)0x80040039)
#define IO_WARNING_DUPLICATE_SIGNATURE   ((NTSTATUS)0x8004003A)
#define IO_WARNING_DUPLICATE_PATH                     ((NTSTATUS)0x8004003B)
#define IO_ERR_THREAD_STUCK_IN_DEVICE_DRIVER ((NTSTATUS)0xC004006C)
#define IO_ERR_PORT_TIMEOUT                                        ((NTSTATUS)0xC0040075)
#define IO_WARNING_BUS_RESET                                       ((NTSTATUS)0x80040076)
#define IO_INFO_THROTTLE_COMPLETE                     ((NTSTATUS)0x40040077)
#define IO_WARNING_RESET                                           ((NTSTATUS)0x80040081)
#define IO_FILE_SYSTEM_REPAIR_SUCCESS    ((NTSTATUS)0x80040082)
#define IO_FILE_SYSTEM_REPAIR_FAILED     ((NTSTATUS)0xC0040083)
#define IO_WARNING_WRITE_FUA_PROBLEM     ((NTSTATUS)0x80040084)
#define IO_CDROM_EXCLUSIVE_LOCK                       ((NTSTATUS)0x40040085)
#define IO_FILE_SYSTEM_TXF_RECOVERY_FAILURE ((NTSTATUS)0x80040086)
#define IO_FILE_SYSTEM_TXF_LOG_FULL_HANDLING_FAILED ((NTSTATUS)0xC0040087)
#define IO_FILE_SYSTEM_TXF_RESOURCE_MANAGER_RESET ((NTSTATUS)0x80040088)
#define IO_FILE_SYSTEM_TXF_RESOURCE_MANAGER_START_FAILED ((NTSTATUS)0xC0040089)
#define IO_FILE_SYSTEM_TXF_RESOURCE_MANAGER_SHUT_DOWN ((NTSTATUS)0xC004008A)
#define IO_LOST_DELAYED_WRITE_NETWORK_DISCONNECTED ((NTSTATUS)0x8004008B)
#define IO_LOST_DELAYED_WRITE_NETWORK_SERVER_ERROR ((NTSTATUS)0x8004008C)
#define IO_LOST_DELAYED_WRITE_NETWORK_LOCAL_DISK_ERROR ((NTSTATUS)0x8004008D)

#define MCA_WARNING_CACHE                                          ((NTSTATUS)0x8005003C)
#define MCA_ERROR_CACHE                                                         ((NTSTATUS)0xC005003D)
#define MCA_WARNING_TLB                                                         ((NTSTATUS)0x8005003E)
#define MCA_ERROR_TLB                                                           ((NTSTATUS)0xC005003F)
#define MCA_WARNING_CPU_BUS                                        ((NTSTATUS)0x80050040)
#define MCA_ERROR_CPU_BUS                                          ((NTSTATUS)0xC0050041)
#define MCA_WARNING_REGISTER_FILE                     ((NTSTATUS)0x80050042)
#define MCA_ERROR_REGISTER_FILE                       ((NTSTATUS)0xC0050043)
#define MCA_WARNING_MAS                                                         ((NTSTATUS)0x80050044)
#define MCA_ERROR_MAS                                                           ((NTSTATUS)0xC0050045)
#define MCA_WARNING_MEM_UNKNOWN                       ((NTSTATUS)0x80050046)
#define MCA_ERROR_MEM_UNKNOWN                                      ((NTSTATUS)0xC0050047)
#define MCA_WARNING_MEM_1_2                                        ((NTSTATUS)0x80050048)
#define MCA_ERROR_MEM_1_2                                          ((NTSTATUS)0xC0050049)
#define MCA_WARNING_MEM_1_2_5                                      ((NTSTATUS)0x8005004A)
#define MCA_ERROR_MEM_1_2_5                                        ((NTSTATUS)0xC005004B)
#define MCA_WARNING_MEM_1_2_5_4                       ((NTSTATUS)0x8005004C)
#define MCA_ERROR_MEM_1_2_5_4                                      ((NTSTATUS)0xC005004D)
#define MCA_WARNING_SYSTEM_EVENT                      ((NTSTATUS)0x8005004E)
#define MCA_ERROR_SYSTEM_EVENT                        ((NTSTATUS)0xC005004F)
#define MCA_WARNING_PCI_BUS_PARITY                    ((NTSTATUS)0x80050050)
#define MCA_ERROR_PCI_BUS_PARITY                      ((NTSTATUS)0xC0050051)
#define MCA_WARNING_PCI_BUS_PARITY_NO_INFO ((NTSTATUS)0x80050052)
#define MCA_ERROR_PCI_BUS_PARITY_NO_INFO ((NTSTATUS)0xC0050053)
#define MCA_WARNING_PCI_BUS_SERR                      ((NTSTATUS)0x80050054)
#define MCA_ERROR_PCI_BUS_SERR                        ((NTSTATUS)0xC0050055)
#define MCA_WARNING_PCI_BUS_SERR_NO_INFO ((NTSTATUS)0x80050056)
#define MCA_ERROR_PCI_BUS_SERR_NO_INFO   ((NTSTATUS)0xC0050057)
#define MCA_WARNING_PCI_BUS_MASTER_ABORT ((NTSTATUS)0x80050058)
#define MCA_ERROR_PCI_BUS_MASTER_ABORT   ((NTSTATUS)0xC0050059)
#define MCA_WARNING_PCI_BUS_MASTER_ABORT_NO_INFO ((NTSTATUS)0x8005005A)
#define MCA_ERROR_PCI_BUS_MASTER_ABORT_NO_INFO ((NTSTATUS)0xC005005B)
#define MCA_WARNING_PCI_BUS_TIMEOUT                   ((NTSTATUS)0x8005005C)
#define MCA_ERROR_PCI_BUS_TIMEOUT                     ((NTSTATUS)0xC005005D)
#define MCA_WARNING_PCI_BUS_TIMEOUT_NO_INFO ((NTSTATUS)0x8005005E)
#define MCA_ERROR_PCI_BUS_TIMEOUT_NO_INFO ((NTSTATUS)0xC005005F)
#define MCA_WARNING_PCI_BUS_UNKNOWN                   ((NTSTATUS)0x80050060)
#define MCA_ERROR_PCI_BUS_UNKNOWN                     ((NTSTATUS)0xC0050061)
#define MCA_WARNING_PCI_DEVICE                        ((NTSTATUS)0x80050062)
#define MCA_ERROR_PCI_DEVICE                                       ((NTSTATUS)0xC0050063)
#define MCA_WARNING_SMBIOS                                         ((NTSTATUS)0x80050064)
#define MCA_ERROR_SMBIOS                                           ((NTSTATUS)0xC0050065)
#define MCA_WARNING_PLATFORM_SPECIFIC    ((NTSTATUS)0x80050066)
#define MCA_ERROR_PLATFORM_SPECIFIC                   ((NTSTATUS)0xC0050067)
#define MCA_WARNING_UNKNOWN                                        ((NTSTATUS)0x80050068)
#define MCA_ERROR_UNKNOWN                                          ((NTSTATUS)0xC0050069)
#define MCA_WARNING_UNKNOWN_NO_CPU                    ((NTSTATUS)0x8005006A)
#define MCA_ERROR_UNKNOWN_NO_CPU                      ((NTSTATUS)0xC005006B)
#define MCA_WARNING_CMC_THRESHOLD_EXCEEDED ((NTSTATUS)0x8005006D)
#define MCA_WARNING_CPE_THRESHOLD_EXCEEDED ((NTSTATUS)0x8005006E)
#define MCA_WARNING_CPU_THERMAL_THROTTLED ((NTSTATUS)0x8005006F)
#define MCA_INFO_CPU_THERMAL_THROTTLING_REMOVED ((NTSTATUS)0x40050070)
#define MCA_WARNING_CPU                                                         ((NTSTATUS)0x80050071)
#define MCA_ERROR_CPU                                                           ((NTSTATUS)0xC0050072)
#define MCA_INFO_NO_MORE_CORRECTED_ERROR_LOGS ((NTSTATUS)0x40050073)
#define MCA_INFO_MEMORY_PAGE_MARKED_BAD  ((NTSTATUS)0x40050074)
#define MCA_MEMORYHIERARCHY_ERROR                     ((NTSTATUS)0xC0050078)
#define MCA_TLB_ERROR                                                           ((NTSTATUS)0xC0050079)
#define MCA_BUS_ERROR                                                           ((NTSTATUS)0xC005007A)
#define MCA_BUS_TIMEOUT_ERROR                                      ((NTSTATUS)0xC005007B)
#define MCA_INTERNALTIMER_ERROR                       ((NTSTATUS)0xC005007C)
#define MCA_MICROCODE_ROM_PARITY_ERROR   ((NTSTATUS)0xC005007E)
#define MCA_EXTERNAL_ERROR                                         ((NTSTATUS)0xC005007F)
#define MCA_FRC_ERROR                                                           ((NTSTATUS)0xC0050080)

#define STATUS_SEVERITY_SUCCESS                       0x0
#define STATUS_SEVERITY_INFORMATIONAL    0x1
#define STATUS_SEVERITY_WARNING                       0x2
#define STATUS_SEVERITY_ERROR                                      0x3
