# Subdirectory make stuff

include Libraries/lib.mk
include Modules/modules.mk 
include Device/device.mk
include Drivers/drivers.mk

# Compiler stuff
TRGT = arm-none-eabi-
CC   = $(TRGT)gcc
CPPC = $(TRGT)g++
# Enable loading with g++ only if you need C++ runtime support.
# NOTE: You can use C++ even without C++ support if you are careful. C++
#       runtime support makes code size explode.
LD   = $(TRGT)gcc
#LD   = $(TRGT)g++
CP   = $(TRGT)objcopy
AS   = $(TRGT)gcc -x assembler-with-cpp
AR   = $(TRGT)ar
OD   = $(TRGT)objdump
SZ   = $(TRGT)size
HEX  = $(CP) -O ihex
BIN  = $(CP) -O binary

# Define C warning options here
CWARN = -Wall -Wextra -Wundef -Wstrict-prototypes -Wshadow
# Define extra C flags here

CFLAGS = -T $(LDSCRIPT) -mthumb -mcpu=$(MCU) -D STM32F303xC -D USE_HAL_DRIVER

# Architecture specific stuff - linker script and architecture
LDSCRIPT= CubeMX/STM32F303CC_FLASH.ld
MCU  = cortex-m4

ASMSRC = $(STARTUPASM)

CSRC := 	$(DEVICE_SRC) \
		$(LIB_SRC) \
		$(MOD_SRC) \
		$(HWDRIVER_SRC) \
		$(SWDRIVER_SRC) \
		$(HAL_SRC) \
		Main/main.c

INCDIR = Main \
		$(LIB_INC) \
		$(MOD_INC) \
		$(HWDRIVER_INC) \
		$(SWDRIVER_INC) \
		$(HAL_INC) \
		CubeMX/Drivers/CMSIS/Device/ST/STM32F3xx/Include

IINCDIR   = $(patsubst %,-I%,$(INCDIR))

all: DieBieBMS-firmware.bin DieBieBMS-firmware.elf

DieBieBMS-firmware.bin: DieBieBMS-firmware.elf
	$(BIN) DieBieBMS-firmware.elf DieBieBMS-firmware.bin --gap-fill 0xFF

DieBieBMS-firmware.elf: $(CSRC)
	$(CC) $(CWARN) $(CFLAGS) $(ASMSRC) $(CSRC) $(IINCDIR) --specs=nosys.specs -o $@