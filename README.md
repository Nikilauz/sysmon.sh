# sysmon.sh
A simple system monitoring script for xfce desktops to set as source of [xfce4 genmon panel plugin](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin).  
It uses some of the [sample scripts](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/blob/master/scripts/) provided by genmon (sysstat, monBandwidth).
#### howto
 - Run `wget -qO - https://raw.githubusercontent.com/Nikilauz/sysmon.sh/main/sysmon_install.sh | bash` in a terminal to add a new instance of sysmon to your panel.  
 - Click on the panel item to open `xfce4-taskmanager`.
#### options
 - `-a [network interface]` choose a network interface (e.g. via executing `netstat -i`), `eth0` is used if not provided
 - `--text` only textual output (disables onclick event)
 - `--no-gpu` disables gpu monitoring
#### faq
 - Hover the panel item to see the order of the displayed values.
 - If you see '?' in network stats, it means propably that the network interface doesn't exist, try to set it manually via `-a` option (see above).
 - Currently, GPU utilization monitoring is supported for Nvidia via `nvidia-smi` (ships with proprietary drivers), for AMD via `aticonfig` (same here) and for Intel via `intel-gpu-tools` (make sure you have installed that one).
