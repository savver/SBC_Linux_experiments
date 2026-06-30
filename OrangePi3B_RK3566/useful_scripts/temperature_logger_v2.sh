#!/bin/bash
#
# 1) create directory 'user_logs'
# 2) every script execution create new file 'tempreture_excel_XXXX_datetime'
#    where XXXX = 0000...9999
# 3) every 6 sec (10 times in min) write line:
#    datetime; all temperatures (from sensors); cpu_current_frequencies; cpu_freq_statistics
#   only digit values and separators ';'
#
# --- ~$ sensors => get 4 temperatures-----
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
#~$ cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq => get 2 values
#408000
#408000
#----------------------------------------
#cpufreq-info | grep stats  => 7 frequences or 4 cores => 28 values
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#  cpufreq stats: 408 MHz:96.83%, 600 MHz:0.72%, 816 MHz:0.10%, 1.10 GHz:0.00%, 1.42 GHz:0.01%, 1.61 GHz:0.01%, 1.80 GHz:2.33%  (341)
#----------------------------------------
#  results:  
#      temperature_excel_0000_2024-11-20-04-32-13.txt
#
#    datetime;	t_gpu;t_cpu;t_nvme_comp;t_nvme_s1;	cpu0_freq;cpu1_freq;cpu2_freq;cpu3_freq;
#   2024-11-20 04:32:13;	43.1;46.1;41.9;41.9;	1800000;1800000;1800000;1800000;
#
#    core0_408;core0_600;core0_816;core0_1100;core0_1420;core0_1610;core0_1800;
#    87.67;0.62;0.14;0.00;0.00;0.00;11.56;87.67;0.62;0.14;0.00;0.00;0.00;11.56;
#
#    core1_408;core1_600;core1_816;core1_1100;core1_1420;core1_1610;core1_1800;
#    87.67;0.62;0.14;0.00;0.00;0.00;11.56;87.67;0.62;0.14;0.00;0.00;0.00;11.56;
#
#    .....
#
LOG_DIR="user_logs"
mkdir -p "$LOG_DIR"

#--- search last file (file with the biggest number) & create new file ---
max_num=-1
for f in "$LOG_DIR"/temperature_excel_[0-9][0-9][0-9][0-9]_*.txt; do
    if [[ -f "$f" ]]; then
        base=$(basename "$f")
        num=$(echo "$base" | cut -d'_' -f3)  # temperature_excel_0001_...
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
filename="$LOG_DIR/temperature_excel_${num_str}_${timestamp}.txt"

echo "new log file is created: $filename"

#---- excel header ---
header="datetime;"$'\t'"t_gpu;t_cpu;t_nvme_comp;t_nvme_s1;"$'\t'"cpu0_freq;cpu1_freq;cpu2_freq;cpu3_freq;"$'\t'\
"core0_408;core0_600;core0_816;core0_1100;core0_1420;core0_1610;core0_1800;"\
"core1_408;core1_600;core1_816;core1_1100;core1_1420;core1_1610;core1_1800;"\
"core2_408;core2_600;core2_816;core2_1100;core2_1420;core2_1610;core2_1800;"\
"core3_408;core3_600;core3_816;core3_1100;core3_1420;core3_1610;core3_1800"

echo "$header" > "$filename"

#----------------------
# cut percentage from 'cpufreq-info | grep stats'
parse_stats() {
    local line="$1"
    local percents=$(echo "$line" | grep -oP '\d+\.\d+(?=%)' | tr '\n' ';')
    percents=${percents%;}
    echo "$percents"
}

#--- main cycle ----
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

	#--- frequencies ----
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

    # --- cores statistics ---
    if command -v cpufreq-info &>/dev/null; then
        stats_lines=$(cpufreq-info 2>/dev/null | grep "cpufreq stats")
        IFS=$'\n' read -rd '' -a stats_array <<< "$stats_lines"
        while [[ ${#stats_array[@]} -lt 4 ]]; do
            stats_array+=("N/A")
        done
        all_percents=""
        for ((i=0; i<4; i++)); do
            line="${stats_array[i]}"
            if [[ "$line" == "N/A" ]]; then
                percents="N/A;N/A;N/A;N/A;N/A;N/A;N/A"
            else
                percents=$(parse_stats "$line")
                count=$(echo "$percents" | grep -o ';' | wc -l)
                if [[ $count -lt 6 ]]; then
                    while [[ $(echo "$percents" | grep -o ';' | wc -l) -lt 6 ]]; do
                        percents="${percents};N/A"
                    done
                fi
            fi
            if [[ -z "$all_percents" ]]; then
                all_percents="$percents"
            else
                all_percents="${all_percents};${percents}"
            fi
        done
    else
        all_percents=$(printf "N/A;%.0s" {1..28})
        all_percents=${all_percents%;}
    fi

    # --- output line ---
    # datetime; + tab + temps; + tab + freqs; + tab + percents
    line="${datetime};"$'\t'"${gpu_temp};${cpu_temp};${nvme_comp};${nvme_s1};"$'\t'"${freq_str};"$'\t'"${all_percents}"

    echo "$line" >> "$filename"
    sleep 6
done