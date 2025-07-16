.intel_syntax noprefix

SYS_READ	=	0	# read text from stdin
SYS_WRITE	=	1	# write text to stdout
SYS_EXIT	=	60	# terminate the program
STDIN		= 	0	# standard input
STDOUT		= 	1	# standard output

# ------------------------------
# @brief declare a buffer for the prompt string
.section .bss
	uinput_len	=	24			# 24 bytes for user input
	uinput:     	  	.skip uinput_len	# buffer for user input

# ------------------------------
# @brief some sys statements 
.section .data
	prompt		:	.asciz "Please input some text: "
	prompt_len	=	.	- prompt - 1			# sub 1 for null terminator
	text		:	.asciz "You Wrote: "
	text_len	=	.	- text - 1

# ------------------------------
# @brief instructions for read and write string from terminal
.section .text
	.global _start

_start:
	mov rax, SYS_WRITE	# Print out the prompt
	mov rdi, STDOUT
	lea rsi, prompt
	mov rdx, prompt_len
	syscall

	mov rax, SYS_READ	# Read the value from terminal
	mov rdi, STDIN
	lea rsi, uinput
	mov rdx, uinput_len
	syscall 		# -> RAX	
	push rax 		# (1)
	 
	mov rax, SYS_WRITE	# Print out "You Wrote: "
	mov rdi, STDOUT
	lea rsi, text
	mov rdx, text_len
	syscall

	pop rdx			# (1)
	lea rsi, uinput		# print out the read string
	mov rdi, STDOUT
	mov rax, SYS_WRITE
	syscall

exit_code:
	xor edi, edi		# sucessful exit
	mov rax, SYS_EXIT
	syscall
