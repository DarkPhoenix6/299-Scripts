#!/bin/bash
fortune | cowsay -f `ls /usr/share/cowsay/cows/ | shuf -n 1`

if [ "$(id -u)" = "1003" ]; then
	echo "Donald Trump for POTUS!" | cowsay -f `ls /usr/share/cowsay/cows/ | shuf -n 1`
fi
