### *** Generates random numbers in a range of [4,max-2] using the rand() c funcion
	## Initializes the rng
rand_init:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rax
	movq $0, %rdi
	call time

	movq %rax, %rdi
	call srand

	## Epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret



### Generates random numbers in a range of [4,max-2] using the rand() c funcion
### 	Arguments:
### %rdi: max
###  	Returns:
### %rax: result
get_rand:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	subq $6, %rdi
	pushq %rdi
	call rand

	popq %rcx
	movq $0, %rdx
	divq %rcx
	addq $4, %rdx
	movq %rdx, %rax

	## Epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
