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
    mov ebx, eax                            # Store string count in ebx

    # Initialize string storage pointers
    call init_strings_pointers

    # Read strings
    mov ecx, 0                              # Initialize counter to 0
read_string_loop:
    cmp ecx, ebx                            # Check if we've read all strings
    jge read_string_done                    # Jump to done if counter >= string_count
    
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

    # Read string into the appropriate storage location
    push rcx
    push rbx
    call read_string
    pop rbx
    pop rcx

    inc ecx                                 # Increment counter
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
    mov ecx, 0                              # Initialize counter to 0
print_string_loop:
    cmp ecx, [string_count]                 # Check if we've printed all strings
    jge exit_code                           # Jump to exit if done
    
    # Get pointer to the current string
    mov rax, rcx                            # Move current index to rax
    mov rdx, 8                              # Each pointer is of 8 bytes 
    mul rdx                                 # Calculate offset (index * 8)
    lea rsi, string_ptrs                    # Load address of pointer array
    add rsi, rax                            # Add offset to get &string_ptrs[index]
    mov rsi, [rsi]                          # Dereference to get actual string pointer

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

    inc ecx                                 # Increment counter
    jmp print_string_loop

# @brief Exit_Code
exit_code:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall	

#------------------------------------------
# @brief Initialize string pointers to point to the storage location
init_strings_pointers:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rdi                                # Save rdi register

    mov ecx, 0                              # Initialize counter to 0
    lea rbx, string_storage                 # Base address of string storage
    lea rdi, string_ptrs                    # Base address of pointer array (use rdi instead of rdx)

init_loop:
    cmp ecx, MAX_STRINGS                    # Check if we've initialized all pointers
    jge init_done                           # Jump to done if counter >= MAX_STRINGS
    
    # Calculate storage address for string i : base + (i * MAX_STRING_SIZE)
    mov rax, rcx                            # Move index to rax
    mov rdx, MAX_STRING_SIZE                # Load string size constant (use rdx for multiplication)
    mul rdx                                 # Multiply index by string size (rax = rcx * MAX_STRING_SIZE)
    add rax, rbx                            # rax = base + (i * MAX_STRING_SIZE)

    # Store pointer in pointer Array
    mov rdx, rcx                            # Move index to rdx
    shl rdx, 3                              # rdx = i * 8 (pointer size)
    add rdx, rdi                            # rdx = &string_ptrs[i]
    mov [rdx], rax                          # string_ptrs[i] = storage address

    inc ecx                                 # Increment counter
    jmp init_loop

init_done:
    pop rdi                                 # Restore rdi register
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

#---------------------------------------
# @brief Read a string from stdin and store it
read_string:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rsi
    
    # Read input into buffer
    mov rax, SYS_READ
    mov rdi, STDIN
    lea rsi, buffer
    mov rdx, MAX_STRING_SIZE - 1            # Leave space for null terminator
    syscall

    # Get current string index from stack context
    # The index is passed via the stack from the calling function
    mov ecx, [rsp + 40]                     # Get ecx from stack (pushed in main loop)

    # Get pointer to the current string storage
    mov rax, rcx                            # Move index to rax
    shl rax, 3                              # rax = index * 8 (pointer size)
    lea rsi, string_ptrs                    # Load address of pointer array
    add rsi, rax                            # Add offset to get &string_ptrs[index]
    mov rdi, [rsi]                          # rdi = storage location for this string

    # Copy string from buffer to storage, removing newline
    lea rsi, buffer                         # Load address of input buffer
copy_string:
    mov al, [rsi]                           # Load character from buffer
    cmp al, 10                              # Check for newline character
    je copy_done                            # Jump to done if newline found
    cmp al, 0                               # Check for null terminator
    je copy_done                            # Jump to done if null found
    mov [rdi], al                           # Store character in string storage
    inc rsi                                 # Move to next character in buffer
    inc rdi                                 # Move to next position in storage
    jmp copy_string                         # Continue copying

copy_done:
    mov byte ptr [rdi], 0                   # Add null terminator to string

    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

#-----------------------------------------
# @brief Bubble sort for strings
bubble_sort_strings:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov ebx, [string_count]                 # Load number of strings (n)
    dec ebx                                 # n-1 for outer loop

outer_loop:
    cmp ebx, 0                              # Check if outer loop is done
    jle sort_done                           # Jump to done if ebx <= 0

    mov ecx, 0                              # Initialize inner loop counter (i = 0)

inner_loop:
    cmp ecx, ebx                            # Check if inner loop is done
    jge outer_next                          # Jump to next outer iteration if ecx >= ebx

    # Get pointers to string[i] and string[i+1]
    mov rax, rcx                            # Move index i to rax
    shl rax, 3                              # rax = i * 8 (pointer size)
    lea rsi, string_ptrs                    # Load address of pointer array
    add rsi, rax                            # Add offset to get &string_ptrs[i]
    mov rdi, [rsi]                          # rdi = string[i]
    mov rsi, [rsi + 8]                      # rsi = string[i+1]

    # Compare strings
    push rcx                                # Save loop counters
    push rbx
    call strcmp                             # Call string comparison function
    pop rbx                                 # Restore loop counters
    pop rcx

    # If string[i] <= string[i+1], no swap needed
    cmp eax, 0                              # Check comparison result
    jle no_swap                             # Jump if no swap needed (eax <= 0)

    # Swap string pointers
    mov rax, rcx                            # Move index i to rax
    shl rax, 3                              # rax = i * 8 (pointer size)
    lea rsi, string_ptrs                    # Load address of pointer array
    add rsi, rax                            # Add offset to get &string_ptrs[i]
    mov rdi, [rsi]                          # rdi = string[i]
    mov rdx, [rsi + 8]                      # rdx = string[i+1]
    mov [rsi], rdx                          # string[i] = string[i+1]
    mov [rsi + 8], rdi                      # string[i+1] = string[i]

no_swap:
    inc ecx                                 # Increment inner loop counter
    jmp inner_loop                          # Continue inner loop

outer_next:
    dec ebx                                 # Decrement outer loop counter
    jmp outer_loop                          # Continue outer loop

sort_done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

#-----------------------------------------
# @brief Compare two strings: strcmp(rdi, rsi)
# @param rdi: pointer to first string
# @param rsi: pointer to second string  
# @return eax: < 0 if rdi < rsi, 0 if equal, > 0 if rdi > rsi
strcmp:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx

compare_loop:
    mov al, [rdi]                           # Load character from first string
    mov bl, [rsi]                           # Load character from second string
    
    cmp al, bl                              # Compare characters
    jne strings_different                   # Jump if characters are different
    
    # If both characters are null, strings are equal
    cmp al, 0                               # Check if character is null terminator
    je strings_equal                        # Jump if strings are equal
    
    # Move to next characters
    inc rdi                                 # Move to next character in first string
    inc rsi                                 # Move to next character in second string
    jmp compare_loop                        # Continue comparison

strings_different:
    # Return difference between characters
    movzx eax, al                           # Zero-extend first character to eax
    movzx ebx, bl                           # Zero-extend second character to ebx
    sub eax, ebx                            # Calculate difference
    jmp strcmp_done                         # Jump to function end

strings_equal:
    xor eax, eax                            # Return 0 for equal strings

strcmp_done:
    pop rcx
    pop rbx
    pop rbp
    ret

#-----------------------------------------
# @brief Print a string to stdout
# @param rsi: pointer to string to print
print_string:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rdi

    # Calculate string length
    mov rdi, rsi                            # rdi = string pointer for length calculation
    xor rcx, rcx                            # Initialize length counter to 0

strlen_loop:
    cmp byte ptr [rdi + rcx], 0             # Check if character is null terminator
    je strlen_done                          # Jump to done if null found
    inc rcx                                 # Increment length counter
    jmp strlen_loop                         # Continue counting

strlen_done:
    # Print the string
    mov rax, SYS_WRITE                      # System call number for write
    mov rdi, STDOUT                         # File descriptor for stdout
    # rsi already contains string pointer
    mov rdx, rcx                            # String length
    syscall                                 # Make system call

    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

#-----------------------------------------
# @brief Read a number from stdin and convert to integer
# @return eax: the converted integer value
read_number:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx

    # Read input from stdin
    mov rax, SYS_READ                       # System call number for read
    mov rdi, STDIN                          # File descriptor for stdin
    lea rsi, buffer                         # Buffer to store input
    mov rdx, 16                             # Maximum bytes to read
    syscall                                 # Make system call

    # Convert string to number
    lea rsi, buffer                         # Load address of input buffer
    xor eax, eax                            # Initialize result to 0
    mov ebx, 10                             # Set base to 10 for decimal conversion

convert_loop:
    movzx ecx, byte ptr [rsi]               # Load next character (zero-extended)
    cmp cl, 10                              # Check for newline character
    je convert_done                         # Jump to done if newline found
    cmp cl, 0                               # Check for null terminator
    je convert_done                         # Jump to done if null found
    cmp cl, '0'                             # Check if character is below '0'
    jl convert_done                         # Jump to done if not a digit
    cmp cl, '9'                             # Check if character is above '9'
    jg convert_done                         # Jump to done if not a digit

    sub cl, '0'                             # Convert character to digit value
    mul ebx                                 # Multiply current result by 10
    add eax, ecx                            # Add new digit to result
    inc rsi                                 # Move to next character
    jmp convert_loop                        # Continue conversion

convert_done:
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret
