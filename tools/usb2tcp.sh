#!/bin/bash

source variables.sh
source user_variables.sh

# Devices, streaming
usb_dev=$USB_DEV_2
usb_bps=$USB_BPS
outbound_tcp_port=$OUTBOUND_TCP_PORT

# Run streaming
str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port} -c $USER_DIR/$APP_NAME/receiver_cfg/um980-rover-automotive.cmd -b 1
