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
	out_len =	. - out - 1		# subtract 1 for null terminator
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
	# Initialize loop variables
	mov rcx, 6		# rcx = array size (loop counter)
	xor rbx, rbx		# rbx = accumulator for sum (initialize to 0)
	lea rsi, arr		# rsi = pointer to start of array

	#--------------------------------
	# @brief main loop to traverse array and calculate sum
top:
    add rbx, [rsi + 8 * rcx - 8]
    loop top

	#--------------------------------
	# @brief store final result
done:
	mov [sum], rbx 		# store accumulated sum in memory

	#--------------------------------
	# @brief display the result to stdout
display:
	# Print "Sum = " message
	mov rax, SYS_WRITE	# system call number for write
    	mov rdi, STDOUT		# file descriptor (stdout)
	lea rsi, out		# pointer to message string
        mov rdx, out_len	# length of message
        syscall			# invoke system call

	#--------------------------------
	# @brief convert sum to ASCII string for display
        mov rax, [sum]		# load sum value into rax for division
        lea rsi, [buffer + 31]	# point to end of buffer (null terminator position)
        mov byte ptr [rsi], 0	# place null terminator
	dec rsi			# move back one position
	mov rbx, 10		# divisor for base-10 conversion

	# Convert number to string (builds string backwards)
convert_loop:
	xor rdx, rdx		# clear rdx (high part of dividend)
	div rbx			# rax = rax/10, rdx = remainder
	add dl, '0'		# convert remainder digit to ASCII
	mov [rsi], dl		# store ASCII digit in buffer
	dec rsi			# move backward in buffer
	test rax, rax		# check if quotient is zero
	jnz convert_loop	# continue if more digits remain

	#--------------------------------
	# @brief print the converted number
	inc rsi			# move forward to first digit
	mov rax, SYS_WRITE	# system call for write
 	mov rdi, STDOUT		# stdout file descriptor
	lea rdx, [buffer + 31]	# calculate string length
	sub rdx, rsi		# rdx = end_pos - start_pos = length
	syscall			# print the number

	#--------------------------------
	# @brief print newline for clean output
	mov rax, SYS_WRITE	# system call for write
	mov rdi, STDOUT		# stdout file descriptor
	lea rsi, newline	# pointer to newline character
	mov rdx, 1		# length of newline (1 byte)
	syscall			# print newline
 
	#--------------------------------
	# @brief clean program termination
exit_code:
	xor rdi, rdi		# exit status = 0 (success)
	mov rax, SYS_EXIT	# system call number for exit
	syscall			# terminate program
