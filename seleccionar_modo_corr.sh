#!/bin/bash
# Bash Menu Script Example

# base_name="$(date +"%Y%m%d-%H%M%S")"
dir="/home/pi/arch_rtk"
suffix="-ubx-nmea-data.ubx"

# Menu
PS3='Elige tu opción: '
options=("corr->rece" "corr->rec & sol->TCP" "corr->rece & sol->TCP & sol->arch" "Salir")
select opt in "${options[@]}"
do
    case $opt in
        "corr->rece")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyS0:38400:8:n:1
            break
            ;;
        "corr->rec & sol->TCP")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyS0:38400:8:n:1 &\
             /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://ttyACM0:115200:8:n:1 -out tcpsvr://localhost:3001
            break
            ;;
        "corr->rece & sol->TCP & sol->arch")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyS0:38400:8:n:1 &\
             /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://ttyACM0:115200:8:n:1 -out tcpsvr://localhost:3001 -out file://$dir/"$(date +"%Y%m%d-%H%M%S")"$suffix
            break
            ;;
        "Salir")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
