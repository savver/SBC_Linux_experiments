temperature_logger_v1.sh 
(temperature_0003_2024-11-19-22-00-12.txt)

a lot of info about cpu_stat, log is too big
use: sensors, cpufreq-info
out: datetime; temperarutes; current_cpu_freq; cpu_freq_stats
------------------------------------------------------------
2024-11-19 22:00:12;	41.2;45.0;41.9;41.9;	1800000;1800000;1800000;1800000;	  cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006);  cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006);  cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006);  cpufreq stats: 408 MHz:96.87%, 600 MHz:0.55%, 816 MHz:0.11%, 1.10 GHz:0.00%, 1.42 GHz:0.00%, 1.61 GHz:0.00%, 1.80 GHz:2.46%  (4006);
============================================================
temperature_logger_v2.sh 
(temperature_excel_0001_2024-11-20-07-45-28.txt)

only digit values and ';' separators
use: sensors, cpufreq-info
out: datetime; temperarutes; current_cpu_freq; cpu_freq_stats
------------------------------------------------------------
datetime;	t_gpu;t_cpu;t_nvme_comp;t_nvme_s1;	cpu0_freq;cpu1_freq;cpu2_freq;cpu3_freq;	core0_408;core0_600;core0_816;core0_1100;core0_1420;core0_1610;core0_1800;core1_408;core1_600;core1_816;core1_1100;core1_1420;core1_1610;core1_1800;core2_408;core2_600;core2_816;core2_1100;core2_1420;core2_1610;core2_1800;core3_408;core3_600;core3_816;core3_1100;core3_1420;core3_1610;core3_1800
2024-11-20 07:45:28;	42.5;45.6;41.9;41.9;	1800000;1800000;1800000;1800000;	84.87;0.65;0.14;0.00;0.00;0.00;14.34;84.87;0.65;0.14;0.00;0.00;0.00;14.34;84.87;0.65;0.14;0.00;0.00;0.00;14.34;84.87;0.65;0.14;0.00;0.00;0.00;14.34
2024-11-20 07:45:34;	43.1;45.6;41.9;41.9;	600000;600000;1800000;1800000;	84.86;0.65;0.14;0.00;0.00;0.00;14.34;84.86;0.65;0.14;0.00;0.00;0.00;14.34;84.86;0.65;0.14;0.00;0.00;0.00;14.34;84.86;0.65;0.14;0.00;0.00;0.00;14.34
============================================================
temperature_logger_v1.1.sh
(temperature_0012_2024-11-21-03-25-53.txt)

cpu_freq_stat is changed on '/proc/stat', recacl time to cpu load percentages
use: sensors, /proc/stat
out: datetime; temperarutes; cpu_load_stats
------------------------------------------------------------
2024-11-21 03:26:04;	t_cpu=45.6;t_gpu=42.5;t_nvme_1=43.9;t_nvme_2=43.9;	1800000;1800000;1800000;1800000;	cpu0_user=0.0;	cpu0_nice=0.0;	cpu0_system=0.1;	cpu0_idle=99.9;	cpu0_iowait=0.0;	cpu0_irq=0.0;	cpu0_softirq=0.0;	cpu0_steal=0.0;	cpu0_guest=0.0;	cpu0_guest_nice=0.0;		cpu1_user=0.1;	cpu1_nice=0.0;	cpu1_system=0.5;	cpu1_idle=99.4;	cpu1_iowait=0.0;	cpu1_irq=0.0;	cpu1_softirq=0.0;	cpu1_steal=0.0;	cpu1_guest=0.0;	cpu1_guest_nice=0.0;		cpu2_user=0.0;	cpu2_nice=0.0;	cpu2_system=0.4;	cpu2_idle=99.6;	cpu2_iowait=0.0;	cpu2_irq=0.0;	cpu2_softirq=0.0;	cpu2_steal=0.0;	cpu2_guest=0.0;	cpu2_guest_nice=0.0;		cpu3_user=0.1;	cpu3_nice=0.0;	cpu3_system=0.3;	cpu3_idle=99.6;	cpu3_iowait=0.0;	cpu3_irq=0.0;	cpu3_softirq=0.0;	cpu3_steal=0.0;	cpu3_guest=0.0;	cpu3_guest_nice=0.0;		
2024-11-21 03:26:15;	t_cpu=45.6;t_gpu=42.5;t_nvme_1=43.9;t_nvme_2=43.9;	1800000;1800000;1800000;1800000;	cpu0_user=0.1;	cpu0_nice=0.0;	cpu0_system=0.3;	cpu0_idle=99.6;	cpu0_iowait=0.0;	cpu0_irq=0.0;	cpu0_softirq=0.0;	cpu0_steal=0.0;	cpu0_guest=0.0;	cpu0_guest_nice=0.0;		cpu1_user=0.2;	cpu1_nice=0.0;	cpu1_system=0.5;	cpu1_idle=99.3;	cpu1_iowait=0.0;	cpu1_irq=0.0;	cpu1_softirq=0.0;	cpu1_steal=0.0;	cpu1_guest=0.0;	cpu1_guest_nice=0.0;		cpu2_user=0.1;	cpu2_nice=0.0;	cpu2_system=0.5;	cpu2_idle=99.4;	cpu2_iowait=0.0;	cpu2_irq=0.0;	cpu2_softirq=0.0;	cpu2_steal=0.0;	cpu2_guest=0.0;	cpu2_guest_nice=0.0;		cpu3_user=0.0;	cpu3_nice=0.0;	cpu3_system=0.3;	cpu3_idle=99.7;	cpu3_iowait=0.0;	cpu3_irq=0.0;	cpu3_softirq=0.0;	cpu3_steal=0.0;	cpu3_guest=0.0;	cpu3_guest_nice=0.0;		
============================================================
temperature_logger_v1.2.sh
(temperature_0014_2024-11-21-05-08-08.txt)

use whitespaces instead of tabs, fixed width for each field, nice view
------------------------------------------------------------
2024-11-21 05:08:19  t_cpu=45.6;    t_gpu=42.5;    t_nvme_1=43.9; t_nvme_2=43.9; 1800000;   1800000;   1800000;   1800000;   cpu0_user=0.1;     cpu0_nice=0.0;     cpu0_system=0.4;   cpu0_idle=99.5;    cpu0_iowait=0.0;   cpu0_irq=0.0;      cpu0_softirq=0.0;  cpu0_steal=0.0;    cpu0_guest=0.0;    cpu0_guest_nice=0.0; cpu1_user=0.1;     cpu1_nice=0.0;     cpu1_system=0.5;   cpu1_idle=99.4;    cpu1_iowait=0.0;   cpu1_irq=0.0;      cpu1_softirq=0.0;  cpu1_steal=0.0;    cpu1_guest=0.0;    cpu1_guest_nice=0.0; cpu2_user=0.1;     cpu2_nice=0.0;     cpu2_system=0.4;   cpu2_idle=99.5;    cpu2_iowait=0.0;   cpu2_irq=0.0;      cpu2_softirq=0.0;  cpu2_steal=0.0;    cpu2_guest=0.0;    cpu2_guest_nice=0.0; cpu3_user=0.1;     cpu3_nice=0.0;     cpu3_system=0.1;   cpu3_idle=99.8;    cpu3_iowait=0.0;   cpu3_irq=0.0;      cpu3_softirq=0.0;  cpu3_steal=0.0;    cpu3_guest=0.0;    cpu3_guest_nice=0.0;
2024-11-21 05:08:30  t_cpu=45.6;    t_gpu=42.5;    t_nvme_1=43.9; t_nvme_2=43.9; 1800000;   1800000;   1800000;   1800000;   cpu0_user=0.0;     cpu0_nice=0.0;     cpu0_system=0.5;   cpu0_idle=99.5;    cpu0_iowait=0.0;   cpu0_irq=0.0;      cpu0_softirq=0.0;  cpu0_steal=0.0;    cpu0_guest=0.0;    cpu0_guest_nice=0.0; cpu1_user=0.2;     cpu1_nice=0.0;     cpu1_system=0.2;   cpu1_idle=99.6;    cpu1_iowait=0.0;   cpu1_irq=0.0;      cpu1_softirq=0.0;  cpu1_steal=0.0;    cpu1_guest=0.0;    cpu1_guest_nice=0.0; cpu2_user=0.0;     cpu2_nice=0.0;     cpu2_system=0.2;   cpu2_idle=99.8;    cpu2_iowait=0.0;   cpu2_irq=0.0;      cpu2_softirq=0.0;  cpu2_steal=0.0;    cpu2_guest=0.0;    cpu2_guest_nice=0.0; cpu3_user=0.0;     cpu3_nice=0.0;     cpu3_system=0.4;   cpu3_idle=99.6;    cpu3_iowait=0.0;   cpu3_irq=0.0;      cpu3_softirq=0.0;  cpu3_steal=0.0;    cpu3_guest=0.0;    cpu3_guest_nice=0.0;
============================================================
temperature_logger_v1.3_realese.sh
(temperature_total_0000_2024-11-21-05-24-47.txt)

use total cpu load, not for individual core
------------------------------------------------------------
2024-11-21 09:11:03; t_cpu=45.6;    t_gpu=42.5;    t_nvme_1=43.9; t_nvme_2=42.9; 600;   1800;  1800;  1800;  user=0.1;          nice=0.0;          system=0.3;        idle=99.6;         iowait=0.0;        irq=0.0;           softirq=0.0;       steal=0.0;         guest=0.0;         guest_nice=0.0;   
============================================================