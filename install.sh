#!/bin/bash

echo -e "This script will attempt to set up the necessary requirements to play the game."
echo -e "The program needs to have temporary read permissions to the keyboard stream to read keypresses directly. \n"
ls /dev/input/by-id/
echo -e "\nPlease copy the name of your keyboard from those appearing in this list, exactly as it is written, and press enter. \n"
read keyboard
echo -e "Creating symbolic link to keyboard stream..."
ln -s -f -v /dev/input/by-id/$keyboard ./symlink/keyboard
echo -e "Now the file permissions have to be set to read using chmod (sudo is required, you can the permissions back after done running the game)"
echo -e "If you don't trust the script, you can run it with a text editor to see what it is doing."
echo -e "Please enter your password. It will be invisible as you type it..."
sudo chmod o+r ./symlink/keyboard
echo - "Done! Now you should be able to play the game. If you cannot move the character, there was likely an error with this installer."
