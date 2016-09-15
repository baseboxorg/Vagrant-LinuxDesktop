#!/bin/bash
#
# bootstrap.sh
#
# This file is specified in the Vagrantfile and is loaded by Vagrant as the
# primary provisioning script on the first `vagrant up` or subsequent 'up' with
# the '--provision' flag; also when `vagrant provision`, or `vagrant reload --provision`
# are used. It provides all of the default packages and configurations included
# with Vagrant's Ubuntu 12.04 Desktop Environment for Windows. You can also bring up your
# environment and explicitly not run provisioners by specifying '--no-provision'.

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

# Capture a basic ping result to Google's primary DNS server to determine if
# outside access is available to us. If this does not reply after 2 attempts,
# we try one of Level3's DNS servers as well. If neither IP replies to a ping,
# then we'll skip a few things further in provisioning rather than creating a
# bunch of errors.
ping_result="$(ping -c 2 8.8.4.4 2>&1)"
if [[ $ping_result != *bytes?from* ]]; then
        ping_result="$(ping -c 2 4.2.2.2 2>&1)"
fi

curl https://repogen.simplylinux.ch/txt/xenial/sources_fe18c6d2bcb4baae6fa3ad88f07a7c5b2cdb504b.txt | tee /etc/apt/sources.list

apt-get install software-properties-common python-software-properties
add-apt-repository ppa:kubuntu-ppa/backports


apt-get update && apt-get -y upgrade && apt-get -y autoremove

export LANGUAGE="en_US.UTF-8"
echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
update-locale LANG=en_US.UTF-8

apt-get install -y kubuntu-desktop

sh -c "echo '[SeatDefaults]' > /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf"
sh -c "echo 'user-session=ubuntu' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf"
sh -c "echo 'allow-guest=false' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf"
sh -c "echo 'Asia/Kuala Lumpur' > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata"

end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Provisioning complete in "$(expr $end_seconds - $start_seconds)" seconds"
if [[ $ping_result == *bytes?from* ]]; then
        echo "External network connection established, packages up to date."
else
        echo "No external network available. Package installation and maintenance skipped."
fi
