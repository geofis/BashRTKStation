#!/bin/bash

base_name="$(date +"%Y%m%d-%H%M%S")"
nmea_name="$base_name-ubx-nmea-data.ubx"
#rover_raw_name="$base_name-rtcm3-rover-raw.rtcm3"

# Send NMEA positions to TCP server (will try to send to BT) and save to file
echo "Saving NMEA data to /home/pi/$nmea_name"
#/home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://ttyACM0:115200:8:n:1 -out file:///home/pi/$nmea_name -out tcpsvr://localhost:3001
#/home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://ttyACM0:115200:8:n:1 -out file:///home/pi/$nmea_name -out serial://serial1:115200:8:n:1
/home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://ttyACM0:115200:8:n:1 -out file:///home/pi/$nmea_name

# Save raw RTMC3 messages file from the rover
#echo "Saving NMEA data to /home/pi/$rover_raw_name"
#/home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://serial0:115200:8:n:1 -out file:///home/pi/$rover_raw_name


