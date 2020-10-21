### *** This file contains subroutines for printing characters to the terminal at
### *** arbitrary positions using ANSI escape sequences and printf.
### *** Also handles anything related to the terminal window.

	.data
	
	## Struct used for the ioctl syscall to get the terminal width and height
	ws_struct:
ws_row:	.word 0
ws_col:	 .word 0
	.skip 4

	.text
	## Strings for printing
scan_sr_s:	.asciz "out: %hu %hu \n"
clr_scr_o: .asciz "\033[2J"
prnt_char_o: .asciz "\033[%u;%uH%c"
prnt_emoji_o:	.asciz "\033[%u;%uH🦀"
prnt_box_o:	.asciz "\033[%u;%uH▒"
prnt_food_o:	.asciz "\033[%u;%uH🍗"
you_lost_o:	.asciz "[ YOU LOST! ]   "
high_score_str:	.asciz "[ HIGHSCORE: 000000 YOU: 000000 ]\033[20D" # s=33
title_o:	.asciz "== [ TERM SNAKE ] ==" # s/2 = 10
input_o:	.asciz " [ INPUT:   ]"


### Clears the screen using ANSI escape codes
### 	Arguments:
### none
###  	Returns:
### none
clear_screen:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rax 		# No vector registers
	movq $clr_scr_o, %rdi
	call printf

	movq $0, %rdi
	call fflush 		# Flush to make reult appear immediately. Alternative could be using a new-line character.

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	
### Prints an ASCII character to an (x,y) coordinate of the terminal using ANSI escape codes.
### 	Arguments:
### %rdi: character to print
### %rsi: line coordinate
### %rdx: collumn coordinate
###  	Returns:
### none
print_char_at_coord:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq %rdi, %rcx

	movq $0, %rax 		# No vector registers
	movq $prnt_char_o, %rdi
	call printf

	movq $0, %rdi
	call fflush

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Prints a crab emoji to an (x,y) coordinate of the terminal using ANSI escape codes.
### 	Arguments:
### %rdi: nothing (kept for compatibility reasons)
### %rsi: line coordinate
### %rdx: collumn coordinate
###  	Returns:
### none
print_emoji_at_coord:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rcx 	

	movq $0, %rax 		# No vector registers
	movq $prnt_emoji_o, %rdi
	call printf

	movq $0, %rdi
	call fflush

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Prints a box unicode character to an (x,y) coordinate of the terminal using ANSI escape codes.
### 	Arguments:
### %rdi: nothing (kept for compatibility reasons)
### %rsi: line coordinate
### %rdx: collumn coordinate
###  	Returns:
### none
print_box:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rax 		# No vector registers
	movq $prnt_box_o, %rdi
	call printf

	movq $0, %rdi
	call fflush

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Prints a food emoji to an (x,y) coordinate of the terminal using ANSI escape codes.
### 	Arguments:
### %rdi: nothing (for compatibility reasons)
### %rsi: line coordinate
### %rdx: collumn coordinate
###  	Returns:
### none
print_food:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rax 		# No vector registers
	movq $prnt_food_o, %rdi
	call printf

	movq $0, %rdi
	call fflush

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Deletes the character at an (x,y) coordinate of the terminal using ANSI escape codes, using a whitespace and leaves the cursor there
### 	Arguments:
### %rdi: line coordinate
### %rsi: collumn coordinate
###  	Returns:
### none
rem_char_at_coord:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq %rsi, %rdx
	movq %rdi, %rsi
	movq $32, %rdi
	call print_char_at_coord

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Deletes the character at an (x,y) coordinate of the terminal using ANSI and a backspace.
### 	Arguments:
### %rdi: line coordinate
### %rsi: collumn coordinate
###  	Returns:
### none
rem_char_at_coord_backspace:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq %rsi, %rdx
	movq %rdi, %rsi
	incq %rsi
	movq $8, %rdi
	call print_char_at_coord

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Attempts to get the terminal size from the kernel using a syscall
### 	Arguments:
### none
###  	Returns:
### %rax: height
### %rbx: width	
get_screen_size:
		# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rdi
	movq $0x5413, %rsi
	movq $ws_struct, %rdx
	movq $16, %rax
	syscall

	movq ws_row, %rsi
	movq ws_col, %rdx
	movq $0, %rax
	movq $scan_sr_s, %rdi
	call printf

	movq ws_col, %rbx
	movq ws_row, %rax
	andq $0xFFFF, %rax

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	
### Prints the game borders on the terminal screen
### 	Arguments:
### none
###  	Returns:
### none
print_borders:
	## Prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	pushq $-1
loop_b:
	incq -8(%rbp)
	
	movq $61, %rdi
	movq -8(%rbp), %rdx
	movq $2, %rsi
	call print_box # Upper border

	movq $61, %rdi
	movq -8(%rbp), %rdx
	movq $height, %rsi
	call print_box # Lower border
	
	movq -8(%rbp), %r8
	cmpq width, %r8
	jle loop_b

	popq %r8

	pushq $1
loop_c:
	incq -8(%rbp)
	
	movq $61, %rdi
	movq -8(%rbp), %rsi
	movq $1, %rdx
	call print_box # Upper border

	movq $61, %rdi
	movq -8(%rbp), %rsi
	movq $width , %rdx
	call print_box # Lower border
	
	movq -8(%rbp), %r8
	cmpq height,%r8
	jle loop_c

	popq %r8

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	
### Prints the game title in the first line of the terminal
### 	Arguments:
### none
###  	Returns:
### none
print_title:
	## Prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq width, %rax
	movq $2, %rcx
	movq $0, %rdx
	divq %rcx
	subq $10, %rax
	pushq %rax

	movq $1, %rsi
	
	popq %rdx
	movq $32, %rdi
	
	call print_char_at_coord

	movq $0, %rax
	movq $title_o, %rdi
	call printf

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	
### Prints the input string on the first line of the terminal
### 	Arguments:
### none
###  	Returns:
### none
print_input_str:
	## Prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $1, %rsi
	
	movq $1, %rdx
	movq $32, %rdi
	
	call print_char_at_coord

	movq $0, %rax
	movq $input_o, %rdi
	call printf

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Prints the final message
### 	Arguments:
### none
###  	Returns:
### none
print_you_lost:
	## Prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq width, %rax
	movq $2, %rcx
	movq $0, %rdx
	divq %rcx
	subq $7, %rax
	pushq %rax

	movq height, %rax
	movq $2, %rcx
	movq $0, %rdx
	divq %rcx
	movq %rax, %rsi
	
	popq %rdx
	movq $32, %rdi
	
	call print_char_at_coord

	movq $0, %rax
	movq $you_lost_o, %rdi
	call printf

	## Restore original cursor position after game ends
	movq height, %rsi
	movq $1, %rdx
	movq $61, %rdi
	call print_char_at_coord

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

### Prints the highscore string and the highscore on the upper left corner of the terminal.
### 	Arguments:
### none
###  	Returns:
### none
print_high_score:
	## Prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq width, %rax
	subq $35, %rax
	pushq %rax

	movq $1, %rsi
	
	popq %rdx
	movq $32, %rdi
	
	call print_char_at_coord

	movq $0, %rax
	movq $high_score_str, %rdi
	call printf

	movq $0, %rax
	movq $high_score, %rdi
	call printf

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
	
### Prints the current score in its correct place
### 	Arguments:
### none
###  	Returns:
### none
print_curr_score:
	## Prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq width, %rax
	subq $10, %rax
	pushq %rax

	movq $1, %rsi
	
	popq %rdx
	movq $32, %rdi
	
	call print_char_at_coord

	movq $0, %rax
	movq $curr_score_o, %rdi
	movq curr_score, %rsi
	call printf

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret
