#!/bin/bash

source variables.sh

# Devices, streaming
usb_dev=$USB_DEV
usb_bps=$USB_BPS
outbound_tcp_port=$OUTBOUND_TCP_PORT

# Run streaming
str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port}
