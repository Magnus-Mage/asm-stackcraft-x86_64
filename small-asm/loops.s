.intel_syntax noprefix

# @brief Different loops and small use case for each

# @brief Initialised Data
.section .data 
newline:        .byte  10
space:          .byte  ' ' 
for_label:      .asciz "FOR:\n"
while_label:    .asciz "While:\n"
dowhile_label:	.asciz "Do-While:\n"

# @brief to hold ascii digit
.section .bss
buffer: 	.skip 1

# @brief _start for entrypoint
.section .text
.global _start

_start: 
	#Print 'FOR:'
	mov rax, 1
	mov rdi, 1
	lea rsi, for_label
	mov rdx, 5
	syscall

# @brief For loop to print 0-5
	mov ecx, 0		# i = 0
for_loop:
	cmp ecx, 5
	jge exit_for
	
	# Convert i to acsii
	mov eax, ecx
	add al, '0'
	mov [buffer], al

	# Print the digit	
	mov rax, 1
	mov rdi, 1
	lea rsi, buffer
	mov rdx, 1
	syscall

	# Print space
	mov rax, 1
	mov rdi, 1
	lea rsi, space
	mov rdx, 1
	syscall
	
	inc ecx
	jmp for_loop

# @brief Exit code, pretty much the same for everyone but as assembly is sequantial, have to use this but can find some better way
exit_for:
	# Print newline
	mov rax, 1
	mov rdi, 1
	lea rsi, newline
	mov rdx, 1
	syscall

	# Print "While:\n"
	mov rax, 1
	mov rdi, 1
	lea rsi, while_label
	mov rdx, 7
	syscall

# @brief A while loop to print 0-5
# @Note  While loop is a part of for loops but a for loop is not part of while loop. 
# Therefore, simple variations can be interchanged but not more complex ones

 
	mov ecx, 0		# i = 0
while_loop:
	cmp ecx, 5
	jge exit_while
	
	# Convert i to acsii
	mov eax, ecx
	add al, '0'
	mov [buffer], al

	# Print the digit	
	mov rax, 1
	mov rdi, 1
	lea rsi, buffer
	mov rdx, 1
	syscall

	# Print space
	mov rax, 1
	mov rdi, 1
	lea rsi, space
	mov rdx, 1
	syscall
	
	inc ecx
	jmp while_loop

# @brief Exit code
exit_while:
	# Print newline
	mov rax, 1
	mov rdi, 1
	lea rsi, newline
	mov rdx, 1
	syscall

	# Print "DoWhile:\n"
	mov rax, 1
	mov rdi, 1
	lea rsi, dowhile_label
	mov rdx, 10
	syscall

# @brief A do while loop to print 0-5

 
	mov ecx, 0		# i = 0
dowhile_loop:

	# Convert i to acsii
	mov eax, ecx
	add al, '0'
	mov [buffer], al

	# Print the digit	
	mov rax, 1
	mov rdi, 1
	lea rsi, buffer
	mov rdx, 1
	syscall

	# Print space
	mov rax, 1
	mov rdi, 1
	lea rsi, space
	mov rdx, 1
	syscall
	
	inc ecx
	cmp ecx, 5
	jl for_loop

# @brief Exit code
exit_dowhile:
	# Print newline
	mov rax, 1
	mov rdi, 1
	lea rsi, newline
	mov rdx, 1
	syscall

	# Exit Code
	mov rax, 60
	xor rdi, rdi
	syscall
