	.data
buffer:
timeval: .skip 40
type:	.word 0
code:	.word 0
value:	.long 0
	
pollfd:
fd:	.long 0x0
events:	.word 0x001
revents: .word 0x0

fd_r:	.quad 0x0

next_x:	.quad 0
next_y:	 .quad 1
	
	.text

pathname:	.asciz "../symlink/keyboard"
out:	.asciz "out: %hu %hu %u \n"
test:	.asciz "out: %u \n"

kbd_init:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	movq $2, %rax 		# Open syscall
	movq $pathname, %rdi 	# char *
	movq $04000, %rsi 	# O_RDONLY, O_NONBLOCK
	syscall

	movq %rax, fd_r 	# file descriptor
	movl %eax, fd 		# clone of fd_r, but inside struct pollfd

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
		
poll_key:	
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	


	movq $7, %rax 		# Poll syscall
	movq $pollfd, %rdi 	# fds
	movq $1, %rsi 		# fds_size
	movq $50, %rdx 		# Wait time in milis
	syscall

	movq $0, %rax 		# Read
	movq fd_r, %rdi 	# %rdi -> file descriptor
	movq $buffer, %rsi	# Output buffer
	movq $48, %rdx 		# Bytes to read
	syscall

	movq code, %rax

read_end:
	
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

read:
	movq $0, %rax 		# No vector register
	movq $out, %rdi 	# 1st: message
	movq type, %rsi 	# 2nd: Type
	movq code, %rdx		# 3rd: code (this is the key code)
	movq value, %rcx 	# 4th: Value
	call printf
	movq $0, %rdi
	call fflush
	jmp read_end

handle_input:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	call poll_key
	
	movq %rax, %rdi
	andq $0xFFFF, %rdi
	
	cmpq $17, %rdi
	je input_w
	
	cmpq $30, %rdi
	je input_a

	cmpq $31, %rdi
	je input_s

	cmpq $32, %rdi
	je input_d

input_merge:
	
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

input_w:
	movq $0, next_x
	movq $-1, next_y
	jmp input_merge
input_a:
	movq $-2, next_x
	movq $0, next_y
	jmp input_merge
input_s:
	movq $0, next_x
	movq $1, next_y
	jmp input_merge
input_d:
	movq $2, next_x
	movq $0, next_y
	jmp input_merge
