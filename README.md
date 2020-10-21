# term_snake
## snake game in x86 assembly for ANSI terminals (Only runs on Linux)

### Information
- The game runs in real time directly in the terminal. It reads keyboard input from /dev/input/ directly and the graphics are made with ANSI escape codes.
- The game has retro-ounding music.
- There best version is the one that uses Unicode emojis, but if your terminal does not support it, you can run the ASCII version.
- Pro-tip: You can customize your terminal to make the game look different (by changing the size of the window, the fonts, colors and even the background)

### To build and run: (See the install.sh script)
- Run the install.sh script from within the term_snake folder (cd to it and run ./install.sh). You might need to run chmod +x ./install.sh to be able to run the script. To do it manually, you can:
  - Create a symbolic link from the correct keyboard device at ./symlink/keyboard pointing towards /dev/input/by-id/<name_of_keyboard>
  - Set the read permissions of the keyboard file to read, so the game can read the keypresses. Alternatively, you can run the game as sudo.
  - Compile the game for your machine using gcc
  - Go to the src folder with cd.
  - Run "gcc -o snake snake.s -no-pie"
  - Run "./snake" to play the game.

### Issues
- If the audio does not stop after the game is over, run "sudo pkill sh && sudo pkill aplay".
- If you cannot move, it means the keyboard stream cannot be read. Make sure you created the symbolic link or ran ./install.sh.
- If you cannot see the emojis, you need to run the game from a terminal that supports them, or install an emoji font.
- Make sure you have the required software.

## Required software: (The newer versions of Ubuntu should have everything that is required. Debian and other distributions might not have emoji fonts)
- aplay (Linus utility to play sound)
- grep
- pgrep
- a terminal with ANSI escape character support
- preferably a terminal with emoji support
- GCC and the C standard library
