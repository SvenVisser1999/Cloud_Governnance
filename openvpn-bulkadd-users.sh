#!/bin/bash

# Fast way for adding lots of users to an openvpn-install setup
# See the main openvpn-install project here: https://github.com/Nyr/openvpn-install
# openvpn-useradd-bulk is NOT supported or maintained and could become obsolete or broken in the future
# Created to satisfy the requirements here: https://github.com/Nyr/openvpn-install/issues/435

if readlink /proc/$$/exe | grep -qs "dash"; then
	echo "This script needs to be run with bash, not sh"
	exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 2
fi

newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-common.txt /home/svisser/$1.ovpn
	echo "<ca>" >> /home/svisser/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> /home/svisser/$1.ovpn
	echo "</ca>" >> /home/svisser/$1.ovpn
	echo "<cert>" >> /home/svisser/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> /home/svisser/$1.ovpn
	echo "</cert>" >> /home/svisser/$1.ovpn
	echo "<key>" >> /home/svisser/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> /home/svisser/$1.ovpn
	echo "</key>" >> /home/svisser/$1.ovpn
	echo "<tls-auth>" >> /home/svisser/$1.ovpn
	cat /etc/openvpn/ta.key >> /home/svisser/$1.ovpn
	echo "</tls-auth>" >> /home/svisser/$1.ovpn
}

if [ "$1" = "" ]; then
	echo "This tool will let you add new user certificates in bulk to your openvpn-install"
	echo ""
	echo "Run this script specifying a file which contains a list of one username per line"
	echo ""
	echo "Eg: openvpn-useradd-bulk.sh users.txt"
	exit
fi

while read line; do
	cd /etc/openvpn/easy-rsa/
	./easyrsa build-client-full $line nopass
	newclient "$line"
	echo ""
	echo "Client $line added, configuration is available at" /home/svisser/"$line.ovpn"
	echo ""
done < $1