	.data
high_score:	.asciz "0&&&&&"
high_score_u:	.quad 0
curr_score:	.quad 0
curr_score_o:	.asciz "%06u"
score_ptr:	.quad 0

	.text
score_path:	.asciz "../res/score"
score_mode_r:	.asciz "r"
score_mode_w:	.asciz "w"
score_format:	.asciz "%s"
score_format_u:	.asciz "%u"

get_score_from_file:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rax
	movq $score_path, %rdi
	movq $score_mode_r, %rsi
	call fopen

	movq %rax, score_ptr

	movq $0, %rax
	movq score_ptr, %rdi
	movq $score_format, %rsi
	movq $high_score, %rdx
	call fscanf

	movq $0, %rax
	movq score_ptr, %rdi
	call rewind

	movq $0, %rax
	movq score_ptr, %rdi
	movq $score_format_u, %rsi
	movq $high_score_u, %rdx
	call fscanf 		# Read score again as unsigned int
	
	movq $0, %rax
	movq score_ptr, %rdi
	call fclose

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	
write_score_to_file:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq curr_score, %rax
	cmpq high_score_u, %rax

	jle write_score_to_file_end # No need to write
	
	movq $0, %rax
	movq $score_path, %rdi
	movq $score_mode_w, %rsi
	call fopen

	movq %rax, score_ptr

	movq $0, %rax
	movq score_ptr, %rdi
	movq $curr_score_o, %rsi
	movq curr_score, %rdx
	call fprintf

	movq $0, %rax
	movq score_ptr, %rdi
	call fclose

write_score_to_file_end:	

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	


