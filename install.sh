#!/bin/bash

apt-get install git -y
cd /root/

#this removes any previous downloads of the installation packages
rm -r 299-Scripts/ initial_setup/ README.md

git -C /root/ clone https://github.com/DarkPhoenix6/299-Scripts.git

cd /root/299-Scripts/

cp -a * ..

cd ../

rm -r 299-Scripts/

touch /var/log/initial_setup.log

exit
#######END :) #######
