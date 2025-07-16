.intel_syntax noprefix

SYS_WRITE	=	1	# write text to STDOUT
SYS_READ	=	0	# read text from STDIN
SYS_EXIT	=	60	# terminate the program
STDIN		=	0	# standard read
STDOUT		=	1	# standard out
SYS_OPENAT	=	257	# open directory
SYS_GETDENTS 	=	78	# read entries ( change to 217 for 64 bit)

# -------------------------------
# @brief buffer for directory entries
.section .bss
	buffer:		.skip	4096
