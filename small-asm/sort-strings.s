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
    
    # Read Number of strings    
    call read_number
    mov [string_count], eax
    mov ecx, eax                            # Store string count    

    # Initialize string storage pointers
    call init_strings_done

    # Read strings
read_string_loop:
    
    # Print string prompt   
    push rcx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    lea rsi, string_prompt
    mov rdx, string_prompt_len
    syscall

    pop rcx

    # Read string into the appropiate storage location
    push rcx
    call read_string
    pop rcx

    jmp read_string_loop

read_string_done:
    # Sort the strings
    call bubble_sort_strings

    # Print sorted strings message
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    lea rsi, output_msg
    mov rdx, output_msg_len
    syscall

    # Print sorted strings
    mov ecx, [string_count]
print_string_loop:
    # Get pointer to the current string
    mov rax, rcx                        # Pointer to the string
    mov rdx, 8                          # Each pointer is of 8 bytes 
    mul rdx
    lea rsi, string_ptrs
    add rsi, rax
    mov rsi, [rsi]

    # Print the string
    push rcx
    call print_string
    pop rcx

    # Print newline
    push rcx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    lea rsi, newline
    mov rdx, 1
    syscall
    pop rcx

    jmp print_string_loop

# @brief Exit_Code
exit_code:
	xor edi, edi
	mov rax, SYS_EXIT	
	syscall	
