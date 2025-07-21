.intel_syntax noprefix

SYS_WRITE	=	1	# write text to stdout
SYS_READ	=	0	# read text from stdin
STDIN		=	0	# standard input
STDOUT		=	1	# standard output
SYS_EXIT	=	60	# terminate the program

#--------------------------------
# @brief implementing an array for stdin and stdout

# @brief define the array
.section .data
	arr	:	.quad 0, 1, 2, 3, 4, 5	# 64 bit integer
	out	:    	.asciz "Sum = "         # output text
	out_len =	. - out
	newline :	.asciz "\n"

#--------------------------------
# @brief a buffer for final print
.section .bss
	sum	: 	.space 8		# space for 64-bit sum
	buffer	:	.space 32

#--------------------------------
# @brief instructions to perform array transversal and sum
.section .text
	.global _start

_start:
	mov rcx, 6		# size of the array
	xor rbx, rbx		# temp to store the sum
	lea rsi, arr		# pointer to the array

top:
	add rbx, [rsi]		# add current array element to temp
	
	imul rsi, 8		# increment the pointer
	dec rax			# decrement the size
	cmp rcx, 0		# compare value in rax to 0
	jnz top			# loop back if not equal to zero

done:
	mov [sum], rbx 		# store sum in "sum"

display:
	mov rax, SYS_WRITE
    	mov rdi, STDOUT
	lea rsi, out
        mov rdx, out_len
        syscall

	
        # Convert i to acsii
        mov rax, [sum]
        lea rsi, [buffer + 32]
        mov byte ptr [rsi], 0
	dec rsi
	mov rbx, 10

convert_loop:
	xor rdx, rdx
	div rbx
	add dl, '0'
	mov [rsi], dl
	dec rsi
	test rax, rax
	jnz convert_loop

	# Print the number
	inc rsi
	mov rax, SYS_WRITE
 	mov rdi, STDOUT
	lea rdx, [buffer + 31]
	sub rdx, rsi
	syscall

	# Print a new line
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, newline
	mov rdx, 1
	syscall
 
exit_code:
	xor rdi, rdi
	mov rax, 60
	syscall

