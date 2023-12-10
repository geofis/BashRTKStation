#!/bin/bash

# Delete variables file
#rm /usr/local/bin/variables.sh

# Variables
source variables.sh
source user_variables.sh

# Backup files
echo "Creating backup copies..."
sudo cp "$BOOT_DIR/firmware/cmdline.txt" "$BOOT_DIR/firmware/cmdline_backup.txt"
sudo cp "$BOOT_DIR/firmare/config.txt" "$BOOT_DIR/firmware/config_backup.txt"

# Enable UART in config.txt
echo "Enabling UART in config.txt..."
if grep -q "enable_uart=1" "$BOOT_DIR/firmware/config.txt"; then
    echo "UART is already enabled"
else
    sudo sh -c "echo 'enable_uart=1' >> $BOOT_DIR/firmware/config.txt"
fi

# Delete console access from serial
echo "Disabling serial console in cmdline.txt..."
sudo sed -i 's/console=serial0,115200 //' "$BOOT_DIR/firmware/cmdline.txt"

# Changing to user dir
echo "Changing to user dir ..."
cd $USER_DIR

# Updating packages
echo "Updating packages information from sources ..."
apt-get update -y

# Install gfortran
echo "Installing gfortran ..."
apt install -y gfortran

# Install gpsd
#echo "Installing gpsd, gpsd-clients and python-gps ..."
#apt install -y gpsd gpsd-clients python-gps

# Check for --no-rtklib-compile flag
if [ "$1" != "--skip-rtklib" ]; then
  # Install RTKLIB
  echo "Removing older versions of RTKLIB repo ..."
  rm -rf $RTKLIB_DIR
  echo "Downloading RTKLIB repo ..."
  sudo -u $USERNAME git clone https://github.com/rtklibexplorer/RTKLIB.git

  # Symlink app dir
  echo "Symlinking RTKLIB directory structure for compatibility ..."
  ln -s $USER_DIR/$RTKLIB_DIR/app/consapp/* $USER_DIR/$RTKLIB_DIR/app/

  # Compile RTKLIB executables
  echo "Compilling str2str app (this may take a while) ..."
  cd ./$RTKLIB_DIR/app/str2str/gcc/
  make
  mv str2str $BIN_DIR/

  #echo "Compilling rtkrcv app (this may take a while) ..."
  #cd ../../rtkrcv/gcc/
  #make
  #mv rtkrcv $BIN_DIR/

  #echo "Compiling convbin app (this may take a while) ..."
  #cd ../../convbin/gcc/
  #make
  #mv convbin $BIN_DIR/

  echo "Compiling iers app ..."
  cd ../../../lib/iers/gcc
  make
  #cp iers $BIN_DIR/

  #echo "Compiling rnx2rtkp app (this may take a while) ..."
  #cd ../../../app/rnx2rtkp/gcc
  #make
  #mv rnx2rtkp $BIN_DIR/

  echo "Compiling pos2kml app ..."
  cd ../../pos2kml/gcc/
  make
  #mv pos2kml $BIN_DIR/
fi

# Create directory for credentials
echo "Creating dir for credentials file ..."
sudo -u $USERNAME mkdir $USER_DIR/$APP_NAME/$CREDENTIALS_DIR

# Create directory for rtk files
echo "Creating dir for rtk files"
sudo -u $USERNAME mkdir $USER_DIR/$RTK_FILES_DIR

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
cp $USER_DIR/$APP_NAME/$TOOLS_DIR/$USER_VARIABLES_FILE $BIN_DIR/
chmod +x $BIN_DIR/$USER_VARIABLES_FILE
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
