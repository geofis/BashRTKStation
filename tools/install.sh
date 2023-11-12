#!/bin/bash

# Variables
source variables.sh

# Changing to user dir
echo "\nChanging to user dir ...\n"
cd $USER_DIR

# Updating packages
echo "\nUpdating packages information from sources ...\n"
apt-get update -y

# Install gfortran
echo "\nInstalling gfortran ...\n"
apt install -y gfortran

# Install gpsd
echo "\nInstalling gpsd, gpsd-clients and python-gps ...\n"
#apt install -y gpsd gpsd-clients python-gps

# Install RTKLIB
echo "\nRemoving older versions of RTKLIB repo ...\n"
rm -rf $RTKLIB_DIR
echo "\nDownloading RTKLIB repo ...\n"
git clone https://github.com/rtklibexplorer/RTKLIB.git

# Symlink app dir
echo "\nSymlinking RTKLIB directory structure for compatibility ...\n"
ln -s $USER_DIR/$RTKLIB_DIR/app/consapp/* $USER_DIR/$RTKLIB_DIR/app/

# Compile RTKLIB executables
echo "\nCompilling str2str app (this may take a while) ...\n"
cd ./$RTKLIB_DIR/app/str2str/gcc/
make

#echo "\nCompilling rtkrcv app (this may take a while) ...\n"
#cd ../../rtkrcv/gcc/
#make

#echo "\nCompiling convbin app (this may take a while) ...\n"
#cd ../../convbin/gcc/
#make

echo "\nCompiling iers app ...\n"
cd ../../../lib/iers/gcc
make

#echo "\nCompiling rnx2rtkp app (this may take a while) ...\n"
#cd ../../../app/rnx2rtkp/gcc
#make

echo "\nCompiling pos2kml app ...\n"
cd ../../pos2kml/gcc/
make

# Create directory for credentials
echo "\nCreating dir for credentials file ...\n"
mkdir $USER_DIR/$APP_NAME/$CREDENTIALS_DIR

# Create directory for rtk files
echo "\nCreating dir for rtk files\n"
mkdir $USER_DIR/$RTK_FILES_DIR

# Set dir ownership
chown $USERNAME:$USERNAME $USER_DIR/$APP_NAME/$CREDENTIALS_DIR
chown $USERNAME:$USERNAME $USER_DIR/$RTK_FILES_DIR

# Copy scripts, +x
cp $USER_DIR/$APP_NAME/$TOOLS_DIR/$ROVER_SCRIPT $BIN_DIR/
chmod +x $BIN_DIR/$ROVER_SCRIPT
cp $USER_DIR/$APP_NAME/$TOOLS_DIR/$CREDENTIALS_SCRIPT $BIN_DIR/
chmod +x $BIN_DIR/$CREDENTIALS_SCRIPT
cp $USER_DIR/$APP_NAME/$TOOLS_DIR/$VARIABLES_FILE $BIN_DIR/
chmod +x $BIN_DIR/$VARIABLES_FILE
cp $USER_DIR/$APP_NAME/$TOOLS_DIR/$USB2TCP_SCRIPT $BIN_DIR/
chmod +x $BIN_DIR/$USB2TCP_SCRIPT

# Creating service: USB output to TCP port
cp $USER_DIR/$APP_NAME/$SERVICES_DIR/usb2tcp.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable usb2tcp.service

# Final message
#echo "Run rover.sh to load the user interface"

# Press enter to quit
read -p "Please REBOOT. Press ENTER to quit" x
