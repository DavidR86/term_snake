	.include "read_kbd.s"
	.include "score.s"
	.include "screen.s"
	.include "rand.s"
	.include "music.s"
	
	.data
	## This struct is for nano_wait. A different wait method is used currently,
	## but it is left here in case I later implement a constant 'framerate'.
timespec:
tv_sec:
	.quad 0
tv_nsec:
	.quad 500000000

dummy:
	.quad 0x0
	.quad 0x0

	## Holds the size of the terminal window (in rows and collumns)
screensize:
height:	.quad 0
width:	.quad 0
width_half:	.quad 0 	# Half of the width, to avoid dividing it all the time.

food:
food_1_x: 	.quad 26 	# x should always be a multiple of 2 because of emoji alignment
food_1_y:	.quad 10
food_2_x:	.quad 40
food_2_y:	.quad 4
food_3_x:	.quad 60
food_3_y:	.quad 7

	.global main 		# Export main

main:
	
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	call get_score_from_file # Read highscore

	call rand_init 		# Initialize rng

	call start_sound 	# Start music
	
	call get_screen_size 	# Get width and height
	movq %rax, height
	movq %rbx, width

	movq %rbx, %rax
	movq $2, %rcx
	movq $0, %rdx
	divq %rcx
	movq %rax, width_half 	# save width/2

	call clear_screen

	call print_borders 	# Borders at the edge of the game

	call print_title 	# Print game name
	call print_input_str 	# Print input field

	## Initialize snake. Elements are added to the snake by pushing its (y,x) coordinates into the stack.
	## New elements are added with (-1,-1) during runtime and get updated as it moves.
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

	pushq $5
	pushq $10

	call print_high_score

	call kbd_init 		# This attempts to get the keyboard input from the keyboard symlink pointing at a device in /dev/input/...

	## Set initial food positions
	call init_food

	## Main game loop 
loop_a:
	
	movq $1, %rdi
	movq $11, %rsi
	call rem_char_at_coord 	# Deletes past user input on terminal windows and positions cursor on (1,11)

	call handle_input 	# Wait for a specfic amount of miliseconds, or until keyboard input is detected.

	## Deletes the tail of the snake if not on a food coordinate.
	## Using jumps instead of subroutines because the snake is saved in the stack, and %rbp and %rsp are used to get the head and tail.
	jmp delete_tail
delete_tail_end:

	## Print food
	movq food_3_x, %rdx
	movq food_3_y, %rsi
	call print_food
	
	## Print food
	movq food_2_x, %rdx
	movq food_2_y, %rsi
	call print_food

	## Print food
	movq food_1_x, %rdx
	movq food_1_y, %rsi
	call print_food

	movq $1, %rdi
	movq $11, %rsi
	call rem_char_at_coord  # Deletes past user input on terminal windows and positions cursor on (1,11)
	
	## Update array positions. Snake n is updated with position n+1. New head is added later
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

	## Update head. handle_input should have updated next_x and next_y based on user input. Otherwise, the snake keeps its course
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
	call print_emoji_at_coord # Emoji version
	
	jmp loop_a 		# End of main game loop. Repeat

	## Final tasks after loosing
game_over:
	
	call print_you_lost

	call write_score_to_file # Writes score if it is greater than highscore

	call stop_sound

	## Main soubroutine epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

	## Not currently used
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

	## Checks if snake has collided with wall or itself
check_defeat:
	## If x > max_width
	movq width, %rax
	dec %rax
	cmpq -16(%rbp), %rax
	jle game_over

	## If x =< 1
	movq $1, %rax
	cmpq -16(%rbp), %rax
	jge game_over

	## If y > max_height
	movq height, %rax
	cmpq -8(%rbp), %rax
	jle game_over

	## If y =< 2
	movq $2, %rax
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
	je game_over 		# If head is at same position as a member of the snake

	addq $16, %rax
	movq %rbp, %rcx
	subq $16, %rcx
	cmpq %rcx, %rax
	jne check_defeat_loop 	# If next, jump to start of loop with next element of the snake.
	
	jmp check_defeat_end

delete_tail:
	## Delete tail of snake if not in a food coordinate

	movq -16(%rbp), %rax
	cmpq $-1, %rax
	je dont_delete_tail 	# If tail hasn't been updated

	movq food_1_x, %rbx
	xorq -16(%rbp), %rbx
	movq food_1_y, %rcx
	xorq -8(%rbp), %rcx
	orq %rbx, %rcx

	cmpq $0, %rcx
	je food_1_eaten 	# If head is at potion of food_1

	movq food_2_x, %rbx
	xorq -16(%rbp), %rbx
	movq food_2_y, %rcx
	xorq -8(%rbp), %rcx
	orq %rbx, %rcx

	cmpq $0, %rcx
	je food_2_eaten

	movq food_3_x, %rbx
	xorq -16(%rbp), %rbx
	movq food_3_y, %rcx
	xorq -8(%rbp), %rcx
	orq %rbx, %rcx

	cmpq $0, %rcx
	je food_3_eaten

	## Delete the tail of the snake
	movq (%rsp), %rsi
	movq 8(%rsp), %rdi
	call rem_char_at_coord 
	jmp delete_tail_end

dont_delete_tail:
	## If tail isn't deleted, food was eaten. Time to make the snake bigger
	pushq $-1 		# Add new element to snake. Coords will be updated automatically
	pushq $-1

	pushq $-1
	pushq $-1

	pushq $-1
	pushq $-1

	pushq $-1
	pushq $-1

	pushq $-1
	pushq $-1

	pushq $-1
	pushq $-1

	## update score by 6
	movq curr_score, %rax
	addq $6, %rax
	movq %rax, curr_score

	call print_curr_score
	
	jmp delete_tail_end
	
	## If food_1 is eaten, move it to another random location within boundaries.
	## The food should be moved to a location that is not a wall, or right next to a wall (makes eating it very hard)
	## Because of emoji alignment, the x coord needs to be a multiple of 2
	## The food can theoretically spawn inside the snake, and would be hidden by it until the snake moves. It should not get eaten.
	## The food can theoreticall spawn inside the head of the snail. It should not be an issue either.
food_1_eaten:
	movq width_half, %rdi
	call get_rand
	movq $2, %rdx
	mulq %rdx
	movq %rax, food_1_x

	movq height, %rdi
	call get_rand
	movq %rax, food_1_y

	## Print food
	movq food_1_x, %rdx
	movq food_1_y, %rsi
	call print_food

	jmp dont_delete_tail

food_2_eaten:
	movq width_half, %rdi
	call get_rand
	movq $2, %rdx
	mulq %rdx
	movq %rax, food_2_x

	movq height, %rdi
	call get_rand
	movq %rax, food_2_y

	## Print food
	movq food_2_x, %rdx
	movq food_2_y, %rsi
	call print_food

	jmp dont_delete_tail

food_3_eaten:
	movq width_half, %rdi
	call get_rand
	movq $2, %rdx
	mulq %rdx
	movq %rax, food_3_x

	movq height, %rdi
	call get_rand
	movq %rax, food_3_y

	## Print food
	movq food_3_x, %rdx
	movq food_3_y, %rsi
	call print_food

	jmp dont_delete_tail

	## Initialize food at random location
init_food:	
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	## Food 1
	movq width_half, %rdi
	call get_rand
	movq $2, %rdx
	mulq %rdx
	movq %rax, food_1_x

	movq height, %rdi
	call get_rand
	movq %rax, food_1_y

	## Food 2
	movq width_half, %rdi
	call get_rand
	movq $2, %rdx
	mulq %rdx
	movq %rax, food_2_x

	movq height, %rdi
	call get_rand
	movq %rax, food_2_y

	## Food 3
	movq width_half, %rdi
	call get_rand
	movq $2, %rdx
	mulq %rdx
	movq %rax, food_3_x

	movq height, %rdi
	call get_rand
	movq %rax, food_3_y
	
	## Epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
