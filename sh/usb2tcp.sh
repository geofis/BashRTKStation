#!/bin/bash

# Devices, streaming
usb_dev=ttyACM0
usb_bps=230400
outbound_tcp_port=3001

# Run streaming
/home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port}
