.intel_syntax noprefix

SYS_WRITE	=	1	# write text to stdout
SYS_READ	=	0	# read text from stdin
STDIN		=	0	# standard input
STDOUT		=	1	# standard output
SYS_EXIT	=	60	# terminate the program

#--------------------------------
# @brief Sorting an array from input and printing it back

# @brief data section for storing snippets
.section .data
    input_prompt      :   .asciz  "Enter the number of elements: \n"   	# simple terminal prompt
    input_prompt_len  =   . - input_prompt - 1

    element_prompt    :   .asciz  "Enter Element: \n"     		
    element_prompt_len=   . - element_prompt - 1

    output_msg	      :	  .asciz "Sorted array: \n"			
    output_msg_len    =   . - output_msg - 1    

    newline	      :   .asciz "\n"
    space	      :	  .asciz " "

    buffer            :   .space 16					# Buffer for the input
    num_buffer	      :   .space 16					# Buffer for number conversion

#-------------------------------
# @brief Buffers to keep the array and the sorted array
.section .bss
    array	:	.space 400		# Space for 100 integers (4 bytes each)
    array_size	:	.space 4		# Size of the array

#--------------------------------
# @brief Instructions for the array and sorting
.section .text
    .global _start

_start:
	# Print prompt for number of elements
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, input_prompt
	mov rdx, input_prompt_len

	# Read number of elements
	call read_number
	mov [array_size], eax
	mov ebx, eax				# Store array size in ebx register
	
	# Read arrray elements
	mov ecx, 0				# Counter

read_loop:
	cmp ecx, ebx
	jge read_done

	# Print element prompt	
	push rcx
	push rbx
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, element_prompt
	mov rdx, element_prompt_len
	syscall
	pop rbx
	pop rcx

	# Read element
	push rcx
	push rbx
	call read_number
	pop rbx
	pop rcx

	# Store element in array
	mov [array + rcx*4], eax
	inc ecx
	jmp read_loop

read_done:
	# Sorting the array (using bubble sort)
	call bubble_sort

	# Print sorted array messages
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, output_msg
	mov rdx, output_msg_len
	syscall

	# Print sorted array
	mov ecx, 0
print_loop:
	cmp ecx, [array_size]
	jge print_done

	# Print current element
	mov eax, [array + rcx * 4]
	push rcx
	call print_number
	pop rcx

	# Print space (except last element)
	inc ecx
	cmp ecx, [array_size]
	jge skip_space
	
	push rcx
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, space
	mov rdx, 1
	syscall
	pop rcx

skip_space:
	jmp print_loop


print_done:
	# Print newline
	mov rax, SYS_WRITE
	mov rax, STDOUT
	lea rsi, newline
	mov rdx, 1
	syscall
#--------------------------------
# @brief Exit the program
exit_code:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

#-----------------------------------
# @brief bubble sort logic here (absolutely cooked brain)
bubble_sort:
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	mov ebx, [array_size]		# n
	dec ebx				# n - 1
	
outer_loop:
	cmp ebx, 0
	jle sort_done
	
	mov ecx, 0			# i = 0

inner_loop:
	cmp ecx, ebx
	jge outer_next

	# Compare array[i] and array[i+1]
	mov eax, [array + rcx * 4]		# array[i]
	mov edx, [array + rcx * 4 + 4]		# array[i + 1]

	cmp eax, edx
	jle no_swap

	# swap elements
	mov [array + rcx * 4], edx
	mov [array + rcx * 4 + 4], eax

no_swap:
	inc rcx
	jmp inner_loop

outer_next:
	dec ebx
	jmp outer_loop

sort_done:
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rbp
	ret

#------------------------------------------
# @brief Read number from stdin
read_number:
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	push rdx

	# Read Input
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, buffer
	mov rdx, 16
	syscall

	# Convert string to number
	lea rsi, buffer
	xor eax, eax
	mov ebx, 10

convert_loop:
	movzx ecx, byte ptr [rsi]
	cmp cl, 10				# newline
	je convert_done
	cmp cl, 0				# null terminator
	je convert_done
	cmp cl, '0'
	jl convert_done	
	cmp cl, '9'
	jg convert_done

	sub cl, '0'				# Convert to digit
	mul ebx					# eax *= 10
	add eax, ecx				# add digit
	inc rsi
	jmp convert_loop

convert_done:
	pop rdx
	pop rcx
	pop rbx
	pop rbp
	ret

#-------------------------------------------
# @brief Print a number from the array to stdout

print_number:
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	mov ebx, 10				# divisor
	lea rsi, num_buffer
	add rsi, 15
	mov byte ptr [rsi], 0			# null terminator
	dec rsi
	
	cmp eax, 0
	jne convert_digits

	# Handle zero case
	mov byte ptr [rsi], '0'
	dec rsi
	jmp print_digits

convert_digits:
	cmp eax, 0
	je print_digits
	
	mov ebx, 0
	div ebx					# eax = eax/10, edx = remainder
	add dl, '0'				# convert remainder to ASCII
	mov [rsi], dl
	dec rsi
	jmp convert_digits

print_digits:
	inc rsi					# point to the first digit
	
	# Calculate the length
	lea rdi, num_buffer
	add rdi, 15
	sub rdi, rsi				# Length = end - start

	# Print the number
	mov rax, SYS_WRITE
	push rdi
	mov rdi, STDOUT				# stdout
	mov rdx, [rsp]				# length
	syscall 
	pop rdi

	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rbp
	ret
	










