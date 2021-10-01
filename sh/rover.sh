#!/bin/bash

echo "
Send corrections to ROVER,
receive solutions and observations"

# Verify credentials
cred_path=/home/pi/BashRTKStation/.credentials/credentials
if [ ! -f "$cred_path" ]
then
  read -p "
File of credentials not found.
For receiving or sending corrections,
this file must be generated.
¿Create it now? [Y/n]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    /home/pi/BashRTKStation/sh/create_credentials.sh
  fi
fi

# Dirs and files
dir="/home/pi/rtk_files"
suffix="-ubx-nmea-data.ubx"

# Devices, streaming
usb_dev=ttyACM0
usb_bps=230400
serial_dev=serial0
serial_bps=115200
outbound_tcp_port=3001

# For corrections from generic source
corr_user_gen=`if [ -f "$cred_path" ]; then sed -n -e 's/^.*corr_user_gen=//p' $cred_path; fi`
corr_addr_gen=`if [ -f "$cred_path" ]; then sed -n -e 's/^.*corr_addr_gen=//p' $cred_path; fi`
corr_port_gen=`if [ -f "$cred_path" ]; then sed -n -e 's/^.*corr_port_gen=//p' $cred_path; fi`
corr_pw_gen=`if [ -f "$cred_path" ]; then sed -n -e 's/^.*corr_pw_gen=//p' $cred_path; fi`
corr_mp_gen=`if [ -f "$cred_path" ]; then sed -n -e 's/^.*corr_mp_gen=//p' $cred_path; fi`

# Timer function
timer () {
  timerfile=$(mktemp)
  progress() {
    pc=0;
    while [ -e $timerfile ]
      do
        echo -ne "$pc sec\033[0K\r"
        sleep 1
        ((pc++))
      done
  }
  progress &
}

# Count fix solutions
count_fix () {
  while :; do
    sed -n -e '/^\$GNGGA/p' $1 | awk -F "," '{ if ($7==4) print }' | echo $(wc -l) fix solutions
    sleep 5
  done
}

# Continue collecting points
continue_rover () {
  read -p "Reload menu? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      /home/pi/BashRTKStation/sh/rover.sh
    else
      exit
    fi
}

# Menu
PS3='Select: '
options=(
"CORR: NTRIP corr->rec"
"CORR+SOLS: NTRIP corr->rec & USB sol+obs->TCP"
"CORR+SOLS: NTRIP corr->rec & USB sol+obs->TCP & file"
"SOLS: USB sol+obs->TCP (combn. w/ 1 or ser.)"
"SOLS: USB sol+obs->file (combn. w/ 1 or ser.)"
"SOLS: USB sol+obs->TCP & file (combn. w/ 1 or ser.)"
"SOLS: TCP sol+obs->file (combn. w/ 2 or 4)"
"View/modify credentials"
"Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CORR: NTRIP corr->rec")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://$corr_user_gen:$corr_pw_gen@$corr_addr_gen:$corr_port_gen/$corr_mp_gen -out serial://$serial_dev:$serial_bps:8:n:1
            continue_rover
            break
            ;;
        "CORR+SOLS: NTRIP corr->rec & USB sol+obs->TCP")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://$corr_user_gen:$corr_pw_gen@$corr_addr_gen:$corr_port_gen/$corr_mp_gen -out serial://$serial_dev:$serial_bps:8:n:1 &\
             /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port}
            continue_rover
            break
            ;;
        "CORR+SOLS: NTRIP corr->rec & USB sol+obs->TCP & file")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            timer
            filename="$(date +"%Y%m%d-%H%M%S")"
            count_fix $dir/$filename$suffix & count_fix_pid=$!
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://$corr_user_gen:$corr_pw_gen@$corr_addr_gen:$corr_port_gen/$corr_mp_gen -out serial://$serial_dev:$serial_bps:8:n:1 &\
             /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port} -out file://$dir/$filename$suffix
            # kill $count_fix_pid
            rm -f $timerfile
            continue_rover
            break
            ;;
        "SOLS: USB sol+obs->file (combn. w/ 1 or ser.)")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            timer
            filename="$(date +"%Y%m%d-%H%M%S")"
            count_fix $dir/$filename$suffix & count_fix_pid=$!
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out file://$dir/$filename$suffix
            # kill $count_fix_pid
            rm -f $timerfile
            continue_rover
            break
            ;;
        "SOLS: USB sol+obs->TCP (combn. w/ 1 or ser.)")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port}
            continue_rover
            break
            ;;
        "SOLS: USB sol+obs->TCP & file (combn. w/ 1 or ser.)")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            timer
            filename="$(date +"%Y%m%d-%H%M%S")"
            count_fix $dir/$filename$suffix & count_fix_pid=$!
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://${usb_dev}:${usb_bps}:8:n:1 -out tcpsvr://localhost:${outbound_tcp_port}} -out file://$dir/$filename$suffix
            # kill $count_fix_pid
            rm -f $timerfile
            continue_rover
            break
            ;;
        "SOLS: TCP sol+obs->file (combn. with 2 or 3)")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            timer
            filename="$(date +"%Y%m%d-%H%M%S")"
            count_fix $dir/$filename$suffix & count_fix_pid=$!
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in tcpcli://localhost:3001 -out file://$dir/$filename$suffix
            # kill $count_fix_pid
            rm -f $timerfile
            continue_rover
            break
            ;;
        "View/modify credentials")
            echo "Selected: $opt"
            echo -ne "\033]0;$opt\007"
            /home/pi/BashRTKStation/sh/create_credentials.sh
            continue_rover
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
