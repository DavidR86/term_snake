	.include "read_kbd.s"
	.include "screen.s"
	
	.data
timespec:
tv_sec:
	.quad 0
tv_nsec:
	.quad 500000000

dummy:
	.quad 0x0
	.quad 0x0

screensize:
height:	.quad 0
width:	.quad 0

food:
food_1_x: 	.quad 26 	# x should be a multiple of 2 because of emoji alignment
food_1_y:	.quad 10
food_2_x:	.quad 40
food_2_y:	.quad 4
food_3_x:	.quad 25
food_3_y:	.quad 2
	.text
start_sound:	.asciz "while [ 1 ]; do aplay ../res/KarmaNES.wav > /dev/null 2>&1; done &"
stop_sound:	.asciz "kill -9 -$(ps -o pgid= $(pgrep -x aplay) | grep -o '[0-9]*')"


	.global main

main:
	
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $start_sound, %rdi
	call system

	call get_screen_size
	movq %rax, height
	movq %rbx, width

	call clear_screen

	call clear_screen

	call print_borders

	pushq $10
	pushq $10

	pushq $9
	pushq $10

	pushq $8
	pushq $10

	pushq $7
	pushq $10

	pushq $6
	pushq $10

	call kbd_init
loop_a:
	
	movq $0, %rdi
	movq $0, %rsi
	call rem_char_at_coord 	# Deletes past user input on terminal windows and positions cursor on (0,0)

	call handle_input

	## Print food
	movq food_1_x, %rdx
	movq food_1_y, %rsi
	call print_food

	movq food_2_x, %rdx
	movq food_2_y, %rsi
	call print_food

	movq food_3_x, %rdx
	movq food_3_y, %rsi
	call print_food

	jmp delete_tail
delete_tail_end:	

	movq $0, %rdi
	movq $0, %rsi
	call rem_char_at_coord  # Deletes past user input on terminal windows and positions cursor on (0,0)
	
	## Update array positions
	movq %rsp, %rax 		# Point to tail
loop_d:
	movq 16(%rax), %rbx 	# Get x+1
	movq 24(%rax), %rcx 	# Get y+1
	movq %rbx, (%rax) 	# Move to x
	movq %rcx, 8(%rax) 	# Move y

	addq $16, %rax
	movq %rbp, %rcx
	subq $16, %rcx
	cmpq %rcx, %rax
	jne loop_d

	## Update head
	movq next_y, %rsi 	
	addq -8(%rbp), %rsi
	movq %rsi, -8(%rbp)
	movq next_x, %rdx
	addq -16(%rbp), %rdx
	movq %rdx, -16(%rbp)

	## Check if collision with border or tail occured
	jmp check_defeat
check_defeat_end:	

	## Print new head
	movq -16(%rbp), %rdx
	movq -8(%rbp), %rsi
	
	movq $0, %rdi
	call print_emoji_at_coord
	
	jmp loop_a

game_over:

	call print_you_lost

	movq $stop_sound, %rdi
	call system
	
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

nano_sleep:

		
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	movq $35, %rax
	movq $timespec, %rdi
	movq $dummy, %rsi
	syscall

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

check_defeat:
	## If x == max_width
	movq width, %rax
	dec %rax
	cmpq -16(%rbp), %rax
	jle game_over

	## If x == 0
	movq $1, %rax
	cmpq -16(%rbp), %rax
	jge game_over

	## If y == max_height
	movq height, %rax
	dec %rax
	cmpq -8(%rbp), %rax
	jle game_over

	## If y == 1
	movq $1, %rax
	cmpq -8(%rbp), %rax
	jge game_over

	movq %rsp, %rax 		# Point to tail
check_defeat_loop:
	movq (%rax), %rbx 	# Get x
	movq 8(%rax), %rcx 	# Get y

	xorq -16(%rbp), %rbx 	# Head x
	xorq -8(%rbp), %rcx 	# Head y

	orq %rbx, %rcx

	cmpq $0, %rcx
	je game_over

	addq $16, %rax
	movq %rbp, %rcx
	subq $16, %rcx
	cmpq %rcx, %rax
	jne check_defeat_loop
	
	jmp check_defeat_end

delete_tail:
	## Delete tail of snake if not in a food coordinate

	movq food_1_x, %rbx
	xorq -16(%rbp), %rbx
	movq food_1_y, %rcx
	xorq -8(%rbp), %rcx
	orq %rbx, %rcx

	cmpq $0, %rcx
	je dont_delete_tail

	movq food_2_x, %rbx
	xorq -16(%rbp), %rbx
	movq food_2_y, %rcx
	xorq -8(%rbp), %rcx
	orq %rbx, %rcx

	cmpq $0, %rcx
	je dont_delete_tail

	movq food_3_x, %rbx
	xorq -16(%rbp), %rbx
	movq food_3_y, %rcx
	xorq -8(%rbp), %rcx
	orq %rbx, %rcx

	cmpq $0, %rcx
	je dont_delete_tail
	
	movq (%rsp), %rsi
	movq 8(%rsp), %rdi
	call rem_char_at_coord
	jmp delete_tail_end

dont_delete_tail:
	pushq $-1 		# Add new element to snake. Coords will be updated automatically
	pushq $-1
	jmp delete_tail_end
