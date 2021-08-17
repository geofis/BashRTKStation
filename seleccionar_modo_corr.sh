#!/bin/bash
# Bash Menu Script Example

base_name="$(date +"%Y%m%d-%H%M%S")"
corr_name="$base_name-rtcm3-base-corrections.rtcm3"

# Menu
PS3='Elige tu opción: '
options=("Enviar correcciones a receptor" "Enviar correcciones a receptor y transmitir soluciones por TCP" "Enviar correcciones a receptor y guardarlas localmente" "Enviar correcciones a receptor, guardarlas localmente y transmitir soluciones por TCP" "Salir")
select opt in "${options[@]}"
do
    case $opt in
        "Enviar correcciones a receptor")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyACM0:115200:8:n:1
            break
            ;;
        "Enviar correcciones a receptor y transmitir soluciones por TCP")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyACM0:115200:8:n:1:#3001
            break
            ;;
        "Enviar correcciones a receptor y guardarlas localmente")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyACM0:115200:8:n:1 -out file:///home/pi/$corr_name
            break
            ;;
        "Enviar correcciones a receptor, guardarlas localmente y transmitir soluciones por TCP")
            echo "Seleccionado: $opt"
            /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://RDSD@148.103.189.6:5020/test -px 2078678.9081 -5683737.3052 2006886.9294  -out serial://ttyACM0:115200:8:n:1#3001 -out file:///home/pi/$corr_name
            break
            ;;
        "Salir")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
