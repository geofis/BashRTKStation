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

PS3='Select an option: '
options=("Create credentials" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Create credentials")
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

      break
      ;;
    "Quit")
      break
      ;;
    *) echo "invalid option $REPLY";;
  esac
done
