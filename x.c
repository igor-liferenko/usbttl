#1 "usb.c"
#1 "<built-in>"
#1 "<command-line>"
#1 "usb.c"
#238 "usb.w"
#3319 "usb.w"

#1 "/usr/lib/avr/include/avr/io.h" 1 3
#99 "/usr/lib/avr/include/avr/io.h" 3
#1 "/usr/lib/avr/include/avr/sfr_defs.h" 1 3
#126 "/usr/lib/avr/include/avr/sfr_defs.h" 3
#1 "/usr/lib/avr/include/inttypes.h" 1 3
#37 "/usr/lib/avr/include/inttypes.h" 3
#1 "/usr/lib/gcc/avr/5.4.0/include/stdint.h" 1 3 4
#9 "/usr/lib/gcc/avr/5.4.0/include/stdint.h" 3 4
#1 "/usr/lib/avr/include/stdint.h" 1 3 4
#125 "/usr/lib/avr/include/stdint.h" 3 4

#125 "/usr/lib/avr/include/stdint.h" 3 4
typedef signed int int8_t __attribute__ ((__mode__(__QI__)));
typedef unsigned int uint8_t __attribute__ ((__mode__(__QI__)));
typedef signed int int16_t __attribute__ ((__mode__(__HI__)));
typedef unsigned int uint16_t __attribute__ ((__mode__(__HI__)));
typedef signed int int32_t __attribute__ ((__mode__(__SI__)));
typedef unsigned int uint32_t __attribute__ ((__mode__(__SI__)));

typedef signed int int64_t __attribute__ ((__mode__(__DI__)));
typedef unsigned int uint64_t __attribute__ ((__mode__(__DI__)));
#146 "/usr/lib/avr/include/stdint.h" 3 4
typedef int16_t intptr_t;

typedef uint16_t uintptr_t;
#163 "/usr/lib/avr/include/stdint.h" 3 4
typedef int8_t int_least8_t;

typedef uint8_t uint_least8_t;

typedef int16_t int_least16_t;

typedef uint16_t uint_least16_t;

typedef int32_t int_least32_t;

typedef uint32_t uint_least32_t;

typedef int64_t int_least64_t;

typedef uint64_t uint_least64_t;
#217 "/usr/lib/avr/include/stdint.h" 3 4
typedef int8_t int_fast8_t;

typedef uint8_t uint_fast8_t;

typedef int16_t int_fast16_t;

typedef uint16_t uint_fast16_t;

typedef int32_t int_fast32_t;

typedef uint32_t uint_fast32_t;

typedef int64_t int_fast64_t;

typedef uint64_t uint_fast64_t;
#277 "/usr/lib/avr/include/stdint.h" 3 4
typedef int64_t intmax_t;

typedef uint64_t uintmax_t;
#10 "/usr/lib/gcc/avr/5.4.0/include/stdint.h" 2 3 4
#38 "/usr/lib/avr/include/inttypes.h" 2 3
#77 "/usr/lib/avr/include/inttypes.h" 3
typedef int32_t int_farptr_t;

typedef uint32_t uint_farptr_t;
#127 "/usr/lib/avr/include/avr/sfr_defs.h" 2 3
#100 "/usr/lib/avr/include/avr/io.h" 2 3
#144 "/usr/lib/avr/include/avr/io.h" 3
#1 "/usr/lib/avr/include/avr/iom32u4.h" 1 3
#145 "/usr/lib/avr/include/avr/io.h" 2 3
#627 "/usr/lib/avr/include/avr/io.h" 3
#1 "/usr/lib/avr/include/avr/portpins.h" 1 3
#628 "/usr/lib/avr/include/avr/io.h" 2 3

#1 "/usr/lib/avr/include/avr/common.h" 1 3
#630 "/usr/lib/avr/include/avr/io.h" 2 3

#1 "/usr/lib/avr/include/avr/version.h" 1 3
#632 "/usr/lib/avr/include/avr/io.h" 2 3

#1 "/usr/lib/avr/include/avr/fuse.h" 1 3
#239 "/usr/lib/avr/include/avr/fuse.h" 3
typedef struct {
    unsigned char low;
    unsigned char high;
    unsigned char extended;
} __fuse_t;
#639 "/usr/lib/avr/include/avr/io.h" 2 3

#1 "/usr/lib/avr/include/avr/lock.h" 1 3
#642 "/usr/lib/avr/include/avr/io.h" 2 3
#3321 "usb.w" 2
#1 "/usr/lib/avr/include/avr/wdt.h" 1 3
#450 "/usr/lib/avr/include/avr/wdt.h" 3
static __inline__ __attribute__ ((__always_inline__))
void wdt_enable(const uint8_t value)
{
    if ((((uint16_t) & ((*(volatile uint8_t *) (0x60)))) < 0x40 + 0x20)) {
	__asm__ __volatile__("in __tmp_reg__,__SREG__" "\n\t"
			     "cli" "\n\t"
			     "wdr" "\n\t"
			     "out %0, %1" "\n\t"
			     "out __SREG__,__tmp_reg__" "\n\t"
			     "out %0, %2"
			     "\n \t"::"I"((((uint16_t) &
					    ((*(volatile uint8_t *)
					      (0x60)))) - 0x20)),
			     "r"((uint8_t) ((1 << (4)) | (1 << (3)))),
			     "r"((uint8_t)
				 ((value & 0x08 ? (1 << (5)) : 0x00) |
				  (1 << (3)) | (value & 0x07)))
			     :"r0");
    } else {
	__asm__ __volatile__("in __tmp_reg__,__SREG__" "\n\t"
			     "cli" "\n\t"
			     "wdr" "\n\t"
			     "sts %0, %1" "\n\t"
			     "out __SREG__,__tmp_reg__" "\n\t"
			     "sts %0, %2"
			     "\n \t"::"n"(((uint16_t) &
					   ((*(volatile uint8_t *)
					     (0x60))))),
			     "r"((uint8_t) ((1 << (4)) | (1 << (3)))),
			     "r"((uint8_t)
				 ((value & 0x08 ? (1 << (5)) : 0x00) |
				  (1 << (3)) | (value & 0x07)))
			     :"r0");
    }
}

static __inline__ __attribute__ ((__always_inline__))
void wdt_disable(void)
{
    if ((((uint16_t) & ((*(volatile uint8_t *) (0x60)))) < 0x40 + 0x20)) {
	uint8_t register temp_reg;
	__asm__ __volatile__("in __tmp_reg__,__SREG__" "\n\t"
			     "cli" "\n\t"
			     "wdr" "\n\t"
			     "in  %[TEMPREG],%[WDTREG]" "\n\t"
			     "ori %[TEMPREG],%[WDCE_WDE]" "\n\t"
			     "out %[WDTREG],%[TEMPREG]" "\n\t"
			     "out %[WDTREG],__zero_reg__" "\n\t"
			     "out __SREG__,__tmp_reg__" "\n\t":[TEMPREG]
			     "=d"(temp_reg)
			     :[WDTREG]
			     "I"((((uint16_t) &
				   ((*(volatile uint8_t *) (0x60)))) -
				  0x20)),
			     [WDCE_WDE]
			     "n"((uint8_t) ((1 << (4)) | (1 << (3))))
			     :"r0");
    } else {
	uint8_t register temp_reg;
	__asm__ __volatile__("in __tmp_reg__,__SREG__" "\n\t"
			     "cli" "\n\t"
			     "wdr" "\n\t"
			     "lds %[TEMPREG],%[WDTREG]" "\n\t"
			     "ori %[TEMPREG],%[WDCE_WDE]" "\n\t"
			     "sts %[WDTREG],%[TEMPREG]" "\n\t"
			     "sts %[WDTREG],__zero_reg__" "\n\t"
			     "out __SREG__,__tmp_reg__" "\n\t":[TEMPREG]
			     "=d"(temp_reg)
			     :[WDTREG]
			     "n"(((uint16_t) &
				  ((*(volatile uint8_t *) (0x60))))),
			     [WDCE_WDE]
			     "n"((uint8_t) ((1 << (4)) | (1 << (3))))
			     :"r0");
    }
}

#3322 "usb.w" 2
#1 "/usr/lib/avr/include/avr/interrupt.h" 1 3
#3323 "usb.w" 2
#1 "/usr/lib/avr/include/avr/power.h" 1 3
#1187 "/usr/lib/avr/include/avr/power.h" 3
static __inline void
    __attribute__ ((__always_inline__))
    __power_all_enable()
{

    (*(volatile uint8_t *) (0x64)) &=
	(uint8_t) ~
	(((1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 5) | (1 << 6) |
	  (1 << 7)));

    (*(volatile uint8_t *) (0x65)) &=
	(uint8_t) ~ (((1 << 0) | (1 << 3) | (1 << 7)));
#1234 "/usr/lib/avr/include/avr/power.h" 3
}

static __inline void
    __attribute__ ((__always_inline__))
    __power_all_disable()
{

    (*(volatile uint8_t *) (0x64)) |=
	(uint8_t) (((1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 5) |
		    (1 << 6) | (1 << 7)));

    (*(volatile uint8_t *) (0x65)) |=
	(uint8_t) (((1 << 0) | (1 << 3) | (1 << 7)));
#1283 "/usr/lib/avr/include/avr/power.h" 3
}

#1453 "/usr/lib/avr/include/avr/power.h" 3
typedef enum {
    clock_div_1 = 0,
    clock_div_2 = 1,
    clock_div_4 = 2,
    clock_div_8 = 3,
    clock_div_16 = 4,
    clock_div_32 = 5,
    clock_div_64 = 6,
    clock_div_128 = 7,
    clock_div_256 = 8
#1473 "/usr/lib/avr/include/avr/power.h" 3
} clock_div_t;

static __inline__ void clock_prescale_set(clock_div_t)
    __attribute__ ((__always_inline__));
#1491 "/usr/lib/avr/include/avr/power.h" 3
void clock_prescale_set(clock_div_t __x)
{
    uint8_t __tmp = (1 << (7));
    __asm__ __volatile__("in __tmp_reg__,__SREG__" "\n\t"
			 "cli" "\n\t"
			 "sts %1, %0" "\n\t"
			 "sts %1, %2" "\n\t"
			 "out __SREG__, __tmp_reg__"::"d"(__tmp),
			 "M"(((uint16_t) &
			      ((*(volatile uint8_t *) (0x61))))), "d"(__x)
			 :"r0");
}

#3324 "usb.w" 2
#1 "/usr/lib/avr/include/avr/pgmspace.h" 1 3
#89 "/usr/lib/avr/include/avr/pgmspace.h" 3
#1 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 1 3 4
#216 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 3 4
typedef unsigned int size_t;
#90 "/usr/lib/avr/include/avr/pgmspace.h" 2 3
#1158 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern const void *memchr_P(const void *, int __val, size_t __len)
    __attribute__ ((__const__));
#1172 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int memcmp_P(const void *, const void *, size_t)
    __attribute__ ((__pure__));

extern void *memccpy_P(void *, const void *, int __val, size_t);
#1188 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern void *memcpy_P(void *, const void *, size_t);

extern void *memmem_P(const void *, size_t, const void *, size_t)
    __attribute__ ((__pure__));
#1207 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern const void *memrchr_P(const void *, int __val, size_t __len)
    __attribute__ ((__const__));
#1217 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strcat_P(char *, const char *);
#1233 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern const char *strchr_P(const char *, int __val)
    __attribute__ ((__const__));
#1245 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern const char *strchrnul_P(const char *, int __val)
    __attribute__ ((__const__));
#1258 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strcmp_P(const char *, const char *) __attribute__ ((__pure__));
#1268 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strcpy_P(char *, const char *);
#1285 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strcasecmp_P(const char *, const char *)
    __attribute__ ((__pure__));

extern char *strcasestr_P(const char *, const char *)
    __attribute__ ((__pure__));
#1305 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strcspn_P(const char *__s, const char *__reject)
    __attribute__ ((__pure__));
#1321 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strlcat_P(char *, const char *, size_t);
#1334 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strlcpy_P(char *, const char *, size_t);
#1346 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strnlen_P(const char *, size_t) __attribute__ ((__const__));
#1357 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strncmp_P(const char *, const char *, size_t)
    __attribute__ ((__pure__));
#1376 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strncasecmp_P(const char *, const char *, size_t)
    __attribute__ ((__pure__));
#1387 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strncat_P(char *, const char *, size_t);
#1401 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strncpy_P(char *, const char *, size_t);
#1416 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strpbrk_P(const char *__s, const char *__accept)
    __attribute__ ((__pure__));
#1427 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern const char *strrchr_P(const char *, int __val)
    __attribute__ ((__const__));
#1447 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strsep_P(char **__sp, const char *__delim);
#1460 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strspn_P(const char *__s, const char *__accept)
    __attribute__ ((__pure__));
#1474 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strstr_P(const char *, const char *)
    __attribute__ ((__pure__));
#1496 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strtok_P(char *__s, const char *__delim);
#1516 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strtok_rP(char *__s, const char *__delim, char **__last);
#1529 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strlen_PF(uint_farptr_t src) __attribute__ ((__const__));
#1545 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strnlen_PF(uint_farptr_t src, size_t len)
    __attribute__ ((__const__));
#1560 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern void *memcpy_PF(void *dest, uint_farptr_t src, size_t len);
#1575 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strcpy_PF(char *dest, uint_farptr_t src);
#1595 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strncpy_PF(char *dest, uint_farptr_t src, size_t len);
#1611 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strcat_PF(char *dest, uint_farptr_t src);
#1632 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strlcat_PF(char *dst, uint_farptr_t src, size_t siz);
#1649 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strncat_PF(char *dest, uint_farptr_t src, size_t len);
#1665 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strcmp_PF(const char *s1, uint_farptr_t s2)
    __attribute__ ((__pure__));
#1682 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strncmp_PF(const char *s1, uint_farptr_t s2, size_t n)
    __attribute__ ((__pure__));
#1698 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strcasecmp_PF(const char *s1, uint_farptr_t s2)
    __attribute__ ((__pure__));
#1716 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int strncasecmp_PF(const char *s1, uint_farptr_t s2, size_t n)
    __attribute__ ((__pure__));
#1732 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern char *strstr_PF(const char *s1, uint_farptr_t s2);
#1744 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t strlcpy_PF(char *dst, uint_farptr_t src, size_t siz);
#1760 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern int memcmp_PF(const void *, uint_farptr_t, size_t)
    __attribute__ ((__pure__));
#1779 "/usr/lib/avr/include/avr/pgmspace.h" 3
extern size_t __strlen_P(const char *) __attribute__ ((__const__));
__attribute__ ((__always_inline__))
static __inline__ size_t strlen_P(const char *s);
static __inline__ size_t strlen_P(const char *s)
{
    return __builtin_constant_p(__builtin_strlen(s))
	? __builtin_strlen(s) : __strlen_P(s);
}

#3325 "usb.w" 2
#3467 "usb.w"

#1 "./LUFA/Drivers/USB/USB.h" 1
#382 "./LUFA/Drivers/USB/USB.h"
#1 "./LUFA/Drivers/USB/../../Common/Common.h" 1
#67 "./LUFA/Drivers/USB/../../Common/Common.h"
#1 "/usr/lib/gcc/avr/5.4.0/include/stdbool.h" 1 3 4
#68 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "/usr/lib/avr/include/string.h" 1 3
#46 "/usr/lib/avr/include/string.h" 3
#1 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 1 3 4
#47 "/usr/lib/avr/include/string.h" 2 3
#125 "/usr/lib/avr/include/string.h" 3
extern int ffs(int __val) __attribute__ ((__const__));

extern int ffsl(long __val) __attribute__ ((__const__));

__extension__ extern int ffsll(long long __val)
    __attribute__ ((__const__));
#150 "/usr/lib/avr/include/string.h" 3
extern void *memccpy(void *, const void *, int, size_t);
#162 "/usr/lib/avr/include/string.h" 3
extern void *memchr(const void *, int, size_t) __attribute__ ((__pure__));
#180 "/usr/lib/avr/include/string.h" 3
extern int memcmp(const void *, const void *, size_t)
    __attribute__ ((__pure__));
#191 "/usr/lib/avr/include/string.h" 3
extern void *memcpy(void *, const void *, size_t);
#203 "/usr/lib/avr/include/string.h" 3
extern void *memmem(const void *, size_t, const void *, size_t)
    __attribute__ ((__pure__));
#213 "/usr/lib/avr/include/string.h" 3
extern void *memmove(void *, const void *, size_t);
#225 "/usr/lib/avr/include/string.h" 3
extern void *memrchr(const void *, int, size_t) __attribute__ ((__pure__));
#235 "/usr/lib/avr/include/string.h" 3
extern void *memset(void *, int, size_t);
#248 "/usr/lib/avr/include/string.h" 3
extern char *strcat(char *, const char *);
#262 "/usr/lib/avr/include/string.h" 3
extern char *strchr(const char *, int) __attribute__ ((__pure__));
#274 "/usr/lib/avr/include/string.h" 3
extern char *strchrnul(const char *, int) __attribute__ ((__pure__));
#287 "/usr/lib/avr/include/string.h" 3
extern int strcmp(const char *, const char *) __attribute__ ((__pure__));
#305 "/usr/lib/avr/include/string.h" 3
extern char *strcpy(char *, const char *);
#320 "/usr/lib/avr/include/string.h" 3
extern int strcasecmp(const char *, const char *)
    __attribute__ ((__pure__));
#333 "/usr/lib/avr/include/string.h" 3
extern char *strcasestr(const char *, const char *)
    __attribute__ ((__pure__));
#344 "/usr/lib/avr/include/string.h" 3
extern size_t strcspn(const char *__s, const char *__reject)
    __attribute__ ((__pure__));
#364 "/usr/lib/avr/include/string.h" 3
extern char *strdup(const char *s1);
#377 "/usr/lib/avr/include/string.h" 3
extern size_t strlcat(char *, const char *, size_t);
#388 "/usr/lib/avr/include/string.h" 3
extern size_t strlcpy(char *, const char *, size_t);
#399 "/usr/lib/avr/include/string.h" 3
extern size_t strlen(const char *) __attribute__ ((__pure__));
#411 "/usr/lib/avr/include/string.h" 3
extern char *strlwr(char *);
#422 "/usr/lib/avr/include/string.h" 3
extern char *strncat(char *, const char *, size_t);
#434 "/usr/lib/avr/include/string.h" 3
extern int strncmp(const char *, const char *, size_t)
    __attribute__ ((__pure__));
#449 "/usr/lib/avr/include/string.h" 3
extern char *strncpy(char *, const char *, size_t);
#464 "/usr/lib/avr/include/string.h" 3
extern int strncasecmp(const char *, const char *, size_t)
    __attribute__ ((__pure__));
#478 "/usr/lib/avr/include/string.h" 3
extern size_t strnlen(const char *, size_t) __attribute__ ((__pure__));
#491 "/usr/lib/avr/include/string.h" 3
extern char *strpbrk(const char *__s, const char *__accept)
    __attribute__ ((__pure__));
#505 "/usr/lib/avr/include/string.h" 3
extern char *strrchr(const char *, int) __attribute__ ((__pure__));
#515 "/usr/lib/avr/include/string.h" 3
extern char *strrev(char *);
#533 "/usr/lib/avr/include/string.h" 3
extern char *strsep(char **, const char *);
#544 "/usr/lib/avr/include/string.h" 3
extern size_t strspn(const char *__s, const char *__accept)
    __attribute__ ((__pure__));
#557 "/usr/lib/avr/include/string.h" 3
extern char *strstr(const char *, const char *) __attribute__ ((__pure__));
#576 "/usr/lib/avr/include/string.h" 3
extern char *strtok(char *, const char *);
#593 "/usr/lib/avr/include/string.h" 3
extern char *strtok_r(char *, const char *, char **);
#606 "/usr/lib/avr/include/string.h" 3
extern char *strupr(char *);

extern int strcoll(const char *s1, const char *s2);
extern char *strerror(int errnum);
extern size_t strxfrm(char *dest, const char *src, size_t n);
#69 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 1 3 4
#149 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 3 4
typedef int ptrdiff_t;
#328 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 3 4
typedef int wchar_t;
#70 "./LUFA/Drivers/USB/../../Common/Common.h" 2

#1 "./LUFA/Drivers/USB/../../Common/Architectures.h" 1
#72 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "./LUFA/Drivers/USB/../../Common/BoardTypes.h" 1
#73 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "./LUFA/Drivers/USB/../../Common/ArchitectureSpecific.h" 1
#74 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "./LUFA/Drivers/USB/../../Common/CompilerSpecific.h" 1
#75 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "./LUFA/Drivers/USB/../../Common/Attributes.h" 1
#76 "./LUFA/Drivers/USB/../../Common/Common.h" 2

#1 "Config/LUFAConfig.h" 1
#79 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#97 "./LUFA/Drivers/USB/../../Common/Common.h"
#1 "/usr/lib/avr/include/avr/eeprom.h" 1 3
#50 "/usr/lib/avr/include/avr/eeprom.h" 3
#1 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 1 3 4
#51 "/usr/lib/avr/include/avr/eeprom.h" 2 3
#137 "/usr/lib/avr/include/avr/eeprom.h" 3
uint8_t eeprom_read_byte(const uint8_t * __p) __attribute__ ((__pure__));

uint16_t eeprom_read_word(const uint16_t * __p) __attribute__ ((__pure__));

uint32_t eeprom_read_dword(const uint32_t * __p)
    __attribute__ ((__pure__));

float eeprom_read_float(const float *__p) __attribute__ ((__pure__));

void eeprom_read_block(void *__dst, const void *__src, size_t __n);

void eeprom_write_byte(uint8_t * __p, uint8_t __value);

void eeprom_write_word(uint16_t * __p, uint16_t __value);

void eeprom_write_dword(uint32_t * __p, uint32_t __value);

void eeprom_write_float(float *__p, float __value);

void eeprom_write_block(const void *__src, void *__dst, size_t __n);

void eeprom_update_byte(uint8_t * __p, uint8_t __value);

void eeprom_update_word(uint16_t * __p, uint16_t __value);

void eeprom_update_dword(uint32_t * __p, uint32_t __value);

void eeprom_update_float(float *__p, float __value);

void eeprom_update_block(const void *__src, void *__dst, size_t __n);
#98 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "/usr/lib/avr/include/avr/boot.h" 1 3
#107 "/usr/lib/avr/include/avr/boot.h" 3
#1 "/usr/lib/gcc/avr/5.4.0/include-fixed/limits.h" 1 3 4
#108 "/usr/lib/avr/include/avr/boot.h" 2 3
#99 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "/usr/lib/avr/include/math.h" 1 3
#127 "/usr/lib/avr/include/math.h" 3
extern double cos(double __x) __attribute__ ((__const__));

extern double sin(double __x) __attribute__ ((__const__));

extern double tan(double __x) __attribute__ ((__const__));

extern double fabs(double __x) __attribute__ ((__const__));

extern double fmod(double __x, double __y) __attribute__ ((__const__));
#168 "/usr/lib/avr/include/math.h" 3
extern double modf(double __x, double *__iptr);

extern float modff(float __x, float *__iptr);

extern double sqrt(double __x) __attribute__ ((__const__));

extern float sqrtf(float) __attribute__ ((__const__));

extern double cbrt(double __x) __attribute__ ((__const__));
#195 "/usr/lib/avr/include/math.h" 3
extern double hypot(double __x, double __y) __attribute__ ((__const__));

extern double square(double __x) __attribute__ ((__const__));

extern double floor(double __x) __attribute__ ((__const__));

extern double ceil(double __x) __attribute__ ((__const__));
#235 "/usr/lib/avr/include/math.h" 3
extern double frexp(double __x, int *__pexp);

extern double ldexp(double __x, int __exp) __attribute__ ((__const__));

extern double exp(double __x) __attribute__ ((__const__));

extern double cosh(double __x) __attribute__ ((__const__));

extern double sinh(double __x) __attribute__ ((__const__));

extern double tanh(double __x) __attribute__ ((__const__));

extern double acos(double __x) __attribute__ ((__const__));

extern double asin(double __x) __attribute__ ((__const__));

extern double atan(double __x) __attribute__ ((__const__));
#299 "/usr/lib/avr/include/math.h" 3
extern double atan2(double __y, double __x) __attribute__ ((__const__));

extern double log(double __x) __attribute__ ((__const__));

extern double log10(double __x) __attribute__ ((__const__));

extern double pow(double __x, double __y) __attribute__ ((__const__));

extern int isnan(double __x) __attribute__ ((__const__));
#334 "/usr/lib/avr/include/math.h" 3
extern int isinf(double __x) __attribute__ ((__const__));

__attribute__ ((__const__))
static inline int isfinite(double __x)
{
    unsigned char __exp;
  __asm__("mov	%0, %C1		\n\t" "lsl	%0		\n\t" "mov	%0, %D1		\n\t" "rol	%0		":"=r"(__exp)
  :	    "r"(__x));
    return __exp != 0xff;
}

__attribute__ ((__const__))
static inline double copysign(double __x, double __y)
{
  __asm__("bst	%D2, 7	\n\t" "bld	%D0, 7	":"=r"(__x)
  :	    "0"(__x), "r"(__y));
    return __x;
}

#377 "/usr/lib/avr/include/math.h" 3
extern int signbit(double __x) __attribute__ ((__const__));

extern double fdim(double __x, double __y) __attribute__ ((__const__));
#393 "/usr/lib/avr/include/math.h" 3
extern double fma(double __x, double __y, double __z)
    __attribute__ ((__const__));

extern double fmax(double __x, double __y) __attribute__ ((__const__));

extern double fmin(double __x, double __y) __attribute__ ((__const__));

extern double trunc(double __x) __attribute__ ((__const__));
#427 "/usr/lib/avr/include/math.h" 3
extern double round(double __x) __attribute__ ((__const__));
#440 "/usr/lib/avr/include/math.h" 3
extern long lround(double __x) __attribute__ ((__const__));
#454 "/usr/lib/avr/include/math.h" 3
extern long lrint(double __x) __attribute__ ((__const__));
#100 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#1 "/usr/lib/avr/include/util/delay.h" 1 3
#45 "/usr/lib/avr/include/util/delay.h" 3
#1 "/usr/lib/avr/include/util/delay_basic.h" 1 3
#40 "/usr/lib/avr/include/util/delay_basic.h" 3
static __inline__ void _delay_loop_1(uint8_t __count)
    __attribute__ ((__always_inline__));
static __inline__ void _delay_loop_2(uint16_t __count)
    __attribute__ ((__always_inline__));
#80 "/usr/lib/avr/include/util/delay_basic.h" 3
void _delay_loop_1(uint8_t __count)
{
    __asm__ volatile ("1: dec %0" "\n\t" "brne 1b":"=r" (__count)
		      :"0"(__count)
	);
}

#102 "/usr/lib/avr/include/util/delay_basic.h" 3
void _delay_loop_2(uint16_t __count)
{
    __asm__ volatile ("1: sbiw %0,1" "\n\t" "brne 1b":"=w" (__count)
		      :"0"(__count)
	);
}

#46 "/usr/lib/avr/include/util/delay.h" 2 3
#86 "/usr/lib/avr/include/util/delay.h" 3
static __inline__ void _delay_us(double __us)
    __attribute__ ((__always_inline__));
static __inline__ void _delay_ms(double __ms)
    __attribute__ ((__always_inline__));
#165 "/usr/lib/avr/include/util/delay.h" 3
void _delay_ms(double __ms)
{
    double __tmp;

    uint32_t __ticks_dc;
    extern void __builtin_avr_delay_cycles(unsigned long);
    __tmp = ((
#174 "/usr/lib/avr/include/util/delay.h"
		 16000000UL
#174 "/usr/lib/avr/include/util/delay.h" 3
	     ) / 1e3) * __ms;
#184 "/usr/lib/avr/include/util/delay.h" 3
    __ticks_dc = (uint32_t) (ceil(fabs(__tmp)));

    __builtin_avr_delay_cycles(__ticks_dc);
#210 "/usr/lib/avr/include/util/delay.h" 3
}

#254 "/usr/lib/avr/include/util/delay.h" 3
void _delay_us(double __us)
{
    double __tmp;

    uint32_t __ticks_dc;
    extern void __builtin_avr_delay_cycles(unsigned long);
    __tmp = ((
#263 "/usr/lib/avr/include/util/delay.h"
		 16000000UL
#263 "/usr/lib/avr/include/util/delay.h" 3
	     ) / 1e6) * __us;
#273 "/usr/lib/avr/include/util/delay.h" 3
    __ticks_dc = (uint32_t) (ceil(fabs(__tmp)));

    __builtin_avr_delay_cycles(__ticks_dc);
#299 "/usr/lib/avr/include/util/delay.h" 3
}

#101 "./LUFA/Drivers/USB/../../Common/Common.h" 2


#102 "./LUFA/Drivers/USB/../../Common/Common.h"
typedef uint8_t uint_reg_t;

#1 "./LUFA/Drivers/USB/../../Common/Endianness.h" 1
#400 "./LUFA/Drivers/USB/../../Common/Endianness.h"
static inline uint16_t SwapEndian_16(const uint16_t Word)
    __attribute__ ((warn_unused_result)) __attribute__ ((const))
    __attribute__ ((always_inline));
static inline uint16_t SwapEndian_16(const uint16_t Word)
{
    if (__builtin_constant_p(Word))
	return (uint16_t) ((((Word) & 0xFF00) >> 8) |
			   (((Word) & 0x00FF) << 8));

    uint8_t Temp;

    union {
	uint16_t Word;
	uint8_t Bytes[2];
    } Data;

    Data.Word = Word;

    Temp = Data.Bytes[0];
    Data.Bytes[0] = Data.Bytes[1];
    Data.Bytes[1] = Temp;

    return Data.Word;
}

#431 "./LUFA/Drivers/USB/../../Common/Endianness.h"
static inline uint32_t SwapEndian_32(const uint32_t DWord)
    __attribute__ ((warn_unused_result)) __attribute__ ((const))
    __attribute__ ((always_inline));
static inline uint32_t SwapEndian_32(const uint32_t DWord)
{
    if (__builtin_constant_p(DWord))
	return (uint32_t) ((((DWord) & 0xFF000000UL) >> 24UL) |
			   (((DWord) & 0x00FF0000UL) >> 8UL) |
			   (((DWord) & 0x0000FF00UL) << 8UL) |
			   (((DWord) & 0x000000FFUL) << 24UL));

    uint8_t Temp;

    union {
	uint32_t DWord;
	uint8_t Bytes[4];
    } Data;

    Data.DWord = DWord;

    Temp = Data.Bytes[0];
    Data.Bytes[0] = Data.Bytes[3];
    Data.Bytes[3] = Temp;

    Temp = Data.Bytes[1];
    Data.Bytes[1] = Data.Bytes[2];
    Data.Bytes[2] = Temp;

    return Data.DWord;
}

#467 "./LUFA/Drivers/USB/../../Common/Endianness.h"
static inline void SwapEndian_n(void *const Data,
				uint8_t Length)
    __attribute__ ((nonnull(1)));
static inline void SwapEndian_n(void *const Data, uint8_t Length)
{
    uint8_t *CurrDataPos = (uint8_t *) Data;

    while (Length > 1) {
	uint8_t Temp = *CurrDataPos;
	*CurrDataPos = *(CurrDataPos + Length - 1);
	*(CurrDataPos + Length - 1) = Temp;

	CurrDataPos++;
	Length -= 2;
    }
}

#110 "./LUFA/Drivers/USB/../../Common/Common.h" 2
#248 "./LUFA/Drivers/USB/../../Common/Common.h"
static inline uint8_t BitReverse(uint8_t Byte)
    __attribute__ ((warn_unused_result)) __attribute__ ((const));
static inline uint8_t BitReverse(uint8_t Byte)
{
    Byte = (((Byte & 0xF0) >> 4) | ((Byte & 0x0F) << 4));
    Byte = (((Byte & 0xCC) >> 2) | ((Byte & 0x33) << 2));
    Byte = (((Byte & 0xAA) >> 1) | ((Byte & 0x55) << 1));

    return Byte;
}

static inline void Delay_MS(uint16_t Milliseconds)
    __attribute__ ((always_inline));
static inline void Delay_MS(uint16_t Milliseconds)
{

    if (__builtin_constant_p(Milliseconds)) {
	_delay_ms(Milliseconds);
    } else {
	while (Milliseconds--)
	    _delay_ms(1);
    }
#294 "./LUFA/Drivers/USB/../../Common/Common.h"
}

#304 "./LUFA/Drivers/USB/../../Common/Common.h"
static inline uint_reg_t GetGlobalInterruptMask(void)
    __attribute__ ((always_inline)) __attribute__ ((warn_unused_result));
static inline uint_reg_t GetGlobalInterruptMask(void)
{
    __asm__ __volatile__("":::"memory");;

    return
#310 "./LUFA/Drivers/USB/../../Common/Common.h" 3
	(*(volatile uint8_t *) ((0x3F) + 0x20))
#310 "./LUFA/Drivers/USB/../../Common/Common.h"
	;

}

#326 "./LUFA/Drivers/USB/../../Common/Common.h"
static inline void SetGlobalInterruptMask(const uint_reg_t GlobalIntState)
    __attribute__ ((always_inline));
static inline void SetGlobalInterruptMask(const uint_reg_t GlobalIntState)
{
    __asm__ __volatile__("":::"memory");;


#332 "./LUFA/Drivers/USB/../../Common/Common.h" 3
    (*(volatile uint8_t *) ((0x3F) + 0x20))
#332 "./LUFA/Drivers/USB/../../Common/Common.h"
	= GlobalIntState;
#342 "./LUFA/Drivers/USB/../../Common/Common.h"
    __asm__ __volatile__("":::"memory");;
}

static inline void GlobalInterruptEnable(void)
    __attribute__ ((always_inline));
static inline void GlobalInterruptEnable(void)
{
    __asm__ __volatile__("":::"memory");;


#355 "./LUFA/Drivers/USB/../../Common/Common.h" 3
    __asm__ __volatile__("sei":::"memory")
#355 "./LUFA/Drivers/USB/../../Common/Common.h"
    ;

    __asm__ __volatile__("":::"memory");;
}

static inline void GlobalInterruptDisable(void)
    __attribute__ ((always_inline));
static inline void GlobalInterruptDisable(void)
{
    __asm__ __volatile__("":::"memory");;


#375 "./LUFA/Drivers/USB/../../Common/Common.h" 3
    __asm__ __volatile__("cli":::"memory")
#375 "./LUFA/Drivers/USB/../../Common/Common.h"
    ;

    __asm__ __volatile__("":::"memory");;
}

#383 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/USBMode.h" 1
#69 "./LUFA/Drivers/USB/Core/USBMode.h"
#1 "./LUFA/Drivers/USB/Core/../../../Common/Common.h" 1
#70 "./LUFA/Drivers/USB/Core/USBMode.h" 2
#384 "./LUFA/Drivers/USB/USB.h" 2

#1 "./LUFA/Drivers/USB/Core/USBTask.h" 1
#46 "./LUFA/Drivers/USB/Core/USBTask.h"
#1 "./LUFA/Drivers/USB/Core/USBMode.h" 1
#47 "./LUFA/Drivers/USB/Core/USBTask.h" 2
#1 "./LUFA/Drivers/USB/Core/USBController.h" 1
#136 "./LUFA/Drivers/USB/Core/USBController.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 1
#52 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../../../../Common/Common.h" 1
#53 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBMode.h" 1
#54 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../Events.h" 1
#62 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../../../../Common/Common.h" 1
#63 "./LUFA/Drivers/USB/Core/AVR8/../Events.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBMode.h" 1
#64 "./LUFA/Drivers/USB/Core/AVR8/../Events.h" 2
#89 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_UIDChange(void);
#102 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Host_HostError(const uint8_t ErrorCode);
#117 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Host_DeviceAttached(void);
#131 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Host_DeviceUnattached(void);
#149 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Host_DeviceEnumerationFailed(const uint8_t ErrorCode,
					    const uint8_t SubErrorCode);
#166 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Host_DeviceEnumerationComplete(void);
#183 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Host_StartOfFrame(void);
#205 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_Connect(void);
#223 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_Disconnect(void);
#249 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_ControlRequest(void);
#263 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_ConfigurationChanged(void);
#281 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_Suspend(void);
#299 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_WakeUp(void);
#311 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_Reset(void);
#327 "./LUFA/Drivers/USB/Core/AVR8/../Events.h"
void EVENT_USB_Device_StartOfFrame(void);
#55 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBTask.h" 1
#56 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBInterrupt.h" 1
#60 "./LUFA/Drivers/USB/Core/AVR8/../USBInterrupt.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 1
#45 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../../../../Common/Common.h" 1
#46 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 2
#60 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
enum USB_Interrupts_t {

    USB_INT_VBUSTI = 0,

    USB_INT_WAKEUPI = 2,
    USB_INT_SUSPI = 3,
    USB_INT_EORSTI = 4,
    USB_INT_SOFI = 5,
    USB_INT_RXSTPI = 6,
#84 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
};

static inline void USB_INT_Enable(const uint8_t Interrupt)
    __attribute__ ((always_inline));
static inline void USB_INT_Enable(const uint8_t Interrupt)
{
    switch (Interrupt) {

    case USB_INT_VBUSTI:

#94 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xD8))
#94 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    |= (1 <<
#94 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		0
#94 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;

    case USB_INT_WAKEUPI:

#104 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#104 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    |= (1 <<
#104 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		4
#104 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_SUSPI:

#107 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#107 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    |= (1 <<
#107 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		0
#107 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_EORSTI:

#110 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#110 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    |= (1 <<
#110 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		3
#110 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_SOFI:

#113 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#113 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    |= (1 <<
#113 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		2
#113 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_RXSTPI:

#116 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xF0))
#116 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    |= (1 <<
#116 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		3
#116 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
#142 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
    default:
	break;
    }
}

static inline void USB_INT_Disable(const uint8_t Interrupt)
    __attribute__ ((always_inline));
static inline void USB_INT_Disable(const uint8_t Interrupt)
{
    switch (Interrupt) {

    case USB_INT_VBUSTI:

#154 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xD8))
#154 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#154 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 0
#154 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;

    case USB_INT_WAKEUPI:

#164 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#164 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#164 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 4
#164 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_SUSPI:

#167 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#167 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#167 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 0
#167 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_EORSTI:

#170 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#170 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#170 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 3
#170 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_SOFI:

#173 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE2))
#173 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#173 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 2
#173 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_RXSTPI:

#176 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xF0))
#176 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#176 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 3
#176 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
#202 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
    default:
	break;
    }
}

static inline void USB_INT_Clear(const uint8_t Interrupt)
    __attribute__ ((always_inline));
static inline void USB_INT_Clear(const uint8_t Interrupt)
{
    switch (Interrupt) {

    case USB_INT_VBUSTI:

#214 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xDA))
#214 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#214 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 0
#214 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;

    case USB_INT_WAKEUPI:

#224 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE1))
#224 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#224 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 4
#224 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_SUSPI:

#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE1))
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 0
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_EORSTI:

#230 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE1))
#230 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#230 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 3
#230 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_SOFI:

#233 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE1))
#233 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#233 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 2
#233 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
    case USB_INT_RXSTPI:

#236 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
	(*(volatile uint8_t *) (0xE8))
#236 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    &= ~(1 <<
#236 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		 3
#236 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    );
	break;
#262 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
    default:
	break;
    }
}

static inline
#267 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3 4
 _Bool
#267 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"

USB_INT_IsEnabled(const uint8_t Interrupt) __attribute__ ((always_inline))
   __attribute__ ((warn_unused_result));
static inline
#268 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3 4
 _Bool
#268 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
USB_INT_IsEnabled(const uint8_t Interrupt)
{
    switch (Interrupt) {

    case USB_INT_VBUSTI:
	return (
#274 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xD8))
#274 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#274 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      0
#274 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));

    case USB_INT_WAKEUPI:
	return (
#282 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE2))
#282 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#282 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      4
#282 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_SUSPI:
	return (
#284 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE2))
#284 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#284 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      0
#284 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_EORSTI:
	return (
#286 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE2))
#286 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#286 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      3
#286 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_SOFI:
	return (
#288 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE2))
#288 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#288 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      2
#288 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_RXSTPI:
	return (
#290 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xF0))
#290 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#290 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      3
#290 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
#308 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
    default:
	return
#309 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3 4
	    0
#309 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    ;
    }
}

static inline
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3 4
 _Bool
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"

USB_INT_HasOccurred(const uint8_t Interrupt)
   __attribute__ ((always_inline)) __attribute__ ((warn_unused_result));
static inline
#314 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3 4
 _Bool
#314 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
USB_INT_HasOccurred(const uint8_t Interrupt)
{
    switch (Interrupt) {

    case USB_INT_VBUSTI:
	return (
#320 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xDA))
#320 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#320 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      0
#320 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));

    case USB_INT_WAKEUPI:
	return (
#328 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE1))
#328 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#328 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      4
#328 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_SUSPI:
	return (
#330 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE1))
#330 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#330 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      0
#330 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_EORSTI:
	return (
#332 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE1))
#332 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#332 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      3
#332 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_SOFI:
	return (
#334 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE1))
#334 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#334 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      2
#334 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
    case USB_INT_RXSTPI:
	return (
#336 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		   (*(volatile uint8_t *) (0xE8))
#336 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   & (1 <<
#336 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3
		      3
#336 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
		   ));
#354 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
    default:
	return
#355 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 3 4
	    0
#355 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h"
	    ;
    }
}

#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../USBMode.h" 1
#361 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../Events.h" 1
#362 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../USBController.h" 1
#363 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/USBInterrupt_AVR8.h" 2

void USB_INT_ClearAllInterrupts(void);
void USB_INT_DisableAllInterrupts(void);
#61 "./LUFA/Drivers/USB/Core/AVR8/../USBInterrupt.h" 2
#57 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#67 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../Device.h" 1
#55 "./LUFA/Drivers/USB/Core/AVR8/../Device.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h" 1
#55 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../Events.h" 1
#56 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h" 2
#200 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
enum USB_DescriptorTypes_t {
    DTYPE_Device = 0x01,
    DTYPE_Configuration = 0x02,
    DTYPE_String = 0x03,
    DTYPE_Interface = 0x04,
    DTYPE_Endpoint = 0x05,
    DTYPE_DeviceQualifier = 0x06,
    DTYPE_Other = 0x07,
    DTYPE_InterfacePower = 0x08,
    DTYPE_InterfaceAssociation = 0x0B,
    DTYPE_CSInterface = 0x24,
    DTYPE_CSEndpoint = 0x25,
};

enum USB_Descriptor_ClassSubclassProtocol_t {
    USB_CSCP_NoDeviceClass = 0x00,

    USB_CSCP_NoDeviceSubclass = 0x00,

    USB_CSCP_NoDeviceProtocol = 0x00,

    USB_CSCP_VendorSpecificClass = 0xFF,

    USB_CSCP_VendorSpecificSubclass = 0xFF,

    USB_CSCP_VendorSpecificProtocol = 0xFF,

    USB_CSCP_IADDeviceClass = 0xEF,

    USB_CSCP_IADDeviceSubclass = 0x02,

    USB_CSCP_IADDeviceProtocol = 0x01,

};
#257 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t Size;
    uint8_t Type;

} __attribute__ ((packed)) USB_Descriptor_Header_t;
#274 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

} __attribute__ ((packed)) USB_StdDescriptor_Header_t;
#291 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    uint16_t USBSpecification;

    uint8_t Class;
    uint8_t SubClass;
    uint8_t Protocol;

    uint8_t Endpoint0Size;

    uint16_t VendorID;
    uint16_t ProductID;
    uint16_t ReleaseNumber;

    uint8_t ManufacturerStrIndex;

    uint8_t ProductStrIndex;

    uint8_t SerialNumStrIndex;
#333 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
    uint8_t NumberOfConfigurations;

} __attribute__ ((packed)) USB_Descriptor_Device_t;
#347 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint16_t bcdUSB;

    uint8_t bDeviceClass;
    uint8_t bDeviceSubClass;
    uint8_t bDeviceProtocol;
    uint8_t bMaxPacketSize0;
    uint16_t idVendor;
    uint16_t idProduct;
    uint16_t bcdDevice;

    uint8_t iManufacturer;

    uint8_t iProduct;

    uint8_t iSerialNumber;
#389 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
    uint8_t bNumConfigurations;

} __attribute__ ((packed)) USB_StdDescriptor_Device_t;
#401 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    uint16_t USBSpecification;

    uint8_t Class;
    uint8_t SubClass;
    uint8_t Protocol;

    uint8_t Endpoint0Size;
    uint8_t NumberOfConfigurations;

    uint8_t Reserved;
} __attribute__ ((packed)) USB_Descriptor_DeviceQualifier_t;
#427 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint16_t bcdUSB;

    uint8_t bDeviceClass;
    uint8_t bDeviceSubClass;
    uint8_t bDeviceProtocol;
    uint8_t bMaxPacketSize0;
    uint8_t bNumConfigurations;

    uint8_t bReserved;
} __attribute__ ((packed)) USB_StdDescriptor_DeviceQualifier_t;
#456 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    uint16_t TotalConfigurationSize;

    uint8_t TotalInterfaces;

    uint8_t ConfigurationNumber;
    uint8_t ConfigurationStrIndex;

    uint8_t ConfigAttributes;

    uint8_t MaxPowerConsumption;

} __attribute__ ((packed)) USB_Descriptor_Config_Header_t;
#487 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint16_t wTotalLength;

    uint8_t bNumInterfaces;
    uint8_t bConfigurationValue;
    uint8_t iConfiguration;
    uint8_t bmAttributes;

    uint8_t bMaxPower;

} __attribute__ ((packed)) USB_StdDescriptor_Config_Header_t;
#517 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    uint8_t InterfaceNumber;
    uint8_t AlternateSetting;

    uint8_t TotalEndpoints;

    uint8_t Class;
    uint8_t SubClass;
    uint8_t Protocol;

    uint8_t InterfaceStrIndex;
} __attribute__ ((packed)) USB_Descriptor_Interface_t;
#545 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint8_t bInterfaceNumber;
    uint8_t bAlternateSetting;

    uint8_t bNumEndpoints;
    uint8_t bInterfaceClass;
    uint8_t bInterfaceSubClass;
    uint8_t bInterfaceProtocol;
    uint8_t iInterface;

} __attribute__ ((packed)) USB_StdDescriptor_Interface_t;
#581 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    uint8_t FirstInterfaceIndex;
    uint8_t TotalInterfaces;

    uint8_t Class;
    uint8_t SubClass;
    uint8_t Protocol;

    uint8_t IADStrIndex;

} __attribute__ ((packed)) USB_Descriptor_Interface_Association_t;
#613 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint8_t bFirstInterface;
    uint8_t bInterfaceCount;
    uint8_t bFunctionClass;
    uint8_t bFunctionSubClass;
    uint8_t bFunctionProtocol;
    uint8_t iFunction;

} __attribute__ ((packed)) USB_StdDescriptor_Interface_Association_t;
#638 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    uint8_t EndpointAddress;

    uint8_t Attributes;

    uint16_t EndpointSize;

    uint8_t PollingIntervalMS;

} __attribute__ ((packed)) USB_Descriptor_Endpoint_t;
#666 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint8_t bEndpointAddress;

    uint8_t bmAttributes;

    uint16_t wMaxPacketSize;

    uint8_t bInterval;

} __attribute__ ((packed)) USB_StdDescriptor_Endpoint_t;
#701 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    USB_Descriptor_Header_t Header;

    wchar_t UnicodeString[];
#721 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
} __attribute__ ((packed)) USB_Descriptor_String_t;
#739 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
typedef struct {
    uint8_t bLength;
    uint8_t bDescriptorType;

    uint16_t bString[];
#754 "./LUFA/Drivers/USB/Core/AVR8/../StdDescriptors.h"
} __attribute__ ((packed)) USB_StdDescriptor_String_t;
#56 "./LUFA/Drivers/USB/Core/AVR8/../Device.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBInterrupt.h" 1
#57 "./LUFA/Drivers/USB/Core/AVR8/../Device.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../Endpoint.h" 1
#94 "./LUFA/Drivers/USB/Core/AVR8/../Endpoint.h"
typedef struct {
    uint8_t Address;
    uint16_t Size;
    uint8_t Type;
    uint8_t Banks;
} USB_Endpoint_Table_t;
#115 "./LUFA/Drivers/USB/Core/AVR8/../Endpoint.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 1
#77 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../USBTask.h" 1
#78 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../USBInterrupt.h" 1
#79 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 2
#93 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline uint8_t Endpoint_BytesToEPSizeMask(const uint16_t Bytes)
    __attribute__ ((warn_unused_result)) __attribute__ ((const))
    __attribute__ ((always_inline));
static inline uint8_t Endpoint_BytesToEPSizeMask(const uint16_t Bytes)
{
    uint8_t MaskVal = 0;
    uint16_t CheckBytes = 8;

    while (CheckBytes < Bytes) {
	MaskVal++;
	CheckBytes <<= 1;
    }

    return (MaskVal <<
#106 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	    4
#106 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

void Endpoint_ClearEndpoints(void);

#111 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
_Bool
#111 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_ConfigureEndpoint_Prv(const uint8_t Number,
			       const uint8_t UECFG0XData,
			       const uint8_t UECFG1XData);
#145 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
enum Endpoint_WaitUntilReady_ErrorCodes_t {
    ENDPOINT_READYWAIT_NoError = 0,
    ENDPOINT_READYWAIT_EndpointStalled = 1,

    ENDPOINT_READYWAIT_DeviceDisconnected = 2,

    ENDPOINT_READYWAIT_BusSuspended = 3,

    ENDPOINT_READYWAIT_Timeout = 4,

};
#196 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline
#196 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#196 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_ConfigureEndpoint(const uint8_t Address,
			   const uint8_t Type,
			   const uint16_t Size,
			   const uint8_t Banks)
   __attribute__ ((always_inline));
static inline
#200 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#200 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_ConfigureEndpoint(const uint8_t Address,
			   const uint8_t Type,
			   const uint16_t Size, const uint8_t Banks)
{
    uint8_t Number = (Address & 0x0F);

    if (Number >= 7)
	return
#208 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#208 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    ;

    return Endpoint_ConfigureEndpoint_Prv(Number, ((Type <<
#211 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
						    6
#211 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
						   ) | ((Address & 0x80)
							? (1 <<
#211 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
							   0
#211 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
							) : 0)), ((1 <<
#212 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
								   1
#212 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
								  ) |
								  ((Banks >
								    1) ? (1
									  <<
#212 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
									  2
#212 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
								   ) : 0) |
								  Endpoint_BytesToEPSizeMask
								  (Size)));
}

static inline uint16_t Endpoint_BytesInEndpoint(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint16_t Endpoint_BytesInEndpoint(void)
{

    return (((uint16_t)
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	     (*(volatile uint8_t *) (0xF3))
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	     << 8) |
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	    (*(volatile uint8_t *) (0xF2))
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);

}

static inline uint8_t Endpoint_GetEndpointDirection(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint8_t Endpoint_GetEndpointDirection(void)
{
    return (
#240 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	       (*(volatile uint8_t *) (0xEC))
#240 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	       & (1 <<
#240 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		  0
#240 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	       ))? 0x80 : 0x00;
}

static inline uint8_t Endpoint_GetCurrentEndpoint(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint8_t Endpoint_GetCurrentEndpoint(void)
{

    return ((
#253 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xE9))
#253 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& 0x0F) | Endpoint_GetEndpointDirection());

}

#266 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_SelectEndpoint(const uint8_t Address)
    __attribute__ ((always_inline));
static inline void Endpoint_SelectEndpoint(const uint8_t Address)
{


#270 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xE9))
#270 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Address & 0x0F);

}

static inline void Endpoint_ResetEndpoint(const uint8_t Address)
    __attribute__ ((always_inline));
static inline void Endpoint_ResetEndpoint(const uint8_t Address)
{

#282 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEA))
#282 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (1 << (Address & 0x0F));

#283 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEA))
#283 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= 0;
}

static inline void Endpoint_EnableEndpoint(void)
    __attribute__ ((always_inline));
static inline void Endpoint_EnableEndpoint(void)
{

#294 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEB))
#294 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	|= (1 <<
#294 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	    0
#294 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline void Endpoint_DisableEndpoint(void)
    __attribute__ ((always_inline));
static inline void Endpoint_DisableEndpoint(void)
{

#303 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEB))
#303 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	&= ~(1 <<
#303 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	     0
#303 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline
#310 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#310 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsEnabled(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#311 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#311 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsEnabled(void)
{
    return ((
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xEB))
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   0
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#313 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

#324 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline uint8_t Endpoint_GetBusyBanks(void)
    __attribute__ ((always_inline)) __attribute__ ((warn_unused_result));
static inline uint8_t Endpoint_GetBusyBanks(void)
{
    return (
#327 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	       (*(volatile uint8_t *) (0xEE))
#327 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	       & (0x03 <<
#327 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		  0
#327 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	       ));
}

#337 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_AbortPendingIN(void)
{
    while (Endpoint_GetBusyBanks() != 0) {

#341 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xE8))
#341 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    |= (1 <<
#341 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		2
#341 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    );
	while (
#342 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		  (*(volatile uint8_t *) (0xE8))
#342 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		  & (1 <<
#342 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		     2
#342 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		  ));
    }
}

#357 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline
#357 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#357 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsReadWriteAllowed(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#358 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#358 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsReadWriteAllowed(void)
{
    return ((
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xE8))
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   5
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#360 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline
#367 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#367 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsConfigured(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#368 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#368 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsConfigured(void)
{
    return ((
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xEE))
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   7
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#370 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline uint8_t Endpoint_GetEndpointInterrupts(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint8_t Endpoint_GetEndpointInterrupts(void)
{
    return
#382 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF4))
#382 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
}

#392 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline
#392 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#392 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_HasEndpointInterrupted(const uint8_t Address)
   __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline
#393 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#393 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_HasEndpointInterrupted(const uint8_t Address)
{
    return ((Endpoint_GetEndpointInterrupts() & (1 << (Address & 0x0F))) ?
#395 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#395 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#395 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#395 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline
#404 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#404 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsINReady(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#405 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#405 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsINReady(void)
{
    return ((
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xE8))
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   0
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#407 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline
#416 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#416 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsOUTReceived(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#417 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#417 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsOUTReceived(void)
{
    return ((
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xE8))
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   2
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#419 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline
#428 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#428 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsSETUPReceived(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#429 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#429 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsSETUPReceived(void)
{
    return ((
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xE8))
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   3
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#431 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

#441 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_ClearSETUP(void)
    __attribute__ ((always_inline));
static inline void Endpoint_ClearSETUP(void)
{

#444 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xE8))
#444 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	&= ~(1 <<
#444 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	     3
#444 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline void Endpoint_ClearIN(void) __attribute__ ((always_inline));
static inline void Endpoint_ClearIN(void)
{


#456 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xE8))
#456 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	&= ~((1 <<
#456 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	      0
#456 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	     ) | (1 <<
#456 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		  7
#456 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	     ));

}

static inline void Endpoint_ClearOUT(void) __attribute__ ((always_inline));
static inline void Endpoint_ClearOUT(void)
{


#471 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xE8))
#471 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	&= ~((1 <<
#471 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	      2
#471 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	     ) | (1 <<
#471 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		  7
#471 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	     ));

}

#488 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_StallTransaction(void)
    __attribute__ ((always_inline));
static inline void Endpoint_StallTransaction(void)
{

#491 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEB))
#491 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	|= (1 <<
#491 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	    5
#491 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline void Endpoint_ClearStall(void)
    __attribute__ ((always_inline));
static inline void Endpoint_ClearStall(void)
{

#501 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEB))
#501 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	|= (1 <<
#501 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	    4
#501 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline
#510 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#510 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_IsStalled(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#511 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
 _Bool
#511 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
Endpoint_IsStalled(void)
{
    return ((
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		(*(volatile uint8_t *) (0xEB))
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		& (1 <<
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   5
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		))?
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    1
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	    :
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
	    0
#513 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline void Endpoint_ResetDataToggle(void)
    __attribute__ ((always_inline));
static inline void Endpoint_ResetDataToggle(void)
{

#520 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEB))
#520 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	|= (1 <<
#520 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	    3
#520 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	);
}

static inline void Endpoint_SetEndpointDirection(const uint8_t
						 DirectionMask)
    __attribute__ ((always_inline));
static inline void Endpoint_SetEndpointDirection(const uint8_t
						 DirectionMask)
{

#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xEC))
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= ((
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	       (*(volatile uint8_t *) (0xEC))
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	       & ~(1 <<
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
		   0
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	       )) | (DirectionMask ? (1 <<
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
				      0
#530 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
		     ) : 0));
}

static inline uint8_t Endpoint_Read_8(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint8_t Endpoint_Read_8(void)
{
    return
#542 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#542 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
}

static inline void Endpoint_Write_8(const uint8_t Data)
    __attribute__ ((always_inline));
static inline void Endpoint_Write_8(const uint8_t Data)
{

#554 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#554 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= Data;
}

static inline void Endpoint_Discard_8(void)
    __attribute__ ((always_inline));
static inline void Endpoint_Discard_8(void)
{
    uint8_t Dummy;

    Dummy =
#566 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#566 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    (void) Dummy;
}

#578 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline uint16_t Endpoint_Read_16_LE(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint16_t Endpoint_Read_16_LE(void)
{
    union {
	uint16_t Value;
	uint8_t Bytes[2];
    } Data;

    Data.Bytes[0] =
#587 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#587 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[1] =
#588 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#588 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    return Data.Value;
}

#600 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline uint16_t Endpoint_Read_16_BE(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint16_t Endpoint_Read_16_BE(void)
{
    union {
	uint16_t Value;
	uint8_t Bytes[2];
    } Data;

    Data.Bytes[1] =
#609 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#609 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[0] =
#610 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#610 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    return Data.Value;
}

#622 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_Write_16_LE(const uint16_t Data)
    __attribute__ ((always_inline));
static inline void Endpoint_Write_16_LE(const uint16_t Data)
{

#625 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#625 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data & 0xFF);

#626 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#626 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 8);
}

#636 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_Write_16_BE(const uint16_t Data)
    __attribute__ ((always_inline));
static inline void Endpoint_Write_16_BE(const uint16_t Data)
{

#639 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#639 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 8);

#640 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#640 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data & 0xFF);
}

static inline void Endpoint_Discard_16(void)
    __attribute__ ((always_inline));
static inline void Endpoint_Discard_16(void)
{
    uint8_t Dummy;

    Dummy =
#652 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#652 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Dummy =
#653 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#653 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    (void) Dummy;
}

#665 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline uint32_t Endpoint_Read_32_LE(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint32_t Endpoint_Read_32_LE(void)
{
    union {
	uint32_t Value;
	uint8_t Bytes[4];
    } Data;

    Data.Bytes[0] =
#674 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#674 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[1] =
#675 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#675 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[2] =
#676 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#676 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[3] =
#677 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#677 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    return Data.Value;
}

#689 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline uint32_t Endpoint_Read_32_BE(void)
    __attribute__ ((warn_unused_result)) __attribute__ ((always_inline));
static inline uint32_t Endpoint_Read_32_BE(void)
{
    union {
	uint32_t Value;
	uint8_t Bytes[4];
    } Data;

    Data.Bytes[3] =
#698 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#698 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[2] =
#699 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#699 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[1] =
#700 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#700 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Data.Bytes[0] =
#701 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#701 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    return Data.Value;
}

#713 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_Write_32_LE(const uint32_t Data)
    __attribute__ ((always_inline));
static inline void Endpoint_Write_32_LE(const uint32_t Data)
{

#716 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#716 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data & 0xFF);

#717 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#717 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 8);

#718 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#718 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 16);

#719 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#719 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 24);
}

#729 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
static inline void Endpoint_Write_32_BE(const uint32_t Data)
    __attribute__ ((always_inline));
static inline void Endpoint_Write_32_BE(const uint32_t Data)
{

#732 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#732 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 24);

#733 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#733 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 16);

#734 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#734 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data >> 8);

#735 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
    (*(volatile uint8_t *) (0xF1))
#735 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	= (Data & 0xFF);
}

static inline void Endpoint_Discard_32(void)
    __attribute__ ((always_inline));
static inline void Endpoint_Discard_32(void)
{
    uint8_t Dummy;

    Dummy =
#747 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#747 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Dummy =
#748 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#748 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Dummy =
#749 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#749 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;
    Dummy =
#750 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3
	(*(volatile uint8_t *) (0xF1))
#750 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
	;

    (void) Dummy;
}

#789 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

#789 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h" 3 4
_Bool
#789 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"

Endpoint_ConfigureEndpointTable(const USB_Endpoint_Table_t * const Table,
				const uint8_t Entries);

void Endpoint_ClearStatusStage(void);
#809 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Endpoint_AVR8.h"
uint8_t Endpoint_WaitUntilReady(void);
#116 "./LUFA/Drivers/USB/Core/AVR8/../Endpoint.h" 2
#58 "./LUFA/Drivers/USB/Core/AVR8/../Device.h" 2
#78 "./LUFA/Drivers/USB/Core/AVR8/../Device.h"
enum USB_Device_States_t {
    DEVICE_STATE_Unattached = 0,

    DEVICE_STATE_Powered = 1,

    DEVICE_STATE_Default = 2,

    DEVICE_STATE_Addressed = 3,

    DEVICE_STATE_Configured = 4,

    DEVICE_STATE_Suspended = 5,

};
#133 "./LUFA/Drivers/USB/Core/AVR8/../Device.h"
uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
				    const uint16_t wIndex,
				    const void **const DescriptorAddress)
    __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(3)));

#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 1
#54 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../StdDescriptors.h" 1
#55 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 2

#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/../Endpoint.h" 1
#57 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 2
#154 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
void USB_Device_SendRemoteWakeup(void);

static inline uint16_t USB_Device_GetFrameNumber(void)
    __attribute__ ((always_inline)) __attribute__ ((warn_unused_result));
static inline uint16_t USB_Device_GetFrameNumber(void)
{
    return
#165 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	(*(volatile uint16_t *) (0xE4))
#165 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	;
}

#175 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
static inline void USB_Device_EnableSOFEvents(void)
    __attribute__ ((always_inline));
static inline void USB_Device_EnableSOFEvents(void)
{
    USB_INT_Enable(USB_INT_SOFI);
}

static inline void USB_Device_DisableSOFEvents(void)
    __attribute__ ((always_inline));
static inline void USB_Device_DisableSOFEvents(void)
{
    USB_INT_Disable(USB_INT_SOFI);
}

static inline void USB_Device_SetLowSpeed(void)
    __attribute__ ((always_inline));
static inline void USB_Device_SetLowSpeed(void)
{

#200 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
    (*(volatile uint8_t *) (0xE0))
#200 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	|= (1 <<
#200 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	    2
#200 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	);
}

static inline void USB_Device_SetFullSpeed(void)
    __attribute__ ((always_inline));
static inline void USB_Device_SetFullSpeed(void)
{

#206 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
    (*(volatile uint8_t *) (0xE0))
#206 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	&= ~(1 <<
#206 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	     2
#206 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	);
}

static inline void USB_Device_SetDeviceAddress(const uint8_t Address)
    __attribute__ ((always_inline));
static inline void USB_Device_SetDeviceAddress(const uint8_t Address)
{

#213 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
    (*(volatile uint8_t *) (0xE3))
#213 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	= (
#213 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	      (*(volatile uint8_t *) (0xE3))
#213 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	      & (1 <<
#213 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
		 7
#213 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	      )) | (Address & 0x7F);
}

static inline void USB_Device_EnableDeviceAddress(const uint8_t Address)
    __attribute__ ((always_inline));
static inline void USB_Device_EnableDeviceAddress(const uint8_t Address)
{
    (void) Address;


#221 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
    (*(volatile uint8_t *) (0xE3))
#221 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	|= (1 <<
#221 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	    7
#221 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	);
}

static inline
#224 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3 4
 _Bool
#224 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"

USB_Device_IsAddressSet(void) __attribute__ ((always_inline))
   __attribute__ ((warn_unused_result));
static inline
#225 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3 4
 _Bool
#225 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
USB_Device_IsAddressSet(void)
{
    return (
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	       (*(volatile uint8_t *) (0xE3))
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	       & (1 <<
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
		  7
#227 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	       ));
}

static inline void USB_Device_GetSerialString(uint16_t *
					      const UnicodeString)
    __attribute__ ((nonnull(1)));
static inline void USB_Device_GetSerialString(uint16_t *
					      const UnicodeString)
{
    uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
    GlobalInterruptDisable();

    uint8_t SigReadAddress = 0x0E;

    for (uint8_t SerialCharNum = 0; SerialCharNum < (80 / 4);
	 SerialCharNum++) {
	uint8_t SerialByte =
#241 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
	    (__extension__({ uint8_t __result;
	  __asm__ __volatile__("sts %1, %2\n\t" "lpm %0, Z" "\n\t": "=r"(__result):"i"(((uint16_t) &
				((*(volatile uint8_t *)
				  ((0x37) + 0x20))))),
	     "r"((uint8_t) (((1 << (0)) | (1 << (5))))), "z"((uint16_t) (
#241 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
										     SigReadAddress
#241 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h" 3
							     )));
			   __result;
			   }))
#241 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/Device_AVR8.h"
	    ;

	if (SerialCharNum & 0x01) {
	    SerialByte >>= 4;
	    SigReadAddress++;
	}

	SerialByte &= 0x0F;

	UnicodeString[SerialCharNum] =
	    ((SerialByte >=
	      10) ? (('A' - 10) + SerialByte) : ('0' + SerialByte));
    }

    SetGlobalInterruptMask(CurrentGlobalInt);
}

#145 "./LUFA/Drivers/USB/Core/AVR8/../Device.h" 2
#68 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../Endpoint.h" 1
#69 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h" 1
#49 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
#1 "./LUFA/Drivers/USB/Core/AVR8/../StdRequestType.h" 1
#163 "./LUFA/Drivers/USB/Core/AVR8/../StdRequestType.h"
typedef struct {
    uint8_t bmRequestType;
    uint8_t bRequest;
    uint16_t wValue;
    uint16_t wIndex;
    uint16_t wLength;
} __attribute__ ((packed)) USB_Request_Header_t;
#179 "./LUFA/Drivers/USB/Core/AVR8/../StdRequestType.h"
enum USB_Control_Request_t {
    REQ_GetStatus = 0,

    REQ_ClearFeature = 1,

    REQ_SetFeature = 3,

    REQ_SetAddress = 5,

    REQ_GetDescriptor = 6,

    REQ_SetDescriptor = 7,

    REQ_GetConfiguration = 8,

    REQ_SetConfiguration = 9,

    REQ_GetInterface = 10,

    REQ_SetInterface = 11,

    REQ_SynchFrame = 12,

};

enum USB_Feature_Selectors_t {
    FEATURE_SEL_EndpointHalt = 0x00,

    FEATURE_SEL_DeviceRemoteWakeup = 0x01,

    FEATURE_SEL_TestMode = 0x02,

};
#50 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBTask.h" 1
#51 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../USBController.h" 1
#52 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h" 2
#72 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
enum USB_DescriptorMemorySpaces_t {

    MEMSPACE_FLASH = 0,

    MEMSPACE_EEPROM = 1,

    MEMSPACE_RAM = 2,
};
#94 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
extern uint8_t USB_Device_ConfigurationNumber;
#110 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
extern
#110 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h" 3 4
 _Bool
#110 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
 USB_Device_RemoteWakeupEnabled;
#120 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
extern
#120 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h" 3 4
 _Bool
#120 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
 USB_Device_CurrentlySelfPowered;
#136 "./LUFA/Drivers/USB/Core/AVR8/../DeviceStandardReq.h"
void USB_Device_ProcessControlRequest(void);
#70 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#1 "./LUFA/Drivers/USB/Core/AVR8/../EndpointStream.h" 1
#69 "./LUFA/Drivers/USB/Core/AVR8/../EndpointStream.h"
enum Endpoint_Stream_RW_ErrorCodes_t {
    ENDPOINT_RWSTREAM_NoError = 0,
    ENDPOINT_RWSTREAM_EndpointStalled = 1,

    ENDPOINT_RWSTREAM_DeviceDisconnected = 2,

    ENDPOINT_RWSTREAM_BusSuspended = 3,

    ENDPOINT_RWSTREAM_Timeout = 4,

    ENDPOINT_RWSTREAM_IncompleteTransfer = 5,

};

enum Endpoint_ControlStream_RW_ErrorCodes_t {
    ENDPOINT_RWCSTREAM_NoError = 0,
    ENDPOINT_RWCSTREAM_HostAborted = 1,
    ENDPOINT_RWCSTREAM_DeviceDisconnected = 2,

    ENDPOINT_RWCSTREAM_BusSuspended = 3,

};

#1 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h" 1
#122 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Discard_Stream(uint16_t Length,
				uint16_t * const BytesProcessed);
#175 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Null_Stream(uint16_t Length,
			     uint16_t * const BytesProcessed);
#238 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Stream_LE(const void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#256 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Stream_BE(const void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#315 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_Stream_LE(void *const Buffer,
				uint16_t Length,
				uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#333 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_Stream_BE(void *const Buffer,
				uint16_t Length,
				uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#357 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Control_Stream_LE(const void *const Buffer,
					 uint16_t Length)
    __attribute__ ((nonnull(1)));
#380 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Control_Stream_BE(const void *const Buffer,
					 uint16_t Length)
    __attribute__ ((nonnull(1)));
#403 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_Control_Stream_LE(void *const Buffer,
					uint16_t Length)
    __attribute__ ((nonnull(1)));
#426 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_Control_Stream_BE(void *const Buffer,
					uint16_t Length)
    __attribute__ ((nonnull(1)));
#442 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_EStream_LE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#455 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_EStream_BE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#468 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_EStream_LE(void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#481 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_EStream_BE(void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#503 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Control_EStream_LE(const void *const Buffer,
					  uint16_t Length)
    __attribute__ ((nonnull(1)));
#524 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Control_EStream_BE(const void *const Buffer,
					  uint16_t Length)
    __attribute__ ((nonnull(1)));
#545 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_Control_EStream_LE(void *const Buffer,
					 uint16_t Length)
    __attribute__ ((nonnull(1)));
#566 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Read_Control_EStream_BE(void *const Buffer,
					 uint16_t Length)
    __attribute__ ((nonnull(1)));
#584 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_PStream_LE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#599 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_PStream_BE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
    __attribute__ ((nonnull(1)));
#623 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Control_PStream_LE(const void *const Buffer,
					  uint16_t Length)
    __attribute__ ((nonnull(1)));
#646 "./LUFA/Drivers/USB/Core/AVR8/../AVR8/EndpointStream_AVR8.h"
uint8_t Endpoint_Write_Control_PStream_BE(const void *const Buffer,
					  uint16_t Length)
    __attribute__ ((nonnull(1)));
#110 "./LUFA/Drivers/USB/Core/AVR8/../EndpointStream.h" 2
#71 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 2
#176 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
static inline
#176 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
 _Bool
#176 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"

USB_VBUS_GetStatus(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#177 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
 _Bool
#177 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
USB_VBUS_GetStatus(void)
{
    return ((
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
		(*(volatile uint8_t *) (0xD9))
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
		& (1 <<
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
		   0
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
		))?
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
	    1
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	    :
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
	    0
#179 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_Detach(void) __attribute__ ((always_inline));
static inline void USB_Detach(void)
{

#190 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xE0))
#190 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	|= (1 <<
#190 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    0
#190 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

#201 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
static inline void USB_Attach(void) __attribute__ ((always_inline));
static inline void USB_Attach(void)
{

#204 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xE0))
#204 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	&= ~(1 <<
#204 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	     0
#204 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

#252 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
void USB_Init(void

    );

void USB_Disable(void);

void USB_ResetInterface(void);
#306 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
static inline void USB_PLL_On(void) __attribute__ ((always_inline));
static inline void USB_PLL_On(void)
{

#309 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) ((0x29) + 0x20))
#309 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	= (1 <<
#309 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	   4
#309 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);

#310 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) ((0x29) + 0x20))
#310 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	= ((1 <<
#310 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    4
#310 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	   ) | (1 <<
#310 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
		1
#310 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	   ));
}

static inline void USB_PLL_Off(void) __attribute__ ((always_inline));
static inline void USB_PLL_Off(void)
{

#316 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) ((0x29) + 0x20))
#316 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	= 0;
}

static inline
#319 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
 _Bool
#319 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"

USB_PLL_IsReady(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#320 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
 _Bool
#320 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
USB_PLL_IsReady(void)
{
    return ((
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
		(*(volatile uint8_t *) ((0x29) + 0x20))
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
		& (1 <<
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
		   0
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
		))?
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
	    1
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	    :
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3 4
	    0
#322 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_REG_On(void) __attribute__ ((always_inline));
static inline void USB_REG_On(void)
{


#329 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD7))
#329 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	|= (1 <<
#329 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    0
#329 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);

}

static inline void USB_REG_Off(void) __attribute__ ((always_inline));
static inline void USB_REG_Off(void)
{


#339 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD7))
#339 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	&= ~(1 <<
#339 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	     0
#339 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);

}

static inline void USB_OTGPAD_On(void) __attribute__ ((always_inline));
static inline void USB_OTGPAD_On(void)
{

#349 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#349 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	|= (1 <<
#349 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    4
#349 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_OTGPAD_Off(void) __attribute__ ((always_inline));
static inline void USB_OTGPAD_Off(void)
{

#355 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#355 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	&= ~(1 <<
#355 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	     4
#355 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_CLK_Freeze(void) __attribute__ ((always_inline));
static inline void USB_CLK_Freeze(void)
{

#362 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#362 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	|= (1 <<
#362 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    5
#362 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_CLK_Unfreeze(void) __attribute__ ((always_inline));
static inline void USB_CLK_Unfreeze(void)
{

#368 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#368 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	&= ~(1 <<
#368 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	     5
#368 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_Controller_Enable(void)
    __attribute__ ((always_inline));
static inline void USB_Controller_Enable(void)
{

#374 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#374 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	|= (1 <<
#374 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    7
#374 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_Controller_Disable(void)
    __attribute__ ((always_inline));
static inline void USB_Controller_Disable(void)
{

#380 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#380 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	&= ~(1 <<
#380 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	     7
#380 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

static inline void USB_Controller_Reset(void)
    __attribute__ ((always_inline));
static inline void USB_Controller_Reset(void)
{

#386 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#386 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	&= ~(1 <<
#386 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	     7
#386 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);

#387 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
    (*(volatile uint8_t *) (0xD8))
#387 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	|= (1 <<
#387 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h" 3
	    7
#387 "./LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.h"
	);
}

#137 "./LUFA/Drivers/USB/Core/USBController.h" 2
#48 "./LUFA/Drivers/USB/Core/USBTask.h" 2
#1 "./LUFA/Drivers/USB/Core/Events.h" 1
#49 "./LUFA/Drivers/USB/Core/USBTask.h" 2
#1 "./LUFA/Drivers/USB/Core/StdRequestType.h" 1
#50 "./LUFA/Drivers/USB/Core/USBTask.h" 2
#1 "./LUFA/Drivers/USB/Core/StdDescriptors.h" 1
#51 "./LUFA/Drivers/USB/Core/USBTask.h" 2

#1 "./LUFA/Drivers/USB/Core/DeviceStandardReq.h" 1
#54 "./LUFA/Drivers/USB/Core/USBTask.h" 2
#81 "./LUFA/Drivers/USB/Core/USBTask.h"
extern volatile
#81 "./LUFA/Drivers/USB/Core/USBTask.h" 3 4
 _Bool
#81 "./LUFA/Drivers/USB/Core/USBTask.h"
 USB_IsInitialized;
#91 "./LUFA/Drivers/USB/Core/USBTask.h"
extern USB_Request_Header_t USB_ControlRequest;
#173 "./LUFA/Drivers/USB/Core/USBTask.h"
void USB_USBTask(void);
#387 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/Events.h" 1
#388 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/StdDescriptors.h" 1
#389 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h" 1
#113 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
typedef uint8_t(*ConfigComparatorPtr_t) (void *);

enum USB_Host_GetConfigDescriptor_ErrorCodes_t {
    HOST_GETCONFIG_Successful = 0,
    HOST_GETCONFIG_DeviceDisconnect = 1,

    HOST_GETCONFIG_PipeError = 2,
    HOST_GETCONFIG_SetupStalled = 3,

    HOST_GETCONFIG_SoftwareTimeOut = 4,
    HOST_GETCONFIG_BuffOverflow = 5,

    HOST_GETCONFIG_InvalidData = 6,
};

enum DSearch_Return_ErrorCodes_t {
    DESCRIPTOR_SEARCH_Found = 0,
    DESCRIPTOR_SEARCH_Fail = 1,
    DESCRIPTOR_SEARCH_NotFound = 2,
};

enum DSearch_Comp_Return_ErrorCodes_t {
    DESCRIPTOR_SEARCH_COMP_Found = 0,

    DESCRIPTOR_SEARCH_COMP_Fail = 1,
    DESCRIPTOR_SEARCH_COMP_EndOfDescriptor = 2,
};
#163 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
uint8_t USB_Host_GetDeviceConfigDescriptor(const uint8_t ConfigNumber,
					   uint16_t * const ConfigSizePtr,
					   void *const BufferPtr,
					   const uint16_t BufferSize)
    __attribute__ ((nonnull(2))) __attribute__ ((nonnull(3)));
#175 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
void USB_GetNextDescriptorOfType(uint16_t * const BytesRem,
				 void **const CurrConfigLoc,
				 const uint8_t Type)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#190 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
void USB_GetNextDescriptorOfTypeBefore(uint16_t * const BytesRem,
				       void **const CurrConfigLoc,
				       const uint8_t Type,
				       const uint8_t BeforeType)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#205 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
void USB_GetNextDescriptorOfTypeAfter(uint16_t * const BytesRem,
				      void **const CurrConfigLoc,
				      const uint8_t Type,
				      const uint8_t AfterType)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#252 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
uint8_t USB_GetNextDescriptorComp(uint16_t * const BytesRem,
				  void **const CurrConfigLoc,
				  ConfigComparatorPtr_t const
				  ComparatorRoutine)
    __attribute__ ((nonnull(1)))
    __attribute__ ((nonnull(2))) __attribute__ ((nonnull(3)));
#264 "./LUFA/Drivers/USB/Core/ConfigDescriptors.h"
static inline void USB_GetNextDescriptor(uint16_t * const BytesRem,
					 void **CurrConfigLoc)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
static inline void USB_GetNextDescriptor(uint16_t * const BytesRem,
					 void **CurrConfigLoc)
{
    uint16_t CurrDescriptorSize =
	(*((USB_Descriptor_Header_t *) (*CurrConfigLoc))).Size;

    if (*BytesRem < CurrDescriptorSize)
	CurrDescriptorSize = *BytesRem;

    *CurrConfigLoc =
	(void *) ((uintptr_t) * CurrConfigLoc + CurrDescriptorSize);
    *BytesRem -= CurrDescriptorSize;
}

#390 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/USBController.h" 1
#391 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/USBInterrupt.h" 1
#392 "./LUFA/Drivers/USB/USB.h" 2

#1 "./LUFA/Drivers/USB/Core/Device.h" 1
#395 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/Endpoint.h" 1
#396 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/DeviceStandardReq.h" 1
#397 "./LUFA/Drivers/USB/USB.h" 2
#1 "./LUFA/Drivers/USB/Core/EndpointStream.h" 1
#398 "./LUFA/Drivers/USB/USB.h" 2

#1 "./LUFA/Drivers/USB/Class/CDCClass.h" 1
#68 "./LUFA/Drivers/USB/Class/CDCClass.h"
#1 "./LUFA/Drivers/USB/Class/../Core/USBMode.h" 1
#69 "./LUFA/Drivers/USB/Class/CDCClass.h" 2

#1 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h" 1
#75 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
#1 "./LUFA/Drivers/USB/Class/Device/../../USB.h" 1
#76 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h" 2
#1 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h" 1
#54 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
#1 "./LUFA/Drivers/USB/Class/Device/../Common/../../Core/StdDescriptors.h" 1
#55 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h" 2
#134 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
enum CDC_Descriptor_ClassSubclassProtocol_t {
    CDC_CSCP_CDCClass = 0x02,

    CDC_CSCP_NoSpecificSubclass = 0x00,

    CDC_CSCP_ACMSubclass = 0x02,

    CDC_CSCP_ATCommandProtocol = 0x01,

    CDC_CSCP_NoSpecificProtocol = 0x00,

    CDC_CSCP_VendorSpecificProtocol = 0xFF,

    CDC_CSCP_CDCDataClass = 0x0A,

    CDC_CSCP_NoDataSubclass = 0x00,

    CDC_CSCP_NoDataProtocol = 0x00,

};

enum CDC_ClassRequests_t {
    CDC_REQ_SendEncapsulatedCommand = 0x00,
    CDC_REQ_GetEncapsulatedResponse = 0x01,
    CDC_REQ_SetLineEncoding = 0x20,
    CDC_REQ_GetLineEncoding = 0x21,
    CDC_REQ_SetControlLineState = 0x22,
    CDC_REQ_SendBreak = 0x23,
};

enum CDC_ClassNotifications_t {
    CDC_NOTIF_SerialState = 0x20,

};

enum CDC_DescriptorSubtypes_t {
    CDC_DSUBTYPE_CSInterface_Header = 0x00,
    CDC_DSUBTYPE_CSInterface_CallManagement = 0x01,
    CDC_DSUBTYPE_CSInterface_ACM = 0x02,
    CDC_DSUBTYPE_CSInterface_DirectLine = 0x03,
    CDC_DSUBTYPE_CSInterface_TelephoneRinger = 0x04,
    CDC_DSUBTYPE_CSInterface_TelephoneCall = 0x05,
    CDC_DSUBTYPE_CSInterface_Union = 0x06,
    CDC_DSUBTYPE_CSInterface_CountrySelection = 0x07,
    CDC_DSUBTYPE_CSInterface_TelephoneOpModes = 0x08,
    CDC_DSUBTYPE_CSInterface_USBTerminal = 0x09,
    CDC_DSUBTYPE_CSInterface_NetworkChannel = 0x0A,
    CDC_DSUBTYPE_CSInterface_ProtocolUnit = 0x0B,
    CDC_DSUBTYPE_CSInterface_ExtensionUnit = 0x0C,
    CDC_DSUBTYPE_CSInterface_MultiChannel = 0x0D,
    CDC_DSUBTYPE_CSInterface_CAPI = 0x0E,
    CDC_DSUBTYPE_CSInterface_Ethernet = 0x0F,
    CDC_DSUBTYPE_CSInterface_ATM = 0x10,
};

enum CDC_LineEncodingFormats_t {
    CDC_LINEENCODING_OneStopBit = 0,
    CDC_LINEENCODING_OneAndAHalfStopBits = 1,
    CDC_LINEENCODING_TwoStopBits = 2,
};

enum CDC_LineEncodingParity_t {
    CDC_PARITY_None = 0,
    CDC_PARITY_Odd = 1,
    CDC_PARITY_Even = 2,
    CDC_PARITY_Mark = 3,
    CDC_PARITY_Space = 4,
};
#237 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    USB_Descriptor_Header_t Header;
    uint8_t Subtype;

    uint16_t CDCSpecification;

} __attribute__ ((packed)) USB_CDC_Descriptor_Func_Header_t;
#261 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    uint8_t bFunctionLength;
    uint8_t bDescriptorType;

    uint8_t bDescriptorSubType;

    uint16_t bcdCDC;

} __attribute__ ((packed)) USB_CDC_StdDescriptor_FunctionalHeader_t;
#285 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    USB_Descriptor_Header_t Header;
    uint8_t Subtype;

    uint8_t Capabilities;

} __attribute__ ((packed)) USB_CDC_Descriptor_Func_ACM_t;
#307 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    uint8_t bFunctionLength;
    uint8_t bDescriptorType;

    uint8_t bDescriptorSubType;

    uint8_t bmCapabilities;

} __attribute__ ((packed)) USB_CDC_StdDescriptor_FunctionalACM_t;
#331 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    USB_Descriptor_Header_t Header;
    uint8_t Subtype;

    uint8_t MasterInterfaceNumber;
    uint8_t SlaveInterfaceNumber;
} __attribute__ ((packed)) USB_CDC_Descriptor_Func_Union_t;
#351 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    uint8_t bFunctionLength;
    uint8_t bDescriptorType;

    uint8_t bDescriptorSubType;

    uint8_t bMasterInterface;
    uint8_t bSlaveInterface0;
} __attribute__ ((packed)) USB_CDC_StdDescriptor_FunctionalUnion_t;
#371 "./LUFA/Drivers/USB/Class/Device/../Common/CDCClassCommon.h"
typedef struct {
    uint32_t BaudRateBPS;
    uint8_t CharFormat;

    uint8_t ParityType;

    uint8_t DataBits;
} __attribute__ ((packed)) CDC_LineEncoding_t;
#77 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h" 2

#1 "/usr/lib/avr/include/stdio.h" 1 3
#45 "/usr/lib/avr/include/stdio.h" 3
#1 "/usr/lib/gcc/avr/5.4.0/include/stdarg.h" 1 3 4
#40 "/usr/lib/gcc/avr/5.4.0/include/stdarg.h" 3 4

#40 "/usr/lib/gcc/avr/5.4.0/include/stdarg.h" 3 4
typedef __builtin_va_list __gnuc_va_list;
#98 "/usr/lib/gcc/avr/5.4.0/include/stdarg.h" 3 4
typedef __gnuc_va_list va_list;
#46 "/usr/lib/avr/include/stdio.h" 2 3

#1 "/usr/lib/gcc/avr/5.4.0/include/stddef.h" 1 3 4
#51 "/usr/lib/avr/include/stdio.h" 2 3
#244 "/usr/lib/avr/include/stdio.h" 3
struct __file {
    char *buf;
    unsigned char unget;
    uint8_t flags;
#263 "/usr/lib/avr/include/stdio.h" 3
    int size;
    int len;
    int (*put) (char, struct __file *);
    int (*get) (struct __file *);
    void *udata;
};
#277 "/usr/lib/avr/include/stdio.h" 3
typedef struct __file FILE;
#407 "/usr/lib/avr/include/stdio.h" 3
extern struct __file *__iob[];
#419 "/usr/lib/avr/include/stdio.h" 3
extern FILE *fdevopen(int (*__put) (char, FILE *), int (*__get) (FILE *));
#436 "/usr/lib/avr/include/stdio.h" 3
extern int fclose(FILE * __stream);
#610 "/usr/lib/avr/include/stdio.h" 3
extern int vfprintf(FILE * __stream, const char *__fmt, va_list __ap);

extern int vfprintf_P(FILE * __stream, const char *__fmt, va_list __ap);

extern int fputc(int __c, FILE * __stream);

extern int putc(int __c, FILE * __stream);

extern int putchar(int __c);
#651 "/usr/lib/avr/include/stdio.h" 3
extern int printf(const char *__fmt, ...);

extern int printf_P(const char *__fmt, ...);

extern int vprintf(const char *__fmt, va_list __ap);

extern int sprintf(char *__s, const char *__fmt, ...);

extern int sprintf_P(char *__s, const char *__fmt, ...);
#687 "/usr/lib/avr/include/stdio.h" 3
extern int snprintf(char *__s, size_t __n, const char *__fmt, ...);

extern int snprintf_P(char *__s, size_t __n, const char *__fmt, ...);

extern int vsprintf(char *__s, const char *__fmt, va_list ap);

extern int vsprintf_P(char *__s, const char *__fmt, va_list ap);
#715 "/usr/lib/avr/include/stdio.h" 3
extern int vsnprintf(char *__s, size_t __n, const char *__fmt, va_list ap);

extern int vsnprintf_P(char *__s, size_t __n, const char *__fmt,
		       va_list ap);

extern int fprintf(FILE * __stream, const char *__fmt, ...);

extern int fprintf_P(FILE * __stream, const char *__fmt, ...);

extern int fputs(const char *__str, FILE * __stream);

extern int fputs_P(const char *__str, FILE * __stream);

extern int puts(const char *__str);

extern int puts_P(const char *__str);
#764 "/usr/lib/avr/include/stdio.h" 3
extern size_t fwrite(const void *__ptr, size_t __size, size_t __nmemb,
		     FILE * __stream);

extern int fgetc(FILE * __stream);

extern int getc(FILE * __stream);

extern int getchar(void);
#812 "/usr/lib/avr/include/stdio.h" 3
extern int ungetc(int __c, FILE * __stream);
#824 "/usr/lib/avr/include/stdio.h" 3
extern char *fgets(char *__str, int __size, FILE * __stream);

extern char *gets(char *__str);
#842 "/usr/lib/avr/include/stdio.h" 3
extern size_t fread(void *__ptr, size_t __size, size_t __nmemb,
		    FILE * __stream);

extern void clearerr(FILE * __stream);
#859 "/usr/lib/avr/include/stdio.h" 3
extern int feof(FILE * __stream);
#870 "/usr/lib/avr/include/stdio.h" 3
extern int ferror(FILE * __stream);

extern int vfscanf(FILE * __stream, const char *__fmt, va_list __ap);

extern int vfscanf_P(FILE * __stream, const char *__fmt, va_list __ap);

extern int fscanf(FILE * __stream, const char *__fmt, ...);

extern int fscanf_P(FILE * __stream, const char *__fmt, ...);

extern int scanf(const char *__fmt, ...);

extern int scanf_P(const char *__fmt, ...);

extern int vscanf(const char *__fmt, va_list __ap);

extern int sscanf(const char *__buf, const char *__fmt, ...);

extern int sscanf_P(const char *__buf, const char *__fmt, ...);
#940 "/usr/lib/avr/include/stdio.h" 3
static __inline__ int fflush(FILE * stream __attribute__ ((unused)))
{
    return 0;
}

__extension__ typedef long long fpos_t;
extern int fgetpos(FILE * stream, fpos_t * pos);
extern FILE *fopen(const char *path, const char *mode);
extern FILE *freopen(const char *path, const char *mode, FILE * stream);
extern FILE *fdopen(int, const char *);
extern int fseek(FILE * stream, long offset, int whence);
extern int fsetpos(FILE * stream, fpos_t * pos);
extern long ftell(FILE * stream);
extern int fileno(FILE *);
extern void perror(const char *s);
extern int remove(const char *pathname);
extern int rename(const char *oldpath, const char *newpath);
extern void rewind(FILE * stream);
extern void setbuf(FILE * stream, char *buf);
extern int setvbuf(FILE * stream, char *buf, int mode, size_t size);
extern FILE *tmpfile(void);
extern char *tmpnam(char *s);
#79 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h" 2
#98 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"

#98 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
typedef struct {
    struct {
	uint8_t ControlInterfaceNumber;

	USB_Endpoint_Table_t DataINEndpoint;
	USB_Endpoint_Table_t DataOUTEndpoint;
	USB_Endpoint_Table_t NotificationEndpoint;
    } Config;

    struct {
	struct {
	    uint16_t HostToDevice;

	    uint16_t DeviceToHost;

	} ControlLineStates;

	CDC_LineEncoding_t LineEncoding;

    } State;

} USB_ClassInfo_CDC_Device_t;
#141 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"

#141 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h" 3 4
_Bool
#141 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"

CDC_Device_ConfigureEndpoints(USB_ClassInfo_CDC_Device_t *
			      const CDCInterfaceInfo)
   __attribute__ ((nonnull(1)));

void CDC_Device_ProcessControlRequest(USB_ClassInfo_CDC_Device_t *
				      const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));

void CDC_Device_USBTask(USB_ClassInfo_CDC_Device_t *
			const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));
#164 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t *
					  const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));
#174 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
void EVENT_CDC_Device_ControLineStateChanged(USB_ClassInfo_CDC_Device_t *
					     const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));

void EVENT_CDC_Device_BreakSent(USB_ClassInfo_CDC_Device_t *
				const CDCInterfaceInfo,
				const uint8_t Duration)
    __attribute__ ((nonnull(1)));
#199 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint8_t CDC_Device_SendData(USB_ClassInfo_CDC_Device_t *
			    const CDCInterfaceInfo,
			    const void *const Buffer,
			    const uint16_t Length)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#217 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint8_t CDC_Device_SendData_P(USB_ClassInfo_CDC_Device_t *
			      const CDCInterfaceInfo,
			      const void *const Buffer,
			      const uint16_t Length)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#234 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint8_t CDC_Device_SendString(USB_ClassInfo_CDC_Device_t *
			      const CDCInterfaceInfo,
			      const char *const String)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#250 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint8_t CDC_Device_SendString_P(USB_ClassInfo_CDC_Device_t *
				const CDCInterfaceInfo,
				const char *const String)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#266 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint8_t CDC_Device_SendByte(USB_ClassInfo_CDC_Device_t *
			    const CDCInterfaceInfo, const uint8_t Data)
    __attribute__ ((nonnull(1)));
#281 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint16_t CDC_Device_BytesReceived(USB_ClassInfo_CDC_Device_t *
				  const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));
#295 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
int16_t CDC_Device_ReceiveByte(USB_ClassInfo_CDC_Device_t *
			       const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));
#306 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
uint8_t CDC_Device_Flush(USB_ClassInfo_CDC_Device_t *
			 const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));
#318 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
void CDC_Device_SendControlLineStateChange(USB_ClassInfo_CDC_Device_t *
					   const CDCInterfaceInfo)
    __attribute__ ((nonnull(1)));
#339 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
void CDC_Device_CreateStream(USB_ClassInfo_CDC_Device_t *
			     const CDCInterfaceInfo, FILE * const Stream)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#350 "./LUFA/Drivers/USB/Class/Device/CDCClassDevice.h"
void CDC_Device_CreateBlockingStream(USB_ClassInfo_CDC_Device_t *
				     const CDCInterfaceInfo,
				     FILE * const Stream)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
#72 "./LUFA/Drivers/USB/Class/CDCClass.h" 2
#405 "./LUFA/Drivers/USB/USB.h" 2
#3469 "usb.w" 2
#1 "./LUFA/Drivers/Board/LEDs.h" 1
#108 "./LUFA/Drivers/Board/LEDs.h"
#1 "./LUFA/Drivers/Board/../../Common/Common.h" 1
#109 "./LUFA/Drivers/Board/LEDs.h" 2
#120 "./LUFA/Drivers/Board/LEDs.h"
#1 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 1
#60 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
#1 "./LUFA/Drivers/Board/AVR8/USBKEY/../../../../Common/Common.h" 1
#61 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 2
#94 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
static inline void LEDs_Init(void)
{

#96 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0A) + 0x20))
#96 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	|= ((1 << 4) | (1 << 5) | (1 << 7) | (1 << 6));

#97 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#97 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	&= ~((1 << 4) | (1 << 5) | (1 << 7) | (1 << 6));
}

static inline void LEDs_Disable(void)
{

#102 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0A) + 0x20))
#102 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	&= ~((1 << 4) | (1 << 5) | (1 << 7) | (1 << 6));

#103 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#103 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	&= ~((1 << 4) | (1 << 5) | (1 << 7) | (1 << 6));
}

static inline void LEDs_TurnOnLEDs(const uint8_t LEDMask)
{

#108 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#108 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	|= LEDMask;
}

static inline void LEDs_TurnOffLEDs(const uint8_t LEDMask)
{

#113 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#113 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	&= ~LEDMask;
}

static inline void LEDs_SetAllLEDs(const uint8_t LEDMask)
{

#118 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#118 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	= ((
#118 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
	       (*(volatile uint8_t *) ((0x0B) + 0x20))
#118 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	       & ~((1 << 4) | (1 << 5) | (1 << 7) | (1 << 6))) | LEDMask);
}

static inline void LEDs_ChangeLEDs(const uint8_t LEDMask,
				   const uint8_t ActiveMask)
{

#124 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#124 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	= ((
#124 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
	       (*(volatile uint8_t *) ((0x0B) + 0x20))
#124 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	       & ~LEDMask) | ActiveMask);
}

static inline void LEDs_ToggleLEDs(const uint8_t LEDMask)
{

#129 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
    (*(volatile uint8_t *) ((0x09) + 0x20))
#129 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	= LEDMask;
}

static inline uint8_t LEDs_GetLEDs(void)
    __attribute__ ((warn_unused_result));
static inline uint8_t LEDs_GetLEDs(void)
{
    return (
#135 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h" 3
	       (*(volatile uint8_t *) ((0x0B) + 0x20))
#135 "./LUFA/Drivers/Board/AVR8/USBKEY/LEDs.h"
	       & ((1 << 4) | (1 << 5) | (1 << 7) | (1 << 6)));
}

#121 "./LUFA/Drivers/Board/LEDs.h" 2
#3470 "usb.w" 2
#1 "./LUFA/Drivers/Peripheral/Serial.h" 1
#64 "./LUFA/Drivers/Peripheral/Serial.h"
#1 "./LUFA/Drivers/Peripheral/../../Common/Common.h" 1
#65 "./LUFA/Drivers/Peripheral/Serial.h" 2

#1 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 1
#74 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
#1 "./LUFA/Drivers/Peripheral/AVR8/../../../Common/Common.h" 1
#75 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 2
#1 "./LUFA/Drivers/Peripheral/AVR8/../../Misc/TerminalCodes.h" 1
#76 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 2
#92 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
extern FILE USARTSerialStream;

int Serial_putchar(char DataByte, FILE * Stream);
int Serial_getchar(FILE * Stream);
int Serial_getchar_Blocking(FILE * Stream);
#126 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
void Serial_SendString_P(const char *FlashStringPtr)
    __attribute__ ((nonnull(1)));

void Serial_SendString(const char *StringPtr) __attribute__ ((nonnull(1)));

void Serial_SendData(const void *Buffer, uint16_t Length)
    __attribute__ ((nonnull(1)));
#155 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
void Serial_CreateStream(FILE * Stream);
#165 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
void Serial_CreateBlockingStream(FILE * Stream);
#175 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
static inline void Serial_Init(const uint32_t BaudRate, const
#176 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
			       _Bool
#176 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
			       DoubleSpeed);
static inline void Serial_Init(const uint32_t BaudRate, const
#178 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
			       _Bool
#178 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
			       DoubleSpeed)
{

#180 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint16_t *) (0xCC))
#180 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= (DoubleSpeed
	   ? ((((16000000UL / 8) + (BaudRate / 2)) / (BaudRate)) -
	      1) : ((((16000000UL / 16) + (BaudRate / 2)) / (BaudRate)) -
		    1));


#182 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xCA))
#182 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= ((1 <<
#182 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
	    2
#182 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	   ) | (1 <<
#182 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		1
#182 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	   ));

#183 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xC8))
#183 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= (DoubleSpeed ? (1 <<
#183 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
			  1
#183 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	   ) : 0);

#184 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xC9))
#184 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= ((1 <<
#184 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
	    3
#184 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	   ) | (1 <<
#184 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		4
#184 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	   ));


#186 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) ((0x0A) + 0x20))
#186 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	|= (1 << 3);

#187 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#187 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	|= (1 << 2);
}

static inline void Serial_Disable(void);
static inline void Serial_Disable(void)
{

#194 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xC9))
#194 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= 0;

#195 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xC8))
#195 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= 0;

#196 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xCA))
#196 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= 0;


#198 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint16_t *) (0xCC))
#198 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= 0;


#200 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) ((0x0A) + 0x20))
#200 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	&= ~(1 << 3);

#201 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#201 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	&= ~(1 << 2);
}

static inline
#208 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
 _Bool
#208 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"

Serial_IsCharReceived(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#209 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
 _Bool
#209 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
Serial_IsCharReceived(void)
{
    return ((
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		(*(volatile uint8_t *) (0xC8))
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
		& (1 <<
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		   7
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
		))?
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
	    1
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	    :
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
	    0
#211 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	);
}

static inline
#219 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
 _Bool
#219 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"

Serial_IsSendReady(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#220 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
 _Bool
#220 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
Serial_IsSendReady(void)
{
    return ((
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		(*(volatile uint8_t *) (0xC8))
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
		& (1 <<
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		   5
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
		))?
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
	    1
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	    :
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
	    0
#222 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	);
}

static inline
#230 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
 _Bool
#230 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"

Serial_IsSendComplete(void) __attribute__ ((warn_unused_result))
   __attribute__ ((always_inline));
static inline
#231 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
 _Bool
#231 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
Serial_IsSendComplete(void)
{
    return ((
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		(*(volatile uint8_t *) (0xC8))
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
		& (1 <<
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
		   6
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
		))?
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
	    1
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	    :
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3 4
	    0
#233 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	);
}

#243 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
static inline void Serial_SendByte(const char DataByte)
    __attribute__ ((always_inline));
static inline void Serial_SendByte(const char DataByte)
{
    while (!(Serial_IsSendReady()));

#247 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
    (*(volatile uint8_t *) (0xCE))
#247 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	= DataByte;
}

static inline int16_t Serial_ReceiveByte(void)
    __attribute__ ((always_inline));
static inline int16_t Serial_ReceiveByte(void)
{
    if (!(Serial_IsCharReceived()))
	return -1;

    return
#260 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h" 3
	(*(volatile uint8_t *) (0xCE))
#260 "./LUFA/Drivers/Peripheral/AVR8/Serial_AVR8.h"
	;
}

#69 "./LUFA/Drivers/Peripheral/Serial.h" 2
#3471 "usb.w" 2
#1 "./LUFA/Drivers/Misc/RingBuffer.h" 1
#97 "./LUFA/Drivers/Misc/RingBuffer.h"
#1 "./LUFA/Drivers/Misc/../../Common/Common.h" 1
#98 "./LUFA/Drivers/Misc/RingBuffer.h" 2
#110 "./LUFA/Drivers/Misc/RingBuffer.h"
typedef struct {
    uint8_t *In;
    uint8_t *Out;
    uint8_t *Start;
    uint8_t *End;
    uint16_t Size;
    uint16_t Count;
} RingBuffer_t;
#129 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline void RingBuffer_InitBuffer(RingBuffer_t * Buffer,
					 uint8_t * const DataPtr,
					 const uint16_t Size)
    __attribute__ ((nonnull(1))) __attribute__ ((nonnull(2)));
static inline void RingBuffer_InitBuffer(RingBuffer_t * Buffer,
					 uint8_t * const DataPtr,
					 const uint16_t Size)
{
    __asm__ __volatile__("":"=b"(Buffer):"0"(Buffer));

    uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
    GlobalInterruptDisable();

    Buffer->In = DataPtr;
    Buffer->Out = DataPtr;
    Buffer->Start = &DataPtr[0];
    Buffer->End = &DataPtr[Size];
    Buffer->Size = Size;
    Buffer->Count = 0;

    SetGlobalInterruptMask(CurrentGlobalInt);
}

#165 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline uint16_t RingBuffer_GetCount(RingBuffer_t * const Buffer)
    __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(1)));
static inline uint16_t RingBuffer_GetCount(RingBuffer_t * const Buffer)
{
    uint16_t Count;

    uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
    GlobalInterruptDisable();

    Count = Buffer->Count;

    SetGlobalInterruptMask(CurrentGlobalInt);
    return Count;
}

#191 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline uint16_t RingBuffer_GetFreeCount(RingBuffer_t * const Buffer)
    __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(1)));
static inline uint16_t RingBuffer_GetFreeCount(RingBuffer_t * const Buffer)
{
    return (Buffer->Size - RingBuffer_GetCount(Buffer));
}

#209 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline
#209 "./LUFA/Drivers/Misc/RingBuffer.h" 3 4
 _Bool
#209 "./LUFA/Drivers/Misc/RingBuffer.h"

RingBuffer_IsEmpty(RingBuffer_t * const Buffer)
   __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(1)));
static inline
#210 "./LUFA/Drivers/Misc/RingBuffer.h" 3 4
 _Bool
#210 "./LUFA/Drivers/Misc/RingBuffer.h"
RingBuffer_IsEmpty(RingBuffer_t * const Buffer)
{
    return (RingBuffer_GetCount(Buffer) == 0);
}

#223 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline
#223 "./LUFA/Drivers/Misc/RingBuffer.h" 3 4
 _Bool
#223 "./LUFA/Drivers/Misc/RingBuffer.h"

RingBuffer_IsFull(RingBuffer_t * const Buffer)
   __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(1)));
static inline
#224 "./LUFA/Drivers/Misc/RingBuffer.h" 3 4
 _Bool
#224 "./LUFA/Drivers/Misc/RingBuffer.h"
RingBuffer_IsFull(RingBuffer_t * const Buffer)
{
    return (RingBuffer_GetCount(Buffer) == Buffer->Size);
}

#238 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline void RingBuffer_Insert(RingBuffer_t * Buffer,
				     const uint8_t Data)
    __attribute__ ((nonnull(1)));
static inline void RingBuffer_Insert(RingBuffer_t * Buffer,
				     const uint8_t Data)
{
    __asm__ __volatile__("":"=b"(Buffer):"0"(Buffer));

    *Buffer->In = Data;

    if (++Buffer->In == Buffer->End)
	Buffer->In = Buffer->Start;

    uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
    GlobalInterruptDisable();

    Buffer->Count++;

    SetGlobalInterruptMask(CurrentGlobalInt);
}

#268 "./LUFA/Drivers/Misc/RingBuffer.h"
static inline uint8_t RingBuffer_Remove(RingBuffer_t * Buffer)
    __attribute__ ((nonnull(1)));
static inline uint8_t RingBuffer_Remove(RingBuffer_t * Buffer)
{
    __asm__ __volatile__("":"=b"(Buffer):"0"(Buffer));

    uint8_t Data = *Buffer->Out;

    if (++Buffer->Out == Buffer->End)
	Buffer->Out = Buffer->Start;

    uint_reg_t CurrentGlobalInt = GetGlobalInterruptMask();
    GlobalInterruptDisable();

    Buffer->Count--;

    SetGlobalInterruptMask(CurrentGlobalInt);

    return Data;
}

static inline uint8_t RingBuffer_Peek(RingBuffer_t * const Buffer)
    __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(1)));
static inline uint8_t RingBuffer_Peek(RingBuffer_t * const Buffer)
{
    return *Buffer->Out;
}

#3472 "usb.w" 2
#1 "./LUFA/Platform/Platform.h" 1
#69 "./LUFA/Platform/Platform.h"
#1 "./LUFA/Platform/../Common/Common.h" 1
#70 "./LUFA/Platform/Platform.h" 2
#3473 "usb.w" 2
#3458 "usb.w"
#239 "usb.w"
#768 "usb.w"

typedef struct {
    USB_Descriptor_Config_Header_t Config;
#893 "usb.w"

    USB_Descriptor_Interface_t CDC_CCI_Interface;
    USB_CDC_Descriptor_Func_Header_t CDC_Functional_Header;
    USB_CDC_Descriptor_Func_ACM_t CDC_Functional_ACM;
    USB_CDC_Descriptor_Func_Union_t CDC_Functional_Union;
    USB_Descriptor_Endpoint_t CDC_NotificationEndpoint;
#771 "usb.w"
#900 "usb.w"

    USB_Descriptor_Interface_t CDC_DCI_Interface;
    USB_Descriptor_Endpoint_t CDC_DataOut_Endpoint;
    USB_Descriptor_Endpoint_t CDC_DataIn_Endpoint;
#772 "usb.w"

} USB_Descriptor_Config_t;
#240 "usb.w"
#442 "usb.w"

void SetupHardware(void);
#466 "usb.w"

void EVENT_USB_Device_Connect(void);
#479 "usb.w"

void EVENT_USB_Device_Disconnect(void);
#490 "usb.w"

void EVENT_USB_Device_ConfigurationChanged(void);
#506 "usb.w"

void EVENT_USB_Device_ControlRequest(void);
#544 "usb.w"

void EVENT_CDC_Device_LineEncodingChanged(USB_ClassInfo_CDC_Device_t *
					  const CDCInterfaceInfo);
#1081 "usb.w"

uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
				    const uint16_t wIndex,
				    const void **const DescriptorAddress)
    __attribute__ ((warn_unused_result)) __attribute__ ((nonnull(3)));
#1140 "usb.w"

void USB_Event_Stub(void) __attribute__ ((const));
void EVENT_USB_Device_Suspend(void) __attribute__ ((weak))
    __attribute__ ((alias("USB_Event_Stub")));
void EVENT_USB_Device_WakeUp(void) __attribute__ ((weak))
    __attribute__ ((alias("USB_Event_Stub")));
void EVENT_USB_Device_Reset(void) __attribute__ ((weak))
    __attribute__ ((alias("USB_Event_Stub")));
void EVENT_USB_Device_StartOfFrame(void) __attribute__ ((weak))
    __attribute__ ((alias("USB_Event_Stub")));
#1412 "usb.w"

static void USB_Init_Device(void);
#1640 "usb.w"

static int CDC_Device_putchar(char c, FILE * Stream)
    __attribute__ ((nonnull(2)));
static int CDC_Device_getchar(FILE * Stream) __attribute__ ((nonnull(1)));
static int CDC_Device_getchar_Blocking(FILE * Stream)
    __attribute__ ((nonnull(1)));

void CDC_Device_Event_Stub(void) __attribute__ ((const));

void EVENT_CDC_Device_ControLineStateChanged(USB_ClassInfo_CDC_Device_t *
					     const CDCInterfaceInfo)
    __attribute__ ((weak)) __attribute__ ((nonnull(1)))
    __attribute__ ((alias("CDC_Device_Event_Stub")));
void EVENT_CDC_Device_BreakSent(USB_ClassInfo_CDC_Device_t *
				const CDCInterfaceInfo,
				const uint8_t Duration)
    __attribute__ ((weak)) __attribute__ ((nonnull(1)))
    __attribute__ ((alias("CDC_Device_Event_Stub")));
#2001 "usb.w"

static void USB_Device_SetAddress(void);
static void USB_Device_SetConfiguration(void);
static void USB_Device_GetConfiguration(void);
static void USB_Device_GetDescriptor(void);
static void USB_Device_GetStatus(void);
static void USB_Device_ClearSetFeature(void);
static void USB_Device_GetInternalSerialDescriptor(void);
#241 "usb.w"
#331 "usb.w"

RingBuffer_t USBtoUSART_Buffer;
#336 "usb.w"

uint8_t USBtoUSART_Buffer_Data[128];
#341 "usb.w"

RingBuffer_t USARTtoUSB_Buffer;
#346 "usb.w"

uint8_t USARTtoUSB_Buffer_Data[128];
#374 "usb.w"

USB_ClassInfo_CDC_Device_t VirtualSerial_CDC_Interface = {
#433 "usb.w"
    {
     0,
     {(0x80 | 3), 16,.Banks = 1},
     {(0x00 | 4), 16,.Banks = 1},
     {(0x80 | 2), 8,.Banks = 1}
     }
#376 "usb.w"

};

#696 "usb.w"

const USB_Descriptor_Device_t
#697 "usb.w" 3
    __attribute__ ((__progmem__))
#697 "usb.w"
    DeviceDescriptor = {
#715 "usb.w"

    {
    sizeof(USB_Descriptor_Device_t), 0x01}
#698 "usb.w"
, (((1 & 0xFF) << 8) | ((1 & 0x0F) << 4) | (0 & 0x0F)),
	0x02,
	0x00,
	0x00,
	8,
	0x03EB,
	0x204B,
	(((0 & 0xFF) << 8) | ((0 & 0x0F) << 4) | (1 & 0x0F)),
	1, 2, 0xDC, 1};
#737 "usb.w"

const USB_Descriptor_Config_t
#738 "usb.w" 3
    __attribute__ ((__progmem__))
#738 "usb.w"
    ConfigurationDescriptor = {
#907 "usb.w"
    {
	{
	sizeof(USB_Descriptor_Config_Header_t), 0x02}
	, sizeof(USB_Descriptor_Config_t),
	    2, 1, 0, (0x80 | 0x40), ((100) >> 1)
    }
#739 "usb.w"
    ,
#744 "usb.w"
#925 "usb.w"
    {
	{
	sizeof(USB_Descriptor_Interface_t), 0x04}
    , 0, 0, 1, 0x02, 0x02, 0x01, 0}
#745 "usb.w"
    ,
#941 "usb.w"
    {
	{
	sizeof(USB_CDC_Descriptor_Func_Header_t), 0x24}
	, 0x00, (((1 & 0xFF) << 8) | ((1 & 0x0F) << 4) | (0 & 0x0F))
    }
#746 "usb.w"
    ,
#950 "usb.w"
    {
	{
	sizeof(USB_CDC_Descriptor_Func_ACM_t), 0x24}
    , 0x02, 0x06}
#747 "usb.w"
    ,
#960 "usb.w"
    {
	{
	sizeof(USB_CDC_Descriptor_Func_Union_t), 0x24}
    , 0x06, 0, 1}
#748 "usb.w"
    ,
#999 "usb.w"
    {
	{
	sizeof(USB_Descriptor_Endpoint_t), 0x05}
    , (0x80 | 2), (0x03 | (0 << 2) | (0 << 4)), 8, 0xFF}
#749 "usb.w"
#740 "usb.w"
    ,
#751 "usb.w"
#1013 "usb.w"
    {
	{
	sizeof(USB_Descriptor_Interface_t), 0x04}
    , 1, 0, 2, 0x0A, 0x00, 0x00, 0}
#752 "usb.w"
    ,
#1024 "usb.w"
    {
	{
	sizeof(USB_Descriptor_Endpoint_t), 0x05}
    , (0x00 | 4), (0x02 | (0 << 2) | (0 << 4)), 16, 0x05}
#753 "usb.w"
    ,
#1032 "usb.w"
    {
	{
	sizeof(USB_Descriptor_Endpoint_t), 0x05}
    , (0x80 | 3), (0x02 | (0 << 2) | (0 << 4)), 16, 0x05}
#754 "usb.w"
#741 "usb.w"

};

#1047 "usb.w"

const USB_Descriptor_String_t
#1048 "usb.w" 3
    __attribute__ ((__progmem__))
#1048 "usb.w"
    LanguageString = {
    .Header = {
	.Size = sizeof(USB_Descriptor_Header_t) + sizeof((uint16_t) {
							 0x0409}
    ),.Type = DTYPE_String}
    ,.UnicodeString = {
    0x0409}
};

#1057 "usb.w"

const USB_Descriptor_String_t
#1058 "usb.w" 3
    __attribute__ ((__progmem__))
#1058 "usb.w"
    ManufacturerString = {
    .Header = {
    .Size =
	    sizeof(USB_Descriptor_Header_t) + (sizeof(L"Dean Camera") -
						   2),.Type = DTYPE_String}
,.UnicodeString = L"Dean Camera"};

#1067 "usb.w"

const USB_Descriptor_String_t
#1068 "usb.w" 3
    __attribute__ ((__progmem__))
#1068 "usb.w"
    ProductString = {
    .Header = {
    .Size =
	    sizeof(USB_Descriptor_Header_t) +
	    (sizeof(L"LUFA USB-RS232 Adapter") - 2),.Type = DTYPE_String}
,.UnicodeString = L"LUFA USB-RS232 Adapter"};

#1155 "usb.w"

volatile
#1156 "usb.w" 3 4
 _Bool
#1156 "usb.w"
 USB_IsInitialized;
USB_Request_Header_t USB_ControlRequest;
#242 "usb.w"

int main(void)
{
    SetupHardware();
    RingBuffer_InitBuffer(&USBtoUSART_Buffer, USBtoUSART_Buffer_Data,
			  sizeof USBtoUSART_Buffer_Data);
    RingBuffer_InitBuffer(&USARTtoUSB_Buffer, USARTtoUSB_Buffer_Data,
			  sizeof USARTtoUSB_Buffer_Data);
#323 "usb.w"

    LEDs_SetAllLEDs((1 << 4));
#252 "usb.w"

    GlobalInterruptEnable();

    while (1) {
#268 "usb.w"

	if (!(RingBuffer_IsFull(&USBtoUSART_Buffer))) {
	    int16_t ReceivedByte =
		CDC_Device_ReceiveByte(&VirtualSerial_CDC_Interface);
#274 "usb.w"

	    if (!(ReceivedByte < 0))
		RingBuffer_Insert(&USBtoUSART_Buffer, ReceivedByte);
#271 "usb.w"

	}
#256 "usb.w"

	uint16_t BufferCount = RingBuffer_GetCount(&USARTtoUSB_Buffer);
	if (BufferCount) {
	    Endpoint_SelectEndpoint(VirtualSerial_CDC_Interface.Config.
				    DataINEndpoint.Address);
#283 "usb.w"

	    if (Endpoint_IsINReady()) {
#294 "usb.w"

		uint8_t BytesToSend =
		    (((BufferCount) <
		      ((16 - 1))) ? (BufferCount) : ((16 - 1)));
#285 "usb.w"
#297 "usb.w"

		while (BytesToSend--) {
#308 "usb.w"

		    if (CDC_Device_SendByte(&VirtualSerial_CDC_Interface,
					    RingBuffer_Peek
					    (&USARTtoUSB_Buffer)) != 0)
			break;
#300 "usb.w"
#313 "usb.w"

		    RingBuffer_Remove(&USARTtoUSB_Buffer);
#302 "usb.w"

		}
#286 "usb.w"

	    }
#260 "usb.w"

	}
#317 "usb.w"

	if (Serial_IsSendReady()
	    && !(RingBuffer_IsEmpty(&USBtoUSART_Buffer)))
	    Serial_SendByte(RingBuffer_Remove(&USBtoUSART_Buffer));
#262 "usb.w"

	CDC_Device_USBTask(&VirtualSerial_CDC_Interface);
	USB_USBTask();
    }
}

#445 "usb.w"

void SetupHardware(void)
{
#455 "usb.w"

#456 "usb.w" 3
    (*(volatile uint8_t *) ((0x34) + 0x20))
#456 "usb.w"
	&= ~(1 <<
#456 "usb.w" 3
	     3
#456 "usb.w"
	);

    wdt_disable();
#449 "usb.w"

    clock_prescale_set(clock_div_1);
#460 "usb.w"

    LEDs_Init();
    USB_Init();
#452 "usb.w"

}

#471 "usb.w"

void EVENT_USB_Device_Connect(void)
{
    LEDs_SetAllLEDs((1 << 5) | (1 << 7));
}

#482 "usb.w"

void EVENT_USB_Device_Disconnect(void)
{
#323 "usb.w"

    LEDs_SetAllLEDs((1 << 4));
#485 "usb.w"

}

#496 "usb.w"

void EVENT_USB_Device_ConfigurationChanged(void)
{

#499 "usb.w" 3 4
    _Bool
#499 "usb.w"
	ConfigSuccess =
#499 "usb.w" 3 4
	1
#499 "usb.w"
	;
    ConfigSuccess &=
	CDC_Device_ConfigureEndpoints(&VirtualSerial_CDC_Interface);
    LEDs_SetAllLEDs(ConfigSuccess ? ((1 << 5) | (1 << 6))
		    : ((1 << 4) | (1 << 7)));
}

#509 "usb.w"

void EVENT_USB_Device_ControlRequest(void)
{
    CDC_Device_ProcessControlRequest(&VirtualSerial_CDC_Interface);
}

#532 "usb.w"

#533 "usb.w" 3
void __vector_25(void) __attribute__ ((signal, used, externally_visible));
void __vector_25(void)
#534 "usb.w"
{
    uint8_t ReceivedByte =
#535 "usb.w" 3
	(*(volatile uint8_t *) (0xCE))
#535 "usb.w"
	;

    if ((
#537 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#537 "usb.w"
	    == 4) && !(RingBuffer_IsFull(&USARTtoUSB_Buffer)))
	RingBuffer_Insert(&USARTtoUSB_Buffer, ReceivedByte);
}

#552 "usb.w"

void EVENT_CDC_Device_LineEncodingChanged(CDCInterfaceInfo)
USB_ClassInfo_CDC_Device_t *const CDCInterfaceInfo;

{
    uint8_t ConfigMask = 0;

    switch (CDCInterfaceInfo->State.LineEncoding.ParityType) {
    case 1:
	ConfigMask = ((1 <<
#562 "usb.w" 3
		       5
#562 "usb.w"
		      ) | (1 <<
#562 "usb.w" 3
			   4
#562 "usb.w"
		      ));

	break;
    case 2:
	ConfigMask = (1 <<
#566 "usb.w" 3
		      5
#566 "usb.w"
	    );
	break;
    }

    if (CDCInterfaceInfo->State.LineEncoding.CharFormat == 2)
	ConfigMask |= (1 <<
#571 "usb.w" 3
		       3
#571 "usb.w"
	    );

    switch (CDCInterfaceInfo->State.LineEncoding.DataBits) {
    case 6:
	ConfigMask |= (1 <<
#577 "usb.w" 3
		       1
#577 "usb.w"
	    );
	break;
    case 7:
	ConfigMask |= (1 <<
#580 "usb.w" 3
		       2
#580 "usb.w"
	    );
	break;
    case 8:

	ConfigMask |= ((1 <<
#584 "usb.w" 3
			2
#584 "usb.w"
		       ) | (1 <<
#584 "usb.w" 3
			    1
#584 "usb.w"
		       ));
	break;
    }

#588 "usb.w" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#588 "usb.w"
	|= (1 << 3);
#599 "usb.w"

#600 "usb.w" 3
    (*(volatile uint8_t *) (0xC9))
#600 "usb.w"
	= 0;

#601 "usb.w" 3
    (*(volatile uint8_t *) (0xC8))
#601 "usb.w"
	= 0;

#602 "usb.w" 3
    (*(volatile uint8_t *) (0xCA))
#602 "usb.w"
	= 0;
#591 "usb.w"
#605 "usb.w"

#606 "usb.w" 3
    (*(volatile uint16_t *) (0xCC))
#606 "usb.w"
	=
	((((16000000UL / 8) +
	   (CDCInterfaceInfo->State.LineEncoding.BaudRateBPS / 2)) /
	  (CDCInterfaceInfo->State.LineEncoding.BaudRateBPS)) - 1);
#592 "usb.w"
#609 "usb.w"

#610 "usb.w" 3
    (*(volatile uint8_t *) (0xCA))
#610 "usb.w"
	= ConfigMask;

#611 "usb.w" 3
    (*(volatile uint8_t *) (0xC8))
#611 "usb.w"
	= (1 <<
#611 "usb.w" 3
	   1
#611 "usb.w"
	);

#612 "usb.w" 3
    (*(volatile uint8_t *) (0xC9))
#612 "usb.w"
	= ((1 <<
#612 "usb.w" 3
	    7
#612 "usb.w"
	   ) | (1 <<
#612 "usb.w" 3
		3
#612 "usb.w"
	   ) | (1 <<
#612 "usb.w" 3
		4
#612 "usb.w"
	   ));
#593 "usb.w"

#594 "usb.w" 3
    (*(volatile uint8_t *) ((0x0B) + 0x20))
#594 "usb.w"
	&= ~(1 << 3);
}

#1093 "usb.w"

uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue,
				    const uint16_t wIndex,
				    const void **const DescriptorAddress)
{
    const uint8_t DescriptorType = (wValue >> 8);
    const uint8_t DescriptorNumber = (wValue & 0xFF);

    const void *Address =
#1101 "usb.w" 3 4
	((void *) 0)
#1101 "usb.w"
	;
    uint16_t Size = 0;

    switch (DescriptorType) {
    case 0x01:
	Address = &DeviceDescriptor;
	Size = sizeof(USB_Descriptor_Device_t);
	break;
    case 0x02:
	Address = &ConfigurationDescriptor;
	Size = sizeof(USB_Descriptor_Config_t);
	break;
    case 0x03:
	switch (DescriptorNumber) {
	case 0:
	    Address = &LanguageString;
	    Size =
#1119 "usb.w" 3
		(__extension__( {
			       uint16_t __addr16 = (uint16_t) ((uint16_t) (
#1119 "usb.w"
									      &LanguageString.
									      Header.
									      Size
#1119 "usb.w" 3
							       ));
			       uint8_t __result;
	      __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
			       __result;
			       }
		 ))
#1119 "usb.w"
		;
	    break;
	case 1:
	    Address = &ManufacturerString;
	    Size =
#1123 "usb.w" 3
		(__extension__( {
			       uint16_t __addr16 = (uint16_t) ((uint16_t) (
#1123 "usb.w"
									      &ManufacturerString.
									      Header.
									      Size
#1123 "usb.w" 3
							       ));
			       uint8_t __result;
	      __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
			       __result;
			       }
		 ))
#1123 "usb.w"
		;
	    break;
	case 2:
	    Address = &ProductString;
	    Size =
#1127 "usb.w" 3
		(__extension__( {
			       uint16_t __addr16 = (uint16_t) ((uint16_t) (
#1127 "usb.w"
									      &ProductString.
									      Header.
									      Size
#1127 "usb.w" 3
							       ));
			       uint8_t __result;
	      __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
			       __result;
			       }
		 ))
#1127 "usb.w"
		;
	    break;
	}

	break;
    }

    *DescriptorAddress = Address;
    return Size;
}

#1147 "usb.w"

void USB_Event_Stub(void)
{

}

#1159 "usb.w"

void USB_USBTask(void)
{
    USB_DeviceTask();
}

#1165 "usb.w"

void USB_DeviceTask(void)
{
    if (
#1168 "usb.w" 3
	   (*(volatile uint8_t *) ((0x1E) + 0x20))
#1168 "usb.w"
	   == DEVICE_STATE_Unattached)
	return;

    uint8_t PrevEndpoint = Endpoint_GetCurrentEndpoint();

    Endpoint_SelectEndpoint(0);

    if (Endpoint_IsSETUPReceived())
	USB_Device_ProcessControlRequest();

    Endpoint_SelectEndpoint(PrevEndpoint);
}

#1183 "usb.w"

void USB_GetNextDescriptorOfType(uint16_t * const BytesRem,
				 void **const CurrConfigLoc,
				 const uint8_t Type)
{
    while (*BytesRem) {
	USB_GetNextDescriptor(BytesRem, CurrConfigLoc);

	if (((USB_Descriptor_Header_t *) (*CurrConfigLoc))->Type == Type)
	    return;
    }
}

void USB_GetNextDescriptorOfTypeBefore(uint16_t * const BytesRem,
				       void **const CurrConfigLoc,
				       const uint8_t Type,
				       const uint8_t BeforeType)
{
    while (*BytesRem) {
	USB_GetNextDescriptor(BytesRem, CurrConfigLoc);

	if (((USB_Descriptor_Header_t *) (*CurrConfigLoc))->Type == Type) {
	    return;
	} else if (((USB_Descriptor_Header_t *) (*CurrConfigLoc))->Type ==
		   BeforeType) {
	    *BytesRem = 0;
	    return;
	}
    }
}

void USB_GetNextDescriptorOfTypeAfter(uint16_t * const BytesRem,
				      void **const CurrConfigLoc,
				      const uint8_t Type,
				      const uint8_t AfterType)
{
    USB_GetNextDescriptorOfType(BytesRem, CurrConfigLoc, AfterType);

    if (*BytesRem)
	USB_GetNextDescriptorOfType(BytesRem, CurrConfigLoc, Type);
}

uint8_t USB_GetNextDescriptorComp(uint16_t * const BytesRem,
				  void **const CurrConfigLoc,
				  ConfigComparatorPtr_t const
				  ComparatorRoutine)
{
    uint8_t ErrorCode;

    while (*BytesRem) {
	uint8_t *PrevDescLoc = *CurrConfigLoc;
	uint16_t PrevBytesRem = *BytesRem;

	USB_GetNextDescriptor(BytesRem, CurrConfigLoc);

	if ((ErrorCode =
	     ComparatorRoutine(*CurrConfigLoc)) !=
	    DESCRIPTOR_SEARCH_NotFound) {
	    if (ErrorCode == DESCRIPTOR_SEARCH_Fail) {
		*CurrConfigLoc = PrevDescLoc;
		*BytesRem = PrevBytesRem;
	    }

	    return ErrorCode;
	}
    }

    return DESCRIPTOR_SEARCH_COMP_EndOfDescriptor;
}

#1259 "usb.w"

void USB_INT_DisableAllInterrupts(void)
{

#1265 "usb.w" 3
    (*(volatile uint8_t *) (0xD8))
#1265 "usb.w"
	&= ~(1 <<
#1265 "usb.w" 3
	     0
#1265 "usb.w"
	);

#1269 "usb.w" 3
    (*(volatile uint8_t *) (0xE2))
#1269 "usb.w"
	= 0;

}

void USB_INT_ClearAllInterrupts(void)
{

#1276 "usb.w" 3
    (*(volatile uint8_t *) (0xDA))
#1276 "usb.w"
	= 0;

#1280 "usb.w" 3
    (*(volatile uint8_t *) (0xE1))
#1280 "usb.w"
	= 0;

}

#1284 "usb.w" 3
void __vector_10(void) __attribute__ ((signal, used, externally_visible));
void __vector_10(void)
#1285 "usb.w"
{

    if (USB_INT_HasOccurred(USB_INT_SOFI)
	&& USB_INT_IsEnabled(USB_INT_SOFI)) {
	USB_INT_Clear(USB_INT_SOFI);

	EVENT_USB_Device_StartOfFrame();
    }

    if (USB_INT_HasOccurred(USB_INT_VBUSTI)
	&& USB_INT_IsEnabled(USB_INT_VBUSTI)) {
	USB_INT_Clear(USB_INT_VBUSTI);

	if (USB_VBUS_GetStatus()) {
	    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2))) {
		USB_PLL_On();
		while (!(USB_PLL_IsReady()));
	    }
#1309 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1309 "usb.w"
		= DEVICE_STATE_Powered;
	    EVENT_USB_Device_Connect();
	} else {
	    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2)))
		USB_PLL_Off();

#1317 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1317 "usb.w"
		= DEVICE_STATE_Unattached;
	    EVENT_USB_Device_Disconnect();
	}
    }

    if (USB_INT_HasOccurred(USB_INT_SUSPI)
	&& USB_INT_IsEnabled(USB_INT_SUSPI)) {
	USB_INT_Disable(USB_INT_SUSPI);
	USB_INT_Enable(USB_INT_WAKEUPI);

	USB_CLK_Freeze();

	if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2)))
	    USB_PLL_Off();

#1337 "usb.w" 3
	(*(volatile uint8_t *) ((0x1E) + 0x20))
#1337 "usb.w"
	    = DEVICE_STATE_Suspended;
	EVENT_USB_Device_Suspend();

    }

    if (USB_INT_HasOccurred(USB_INT_WAKEUPI)
	&& USB_INT_IsEnabled(USB_INT_WAKEUPI)) {
	if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2))) {
	    USB_PLL_On();
	    while (!(USB_PLL_IsReady()));
	}

	USB_CLK_Unfreeze();

	USB_INT_Clear(USB_INT_WAKEUPI);

	USB_INT_Disable(USB_INT_WAKEUPI);
	USB_INT_Enable(USB_INT_SUSPI);

	if (USB_Device_ConfigurationNumber)
#1358 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1358 "usb.w"
		= DEVICE_STATE_Configured;
	else
#1360 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1360 "usb.w"
		= (USB_Device_IsAddressSet())? DEVICE_STATE_Addressed :
		DEVICE_STATE_Powered;

	EVENT_USB_Device_WakeUp();

    }

    if (USB_INT_HasOccurred(USB_INT_EORSTI)
	&& USB_INT_IsEnabled(USB_INT_EORSTI)) {
	USB_INT_Clear(USB_INT_EORSTI);

#1373 "usb.w" 3
	(*(volatile uint8_t *) ((0x1E) + 0x20))
#1373 "usb.w"
	    = DEVICE_STATE_Default;
	USB_Device_ConfigurationNumber = 0;

	USB_INT_Clear(USB_INT_SUSPI);
	USB_INT_Disable(USB_INT_SUSPI);
	USB_INT_Enable(USB_INT_WAKEUPI);

	Endpoint_ConfigureEndpoint(0, 0x00, 8, 1);

	USB_INT_Enable(USB_INT_RXSTPI);

	EVENT_USB_Device_Reset();
    }

}

#1393 "usb.w" 3
void __vector_11(void) __attribute__ ((signal, used, externally_visible));
void __vector_11(void)
#1394 "usb.w"
{
    uint8_t PrevSelectedEndpoint = Endpoint_GetCurrentEndpoint();

    Endpoint_SelectEndpoint(0);
    USB_INT_Disable(USB_INT_RXSTPI);

    GlobalInterruptEnable();

    USB_Device_ProcessControlRequest();

    Endpoint_SelectEndpoint(0);
    USB_INT_Enable(USB_INT_RXSTPI);
    Endpoint_SelectEndpoint(PrevSelectedEndpoint);
}

#1415 "usb.w"

void USB_Init(void)
{

    USB_OTGPAD_Off();

    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 1)))
	USB_REG_On();
    else
	USB_REG_Off();

    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2)))
#1429 "usb.w" 3
	(*(volatile uint8_t *) ((0x32) + 0x20))
#1429 "usb.w"
	    = (1 <<
#1429 "usb.w" 3
	       2
#1429 "usb.w"
	    );

    USB_IsInitialized =
#1431 "usb.w" 3 4
	1
#1431 "usb.w"
	;

    USB_ResetInterface();
}

void USB_Disable(void)
{
    USB_INT_DisableAllInterrupts();
    USB_INT_ClearAllInterrupts();

    USB_Detach();
    USB_Controller_Disable();

    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2)))
	USB_PLL_Off();

    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 3)))
	USB_REG_Off();

    USB_OTGPAD_Off();

    USB_IsInitialized =
#1452 "usb.w" 3 4
	0
#1452 "usb.w"
	;
}

void USB_ResetInterface(void)
{
    USB_INT_DisableAllInterrupts();
    USB_INT_ClearAllInterrupts();

    USB_Controller_Reset();

    USB_CLK_Unfreeze();

    if (!(((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 2)))
	USB_PLL_Off();

    USB_Init_Device();

    USB_OTGPAD_On();
}

static void USB_Init_Device(void)
{

#1474 "usb.w" 3
    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1474 "usb.w"
	= DEVICE_STATE_Unattached;
    USB_Device_ConfigurationNumber = 0;

    USB_Device_RemoteWakeupEnabled =
#1477 "usb.w" 3 4
	0
#1477 "usb.w"
	;

    USB_Device_CurrentlySelfPowered =
#1479 "usb.w" 3 4
	0
#1479 "usb.w"
	;

    if (((0 << 0) | (0 << 1) | (0 << 2)) & (1 << 0))
	USB_Device_SetLowSpeed();
    else
	USB_Device_SetFullSpeed();

    USB_INT_Enable(USB_INT_VBUSTI);

    Endpoint_ConfigureEndpoint(0, 0x00, 8, 1);

    USB_INT_Clear(USB_INT_SUSPI);
    USB_INT_Enable(USB_INT_SUSPI);
    USB_INT_Enable(USB_INT_EORSTI);

    USB_Attach();
}

#1500 "usb.w"

#1501 "usb.w" 3 4
_Bool
#1501 "usb.w"
Endpoint_ConfigureEndpointTable(const USB_Endpoint_Table_t * const Table,
				const uint8_t Entries)
{
    for (uint8_t i = 0; i < Entries; i++) {
	if (!(Table[i].Address))
	    continue;

	if (!
	    (Endpoint_ConfigureEndpoint
	     (Table[i].Address, Table[i].Type, Table[i].Size,
	      Table[i].Banks)))
	    return
#1510 "usb.w" 3 4
		0
#1510 "usb.w"
		;
    }

    return
#1513 "usb.w" 3 4
	1
#1513 "usb.w"
	;
}

#1516 "usb.w" 3 4
_Bool
#1516 "usb.w"
Endpoint_ConfigureEndpoint_Prv(const uint8_t Number,
			       const uint8_t UECFG0XData,
			       const uint8_t UECFG1XData)
{
    for (uint8_t EPNum = Number; EPNum < 7; EPNum++) {
	uint8_t UECFG0XTemp;
	uint8_t UECFG1XTemp;
	uint8_t UEIENXTemp;

	Endpoint_SelectEndpoint(EPNum);

	if (EPNum == Number) {
	    UECFG0XTemp = UECFG0XData;
	    UECFG1XTemp = UECFG1XData;
	    UEIENXTemp = 0;
	} else {
	    UECFG0XTemp =
#1536 "usb.w" 3
		(*(volatile uint8_t *) (0xEC))
#1536 "usb.w"
		;
	    UECFG1XTemp =
#1537 "usb.w" 3
		(*(volatile uint8_t *) (0xED))
#1537 "usb.w"
		;
	    UEIENXTemp =
#1538 "usb.w" 3
		(*(volatile uint8_t *) (0xF0))
#1538 "usb.w"
		;
	}

	if (!(UECFG1XTemp & (1 <<
#1541 "usb.w" 3
			     1
#1541 "usb.w"
	      )))
	    continue;

	Endpoint_DisableEndpoint();

#1545 "usb.w" 3
	(*(volatile uint8_t *) (0xED))
#1545 "usb.w"
	    &= ~(1 <<
#1545 "usb.w" 3
		 1
#1545 "usb.w"
	    );

	Endpoint_EnableEndpoint();

#1548 "usb.w" 3
	(*(volatile uint8_t *) (0xEC))
#1548 "usb.w"
	    = UECFG0XTemp;

#1549 "usb.w" 3
	(*(volatile uint8_t *) (0xED))
#1549 "usb.w"
	    = UECFG1XTemp;

#1550 "usb.w" 3
	(*(volatile uint8_t *) (0xF0))
#1550 "usb.w"
	    = UEIENXTemp;

	if (!(Endpoint_IsConfigured()))
	    return
#1553 "usb.w" 3 4
		0
#1553 "usb.w"
		;
    }

    Endpoint_SelectEndpoint(Number);
    return
#1557 "usb.w" 3 4
	1
#1557 "usb.w"
	;
}

void Endpoint_ClearEndpoints(void)
{

#1562 "usb.w" 3
    (*(volatile uint8_t *) (0xF4))
#1562 "usb.w"
	= 0;

    for (uint8_t EPNum = 0; EPNum < 7; EPNum++) {
	Endpoint_SelectEndpoint(EPNum);

#1567 "usb.w" 3
	(*(volatile uint8_t *) (0xF0))
#1567 "usb.w"
	    = 0;

#1568 "usb.w" 3
	(*(volatile uint8_t *) (0xE8))
#1568 "usb.w"
	    = 0;

#1569 "usb.w" 3
	(*(volatile uint8_t *) (0xED))
#1569 "usb.w"
	    = 0;
	Endpoint_DisableEndpoint();
    }
}

void Endpoint_ClearStatusStage(void)
{
    if (USB_ControlRequest.bmRequestType & (1 << 7)) {
	while (!(Endpoint_IsOUTReceived())) {
	    if (
#1580 "usb.w" 3
		   (*(volatile uint8_t *) ((0x1E) + 0x20))
#1580 "usb.w"
		   == DEVICE_STATE_Unattached)
		return;
	}

	Endpoint_ClearOUT();
    } else {
	while (!(Endpoint_IsINReady())) {
	    if (
#1590 "usb.w" 3
		   (*(volatile uint8_t *) ((0x1E) + 0x20))
#1590 "usb.w"
		   == DEVICE_STATE_Unattached)
		return;
	}

	Endpoint_ClearIN();
    }
}

uint8_t Endpoint_WaitUntilReady(void)
{
    uint8_t TimeoutMSRem = 100;

    uint16_t PreviousFrameNumber = USB_Device_GetFrameNumber();

    for (;;) {
	if (Endpoint_GetEndpointDirection() == 0x80) {
	    if (Endpoint_IsINReady())
		return ENDPOINT_READYWAIT_NoError;
	} else {
	    if (Endpoint_IsOUTReceived())
		return ENDPOINT_READYWAIT_NoError;
	}

	uint8_t USB_DeviceState_LCL =
#1617 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1617 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_READYWAIT_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_READYWAIT_BusSuspended;
	else if (Endpoint_IsStalled())
	    return ENDPOINT_READYWAIT_EndpointStalled;

	uint16_t CurrentFrameNumber = USB_Device_GetFrameNumber();

	if (CurrentFrameNumber != PreviousFrameNumber) {
	    PreviousFrameNumber = CurrentFrameNumber;

	    if (!(TimeoutMSRem--))
		return ENDPOINT_READYWAIT_Timeout;
	}
    }
}

#1656 "usb.w"

void CDC_Device_ProcessControlRequest(USB_ClassInfo_CDC_Device_t *
				      const CDCInterfaceInfo)
{
    if (!(Endpoint_IsSETUPReceived()))
	return;

    if (USB_ControlRequest.wIndex !=
	CDCInterfaceInfo->Config.ControlInterfaceNumber)
	return;

    switch (USB_ControlRequest.bRequest) {
    case CDC_REQ_GetLineEncoding:
	if (USB_ControlRequest.bmRequestType ==
	    ((1 << 7) | (1 << 5) | (1 << 0))) {
	    Endpoint_ClearSETUP();

	    while (!(Endpoint_IsINReady()));

	    Endpoint_Write_32_LE(CDCInterfaceInfo->State.LineEncoding.
				 BaudRateBPS);
	    Endpoint_Write_8(CDCInterfaceInfo->State.LineEncoding.
			     CharFormat);
	    Endpoint_Write_8(CDCInterfaceInfo->State.LineEncoding.
			     ParityType);
	    Endpoint_Write_8(CDCInterfaceInfo->State.LineEncoding.
			     DataBits);

	    Endpoint_ClearIN();
	    Endpoint_ClearStatusStage();
	}

	break;
    case CDC_REQ_SetLineEncoding:
	if (USB_ControlRequest.bmRequestType ==
	    ((0 << 7) | (1 << 5) | (1 << 0))) {
	    Endpoint_ClearSETUP();

	    while (!(Endpoint_IsOUTReceived())) {
		if (
#1693 "usb.w" 3
		       (*(volatile uint8_t *) ((0x1E) + 0x20))
#1693 "usb.w"
		       == DEVICE_STATE_Unattached)
		    return;
	    }

	    CDCInterfaceInfo->State.LineEncoding.BaudRateBPS
		= Endpoint_Read_32_LE();
	    CDCInterfaceInfo->State.LineEncoding.CharFormat
		= Endpoint_Read_8();
	    CDCInterfaceInfo->State.LineEncoding.ParityType
		= Endpoint_Read_8();
	    CDCInterfaceInfo->State.LineEncoding.DataBits
		= Endpoint_Read_8();

	    Endpoint_ClearOUT();
	    Endpoint_ClearStatusStage();

	    EVENT_CDC_Device_LineEncodingChanged(CDCInterfaceInfo);
	}

	break;
    case CDC_REQ_SetControlLineState:
	if (USB_ControlRequest.bmRequestType ==
	    ((0 << 7) | (1 << 5) | (1 << 0))) {
	    Endpoint_ClearSETUP();
	    Endpoint_ClearStatusStage();

	    CDCInterfaceInfo->State.ControlLineStates.HostToDevice
		= USB_ControlRequest.wValue;

	    EVENT_CDC_Device_ControLineStateChanged(CDCInterfaceInfo);
	}

	break;
    case CDC_REQ_SendBreak:
	if (USB_ControlRequest.bmRequestType ==
	    ((0 << 7) | (1 << 5) | (1 << 0))) {
	    Endpoint_ClearSETUP();
	    Endpoint_ClearStatusStage();

	    EVENT_CDC_Device_BreakSent(CDCInterfaceInfo,
				       (uint8_t) USB_ControlRequest.
				       wValue);
	}

	break;
    }
}

#1742 "usb.w" 3 4
_Bool
#1742 "usb.w"
CDC_Device_ConfigureEndpoints(USB_ClassInfo_CDC_Device_t *
			      const CDCInterfaceInfo)
{
    memset(&CDCInterfaceInfo->State, 0x00,
	   sizeof(CDCInterfaceInfo->State));

    CDCInterfaceInfo->Config.DataINEndpoint.Type = 0x02;
    CDCInterfaceInfo->Config.DataOUTEndpoint.Type = 0x02;
    CDCInterfaceInfo->Config.NotificationEndpoint.Type = 0x03;

    if (!
	(Endpoint_ConfigureEndpointTable
	 (&CDCInterfaceInfo->Config.DataINEndpoint, 1)))
	return
#1751 "usb.w" 3 4
	    0
#1751 "usb.w"
	    ;

    if (!
	(Endpoint_ConfigureEndpointTable
	 (&CDCInterfaceInfo->Config.DataOUTEndpoint, 1)))
	return
#1754 "usb.w" 3 4
	    0
#1754 "usb.w"
	    ;

    if (!
	(Endpoint_ConfigureEndpointTable
	 (&CDCInterfaceInfo->Config.NotificationEndpoint, 1)))
	return
#1757 "usb.w" 3 4
	    0
#1757 "usb.w"
	    ;

    return
#1759 "usb.w" 3 4
	1
#1759 "usb.w"
	;
}

void CDC_Device_USBTask(USB_ClassInfo_CDC_Device_t *
			const CDCInterfaceInfo)
{
    if ((
#1764 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1764 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);

    if (Endpoint_IsINReady())
	CDC_Device_Flush(CDCInterfaceInfo);
}

uint8_t CDC_Device_SendString(USB_ClassInfo_CDC_Device_t *
			      const CDCInterfaceInfo,
			      const char *const String)
{
    if ((
#1777 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1777 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return ENDPOINT_RWSTREAM_DeviceDisconnected;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);
    return Endpoint_Write_Stream_LE(String, strlen(String),
#1782 "usb.w" 3 4
				    ((void *) 0)
#1782 "usb.w"
	);
}

uint8_t CDC_Device_SendString_P(USB_ClassInfo_CDC_Device_t *
				const CDCInterfaceInfo,
				const char *const String)
{
    if ((
#1788 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1788 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return ENDPOINT_RWSTREAM_DeviceDisconnected;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);
    return Endpoint_Write_PStream_LE(String, strlen_P(String),
#1793 "usb.w" 3 4
				     ((void *) 0)
#1793 "usb.w"
	);
}

uint8_t CDC_Device_SendData(USB_ClassInfo_CDC_Device_t *
			    const CDCInterfaceInfo,
			    const void *const Buffer,
			    const uint16_t Length)
{
    if ((
#1800 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1800 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return ENDPOINT_RWSTREAM_DeviceDisconnected;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);
    return Endpoint_Write_Stream_LE(Buffer, Length,
#1805 "usb.w" 3 4
				    ((void *) 0)
#1805 "usb.w"
	);
}

uint8_t CDC_Device_SendData_P(USB_ClassInfo_CDC_Device_t *
			      const CDCInterfaceInfo,
			      const void *const Buffer,
			      const uint16_t Length)
{
    if ((
#1812 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1812 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return ENDPOINT_RWSTREAM_DeviceDisconnected;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);
    return Endpoint_Write_PStream_LE(Buffer, Length,
#1817 "usb.w" 3 4
				     ((void *) 0)
#1817 "usb.w"
	);
}

uint8_t CDC_Device_SendByte(USB_ClassInfo_CDC_Device_t *
			    const CDCInterfaceInfo, const uint8_t Data)
{
    if ((
#1823 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1823 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return ENDPOINT_RWSTREAM_DeviceDisconnected;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);

    if (!(Endpoint_IsReadWriteAllowed())) {
	Endpoint_ClearIN();

	uint8_t ErrorCode;

	if ((ErrorCode =
	     Endpoint_WaitUntilReady()) != ENDPOINT_READYWAIT_NoError)
	    return ErrorCode;
    }

    Endpoint_Write_8(Data);
    return ENDPOINT_READYWAIT_NoError;
}

uint8_t CDC_Device_Flush(USB_ClassInfo_CDC_Device_t *
			 const CDCInterfaceInfo)
{
    if ((
#1845 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1845 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return ENDPOINT_RWSTREAM_DeviceDisconnected;

    uint8_t ErrorCode;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataINEndpoint.
			    Address);

    if (!(Endpoint_BytesInEndpoint()))
	return ENDPOINT_READYWAIT_NoError;

#1856 "usb.w" 3 4
    _Bool
#1856 "usb.w"
	BankFull = !(Endpoint_IsReadWriteAllowed());

    Endpoint_ClearIN();

    if (BankFull) {
	if ((ErrorCode =
	     Endpoint_WaitUntilReady()) != ENDPOINT_READYWAIT_NoError)
	    return ErrorCode;

	Endpoint_ClearIN();
    }

    return ENDPOINT_READYWAIT_NoError;
}

uint16_t CDC_Device_BytesReceived(USB_ClassInfo_CDC_Device_t *
				  const CDCInterfaceInfo)
{
    if ((
#1873 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1873 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return 0;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataOUTEndpoint.
			    Address);

    if (Endpoint_IsOUTReceived()) {
	if (!(Endpoint_BytesInEndpoint())) {
	    Endpoint_ClearOUT();
	    return 0;
	} else {
	    return Endpoint_BytesInEndpoint();
	}
    } else {
	return 0;
    }
}

int16_t CDC_Device_ReceiveByte(USB_ClassInfo_CDC_Device_t *
			       const CDCInterfaceInfo)
{
    if ((
#1899 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1899 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return -1;

    int16_t ReceivedByte = -1;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.DataOUTEndpoint.
			    Address);

    if (Endpoint_IsOUTReceived()) {
	if (Endpoint_BytesInEndpoint())
	    ReceivedByte = Endpoint_Read_8();

	if (!(Endpoint_BytesInEndpoint()))
	    Endpoint_ClearOUT();
    }

    return ReceivedByte;
}

void CDC_Device_SendControlLineStateChange(USB_ClassInfo_CDC_Device_t *
					   const CDCInterfaceInfo)
{
    if ((
#1921 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#1921 "usb.w"
	    != DEVICE_STATE_Configured) ||
	!(CDCInterfaceInfo->State.LineEncoding.BaudRateBPS))
	return;

    Endpoint_SelectEndpoint(CDCInterfaceInfo->Config.NotificationEndpoint.
			    Address);

    USB_Request_Header_t Notification = (USB_Request_Header_t) {
	.bmRequestType = ((1 << 7) | (1 << 5) | (1 << 0)),
	.bRequest = CDC_NOTIF_SerialState,
	.wValue = (0),
	.wIndex = (0),
	.wLength =
	    (sizeof
	     (CDCInterfaceInfo->State.ControlLineStates.DeviceToHost)),
    };

    Endpoint_Write_Stream_LE(&Notification, sizeof(USB_Request_Header_t),
#1937 "usb.w" 3 4
			     ((void *) 0)
#1937 "usb.w"
	);
    Endpoint_Write_Stream_LE(&CDCInterfaceInfo->State.ControlLineStates.
			     DeviceToHost,
			     sizeof(CDCInterfaceInfo->State.
				    ControlLineStates.DeviceToHost),
#1940 "usb.w" 3 4
			     ((void *) 0)
#1940 "usb.w"
	);
    Endpoint_ClearIN();
}

void CDC_Device_CreateStream(USB_ClassInfo_CDC_Device_t *
			     const CDCInterfaceInfo, FILE * const Stream)
{
    *Stream = (FILE)
#1947 "usb.w" 3
    {
	.put =
#1947 "usb.w"
	    CDC_Device_putchar
#1947 "usb.w" 3
	    ,.get =
#1947 "usb.w"
	    CDC_Device_getchar
#1947 "usb.w" 3
    ,.flags = (0x0001 | 0x0002),.udata = 0,}
#1947 "usb.w"
    ;

#1948 "usb.w" 3
    do {
	(
#1948 "usb.w"
	    Stream
#1948 "usb.w" 3
	    )->udata =
#1948 "usb.w"
	    CDCInterfaceInfo
#1948 "usb.w" 3
	    ;
    } while (0)
#1948 "usb.w"
    ;
}

void CDC_Device_CreateBlockingStream(USB_ClassInfo_CDC_Device_t *
				     const CDCInterfaceInfo,
				     FILE * const Stream)
{
    *Stream = (FILE)
#1954 "usb.w" 3
    {
	.put =
#1954 "usb.w"
	    CDC_Device_putchar
#1954 "usb.w" 3
	    ,.get =
#1954 "usb.w"
	    CDC_Device_getchar_Blocking
#1954 "usb.w" 3
    ,.flags = (0x0001 | 0x0002),.udata = 0,}

#1955 "usb.w"
    ;

#1956 "usb.w" 3
    do {
	(
#1956 "usb.w"
	    Stream
#1956 "usb.w" 3
	    )->udata =
#1956 "usb.w"
	    CDCInterfaceInfo
#1956 "usb.w" 3
	    ;
    } while (0)
#1956 "usb.w"
    ;
}

static int CDC_Device_putchar(char c, FILE * Stream)
{
    return CDC_Device_SendByte((USB_ClassInfo_CDC_Device_t *)
#1962 "usb.w" 3
			       ((
#1962 "usb.w"
				    Stream
#1962 "usb.w" 3
				)->udata)
#1962 "usb.w"
			       , c) ?
#1963 "usb.w" 3
	(-1)
#1963 "usb.w"
	: 0;
}

static int CDC_Device_getchar(FILE * Stream)
{
    int16_t ReceivedByte =
	CDC_Device_ReceiveByte((USB_ClassInfo_CDC_Device_t *)
#1969 "usb.w" 3
			       ((
#1969 "usb.w"
				    Stream
#1969 "usb.w" 3
				)->udata)
#1969 "usb.w"
	);

    if (ReceivedByte < 0)
	return
#1972 "usb.w" 3
	    (-2)
#1972 "usb.w"
	    ;

    return ReceivedByte;
}

static int CDC_Device_getchar_Blocking(FILE * Stream)
{
    int16_t ReceivedByte;

    while ((ReceivedByte =
	    CDC_Device_ReceiveByte((USB_ClassInfo_CDC_Device_t *)
#1982 "usb.w" 3
				   ((
#1982 "usb.w"
					Stream
#1982 "usb.w" 3
				    )->udata)
#1982 "usb.w"
	    )) < 0) {
	if (
#1984 "usb.w" 3
	       (*(volatile uint8_t *) ((0x1E) + 0x20))
#1984 "usb.w"
	       == DEVICE_STATE_Unattached)
	    return
#1985 "usb.w" 3
		(-2)
#1985 "usb.w"
		;

	CDC_Device_USBTask((USB_ClassInfo_CDC_Device_t *)
#1987 "usb.w" 3
			   ((
#1987 "usb.w"
				Stream
#1987 "usb.w" 3
			    )->udata)
#1987 "usb.w"
	    );
	USB_USBTask();
    }

    return ReceivedByte;
}

void CDC_Device_Event_Stub(void)
{

}

#2010 "usb.w"

uint8_t USB_Device_ConfigurationNumber;

#2013 "usb.w" 3 4
_Bool
#2013 "usb.w"
    USB_Device_CurrentlySelfPowered;

#2015 "usb.w" 3 4
_Bool
#2015 "usb.w"
    USB_Device_RemoteWakeupEnabled;

void USB_Device_ProcessControlRequest(void)
{
    uint8_t *RequestHeader = (uint8_t *) & USB_ControlRequest;

    for (uint8_t RequestHeaderByte = 0;
	 RequestHeaderByte < sizeof(USB_Request_Header_t);
	 RequestHeaderByte++)
	*(RequestHeader++) = Endpoint_Read_8();

    EVENT_USB_Device_ControlRequest();

    if (Endpoint_IsSETUPReceived()) {
	uint8_t bmRequestType = USB_ControlRequest.bmRequestType;

	switch (USB_ControlRequest.bRequest) {
	case REQ_GetStatus:
	    if ((bmRequestType == ((1 << 7) | (0 << 5) | (0 << 0))) ||
		(bmRequestType == ((1 << 7) | (0 << 5) | (2 << 0))))
		USB_Device_GetStatus();

	    break;
	case REQ_ClearFeature:
	case REQ_SetFeature:
	    if ((bmRequestType == ((0 << 7) | (0 << 5) | (0 << 0))) ||
		(bmRequestType == ((0 << 7) | (0 << 5) | (2 << 0))))
		USB_Device_ClearSetFeature();
	    break;
	case REQ_SetAddress:
	    if (bmRequestType == ((0 << 7) | (0 << 5) | (0 << 0)))
		USB_Device_SetAddress();
	    break;
	case REQ_GetDescriptor:
	    if ((bmRequestType == ((1 << 7) | (0 << 5) | (0 << 0))) ||
		(bmRequestType == ((1 << 7) | (0 << 5) | (1 << 0))))
		USB_Device_GetDescriptor();
	    break;
	case REQ_GetConfiguration:
	    if (bmRequestType == ((1 << 7) | (0 << 5) | (0 << 0)))
		USB_Device_GetConfiguration();
	    break;
	case REQ_SetConfiguration:
	    if (bmRequestType == ((0 << 7) | (0 << 5) | (0 << 0)))
		USB_Device_SetConfiguration();
	    break;
	default:
	    break;
	}
    }

    if (Endpoint_IsSETUPReceived()) {
	Endpoint_ClearSETUP();
	Endpoint_StallTransaction();
    }
}

static void USB_Device_SetAddress(void)
{
    uint8_t DeviceAddress = (USB_ControlRequest.wValue & 0x7F);

    USB_Device_SetDeviceAddress(DeviceAddress);

    Endpoint_ClearSETUP();

    Endpoint_ClearStatusStage();

    while (!(Endpoint_IsINReady()));

    USB_Device_EnableDeviceAddress(DeviceAddress);

#2085 "usb.w" 3
    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2085 "usb.w"
	= (DeviceAddress) ? DEVICE_STATE_Addressed : DEVICE_STATE_Default;
}

static void USB_Device_SetConfiguration(void)
{
    if ((uint8_t) USB_ControlRequest.wValue > 1)
	return;

    Endpoint_ClearSETUP();

    USB_Device_ConfigurationNumber = (uint8_t) USB_ControlRequest.wValue;

    Endpoint_ClearStatusStage();

    if (USB_Device_ConfigurationNumber)
#2100 "usb.w" 3
	(*(volatile uint8_t *) ((0x1E) + 0x20))
#2100 "usb.w"
	    = DEVICE_STATE_Configured;
    else
#2102 "usb.w" 3
	(*(volatile uint8_t *) ((0x1E) + 0x20))
#2102 "usb.w"
	    = (USB_Device_IsAddressSet())? DEVICE_STATE_Configured :
	    DEVICE_STATE_Powered;

    EVENT_USB_Device_ConfigurationChanged();
}

static void USB_Device_GetConfiguration(void)
{
    Endpoint_ClearSETUP();

    Endpoint_Write_8(USB_Device_ConfigurationNumber);
    Endpoint_ClearIN();

    Endpoint_ClearStatusStage();
}

static void USB_Device_GetInternalSerialDescriptor(void)
{
    struct {
	USB_Descriptor_Header_t Header;
	uint16_t UnicodeString[80 / 4];
    } SignatureDescriptor;

    SignatureDescriptor.Header.Type = DTYPE_String;
    SignatureDescriptor.Header.Size =
	(sizeof(USB_Descriptor_Header_t) + ((80 / 4) << 1));

    USB_Device_GetSerialString(SignatureDescriptor.UnicodeString);

    Endpoint_ClearSETUP();

    Endpoint_Write_Control_Stream_LE(&SignatureDescriptor,
				     sizeof(SignatureDescriptor));
    Endpoint_ClearOUT();
}

static void USB_Device_GetDescriptor(void)
{
    const void *DescriptorPointer;
    uint16_t DescriptorSize;

    if (USB_ControlRequest.wValue == ((DTYPE_String << 8) | 0xDC)) {
	USB_Device_GetInternalSerialDescriptor();
	return;
    }

    if ((DescriptorSize =
	 CALLBACK_USB_GetDescriptor(USB_ControlRequest.wValue,
				    USB_ControlRequest.wIndex,
				    &DescriptorPointer)) == 0)
	return;

    Endpoint_ClearSETUP();

    Endpoint_Write_Control_PStream_LE(DescriptorPointer, DescriptorSize);

    Endpoint_ClearOUT();
}

static void USB_Device_GetStatus(void)
{
    uint8_t CurrentStatus = 0;

    switch (USB_ControlRequest.bmRequestType) {
    case ((1 << 7) | (0 << 5) | (0 << 0)):
	{
	    if (USB_Device_CurrentlySelfPowered)
		CurrentStatus |= (1 << 0);

	    if (USB_Device_RemoteWakeupEnabled)
		CurrentStatus |= (1 << 1);
	    break;
	}
    case ((1 << 7) | (0 << 5) | (2 << 0)):
	{
	    uint8_t EndpointIndex =
		((uint8_t) USB_ControlRequest.wIndex & 0x0F);

	    if (EndpointIndex >= 7)
		return;

	    Endpoint_SelectEndpoint(EndpointIndex);

	    CurrentStatus = Endpoint_IsStalled();

	    Endpoint_SelectEndpoint(0);

	    break;
	}
    default:
	return;
    }

    Endpoint_ClearSETUP();

    Endpoint_Write_16_LE(CurrentStatus);
    Endpoint_ClearIN();

    Endpoint_ClearStatusStage();
}

static void USB_Device_ClearSetFeature(void)
{
    switch (USB_ControlRequest.bmRequestType & 0x1F) {
    case (0 << 0):
	{
	    if ((uint8_t) USB_ControlRequest.wValue ==
		FEATURE_SEL_DeviceRemoteWakeup)
		USB_Device_RemoteWakeupEnabled =
		    (USB_ControlRequest.bRequest == REQ_SetFeature);
	    else
		return;
	    break;
	}
    case (2 << 0):
	{
	    if ((uint8_t) USB_ControlRequest.wValue ==
		FEATURE_SEL_EndpointHalt) {
		uint8_t EndpointIndex =
		    ((uint8_t) USB_ControlRequest.wIndex & 0x0F);

		if (EndpointIndex == 0 || EndpointIndex >= 7)
		    return;

		Endpoint_SelectEndpoint(EndpointIndex);

		if (Endpoint_IsEnabled()) {
		    if (USB_ControlRequest.bRequest == REQ_SetFeature)
			Endpoint_StallTransaction();
		    else {
			Endpoint_ClearStall();
			Endpoint_ResetEndpoint(EndpointIndex);
			Endpoint_ResetDataToggle();
		    }
		}
	    }
	    break;
	}
    default:
	return;
    }

    Endpoint_SelectEndpoint(0);

    Endpoint_ClearSETUP();

    Endpoint_ClearStatusStage();
}

#2247 "usb.w"

uint8_t Endpoint_Discard_Stream(uint16_t Length,
				uint16_t * const BytesProcessed)
{
    uint8_t ErrorCode;
    uint16_t BytesInTransfer = 0;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2257 "usb.w" 3 4
	((void *) 0)
#2257 "usb.w"
	)
	Length -= *BytesProcessed;

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearOUT();

	    if (BytesProcessed !=
#2266 "usb.w" 3 4
		((void *) 0)
#2266 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Discard_8();

	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Null_Stream(uint16_t Length,
			     uint16_t * const BytesProcessed)
{
    uint8_t ErrorCode;
    uint16_t BytesInTransfer = 0;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2296 "usb.w" 3 4
	((void *) 0)
#2296 "usb.w"
	)
	Length -= *BytesProcessed;

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2305 "usb.w" 3 4
		((void *) 0)
#2305 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(0);

	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_Stream_LE(const void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2337 "usb.w" 3 4
	((void *) 0)
#2337 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream += *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2353 "usb.w" 3 4
		((void *) 0)
#2353 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(*DataStream);
	    DataStream += 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_Stream_BE(const void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2385 "usb.w" 3 4
	((void *) 0)
#2385 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream -= *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2401 "usb.w" 3 4
		((void *) 0)
#2401 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(*DataStream);
	    DataStream -= 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_Stream_LE(void *const Buffer,
				uint16_t Length,
				uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2433 "usb.w" 3 4
	((void *) 0)
#2433 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream += *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearOUT();

	    if (BytesProcessed !=
#2449 "usb.w" 3 4
		((void *) 0)
#2449 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    *DataStream = Endpoint_Read_8();
	    DataStream += 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_Stream_BE(void *const Buffer,
				uint16_t Length,
				uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2481 "usb.w" 3 4
	((void *) 0)
#2481 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream -= *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearOUT();

	    if (BytesProcessed !=
#2497 "usb.w" 3 4
		((void *) 0)
#2497 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    *DataStream = Endpoint_Read_8();
	    DataStream -= 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_PStream_LE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2529 "usb.w" 3 4
	((void *) 0)
#2529 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream += *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2545 "usb.w" 3 4
		((void *) 0)
#2545 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(
#2556 "usb.w" 3
				(__extension__( {
					       uint16_t __addr16 =
					       (uint16_t) ((uint16_t) (
#2556 "usb.w"
									     DataStream
#2556 "usb.w" 3
							   ));
					       uint8_t __result;
	      __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
					       __result;
					       }
				 ))
#2556 "usb.w"
		);
	    DataStream += 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_PStream_BE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2577 "usb.w" 3 4
	((void *) 0)
#2577 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream -= *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2593 "usb.w" 3 4
		((void *) 0)
#2593 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(
#2604 "usb.w" 3
				(__extension__( {
					       uint16_t __addr16 =
					       (uint16_t) ((uint16_t) (
#2604 "usb.w"
									     DataStream
#2604 "usb.w" 3
							   ));
					       uint8_t __result;
	      __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
					       __result;
					       }
				 ))
#2604 "usb.w"
		);
	    DataStream -= 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_EStream_LE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2625 "usb.w" 3 4
	((void *) 0)
#2625 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream += *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2641 "usb.w" 3 4
		((void *) 0)
#2641 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(eeprom_read_byte(DataStream));
	    DataStream += 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_EStream_BE(const void *const Buffer,
				  uint16_t Length,
				  uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2673 "usb.w" 3 4
	((void *) 0)
#2673 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream -= *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearIN();

	    if (BytesProcessed !=
#2689 "usb.w" 3 4
		((void *) 0)
#2689 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    Endpoint_Write_8(eeprom_read_byte(DataStream));
	    DataStream -= 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_EStream_LE(void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2721 "usb.w" 3 4
	((void *) 0)
#2721 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream += *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearOUT();

	    if (BytesProcessed !=
#2737 "usb.w" 3 4
		((void *) 0)
#2737 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    eeprom_update_byte(DataStream, Endpoint_Read_8());
	    DataStream += 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Read_EStream_BE(void *const Buffer,
				 uint16_t Length,
				 uint16_t * const BytesProcessed)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));
    uint16_t BytesInTransfer = 0;
    uint8_t ErrorCode;

    if ((ErrorCode = Endpoint_WaitUntilReady()))
	return ErrorCode;

    if (BytesProcessed !=
#2769 "usb.w" 3 4
	((void *) 0)
#2769 "usb.w"
	) {
	Length -= *BytesProcessed;
	DataStream -= *BytesProcessed;
    }

    while (Length) {
	if (!(Endpoint_IsReadWriteAllowed())) {
	    Endpoint_ClearOUT();

	    if (BytesProcessed !=
#2785 "usb.w" 3 4
		((void *) 0)
#2785 "usb.w"
		) {
		*BytesProcessed += BytesInTransfer;
		return ENDPOINT_RWSTREAM_IncompleteTransfer;
	    }

	    if ((ErrorCode = Endpoint_WaitUntilReady()))
		return ErrorCode;
	} else {
	    eeprom_update_byte(DataStream, Endpoint_Read_8());
	    DataStream -= 1;
	    Length--;
	    BytesInTransfer++;
	}
    }

    return ENDPOINT_RWSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_Stream_LE(const void *const Buffer,
					 uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);

#2810 "usb.w" 3 4
    _Bool
#2810 "usb.w"
	LastPacketFull =
#2810 "usb.w" 3 4
	0
#2810 "usb.w"
	;

    if (Length > USB_ControlRequest.wLength)
	Length = USB_ControlRequest.wLength;
    else if (!(Length))
	Endpoint_ClearIN();

    while (Length || LastPacketFull) {
	uint8_t USB_DeviceState_LCL =
#2819 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2819 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
	else if (Endpoint_IsOUTReceived())
	    break;

	if (Endpoint_IsINReady()) {
	    uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

	    while (Length && (BytesInEndpoint < 8)) {
		Endpoint_Write_8(*DataStream);
		DataStream += 1;
		Length--;
		BytesInEndpoint++;
	    }

	    LastPacketFull = (BytesInEndpoint == 8);
	    Endpoint_ClearIN();
	}
    }

    while (!(Endpoint_IsOUTReceived())) {
	uint8_t USB_DeviceState_LCL =
#2849 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2849 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_Stream_BE(const void *const Buffer,
					 uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));

#2866 "usb.w" 3 4
    _Bool
#2866 "usb.w"
	LastPacketFull =
#2866 "usb.w" 3 4
	0
#2866 "usb.w"
	;

    if (Length > USB_ControlRequest.wLength)
	Length = USB_ControlRequest.wLength;
    else if (!(Length))
	Endpoint_ClearIN();

    while (Length || LastPacketFull) {
	uint8_t USB_DeviceState_LCL =
#2875 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2875 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
	else if (Endpoint_IsOUTReceived())
	    break;

	if (Endpoint_IsINReady()) {
	    uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

	    while (Length && (BytesInEndpoint < 8)) {
		Endpoint_Write_8(*DataStream);
		DataStream -= 1;
		Length--;
		BytesInEndpoint++;
	    }

	    LastPacketFull = (BytesInEndpoint == 8);
	    Endpoint_ClearIN();
	}
    }

    while (!(Endpoint_IsOUTReceived())) {
	uint8_t USB_DeviceState_LCL =
#2905 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2905 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_Stream_LE(void *const Buffer,
					uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);

    if (!(Length))
	Endpoint_ClearOUT();

    while (Length) {
	uint8_t USB_DeviceState_LCL =
#2927 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2927 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;

	if (Endpoint_IsOUTReceived()) {
	    while (Length && Endpoint_BytesInEndpoint()) {
		*DataStream = Endpoint_Read_8();
		DataStream += 1;
		Length--;
	    }

	    Endpoint_ClearOUT();
	}
    }

    while (!(Endpoint_IsINReady())) {
	uint8_t USB_DeviceState_LCL =
#2951 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2951 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_Stream_BE(void *const Buffer,
					uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));

    if (!(Length))
	Endpoint_ClearOUT();

    while (Length) {
	uint8_t USB_DeviceState_LCL =
#2971 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2971 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;

	if (Endpoint_IsOUTReceived()) {
	    while (Length && Endpoint_BytesInEndpoint()) {
		*DataStream = Endpoint_Read_8();
		DataStream -= 1;
		Length--;
	    }

	    Endpoint_ClearOUT();
	}
    }

    while (!(Endpoint_IsINReady())) {
	uint8_t USB_DeviceState_LCL =
#2995 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#2995 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_PStream_LE(const void *const Buffer,
					  uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);

#3010 "usb.w" 3 4
    _Bool
#3010 "usb.w"
	LastPacketFull =
#3010 "usb.w" 3 4
	0
#3010 "usb.w"
	;

    if (Length > USB_ControlRequest.wLength)
	Length = USB_ControlRequest.wLength;
    else if (!(Length))
	Endpoint_ClearIN();

    while (Length || LastPacketFull) {
	uint8_t USB_DeviceState_LCL =
#3019 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3019 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
	else if (Endpoint_IsOUTReceived())
	    break;

	if (Endpoint_IsINReady()) {
	    uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

	    while (Length && (BytesInEndpoint < 8)) {
		Endpoint_Write_8(
#3036 "usb.w" 3
				    (__extension__( {
						   uint16_t __addr16 =
						   (uint16_t) ((uint16_t) (
#3036 "usb.w"
										 DataStream
#3036 "usb.w" 3
							       ));
						   uint8_t __result;
		  __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
						   __result;
						   }
				     ))
#3036 "usb.w"
		    );
		DataStream += 1;
		Length--;
		BytesInEndpoint++;
	    }

	    LastPacketFull = (BytesInEndpoint == 8);
	    Endpoint_ClearIN();
	}
    }

    while (!(Endpoint_IsOUTReceived())) {
	uint8_t USB_DeviceState_LCL =
#3049 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3049 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_PStream_BE(const void *const Buffer,
					  uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));

#3066 "usb.w" 3 4
    _Bool
#3066 "usb.w"
	LastPacketFull =
#3066 "usb.w" 3 4
	0
#3066 "usb.w"
	;

    if (Length > USB_ControlRequest.wLength)
	Length = USB_ControlRequest.wLength;
    else if (!(Length))
	Endpoint_ClearIN();

    while (Length || LastPacketFull) {
	uint8_t USB_DeviceState_LCL =
#3075 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3075 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
	else if (Endpoint_IsOUTReceived())
	    break;

	if (Endpoint_IsINReady()) {
	    uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

	    while (Length && (BytesInEndpoint < 8)) {
		Endpoint_Write_8(
#3092 "usb.w" 3
				    (__extension__( {
						   uint16_t __addr16 =
						   (uint16_t) ((uint16_t) (
#3092 "usb.w"
										 DataStream
#3092 "usb.w" 3
							       ));
						   uint8_t __result;
		  __asm__ __volatile__("lpm %0, Z" "\n\t": "=r"(__result):"z"(__addr16));
						   __result;
						   }
				     ))
#3092 "usb.w"
		    );
		DataStream -= 1;
		Length--;
		BytesInEndpoint++;
	    }

	    LastPacketFull = (BytesInEndpoint == 8);
	    Endpoint_ClearIN();
	}
    }

    while (!(Endpoint_IsOUTReceived())) {
	uint8_t USB_DeviceState_LCL =
#3105 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3105 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_EStream_LE(const void *const Buffer,
					  uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);

#3122 "usb.w" 3 4
    _Bool
#3122 "usb.w"
	LastPacketFull =
#3122 "usb.w" 3 4
	0
#3122 "usb.w"
	;

    if (Length > USB_ControlRequest.wLength)
	Length = USB_ControlRequest.wLength;
    else if (!(Length))
	Endpoint_ClearIN();

    while (Length || LastPacketFull) {
	uint8_t USB_DeviceState_LCL =
#3131 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3131 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
	else if (Endpoint_IsOUTReceived())
	    break;

	if (Endpoint_IsINReady()) {
	    uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

	    while (Length && (BytesInEndpoint < 8)) {
		Endpoint_Write_8(eeprom_read_byte(DataStream));
		DataStream += 1;
		Length--;
		BytesInEndpoint++;
	    }

	    LastPacketFull = (BytesInEndpoint == 8);
	    Endpoint_ClearIN();
	}
    }

    while (!(Endpoint_IsOUTReceived())) {
	uint8_t USB_DeviceState_LCL =
#3161 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3161 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Write_Control_EStream_BE(const void *const Buffer,
					  uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));

#3178 "usb.w" 3 4
    _Bool
#3178 "usb.w"
	LastPacketFull =
#3178 "usb.w" 3 4
	0
#3178 "usb.w"
	;

    if (Length > USB_ControlRequest.wLength)
	Length = USB_ControlRequest.wLength;
    else if (!(Length))
	Endpoint_ClearIN();

    while (Length || LastPacketFull) {
	uint8_t USB_DeviceState_LCL =
#3187 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3187 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
	else if (Endpoint_IsOUTReceived())
	    break;

	if (Endpoint_IsINReady()) {
	    uint16_t BytesInEndpoint = Endpoint_BytesInEndpoint();

	    while (Length && (BytesInEndpoint < 8)) {
		Endpoint_Write_8(eeprom_read_byte(DataStream));
		DataStream -= 1;
		Length--;
		BytesInEndpoint++;
	    }

	    LastPacketFull = (BytesInEndpoint == 8);
	    Endpoint_ClearIN();
	}
    }

    while (!(Endpoint_IsOUTReceived())) {
	uint8_t USB_DeviceState_LCL =
#3217 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3217 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_EStream_LE(void *const Buffer,
					 uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + 0);

    if (!(Length))
	Endpoint_ClearOUT();

    while (Length) {
	uint8_t USB_DeviceState_LCL =
#3239 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3239 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;

	if (Endpoint_IsOUTReceived()) {
	    while (Length && Endpoint_BytesInEndpoint()) {
		eeprom_update_byte(DataStream, Endpoint_Read_8());
		DataStream += 1;
		Length--;
	    }

	    Endpoint_ClearOUT();
	}
    }

    while (!(Endpoint_IsINReady())) {
	uint8_t USB_DeviceState_LCL =
#3263 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3263 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}

uint8_t Endpoint_Read_Control_EStream_BE(void *const Buffer,
					 uint16_t Length)
{
    uint8_t *DataStream = ((uint8_t *) Buffer + (Length - 1));

    if (!(Length))
	Endpoint_ClearOUT();

    while (Length) {
	uint8_t USB_DeviceState_LCL =
#3283 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3283 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
	else if (Endpoint_IsSETUPReceived())
	    return ENDPOINT_RWCSTREAM_HostAborted;

	if (Endpoint_IsOUTReceived()) {
	    while (Length && Endpoint_BytesInEndpoint()) {
		eeprom_update_byte(DataStream, Endpoint_Read_8());
		DataStream -= 1;
		Length--;
	    }

	    Endpoint_ClearOUT();
	}
    }

    while (!(Endpoint_IsINReady())) {
	uint8_t USB_DeviceState_LCL =
#3307 "usb.w" 3
	    (*(volatile uint8_t *) ((0x1E) + 0x20))
#3307 "usb.w"
	    ;

	if (USB_DeviceState_LCL == DEVICE_STATE_Unattached)
	    return ENDPOINT_RWCSTREAM_DeviceDisconnected;
	else if (USB_DeviceState_LCL == DEVICE_STATE_Suspended)
	    return ENDPOINT_RWCSTREAM_BusSuspended;
    }

    return ENDPOINT_RWCSTREAM_NoError;
}
