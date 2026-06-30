#!/bin/bash
#
# 1) create directory 'user_logs'
# 2) every script execution create new file 'tempreture_XXXX_datetime'
#    where XXXX = 0000...9999
# 3) every 6 sec (10 times in min) write line:
#    datetime; all temperatures (from sensors); cpu_current_frequencies; cpu_freq_statistics
#
# --- ~$ sensors ------------------------
#gpu_thermal-virtual-0
#Adapter: Virtual device
#temp1:        +40.6°C
#
#nvme-pci-0100
#Adapter: PCI adapter
#Composite:    +36.9°C  (low  = -273.1°C, high = +84.8°C)
#                       (crit = +84.8°C)
#Sensor 1:     +36.9°C  (low  = -273.1°C, high = +65261.8°C)
#Sensor 2:     +38.9°C  (low  = -273.1°C, high = +65261.8°C)
#
#cpu_thermal-virtual-0
#Adapter: Virtual device
#temp1:        +43.8°C
#----------------------------------------
#~$ cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
#408000
#408000
#----------------------------------------
#cpufreq-info | grep stats
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#----------------------------------------
#
# script results:
#    temperature_0000_2024-11-19-21-17-11.txt ... temperature_0003_2024-11-19-22-00-12.txt ...
#
#2024-11-19 22:00:12;	41.2;45.0;41.9;41.9;	1800000;1800000;1800000;1800000;	  \ 
# cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006); \
# cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006); \
# cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006); \
# cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006);
#

LOG_DIR="user_logs"
mkdir -p "$LOG_DIR"

#--- search last file (file with the biggest number) & create new file ---
max_num=-1
for f in "$LOG_DIR"/temperature_[0-9][0-9][0-9][0-9]_*.txt; do
    if [[ -f "$f" ]]; then
        base=$(basename "$f")
        num=$(echo "$base" | cut -d'_' -f2)
        if [[ $num =~ ^[0-9]{4}$ ]]; then
            if ((10#$num > max_num)); then
                max_num=$((10#$num))
            fi
        fi
    fi
done

if [[ $max_num -eq -1 ]]; then
    next_num=0
else
    next_num=$(( (max_num + 1) % 10000 ))
fi

printf -v num_str "%04d" $next_num
timestamp=$(date +"%Y-%m-%d-%H-%M-%S")
filename="$LOG_DIR/temperature_${num_str}_${timestamp}.txt"

echo "new log file is created: $filename"

#--- main cycle --------------------------------------------------------
while true; do
    datetime=$(date +"%Y-%m-%d %H:%M:%S")
    sensors_out=$(sensors)

    gpu_temp=$(echo "$sensors_out" | awk '/gpu_thermal/,/temp1/ {if (/temp1:/) {print $2; exit}}' | sed 's/[+°C]//g')
    cpu_temp=$(echo "$sensors_out" | awk '/cpu_thermal/,/temp1/ {if (/temp1:/) {print $2; exit}}' | sed 's/[+°C]//g')
    nvme_comp=$(echo "$sensors_out" | awk '/nvme-pci/,/Composite:/ {if (/Composite:/) {print $2; exit}}' | sed 's/[+°C]//g')
    nvme_s1=$(echo "$sensors_out" | awk '/nvme-pci/,/Sensor 1:/ {if (/Sensor 1:/) {print $3; exit}}' | sed 's/[+°C]//g')

    [[ -z "$gpu_temp" ]] && gpu_temp="N/A"
    [[ -z "$cpu_temp" ]] && cpu_temp="N/A"
    [[ -z "$nvme_comp" ]] && nvme_comp="N/A"
    [[ -z "$nvme_s1" ]] && nvme_s1="N/A"

    freqs=()
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        if [[ -f "$cpu" ]]; then
            freq=$(cat "$cpu" 2>/dev/null)
            [[ -n "$freq" ]] && freqs+=("$freq") || freqs+=("N/A")
        else
            freqs+=("N/A")
        fi
    done
    while [[ ${#freqs[@]} -lt 4 ]]; do
        freqs+=("N/A")
    done

    freq_str=$(printf ";%s" "${freqs[@]}")
    freq_str=${freq_str:1}  

    if command -v cpufreq-info &>/dev/null; then
        stats=$(cpufreq-info 2>/dev/null | grep "cpufreq stats")
        stats_line=$(echo "$stats" | tr '\n' '; ' | sed 's/; $//')
    else
        stats_line="cpufreq-info not available"
    fi

    line="${datetime};"$'\t'"${gpu_temp};${cpu_temp};${nvme_comp};${nvme_s1};"$'\t'"${freq_str};"$'\t'"${stats_line}"

    echo "$line" >> "$filename"
    sleep 6
done