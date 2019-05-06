################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/core1_start.c \
../src/dma_intr.c \
../src/gpio_dev.c \
../src/lwip_mod.c \
../src/main.c \
../src/platform.c \
../src/ps7_init.c \
../src/shared_mem.c \
../src/software_intr.c \
../src/sys_intr.c \
../src/timer_intr.c \
../src/xqspips_flash.c 

OBJS += \
./src/core1_start.o \
./src/dma_intr.o \
./src/gpio_dev.o \
./src/lwip_mod.o \
./src/main.o \
./src/platform.o \
./src/ps7_init.o \
./src/shared_mem.o \
./src/software_intr.o \
./src/sys_intr.o \
./src/timer_intr.o \
./src/xqspips_flash.o 

C_DEPS += \
./src/core1_start.d \
./src/dma_intr.d \
./src/gpio_dev.d \
./src/lwip_mod.d \
./src/main.d \
./src/platform.d \
./src/ps7_init.d \
./src/shared_mem.d \
./src/software_intr.d \
./src/sys_intr.d \
./src/timer_intr.d \
./src/xqspips_flash.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../standalone_bsp_0/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


