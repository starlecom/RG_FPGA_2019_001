################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/filter.c \
../src/main.c \
../src/pl_timer.c \
../src/platform.c \
../src/shared_mem.c \
../src/software_intr.c \
../src/sys_intr.c \
../src/xadc_dev.c 

OBJS += \
./src/filter.o \
./src/main.o \
./src/pl_timer.o \
./src/platform.o \
./src/shared_mem.o \
./src/software_intr.o \
./src/sys_intr.o \
./src/xadc_dev.o 

C_DEPS += \
./src/filter.d \
./src/main.d \
./src/pl_timer.d \
./src/platform.d \
./src/shared_mem.d \
./src/software_intr.d \
./src/sys_intr.d \
./src/xadc_dev.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../app_cpu1_bsp/ps7_cortexa9_1/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


