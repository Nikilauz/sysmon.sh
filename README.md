# sysmon.sh
A simple system monitoring script for xfce desktops to set as source of [xfce4 genmon panel plugin](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin).  
It uses some of the [sample scripts](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/blob/master/scripts/) provided by genmon (sysstat, monBandwidth).
#### setup
1. download this repo (e.g. to ~/.local/share/sysmon)
2. install [xfce4-gemon-plugin](apt://xfce4-genmon-plugin)
3. execute `xfce4-panel --add=genmon`
4. right-click on the newly added item in your panel and set the command path property to your `sysmon.sh` script
#### options
 - `-a [network interface]` choose a network interface (e.g. via executing `netstat -i`), `eth0` is used if not provided
 - `--text` only textual output, no bars
 - `--no-gpu` disables gpu monitoring
#### faq
 - Hover the panel item to see the order of the displayed values.
 - Currently, GPU-Utilization monitoring is supported for Nvidia via `nvidia-smi` (ships with proprietary drivers), for AMD (same here) via `aticonfig` and for Intel via `intel-gpu-tools` (make sure you have installed that one).
 