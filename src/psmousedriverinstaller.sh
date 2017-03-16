#!/bin/sh

if [ "$(id -u)" != "0" ]; then
  echo "$0 must be run as root"
  exit 1
fi

echo 'Internet required for this to work'
cd ~

apt-get update
apt-get -y install build-essential linux-headers-generic linux-headers-`uname -r`

echo "Downloading drivers...\n";
wget -O- http://goo.gl/2G9CF | tar jx;

echo "Running install script...\n";
cd psmouse-alps;
pwd;
ls
exec ./install_alps.sh;

echo "Removing driver temp directory...\n";
rm -rf psmouse-alps

echo "Done\n";
