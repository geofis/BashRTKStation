#!/bin/bash

# Delete variables file
#rm /usr/local/bin/variables.sh

# Variables
source variables.sh
source user_variables.sh

# Backup files
echo "Creating backup copies..."
sudo cp "$BOOT_DIR/firmware/cmdline.txt" "$BOOT_DIR/firmware/cmdline_backup.txt"
sudo cp "$BOOT_DIR/firmware/config.txt" "$BOOT_DIR/firmware/config_backup.txt"

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

# gpsd and chrony. Adapted from RTKBASE
echo "Installing and configuring gpsd and chrony ..."
#chrony
apt install chrony -y
#Disabling and masking systemd-timesyncd
systemctl stop systemd-timesyncd
systemctl disable systemd-timesyncd
systemctl mask systemd-timesyncd
#Adding GPS as source for chrony
grep -q 'set larger delay to allow the GPS' /etc/chrony/chrony.conf || echo '# set larger delay to allow the GPS source to overlap with the other sources and avoid the falseticker status' >> /etc/chrony/chrony.conf
grep -qxF 'refclock SHM 0 refid GNSS precision 1e-1 offset 0 delay 0.2' /etc/chrony/chrony.conf || echo 'refclock SHM 0 refid GNSS precision 1e-1 offset 0 delay 0.2' >> /etc/chrony/chrony.conf
#Adding PPS as an optionnal source for chrony
grep -q 'refclock PPS /dev/pps0 refid PPS lock GNSS' /etc/chrony/chrony.conf || echo '#refclock PPS /dev/pps0 refid PPS lock GNSS' >> /etc/chrony/chrony.conf
#Overriding chrony.service with custom dependency
cp /lib/systemd/system/chrony.service /etc/systemd/system/chrony.service
sed -i s/^After=.*/After=gpsd.service/ /etc/systemd/system/chrony.service
#gpsd
apt install gpsd -y
#disable hotplug
sed -i 's/^USBAUTO=.*/USBAUTO="false"/' /etc/default/gpsd
#Setting correct input for gpsd
sed -i 's/^DEVICES=.*/DEVICES="tcp:\/\/localhost:3001"/' /etc/default/gpsd
#Adding example for using pps
grep -qi 'DEVICES="tcp:/localhost:3001 /dev/pps0' /etc/default/gpsd || sed -i '/^DEVICES=.*/a #DEVICES="tcp:\/\/localhost:3001 \/dev\/pps0"' /etc/default/gpsd
#gpsd should always run, in read only mode
sed -i 's/^GPSD_OPTIONS=.*/GPSD_OPTIONS="-n -b"/' /etc/default/gpsd
#Overriding gpsd.service with custom dependency
cp /lib/systemd/system/gpsd.service /etc/systemd/system/gpsd.service
sed -i 's/^After=.*/After=usb2tcp.service/' /etc/systemd/system/gpsd.service
sed -i '/^# Needed with chrony/d' /etc/systemd/system/gpsd.service
#Add restart condition
grep -qi '^Restart=' /etc/systemd/system/gpsd.service || sed -i '/^ExecStart=.*/a Restart=always' /etc/systemd/system/gpsd.service
grep -qi '^RestartSec=' /etc/systemd/system/gpsd.service || sed -i '/^Restart=always.*/a RestartSec=30' /etc/systemd/system/gpsd.service
#Add ExecStartPre condition to not start gpsd if str2str_tcp is not running. See https://github.com/systemd/systemd/issues/1312
grep -qi '^ExecStartPre=' /etc/systemd/system/gpsd.service || sed -i '/^ExecStart=.*/i ExecStartPre=systemctl is-active usb2tcp.service' /etc/systemd/system/gpsd.service
#Reload systemd services and enable chrony and gpsd
systemctl daemon-reload
systemctl enable gpsd
#systemctl enable chrony # chrony is already enabled

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
  cd $USER_DIR/$RTKLIB_DIR/app/pos2kml/gcc/
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
