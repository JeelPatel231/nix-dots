glsblk() {
  if [ -z "$@" ]; then
    lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT,FSUSED,FSAVAIL
  else
    lsblk $@
  fi
}

start_dropdown(){
  kitty --title dropdown_terminal &
  disown
}

aria2_rpc(){
  aria2c --enable-rpc --rpc-listen-all --rpc-allow-origin-all --seed-time=0
}

reboot(){
  if [[ $1 == "windows" ]]; then
    systemctl reboot --boot-loader-entry=auto-windows
  elif [[ $1 == "bios" ]]; then
    systemctl reboot --firmware-setup
  else
    systemctl reboot
  fi
}

nixenv() {
  sudo nix-env -p /nix/var/nix/profiles/system $@
}



eval "$(direnv hook bash)"
