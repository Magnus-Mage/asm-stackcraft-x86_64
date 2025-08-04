.intel_syntax noprefix

SYS_WRITE 	=	1	# Write out to stdout
STDOUT		=	1	# Standard Output
SYS_READ	=	0	# Read from stdin
STDIN		=	0	# Standard Read
SYS_EXIT	=	60	# terminate the program
MAX_STRING_SIZE	=	64	# string size of 63 with last character being null terminator
MAX_STRINGS	=	20

#--------------------------------
# @brief Sorting Strings from input using TIM SORT

# @brief Prompts and output strings
.section .data
	input_prompt		:	.asciz "Enter the number of strings: "
	input_prompt_len	=	. - input_prompt - 1
	
	string_prompt		:	.asciz "Enter String: "
	string_prompt_len	=	. - string_prompt - 1

	output_msg		:	.asciz "Sorted Strings: "
	output_msg_len		=	. - output_msg - 1
	
	newline			: 	.asciz "\n"
	buffer			:	.space 64			# Input buffer for reading strings
	num_buffer		: 	.space 16			# Buffer for number conversion

#-----------------------------------
# @brief Buffers for storing strings and ptrs
.section .bss
	string_count		: 	.space 4			# Number of strings
	# Array of string pointer (each pointer is 8 bytes)
	string_ptrs		:	.space 160			# 20 * 8 bytes = 160 bytes
	# Storage for actual strings
	string_storage		: 	.space 1280			# 20 * 64 bytes = 1280 bytes

#-------------------------------------
# @brief Instruction set for main
.section .text
	.global _start

_start:
	# Print the prompt for number of inputs
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, input_prompt
	mov rdx, input_prompt_len
	syscall

	# Read number of strings
	call read_number
	mov [string_count], eax
	mov ebx, eax


#-------------------------------------
# @brief Read number of strings and conver from string to num
# @return eax: the converted integer value
read_number:
	# Push to stack to preserve
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	push rdx

	# Read from stdin
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, num_buffer
	mov rdx, 16
	syscall

	# Convert the string to number
	lea rsi, buffer
	xor eax, eax
	mov ebx, 10				# Set base to 10 for decimal conversion

convert_loop:
	movzx ecx, byte ptr [rsi] 		# Load next character (zero-extended)
	cmp cl, 10
	je convert_done
	cmp cl, 0
	je convert_done
	cmp cl, '0'
	jl convert_done
	cmp cl, '9;
	jg convert_done

	sub cl, '0'				# Convert character to digit
	mul ebx
	add eax, ecx
	inc rsi
	jmp convert_loop			# Continue

convert_done:
	pop rdx
	pop rcx
	pop rbx
	pop rbp
	ret

	

	
