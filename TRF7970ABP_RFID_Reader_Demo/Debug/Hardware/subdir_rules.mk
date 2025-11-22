################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

# Each subdirectory must supply rules for building sources it contributes
Hardware/%.obj: ../Hardware/%.asm $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: MSP430 Compiler'
	"C:/ti/ccs1040/ccs/tools/compiler/msp430_4.3.3/bin/cl430" -vmsp --abi=coffabi -O3 --opt_for_speed=0 --include_path="C:/ti/ccs1040/ccs/ccs_base/msp430/include" --include_path="C:/ti/ccs1040/ccs/tools/compiler/msp430_4.3.3/include" --include_path="C:/Users/suvan/Documents/College/Bring-Up/Repo/nfc_firmware/TRF7970ABP_RFID_Reader_Demo/NFC" --include_path="C:/Users/suvan/Documents/College/Bring-Up/Repo/nfc_firmware/TRF7970ABP_RFID_Reader_Demo/Hardware" -g --define=__MSP430G2553__ --diag_warning=225 --display_error_number --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --printf_support=minimal --preproc_with_compile --preproc_dependency="Hardware/$(basename $(<F)).d_raw" --obj_directory="Hardware" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

Hardware/%.obj: ../Hardware/%.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: MSP430 Compiler'
	"C:/ti/ccs1040/ccs/tools/compiler/msp430_4.3.3/bin/cl430" -vmsp --abi=coffabi -O3 --opt_for_speed=0 --include_path="C:/ti/ccs1040/ccs/ccs_base/msp430/include" --include_path="C:/ti/ccs1040/ccs/tools/compiler/msp430_4.3.3/include" --include_path="C:/Users/suvan/Documents/College/Bring-Up/Repo/nfc_firmware/TRF7970ABP_RFID_Reader_Demo/NFC" --include_path="C:/Users/suvan/Documents/College/Bring-Up/Repo/nfc_firmware/TRF7970ABP_RFID_Reader_Demo/Hardware" -g --define=__MSP430G2553__ --diag_warning=225 --display_error_number --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --printf_support=minimal --preproc_with_compile --preproc_dependency="Hardware/$(basename $(<F)).d_raw" --obj_directory="Hardware" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '


