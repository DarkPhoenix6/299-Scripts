# 299-Scripts

run as root:

cd /root/
rm -r 299-Scripts/ initial_setup/ README.md
git -C /root/ clone https://github.com/DarkPhoenix6/299-Scripts.git
cd /root/299-Scripts/
cp -a * ..
cd ../
rm -r 299-Scripts/
touch /var/log/initial_setup.log
bash -x /root/initial_setup/mail/initial_install_script.sh fedun.ca &>> /var/log/initial_setup.log