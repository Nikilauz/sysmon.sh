#!/bin/bash

network_adapter=wlp2s0

script_dir=$(dirname ${BASH_SOURCE[0]})


# https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/blob/master/scripts/sysstat
cpu=$(cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{printf("%2d", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5))}')

gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

ram=$(free | sed '2q;d' | awk '{printf("%d",  $3/$2 * 100.0)}')

swap=$(free | sed '3q;d' | awk '{printf("%d",  $3/$2 * 100.0)}')

network=$($script_dir/scripts_monBandwidth $network_adapter)

echo "<txt> <b>v/^</b> $network <b>C</b> $cpu% <b>G</b> $gpu% <b>R</b> $ram% <b>S</b> $swap% </txt>"

#/home/julian/Code/bash/sysmon/sysmon.sh

