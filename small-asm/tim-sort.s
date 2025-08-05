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
	
	# Initialise the string pointers
	call init_string_pointers

	# Read strings
	mov ecx, 0
read_string_loop:
	cmp ecx, ebx
	jge read_string_done
	
	# Print string prompt
	push rcx
	push rbx
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, string_prompt
	mov rdx, string_prompt_len
	syscall
	pop rbx
	pop rcx

	# Read string - pass index in rdi
	mov rdi, rcx
	call read_string

	inc ecx
	jmp read_string_loop

read_string_done:
	# sort the strings
	call tim_sort_strings
	
	# Print sorted strings
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, output_msg
	mov rdx, output_msg_len
	syscall
	
	# Print sorted strings
	mov ecx, 0
print_string_loop:
	mov eax, [string_count]
	cmp ecx, eax
	jge exit_code

	# Get the pointer to the current string	
	mov rax, rcx
	mov rdx, 8
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
	inc ecx
	jmp print_string_loop

#-------------------------------
# @brief terminate the coed
exit_code:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall	

#-------------------------------------
# @brief initialise the string buffer to store strings and keep a string ptr to translate
# @brief string_ptrs: return the ptr to the storage for string buffer
init_string_pointers:
	push ebp
	mov ebp, esp
	push rbx
	push rdx
	push rcx
	push rdi
	
	mov ecx, 0
	lea rbx, string_storage
	lea rdi, string_ptrs
	
init_loop:
	cmp ecx, MAX_STRINGS
	jge init_done
	
	mov rax, rcx
	mov rdx, MAX_STRING_SIZE
	mul rdx
	add rax, rbx
	
	mov rdx, rcx
	shl rdx, 3			# rdx = i * 8 (pointer size)
	add rdx, rdi			# rdx = &string_ptrs[i]
	mov [rdx], rax			# string_ptrs[i] = storage address
	
	inc ecx
	jmp init_loop

init_done:
	pop rdi
	pop rcx
	pop rdx
	pop rbx
	pop rbp	
	
#-------------------------------------
# @brief Read a string from stdin and store it
# @param rdi: current string index
read_string:
	push rbp
	mov rbp, rsp
	push rbx
	push rdx
	push rcx
	push rsi
	push rdi

	# Read input into buffer
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, buffer
	mov rdx, MAX_STRING_SIZE - 1
	syscall

	# Get the string index from the saved parameter
	pop rdi
	push rdi
	
	mov rax, rdi
	shl rax, 3			# rax = index * 8
	lea rsi, string_ptrs
	add rsi, rax
	mov rdi, [rsi]			# Storage location for this string
	
	# Copy string from buffer to storage, removing newline
	lea rsi, buffer
copy_string:
	mov al, [rsi]
	cmp al, 10
	je copy_done
	cmp al, 0
	je copy_done
	mov [rdi], al
	
	inc rsi
	inc rdi
	jmp copy_string

copy_done:
	mov byte ptr [rdi], 0 		# Ad null terminator
	
	pop rdi
	pop rsi
	pop rcx
	pop rdx
	pop rbx
	pop rbp

#--------------------------------------
# @brief Tim sort (don't know how know)
tim_sort_strings:
	push rbp
	
	
		

	
	




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

	

	
