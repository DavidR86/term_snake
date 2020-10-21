# term_snake
snake game in x86 assembly for ANSI terminals (Only runs on Linux)

To build and run: (See the install.sh script)
- Run the install.sh script, or:
   - Make a symlink of your keyboard stream to term_snake/symlink/keyboard.
   - set read permissions of the stream for non-root users to read (can be set back after done running the game).
   
- Go to the src folder with cd.
- Run "gcc -o snake snake.s -no-pie"
- Run "./snake" to play the game.


- If the audio does not stop after the game is over, run "sudo pkill sh && pkill aplay".
Required software:
- aplay
- grep
- pgrep
- a terminal with ANSI support
- preferably a terminal with emoji support
