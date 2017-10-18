#!/bin/bash
# Get updates
echo "getting updates"
apt-get update
# Install Uncomplicated Firewall (UFW)
echo "installing Uncomplicated firewall"
apt-get install ufw -y
# Upgrade all installed packages
echo "installing updates"
apt-get upgrade -y
# Clean up unnecessary junk
echo "running autoclean and autoremove"
apt-get autoclean
apt-get autoremove -y
# enable UFW
echo "enabling UFW"
ufw enable
# make log dir
echo "creating /var/local"
mkdir /var/local/
# Create/clear log files
echo "creating log files in /var/local"
echo -n "" > /var/local/ASAO.log
echo -n "" > /var/local/mediafiles.log
echo -n "" > /var/local/cronjoblist.log
# Add additional instructions to log file
echo "adding instructions to log file"
echo "getent group <groupname> |||| Users in group" >> /var/local/ASAO.log
echo "/etc/pam.d/common-password	minlen-8 |||| password length" >> /var/local/ASAO.log
echo "/etc/login.defs |||| Password expiration" >> /var/local/ASAO.log
echo "/etc/ssh/sshd_config	PermitRootLogin no' |||| Disable Root Login" >> /var/local/ASAO.log
echo "Don't Forget to Restart"
echo "more password stuff @ https://www.cyberciti.biz/tips/linux-check-passwords-against-a-dictionary-attack.html"
# Install libpam-cracklib which is used to check passwords
echo "installing libpam-cracklib for passwords"
apt-get install libpam-cracklib -y
# Setup Pam config
sed -e "25s/.*/password	requisite	pam_cracklib.so retry=3 minlen=8 difok=3 ucredit=-1 1credit=-2 ocredit=-1/" /etc/pam.d/common-password > /var/local/temp.txt
sed -e "26s/.*/password	[success=1 default=ignore]	pam_unix.so obscure use_authtok try_first_pass sha512 remember=5/" /var/local/temp.txt > /var/local/temp2.txt
mv /var/local/temp2.txt /var/local/temp.txt
mv /etc/pam.d/common-password /etc/pam.d/common-password.old
mv /var/local/temp.txt /etc/pam.d/common-password
# Setup password aging policy
sed -e "s/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	30" /etc/login.defs > /var/local/temp3.txt
mv /var/local/temp3.txt /etc/login.defs
# Find all video files
echo "||||Video Files||||" >> /var/local/mediafiles.log
locate *.mkv *.webm *.flv *.vob *.ogv *.drc *.gifv *.mng *.avi$ *.mov *.qt *.wmv *.yuv *.rm *.rmvb *.asf *.amv *.mp4$ *.m4v *.mp *.m?v *.svi *.3gp *.flv *.f4v >> /var/local/mediafiles.log
echo "||||Audo Files||||" >> /var/local/mediafiles.log
locate *.3ga *.aac *.aiff *.amr *.ape *.arf *.asf *.asx *.cda *.dvf *.flac *.gp4 *.gp5 *.gpx *.logic *.m4a *.m4b *.m4p *.midi *.mp3 *.pcm *.rec *.snd *.sng *.uax *.wav *.wma *.wpl *.zab >> /var/local/mediafiles.log
# Lists all cronjobs & output to /var/local/cronjoblist.log
crontab -l >> /var/local/cronjoblist.log
# Install clam antivirus
apt-get install clamav -y
# Update clam signatures
freshclam
# Run a full scan of the "/home" directory
sudo clamscan -r /home
