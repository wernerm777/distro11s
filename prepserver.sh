#!/bin/bash

echo "Setting locale environment"
export LC_ALL=C

echo "preparing Ubuntu with the latest updates"

apt-get update
apt-get upgrade
apt-get install -f


echo "Preparing system with prerequisite software...."

apt-get install git
apt-get install dpkg
apt-get install debian-archive-keyring
apt-get install gnupg
apt-get install ubuntu-keyring
apt-get install debootstrap
apt-get install make


echo "Creating distro host file for IP addressing"
echo "11" > /etc/distro11s-hostnumber
cp /etc/locale.alias /etc/locale.gen

echo "Preparing build directory"
mkdir /builds
cd /builds
echo "Cloning git Archive"
git clone https://github.com/cozybit/distro11s

echo "prepping initial environment"
touch /root/.ssh/known_hosts

apt-get install python-dev uml-utilities git debootstrap autoconf libtool flex bison qemu

wget -O /usr/share/qemu/pxe-rtl8139.bin \
     "http://svn.savannah.gnu.org/viewvc/*checkout*/trunk/pc-bios/pxe-rtl8139.bin?root=qemu"
wget -O /usr/share/qemu/pxe-e1000.bin \
     "http://svn.savannah.gnu.org/viewvc/*checkout*/trunk/pc-bios/pxe-e1000.bin?root=qemu"
sudo apt-get remove gnu-fdisk

echo "Creating distro11s config file"
cp distro11s.sample.conf distro11s.conf
echo "Fething current builds.... Please be patient, this takes some time"
./scripts/fetch.sh

echo "Retrieving packages for all builds and building your various environment. This will take time"
./scripts/build.sh
echo "Build complete, please dont forgget to make changes to your default build config as below:"
echo "Please make the following changes to the config file in /builds/distro11s/distro11s.conf"
echo '
#Make the following changes
	# do you want the board to know about your development host?  Some boards
	# (e.g., qemu) will use this to automount an sshfs from your dev machine at
	# boot time.
	DISTRO11S_HOST_IP=69.30.242.235

	# Want your target board to have a default root password?  Set it here.
	# IMPORTANT: This variable is used ONLY at build time. This means that all the
	# nodes created from a specific distro11s build (USB installer) will share the
	# same root password. You will need to rebuild the rootpassword package and
	# then create a new USB installer. Also, you can always change the root
	# password manually using "sudo passwd root" from any of the nodes.
	DISTRO11S_ROOT_PW="Warcraft1"

	# If a name is given, a bridge with that name will be created and all tap
	# interfaces will be bridged together.  This is required for multiple qemu
	# instances
	DISTRO11S_BRIDGE="br0"
'
echo "You may also include a config build in any build environment as you would like to change as per environment"
echo "If you want to support simultaneous builds for different boards, you can have a different config file for each board."
echo "Just set the DISTRO11S_CONF environment variable to the config file that you want to use."
echo "I suggest you put the config file inside the /board directory and change the variable above accordingly"
