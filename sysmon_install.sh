#!/bin/bash

dpkg-query -l xfce4-genmon-plugin
if (( $? )); then
    xdg-open "apt:xfce4-genmon-plugin"
    exit 1
fi

mkdir -p ~/.local/share/sysmon
wget -O ~/.local/share/sysmon/sysmon.sh http://polemix.dx.am/sysmon
if [[ $? == 1 ]]
then
    exit 1
fi
chmod +x ~/.local/share/sysmon/sysmon.sh

adapter=`ls /sys/class/net | zenity --list --column "network interface"`
if [[ $adapter ]]; then
    if ! [[ $adapter == "eth0" ]]; then
        adapter=" -a $adapter"
    else
        adapter=""
    fi
else
    exit 1
fi
    

xfce4-panel --add=genmon
sleep 1
xfce4-panel --restart
sleep 1
xfce4-panel --quit

genmon=`cd ~/.config/xfce4/panel/; ls -c genmon*.rc | grep -o -E -e "[0-9]+"`
echo $genmon > ~/.local/share/sysmon/genmon.txt
genmon_path=`realpath ~/.config/xfce4/panel/genmon-$genmon".rc"`
script_path=`realpath ~/.local/share/sysmon/sysmon.sh`

sed -i 's|^Command.*|Command='$script_path"$adapter"'|' $genmon_path
sed -i "s/^UseLabel.*/UseLabel=0/" $genmon_path
sed -i "s/^Text.*/Text=/" $genmon_path
sed -i "s/^UpdatePeriod.*/UpdatePeriod=3000/" $genmon_path

mkdir -p ~/.cache/sysmon

xfce4-panel >/dev/null 2>/dev/null &

