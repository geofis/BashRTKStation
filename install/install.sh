#!/bin/bash

echo "\nChanging to /home/pi dir ...\n"

cd /home/pi/

echo "\nUpdating packages information from sources ...\n"

apt-get update -y

# Install gfortran
echo "\nInstalling gfortran ...\n"
apt install -y gfortran

# Install xterm
echo "\nInstalling xterm ...\n"
apt install -y xterm

# Install gpsd
echo "\nInstalling gpsd, gpsd-clients and python-gps ...\n"
apt install -y gpsd gpsd-clients python-gps

# Install RTKLIB
echo "\nRemoving older versions of RTKLIB repo ...\n"
rm -rf RTKLIB
echo "\nDownloading RTKLIB repo ...\n"
git clone https://github.com/rtklibexplorer/RTKLIB.git

# Symlink app dir
echo "\nSymlinking RTKLIB directory structure for compatibility ...\n"
ln -s /home/pi/RTKLIB/app/consapp/* /home/pi/RTKLIB/app/

# Compile RTKLIB executables
echo "\nCompilling str2str app (this may take a while) ...\n"
cd ./RTKLIB/app/str2str/gcc/
make

echo "\nCompilling rtkrcv app (this may take a while) ...\n"
cd ../../rtkrcv/gcc/
make

echo "\nCompiling convbin app (this may take a while) ...\n"
cd ../../convbin/gcc/
make

echo "\nCompiling iers app ...\n"
cd ../../../lib/iers/gcc
make

echo "\nCompiling rnx2rtkp app (this may take a while) ...\n"
cd ../../../app/rnx2rtkp/gcc
make

echo "\nCompiling pos2kml app ...\n"
cd ../../pos2kml/gcc/
make

# Create directory for credentials
echo "\nCreating dir for credentials file ...\n"
mkdir /home/pi/BashRTKStation/.credentials

# Create directory for rtk files
echo "\nCreating dir for rtk files\n"
mkdir /home/pi/arch_rtk

chown pi:pi /home/pi/BashRTKStation/.credentials
chown pi:pi /home/pi/arch_rtk

# Copy shortcuts to desktop
echo "\nCopying shortcuts to Desktop ...\n"
cp -aP /home/pi/BashRTKStation/sh/shortcuts/* /home/pi/Desktop

# Customizing xterm
echo "xterm*faceName: Ubuntu Mono" > /home/pi/.Xresources
echo "xterm*faceSize: 16" >> /home/pi/.Xresources
echo "xterm*renderFont: true" >> /home/pi/.Xresources
chown pi:pi /home/pi/.Xresources
systemctl restart display-manager

# Final message
echo "If you want the Desktop icons to launch without asking, open a File Manager window, go to 'Edit > Preferences > General' and check option 'Don't ask options on launch executable"

# Press enter to quit
read -p "Press ENTER to quit" x

