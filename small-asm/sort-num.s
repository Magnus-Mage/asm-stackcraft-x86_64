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
    prompt      :   .asciz  "Type out your array: \n"   # simple terminal prompt
    prompt_len  =   . - prompt - 1
    out         :   .asciz  "Your sorted array: \n"     # final output prompt
    out_len     =   . - out - 1

#-------------------------------
# @brief Buffers to keep the array and the sorted array
.section .bss










#--------------------------------
# @brief Exit the program
exit_code:
    xor rdi, rdi
    mov rax, SYS_EXIT
    syscall


