.global _start
.intel_syntax noprefix

# @brief Data section to read/write and store initialized data
.section .data
msg:    .asciz "Hello, World!\n"    # string literal
len = . - msg

# @brief text section for executable code
.section .text
_start:
        mov rax, 1          # syscall: write
        mov rdi, 1          # file descriptor: stdout
        mov rsi, offset msg # pointer to message
        mov rdx, len        # message length
        syscall

        mov rax, 60         # syscall: exit
        xor rdi, rdi        # status: 0
        syscall

