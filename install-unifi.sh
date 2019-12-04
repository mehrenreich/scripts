#!/bin/bash
#
# All steps taken from https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu
#
# (C) 2019 Michael Ehrenreich <michael.ehrenreich@mailbox.org>
#

source /etc/os-release
if [[ $NAME != "Ubuntu" ]] || [[ $VERSION_ID != "18.04" ]] ; then
        echo >/dev/stderr
        echo "This script have been tested on Ubuntu 18.04." >/dev/stderr
        echo "For other operating systems and / or versions, please modify this script" >/dev/stderr
        echo "and remove this check." >/dev/stderr
        echo >/dev/stderr
        exit 1
fi

function install_key {
	id=$1
	apt-key list $id 2>&1 | grep -A1 -wq pub
	[[ $? != 0 ]] && apt-key adv --keyserver keyserver.ubuntu.com --recv $id
}

# install prerequisites
apt update -y
apt install -y ca-certificates apt-transport-https gnupg

# fetch and install apt key for unifi repository
install_key 06E85760C0A52C50

# add apt source for unifi
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/unifi.list

# fetch and install apt key for mongodb repository
install_key 0C49F3730359A14518585931BC711F9BA15703C6

# add apt source for mongodb
echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.4.list

# udpate apt cache
apt update -y

# install unifi
apt install unifi
