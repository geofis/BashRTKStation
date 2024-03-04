#!/bin/bash

# Variables
source variables.sh
source user_variables.sh

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

# Press enter to quit
read -p "Please REBOOT. Press ENTER to quit" x
