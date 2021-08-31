#!/bin/bash
# xmessage `ifconfig wlan0 | grep 'inet ' | awk '{print $2}'`
xmessage `lsusb | grep U-Blox | awk '{print $7}'`
