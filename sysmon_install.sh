#!/bin/bash

if [[ $SUDO_USER ]]; then
    echo "Please don't execute as sudo (to be able to edit the panel)!"
    exit 1
fi

dpkg-query -l xfce4-genmon-plugin >/dev/null
if (( $? )); then
    echo "Please install genmon!"
    xdg-open "apt:xfce4-genmon-plugin"
    exit 1
fi

mkdir -p ~/.local/share/sysmon
wget -qO ~/.local/share/sysmon/sysmon.sh http://polemix.dx.am/sysmon
if [[ $? == 1 ]]
then
    echo "Failed to download sysmon.sh!"
    exit 1
fi
chmod +x ~/.local/share/sysmon/sysmon.sh

adapter=`ls /sys/class/net | zenity --list --column "network interface" 2>/dev/null`
if [[ $adapter ]]; then
    if ! [[ $adapter == "eth0" ]]; then
        adapter=" -a $adapter"
    else
        adapter=""
    fi
else
    echo "Please select a network adapter!"
    exit 1
fi
    

existing=`cd ~/.config/xfce4/panel/; ls -t genmon*.rc 2>/dev/null | grep -o -E -e "[0-9]+"`

xfce4-panel --add=genmon
sleep 1 
xfce4-panel --save
sleep 0.5
xfce4-panel --quit
sleep 0.5

for g in `cd ~/.config/xfce4/panel/; ls -t genmon*.rc | grep -o -E -e "[0-9]+"`; do
    if ! [[ `echo $existing | grep $g` ]]; then
        genmon=$g
    fi
done

genmon_path=`realpath ~/.config/xfce4/panel/genmon-$genmon".rc"`
script_path=`realpath ~/.local/share/sysmon/sysmon.sh`

sed -i 's|^Command.*|Command='$script_path" -i $genmon$adapter"'|' $genmon_path
sed -i "s/^UseLabel.*/UseLabel=0/" $genmon_path
sed -i "s/^Text.*/Text=/" $genmon_path
sed -i "s/^UpdatePeriod.*/UpdatePeriod=3000/" $genmon_path

mkdir -p ~/.cache/sysmon

xfce4-panel >/dev/null 2>/dev/null &

