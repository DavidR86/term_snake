### *** Plays the music in a separate process
	.text
	## Commands for playing the music in a separate process, and stopping it.
start_sound_o:	.asciz "while [ 1 ]; do aplay ./res/KarmaNES.wav > /dev/null 2>&1; done &" 
stop_sound_o:	.asciz "kill -9 -$(ps -o pgid= $(pgrep -x aplay) | grep -o '[0-9]*')"

start_sound:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $start_sound_o, %rdi
	call system

	
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

stop_sound:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $stop_sound_o, %rdi
	call system

	
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
