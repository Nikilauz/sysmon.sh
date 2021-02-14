#!/bin/bash


# get gpu load
function get_gpu() {
    if [[ `which nvidia-smi` ]]; then
        echo `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`
    elif [[ `which aticonfig --odgc --odgt` ]]; then
        echo `aticonfig --odgc --odgt | grep "GPU load" | awk '{printf("%s", $4)}'`
    elif [[ `which intel_gpu_top` ]]; then
        intel=`(timeout 0.3 intel_gpu_top)`
        echo $(echo `echo $intel | grep "render busy" | cut -d "%:" -f3\
            ` `echo $intel | grep "bitstream busy" | cut -d ":" -f3\
            ` `echo $intel | grep "blitter busy" | cut -d ":" -f3`\
            | awk '{printf("%d\%", ($1+$2+$3)/3)}')
    else
        echo "no supported GPU (driver)"
    fi
}

# print svg bar; params: x-position amplitude fill-color
function svg_bar() {
    echo "<rect x=\"$1\" y=\""$(( 100 - $2 ))"%\" width=\"10\" height=\"$2%\" fill=\"$3\" />"
    echo "<rect x=\"$1\" width=\"10\" height=\"100%\" fill=\"none\" stroke=\"black\" stroke-width=\"1\" />"
}

# format bit rate; params: bit-rate
human_bandwidth () {
    bandwidth=$1
    p=0
    while [ "$bandwidth" -gt "1024" -a "$p" -le "3" ] ; do
        bandwidth=$(($bandwidth/1024))
        p=$(($p+1))
    done
    case $p in
        0)
        bandwidth="$bandwidth B/s"
        ;;
        1)
        bandwidth="$bandwidth KB/s"
        ;;
        2)
        bandwidth="$bandwidth MB/s"
        ;;
    esac
    echo $bandwidth
}


# args
network_adapter=$(echo $@ | grep -E -e "-a .+" | awk '{printf("%s", $2)}')
network_adapter=`(test $network_adapter && echo $network_adapter) || echo eth0`
network=`test -d /sys/class/net/$network_adapter && echo 1`
text=$(echo $@ | grep -c -e "--text")
no_gpu=$(echo $@ | grep -e "--no-gpu")

# script location directory
script_dir=$(dirname ${BASH_SOURCE[0]})


# get values

# staticly
ram=$(free | sed '2q;d' | awk '{printf("%d",  $3/$2 * 100.0)}')
swap=$(free | sed '3q;d' | awk '{printf("%d",  $3/$2 * 100.0)}')
gpu=$(test $no_gpu || get_gpu)

# progressively
cpu1=$(cat <(grep 'cpu ' /proc/stat))
rx1=`test $network && cat /sys/class/net/$network_adapter/statistics/rx_bytes`
tx1=`test $network && cat /sys/class/net/$network_adapter/statistics/tx_bytes`
sleep 1
cpu2=$(cat <(grep 'cpu ' /proc/stat))
rx2=`test $network && cat /sys/class/net/$network_adapter/statistics/rx_bytes`
tx2=`test $network && cat /sys/class/net/$network_adapter/statistics/tx_bytes`

cpu=$(echo $cpu1 $cpu2 | awk -v RS="" '{printf("%d", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5))}')
rx=`test $network && human_bandwidth $(($rx2 - $rx1))`
tx=`test $network && human_bandwidth $(($tx2 - $tx1))`


# create textual output
text_out="<b>Network:</b> v$tx ^$rx <b>CPU:</b> $cpu% <b>GPU:</b> $gpu% <b>RAM:</b> $ram% <b>swap:</b> $swap%"

# create svg if requested
if ! (( $text )); then
    color=$(if [[ $(xfconf-query -lvc xsettings -p /Net/ThemeName | grep -i "dark") ]]; then echo white; else echo black; fi)
    font=$(xfconf-query -lvc xsettings -p /Gtk/FontName | awk '{printf("%s", $2)}')

    svg="<svg width=\"120\" height=\"30\">"
    svg+="<g fill=\"$color\" font-size=\"12\" font-family=\"$font\">"
    svg+="<text x=\"0\" y=\"15\" textLength=\"50\" lengthAdjust=\"spacingAndGlyphs\">"
    svg+="<tspan>&#8593;"${tx:-#}"</tspan><tspan x=\"0\" dy=\"13\">&#8595;"${rx:-#}"</tspan>"
    svg+="</text>"
    svg+=`svg_bar 60 $cpu blue`
    svg+=`test $no_gpu || svg_bar 75 $gpu green`
    svg+=`svg_bar 90 $ram orange`
    svg+=`svg_bar 105 $swap yellow`
    svg+="</g>"
    svg+="</svg>"
    
    echo $svg > $script_dir/icon.svg
    echo "<img>$script_dir/icon.svg</img><click>xfce4-taskmanager</click>"
else
    echo "<txt> $text_out </txt>"
fi
echo "<tool>$text_out</tool>"
