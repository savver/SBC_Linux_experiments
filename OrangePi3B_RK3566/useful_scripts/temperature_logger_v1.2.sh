#!/bin/bash
#
# 1) create directory 'user_logs'
# 2) every script execution create new file 'tempreture_XXXX_datetime'
#    where XXXX = 0000...9999
# 3) every 10 sec write line:
#    datetime; all temperatures (from sensors); cpu_current_frequencies; cpu_load_statistics
#
# *v.1.sh    use 'cpufreq-info | grep stats' -> dynamic freq scaling analyze
# *v.1.1.sh  use '/proc/stat' and fields 'cpu0 ... cpu3'
#            2 snapshots with intervals of 10 sec and recalc times to precentage of load
# *v.1.2.sh  use whitespaces instead of tabs, fixed width for each field, nice view
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
#
# we get as "t_cpu=43.8;    t_gpu=40.6;    t_nvme_1=36.9; t_nvme_2=38.9;"
#
#--- cat /proc/stat/ --------------------
#cpu  82640 106 361608 24945471 55391 0 198 0 0 0
#cpu0 20723 4 89688 6235053 13692 0 196 0 0 0
#cpu1 21653 45 90172 6237234 13856 0 1 0 0 0
#cpu2 20570 17 90603 6235488 13354 0 0 0 0 0
#cpu3 19692 38 91145 6237695 14487 0 0 0 0 0
#
#--- script result ----------------------
# temperature_0014_2024-11-21-05-08-08.txt
#
#2024-11-21 05:08:19  t_cpu=45.6;    t_gpu=42.5;    t_nvme_1=43.9; t_nvme_2=43.9; 1800000;   
#2024-11-21 05:08:30  t_cpu=45.6;    t_gpu=42.5;    t_nvme_1=43.9; t_nvme_2=43.9; 1800000;   
#2024-11-21 05:08:41  t_cpu=45.6;    t_gpu=42.5;    t_nvme_1=43.9; t_nvme_2=43.9; 816000;    
#

SLEEP_INTERVAL=10         
LOG_DIR="user_logs"

WIDTH_DATETIME=20
WIDTH_TEMP=14
WIDTH_FREQ=10
WIDTH_STAT=18

#--- search last file (file with the biggest number) & create new file ---
mkdir -p "$LOG_DIR"

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

# --- cacl cpu load in percentages, based on  /proc/stat ---
calc_stats() {
    local line1="$1"
    local line2="$2"
    
    local u1=$(echo "$line1" | awk '{print $2}')
    local n1=$(echo "$line1" | awk '{print $3}')
    local s1=$(echo "$line1" | awk '{print $4}')
    local i1=$(echo "$line1" | awk '{print $5}')
    local w1=$(echo "$line1" | awk '{print $6}')
    local irq1=$(echo "$line1" | awk '{print $7}')
    local si1=$(echo "$line1" | awk '{print $8}')
    local st1=$(echo "$line1" | awk '{print $9}')
    local g1=$(echo "$line1" | awk '{print $10}')
    local gn1=$(echo "$line1" | awk '{print $11}')
    
    local u2=$(echo "$line2" | awk '{print $2}')
    local n2=$(echo "$line2" | awk '{print $3}')
    local s2=$(echo "$line2" | awk '{print $4}')
    local i2=$(echo "$line2" | awk '{print $5}')
    local w2=$(echo "$line2" | awk '{print $6}')
    local irq2=$(echo "$line2" | awk '{print $7}')
    local si2=$(echo "$line2" | awk '{print $8}')
    local st2=$(echo "$line2" | awk '{print $9}')
    local g2=$(echo "$line2" | awk '{print $10}')
    local gn2=$(echo "$line2" | awk '{print $11}')
    
    local d_user=$((u2 - u1))
    local d_nice=$((n2 - n1))
    local d_system=$((s2 - s1))
    local d_idle=$((i2 - i1))
    local d_iowait=$((w2 - w1))
    local d_irq=$((irq2 - irq1))
    local d_softirq=$((si2 - si1))
    local d_steal=$((st2 - st1))
    local d_guest=$((g2 - g1))
    local d_guest_nice=$((gn2 - gn1))
    
    local total=$((d_user + d_nice + d_system + d_idle + d_iowait + d_irq + d_softirq + d_steal + d_guest + d_guest_nice))
    
    if [[ $total -eq 0 ]]; then
        echo "user=0.0;nice=0.0;system=0.0;idle=0.0;iowait=0.0;irq=0.0;softirq=0.0;steal=0.0;guest=0.0;guest_nice=0.0"
    else
        local p_user=$(awk "BEGIN {printf \"%.1f\", ($d_user * 100.0) / $total}")
        local p_nice=$(awk "BEGIN {printf \"%.1f\", ($d_nice * 100.0) / $total}")
        local p_system=$(awk "BEGIN {printf \"%.1f\", ($d_system * 100.0) / $total}")
        local p_idle=$(awk "BEGIN {printf \"%.1f\", ($d_idle * 100.0) / $total}")
        local p_iowait=$(awk "BEGIN {printf \"%.1f\", ($d_iowait * 100.0) / $total}")
        local p_irq=$(awk "BEGIN {printf \"%.1f\", ($d_irq * 100.0) / $total}")
        local p_softirq=$(awk "BEGIN {printf \"%.1f\", ($d_softirq * 100.0) / $total}")
        local p_steal=$(awk "BEGIN {printf \"%.1f\", ($d_steal * 100.0) / $total}")
        local p_guest=$(awk "BEGIN {printf \"%.1f\", ($d_guest * 100.0) / $total}")
        local p_guest_nice=$(awk "BEGIN {printf \"%.1f\", ($d_guest_nice * 100.0) / $total}")
        echo "user=${p_user};nice=${p_nice};system=${p_system};idle=${p_idle};iowait=${p_iowait};irq=${p_irq};softirq=${p_softirq};steal=${p_steal};guest=${p_guest};guest_nice=${p_guest_nice}"
    fi
}

#--- main cycle --------------------------------------------------------
while true; do
    
    stat1=$(cat /proc/stat | grep -E '^cpu[0-3] ')

    sleep "$SLEEP_INTERVAL"

    stat2=$(cat /proc/stat | grep -E '^cpu[0-3] ')

    sensors_out=$(sensors)
    cpu_temp=$(echo "$sensors_out" | awk '/cpu_thermal/,/temp1/ {if (/temp1:/) {print $2; exit}}' | sed 's/[+°C]//g')
    gpu_temp=$(echo "$sensors_out" | awk '/gpu_thermal/,/temp1/ {if (/temp1:/) {print $2; exit}}' | sed 's/[+°C]//g')
    nvme1=$(echo "$sensors_out" | awk '/nvme-pci/,/Sensor 1:/ {if (/Sensor 1:/) {print $3; exit}}' | sed 's/[+°C]//g')
    nvme2=$(echo "$sensors_out" | awk '/nvme-pci/,/Sensor 2:/ {if (/Sensor 2:/) {print $3; exit}}' | sed 's/[+°C]//g')

    [[ -z "$cpu_temp" ]] && cpu_temp="N/A"
    [[ -z "$gpu_temp" ]] && gpu_temp="N/A"
    [[ -z "$nvme1" ]] && nvme1="N/A"
    [[ -z "$nvme2" ]] && nvme2="N/A"

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

    IFS=$'\n' read -rd '' -a lines1 <<< "$stat1"
    IFS=$'\n' read -rd '' -a lines2 <<< "$stat2"
    
    core_stats_raw=()
    for idx in 0 1 2 3; do
        line1="${lines1[$idx]}"
        line2="${lines2[$idx]}"
        raw=$(calc_stats "$line1" "$line2")
        prefixed=$(echo "$raw" | sed "s/^/cpu${idx}_/; s/;/;cpu${idx}_/g")
        core_stats_raw+=("$prefixed")
    done

    datetime=$(date +"%Y-%m-%d %H:%M:%S")

    temp_fields=("t_cpu=${cpu_temp};" "t_gpu=${gpu_temp};" "t_nvme_1=${nvme1};" "t_nvme_2=${nvme2};")

    freq_fields=()
    for f in "${freqs[@]}"; do
        freq_fields+=("${f};")
    done

    stat_fields=()
    for str in "${core_stats_raw[@]}"; do
        IFS=';' read -ra arr <<< "$str"
        for val in "${arr[@]}"; do
            if [[ -n "$val" ]]; then
                stat_fields+=("${val};")
            fi
        done
    done

    line=""
    printf -v padded "%-${WIDTH_DATETIME}s" "$datetime"
    line+="$padded "

    for f in "${temp_fields[@]}"; do
        printf -v padded "%-${WIDTH_TEMP}s" "$f"
        line+="$padded "
    done

    for f in "${freq_fields[@]}"; do
        printf -v padded "%-${WIDTH_FREQ}s" "$f"
        line+="$padded "
    done

    for f in "${stat_fields[@]}"; do
        printf -v padded "%-${WIDTH_STAT}s" "$f"
        line+="$padded "
    done

    line=${line% }

    echo "$line" >> "$filename"
done