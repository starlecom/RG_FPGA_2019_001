################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
amp_fsbl.elf.size \


# All Target
all: amp_fsbl.elf secondary-outputs

# Tool invocations
amp_fsbl.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM gcc linker'
	arm-xilinx-eabi-gcc -L"F:\Project\RG-2018-YF-001\FPGA\YF-012-V2.1-FPGA\YF-012-V1.0-FPGA\YF-012-V1.0-FPGA.sdk\amp_fsbl\src" -Wl,-T -Wl,../src/lscript.ld -L../../amp_fsbl_bsp/ps7_cortexa9_0/lib -o "amp_fsbl.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

amp_fsbl.elf.size: amp_fsbl.elf
	@echo 'Invoking: ARM Print Size'
	arm-xilinx-eabi-size amp_fsbl.elf  |tee "amp_fsbl.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) amp_fsbl.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
