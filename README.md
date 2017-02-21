# 299-Scripts

this is designed to be run manually or with rc.local upon boot-up 

run as root:	

  apt-get install git -y
  
  cd /root/
  
  rm -r 299-Scripts/ initial_setup/ README.md
 
  git -C /root/ clone https://github.com/DarkPhoenix6/299-Scripts.git
  
  cd /root/299-Scripts/
  
  cp -a * ..
  
  cd ../
  
  rm -r 299-Scripts/
  
  touch /var/log/initial_setup.log
  
  bash -x /root/initial_setup/mail/initial_install_script.sh \<hostname> \<your_domain> &>> /var/log/initial_setup.log

or to send stdout and stderr to different files

  bash -x /root/initial_setup/mail/initial_install_script.sh \<hostname> \<your_domain> 2>> /var/log/initial_setup.err.log 1>> /var/log/initial_setup.log



you can follow the install process by using "tail -f /var/log/initial_setup" 
while in another terminal...

or by issuing 
"bash -x /root/initial_setup/mail/initial_install_script.sh \<hostname> \<your_domain> &>> /var/log/initial_setup.log"
in "screen"
