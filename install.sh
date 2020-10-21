#!/bin/bash
## Run this script from inside the term_snake folder, otherwise it will not work (because of relative addressing).
## You might need to do chmod +x ./install.sh to be able to execute the script.
## You can also do this manually if you follow these steps.
## The script attempts to:
## - Create a symbolic link from the correct keyboard device at ./symlink/keyboard pointing towards /dev/input/by-id/<name_of_keyboard>
## - Set the read permissions of the keyboard file to read, so the game can read the keypresses. Alternatively, you can run the game as sudo.
## - Compile the game for your machine using gcc

echo -e "\033[1m\033[33mThis script will attempt to set up the necessary requirements to play the game. Run it while inside the term_snake folder"
echo -e "(cd to the term_snake folder and run ./install.sh )" 
echo -e "The program needs to have temporary read permissions to the keyboard stream to read keypresses directly. \n\033[22m"
ls /dev/input/by-id/ | grep kbd
echo -e "\033[1m\nPlease copy the name of your keyboard from those appearing in this list, exactly as it is written, and press enter. \n\033[22m"
read keyboard
echo -e "\033[1mCreating symbolic link to keyboard stream..."
ln -s -f -v /dev/input/by-id/$keyboard ./symlink/keyboard
echo -e "Now the file permissions have to be set to read using chmod ( sudo is required, you can change the permissions back after done running the game)"
echo -e "If you don't trust the script, you can open it with a text editor to see what it is doing."
echo -e "Please enter your password. It will be invisible as you type it..."
sudo chmod o+r ./symlink/keyboard
echo -e "Done! Now the game should be able to read the keyboard input. If you cannot move the character, there was likely an error with this step \n"
echo -e "The game will now be compiled. You can compile it yourself by running 'cd ./src/ && gcc -o ../snake snake.s -no-pie && cd ..'"
cd ./src && gcc -o ../snake snake.s -no-pie && cd ../
echo -e "Done! Now you should be able to play the game by writing './snake' from withing the term_snake folder \nPro-tip: You can customize your terminal to make the game look different ( by changing the size of the window, the fonts, colors and even the background ) \n\033[0m"

