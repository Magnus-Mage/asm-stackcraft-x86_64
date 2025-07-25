.intel_syntax noprefix

SYS_WRITE	=	1	# write out to stdout
STDOUT		=	1	# standard output
SYS_READ	=	0	# read from stdin
STDIN		=	0	# standard read
SYS_EXIT	=	60	# terminate the program
MAX_STRING_SIZE	=	64	# String size of 63 with last character for null terminator
MAX_STRINGS	=	20
 
#------------------------------------
# @brief Sorting strings from input

# @brief Prompts and output strings
.section .data
	input_prompt		:	.asciz	"Enter the number of strings: "    
	input_prompt_len	=	. - input_prompt - 1

	string_prompt		:	.asciz	"Enter String: "
	string_prompt_len	=	. - string_prompt - 1

	output_msg		:	.asciz	"Sorted strings:\n"
	output_msg_len		=	. - output_msg - 1

	newline			:	.asciz	"\n"
	buffer			:	.space 64			# Input buffer for reading strings
	num_buffer		: 	.space 16			# Buffer for number conversion

#-------------------------------------
# @brief buffers for storing strings
.section .bss
	string_count		:	.space 4			# Number of strings
	# Array of string pointers (each pointer is 8 bytes)
	string_ptrs		:	.space 160			# 20 strings * 8 bytes = 160 bytes
	# Storage for actual strings
	string_storage		:	.space 1280			# 20 strings * 64 bytes = 1280 bytes

#-------------------------------------
# @brief Instruction set for main logic
.section .text
	.global _start

_start:
	# Print input prompt for number of strings
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, input_prompt
	mov rdx, input_prompt_len
	syscall








# @brief Exit_Code
exit_code:
	xor edi, edi
	mov rax, SYS_EXIT	
	syscall	
