#!/bin/bash

# args
network_adapter=$(echo $@ | grep -E -e "-a .+" | awk '{printf("%s", $2)}')
as_svg=`if [[ $(echo $@ | grep -e "--svg") ]]; then echo 1; else echo 0; fi`

# script location directory
script_dir=$(dirname ${BASH_SOURCE[0]})

function svg_bar() {
    svg+="<rect x=\"$1\" y=\""$(( 100 - $2 ))"%\" width=\"10\" height=\"$2%\" fill=\"$3\" />"
    svg+="<rect x=\"$1\" width=\"10\" height=\"100%\" fill=\"none\" stroke=\"black\" stroke-width=\"1\" />"
}


# get values

# https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/blob/master/scripts/sysstat
cpu=$(cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{printf("%d", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5))}')

gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

ram=$(free | sed '2q;d' | awk '{printf("%d",  $3/$2 * 100.0)}')

swap=$(free | sed '3q;d' | awk '{printf("%d",  $3/$2 * 100.0)}')

network=$($script_dir/scripts_monBandwidth $network_adapter)

# create textual output
text_out="<b>Network (v/^):</b> $network <b>CPU:</b> $cpu% <b>GPU:</b> $gpu% <b>RAM:</b> $ram% <b>swap:</b> $swap%"

# create svg if requested
if (( $as_svg )); then
    color=$(if [[ $(xfconf-query -lvc xsettings -p /Net/ThemeName | grep -i "dark") ]]; then echo white; else echo black; fi)
    font=$(xfconf-query -lvc xsettings -p /Gtk/FontName | awk '{printf("%s", $2)}')
    svg="<svg width=\"120\" height=\"30\">"
    svg+="<g fill=\"$color\" font-size=\"12\" font-family=\"$font\">"
    svg+="<text x=\"0\" y=\"15\" textLength=\"50\" lengthAdjust=\"spacingAndGlyphs\">"
    svg+="<tspan>&#8593;"$(echo $network | awk '{printf("%s %s", $3, $4)}')"</tspan>"
    svg+="<tspan x=\"0\" dy=\"13\">&#8595;"$(echo $network | awk '{printf("%s %s", $1, $2)}')"</tspan>"
    svg+="</text>"
    svg_bar 60 $cpu blue
    svg_bar 75 $gpu green
    svg_bar 90 $ram orange
    svg_bar 105 $swap yellow
    svg+="</g>"
    svg+="</svg>"
    
    echo $svg > $script_dir/icon.svg
    echo "<img>$script_dir/icon.svg</img><tool>$text_out</tool>"
else
    echo "<txt> $text_out </txt>"
fi
