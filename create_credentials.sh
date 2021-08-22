#!/bin/bash

template_path=/home/pi/BashRTKStation/credentials_template
target_path=/home/pi/BashRTKStation/.credentials/credentials

while [ ! -f "$target_path" ]
do
  read -p "File of credentials not found. Create it now? [Y/n]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    cp $template_path $target_path
    break
  else
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  fi
done

PS3='Create credentials for: '
options=("rtk2go" "UNAVCO" "Generic" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "rtk2go")
      echo "Selected: $opt"

      output_pw0=`awk -F '=' '$1=="output_pw" {print $2}' $target_path`
      read -p "Password en rtk2go [ENTER para dejar valor actual '$output_pw0']: " output_pw
      output_pw=${output_pw:-$output_pw0}
      sed -i "s/output_pw=.*$/output_pw=$output_pw/g" $target_path

      mp_rtk2go0=`awk -F '=' '$1=="mp_rtk2go" {print $2}' $target_path`
      read -p "Mount point en rtk2go [ENTER para dejar valor actual '$mp_rtk2go0']: " mp_rtk2go
      mp_rtk2go=${mp_rtk2go:-$mp_rtk2go0}
      sed -i "s/mp_rtk2go=.*$/mp_rtk2go=$mp_rtk2go/g" $target_path

      break
      ;;
    "UNAVCO")
      echo "Selected: $opt"

      corr_user_unavco0=`awk -F '=' '$1=="corr_user_unavco" {print $2}' $target_path`
      read -p "Nombre de usuario en UNAVCO [ENTER para dejar valor actual '$corr_user_unavco0']: " corr_user_unavco
      corr_user_unavco=${corr_user_unavco:-$corr_user_unavco0}
      sed -i "s/corr_user_unavco=.*$/corr_user_unavco=$corr_user_unavco/g" $target_path

      corr_pw_unavco0=`awk -F '=' '$1=="corr_pw_unavco" {print $2}' $target_path`
      read -p "Password en UNAVCO [ENTER para dejar valor actual '$corr_pw_unavco0']: " corr_pw_unavco
      corr_pw_unavco=${corr_pw_unavco:-$corr_pw_unavco0}
      sed -i "s/corr_pw_unavco=.*$/corr_pw_unavco=$corr_pw_unavco/g" $target_path

      mp_unavco0=`awk -F '=' '$1=="mp_unavco" {print $2}' $target_path`
      read -p "Mount point en UNAVCO [ENTER para dejar valor actual '$mp_unavco0']: " mp_unavco
      mp_unavco=${mp_unavco:-$mp_unavco0}
      sed -i "s/mp_unavco=.*$/mp_unavco=$mp_unavco/g" $target_path

      break
      ;;
    "Generic")
      echo "Selected: $opt"

      corr_user_gen0=`awk -F '=' '$1=="corr_user_gen" {print $2}' $target_path`
      read -p "Username [ENTER for current value '$corr_user_gen0']: " corr_user_gen
      corr_user_gen=${corr_user_gen:-$corr_user_gen0}
      sed -i "s/corr_user_gen=.*$/corr_user_gen=$corr_user_gen/g" $target_path

      corr_pw_gen0=`awk -F '=' '$1=="corr_pw_gen" {print $2}' $target_path`
      read -p "Password [ENTER for current value '$corr_pw_gen0']: " corr_pw_gen
      corr_pw_gen=${corr_pw_gen:-$corr_pw_gen0}
      sed -i "s/corr_pw_gen=.*$/corr_pw_gen=$corr_pw_gen/g" $target_path

      corr_addr_gen0=`awk -F '=' '$1=="corr_addr_gen" {print $2}' $target_path`
      read -p "URL/IP [ENTER for current value '$corr_addr_gen0']: " corr_addr_gen
      corr_addr_gen=${corr_addr_gen:-$corr_addr_gen0}
      sed -i "s/corr_addr_gen=.*$/corr_addr_gen=$corr_addr_gen/g" $target_path

      corr_port_gen0=`awk -F '=' '$1=="corr_port_gen" {print $2}' $target_path`
      read -p "Port [ENTER for current value '$corr_port_gen0']: " corr_port_gen
      corr_port_gen=${corr_port_gen:-$corr_port_gen0}
      sed -i "s/corr_port_gen=.*$/corr_port_gen=$corr_port_gen/g" $target_path

      corr_mp_gen0=`awk -F '=' '$1=="corr_mp_gen" {print $2}' $target_path`
      read -p "Mount point [ENTER for current value '$corr_mp_gen0']: " corr_mp_gen
      corr_mp_gen=${corr_mp_gen:-$corr_mp_gen0}
      sed -i "s/corr_mp_gen=.*$/corr_mp_gen=$corr_mp_gen/g" $target_path

      base_pos_type_gen0=`awk -F '=' '$1=="base_pos_type_gen" {print $2}' $target_path`
      read -p "Type of base pos. (-p for LLH, -px for ECEF) [ENTER for current value '$base_pos_type_gen0']: " base_pos_type_gen
      base_pos_type_gen=${base_pos_type_gen:-$base_pos_type_gen0}
      sed -i "s/base_pos_type_gen=.*$/base_pos_type_gen=$base_pos_type_gen/g" $target_path

      base_pos_1_gen0=`awk -F '=' '$1=="base_pos_1_gen" {print $2}' $target_path`
      read -p "Base pos. 1: lat (deg) or X (m) [ENTER for current value '$base_pos_1_gen0']: " base_pos_1_gen
      base_pos_1_gen=${base_pos_1_gen:-$base_pos_1_gen0}
      sed -i "s/base_pos_1_gen=.*$/base_pos_1_gen=$base_pos_1_gen/g" $target_path

      base_pos_2_gen0=`awk -F '=' '$1=="base_pos_2_gen" {print $2}' $target_path`
      read -p "Base pos. 2: lon (deg) or Y (m) [ENTER for current value '$base_pos_2_gen0']: " base_pos_2_gen
      base_pos_2_gen=${base_pos_2_gen:-$base_pos_2_gen0}
      sed -i "s/base_pos_2_gen=.*$/base_pos_2_gen=$base_pos_2_gen/g" $target_path

      base_pos_3_gen0=`awk -F '=' '$1=="base_pos_3_gen" {print $2}' $target_path`
      read -p "Base pos. 3: height (deg) or Z (m) [ENTER for current value '$base_pos_3_gen0']: " base_pos_3_gen
      base_pos_3_gen=${base_pos_3_gen:-$base_pos_3_gen0}
      sed -i "s/base_pos_3_gen=.*$/base_pos_3_gen=$base_pos_3_gen/g" $target_path

      break
      ;;
    "Quit")
      break
      ;;
    *) echo "invalid option $REPLY";;
  esac
done
