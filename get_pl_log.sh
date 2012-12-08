#!/bin/bash
cat << \EOF > update_pl.sh
curl twoswarm.cs.washington.edu:31337/?djaangM4v=mevivaeidethea > pltmptmp
python convert_to_viz.py pltmptmp $1 plviztmp `cat pl_log.txt | wc -l`
cat 12_07_17-23\:23\:51.txt plviztmp > tmpytmp
mv -f tmpytmp 12_07_17-23\:23\:51.txt
EOF

cat << \EOF > change_timestamp_format.py
import sys
import re

if len(sys.argv) != 2:
    print "Usage: python change_timestamp_format.py <input_file>"
else:
    inp = open(sys.argv[1])
    line = inp.readline()
    while line != "":
        line = line.strip()
        if re.match("[0-9][0-9]_[0-9][0-9]_[0-9][0-9]-[0-9][0-9]:[0-9][0-9]:[0-9][0-9]", line):
            date = line.split("-")[0]
            time = line.split("-")[1]
            month = date.split("_")[0]
            day = date.split("_")[1]
            year = date.split("_")[2]
            if int(month) < 12:
                newtimestamp = year + "_" + month + "_" + day + "-" + time
                print newtimestamp
            else:
                print line
        else:
            print line
        line = inp.readline()
    inp.close()

EOF

cat << \EOF > convert_to_viz.py
import sys
import socket

if len(sys.argv) < 4:
    print "python convert_to_viz.py <input_file> <success | time> <TIMESTAMP | output_file> [<num_lines>]"
else:
    inp = open(sys.argv[1])
    if sys.argv[3] == "TIMESTAMP":
        host = inp.readline()
        host = host.strip()
        timestamp = inp.readline().strip()
        out = open("data/" + timestamp + ".txt", 'w')
        print(timestamp + ".txt")
        icmp_stats = inp.readline().strip()
        if icmp_stats.split("_")[0] != "":
            icmp_success = int(icmp_stats.split("_")[0])
        else:
            icmp_success = -1
        if len(icmp_stats.split("_")) == 2 and icmp_stats.split("_")[1] != "":
            icmp_speed = float(icmp_stats.split("_")[1])
        else:
            icmp_speed = 0
        udp_stats = inp.readline().strip()
        if udp_stats.split("_")[0] != "":
            udp_success = int(udp_stats.split("_")[0])
        else:
            udp_success = -1
        if len(udp_stats.split("_")) == 2 and udp_stats.split("_")[1] != "":
            udp_speed = float(udp_stats.split("_")[1])
        else:
            udp_speed = 0
        icmp_last_ip = inp.readline().strip()
        udp_last_ip = inp.readline().strip()
        inp.readline()
        try:
            ip = socket.gethostbyname(host)
        except socket.gaierror:
            ip = ""
        except:
            raise
    
        if icmp_success != -1 and udp_success != -1:
            if sys.argv[2] == "success":
                out.write(ip + "\t" + timestamp + "\t" + str((100 - icmp_success)) + "\t" + icmp_last_ip + "\tICMP\n")
                out.write(ip + "\t" + timestamp + "\t" + str((100 - udp_success)) + "\t" + udp_last_ip + "\tUDP\n")
            else:
                if icmp_success > 0:
                    out.write(ip + "\t" + timestamp + "\t" + str(icmp_speed) + "\t" + "-1\tICMP\n")
                else:
                    out.write(ip + "\t" + timestamp + "\t" + "-1\t" + icmp_last_ip + "\tICMP\n")
                    
                if udp_success > 0:
                    out.write(ip + "\t" + timestamp + "\t" + str(udp_speed) + "\t" + "-1\tUDP\n")
                else:
                    out.write(ip + "\t" + timestamp + "\t" + "-1\t" + udp_last_ip + "\tUDP\n")

        host = inp.readline()
    else:
        out = open("data/" + sys.argv[3], 'w')
        print sys.argv[3]
        i = 0
        while i < int(sys.argv[4]):
            inp.readline()
    while host != "":
        host = host.strip()
        timestamp = inp.readline().strip()
        icmp_stats = inp.readline().strip()
        if icmp_stats.split("_")[0] != "":
            icmp_success = int(icmp_stats.split("_")[0])
        else:
            icmp_success = -1
        if len(icmp_stats.split("_")) == 2 and icmp_stats.split("_")[1] != "":
            icmp_speed = float(icmp_stats.split("_")[1])
        else:
            icmp_speed = 0
        udp_stats = inp.readline().strip()
        if udp_stats.split("_")[0] != "":
            udp_success = int(udp_stats.split("_")[0])
        else:
            udp_success = -1
        if len(udp_stats.split("_")) == 2 and udp_stats.split("_")[1] != "":
            udp_speed = float(udp_stats.split("_")[1])
        else:
            udp_speed = 0
        icmp_last_ip = inp.readline().strip()
        udp_last_ip = inp.readline().strip()
        inp.readline()
        try:
            ip = socket.gethostbyname(host)
        except socket.gaierror:
            ip = ""
        except:
            raise
        
        if icmp_success != -1 and udp_success != -1:
            if sys.argv[2] == "success":
                out.write(ip + "\t" + timestamp + "\t" + str((100 - icmp_success)) + "\t" + icmp_last_ip + "\tICMP\n")
                out.write(ip + "\t" + timestamp + "\t" + str((100 - udp_success)) + "\t" + udp_last_ip + "\tUDP\n")
            else:
                if icmp_success > 0:
                    out.write(ip + "\t" + timestamp + "\t" + str(icmp_speed) + "\t" + "-1\tICMP\n")
                else:
                    out.write(ip + "\t" + timestamp + "\t" + "-1\t" + icmp_last_ip + "\tICMP\n")
                    
                if udp_success > 0:
                    out.write(ip + "\t" + timestamp + "\t" + str(udp_speed) + "\t" + "-1\tUDP\n")
                else:
                    out.write(ip + "\t" + timestamp + "\t" + "-1\t" + udp_last_ip + "\tUDP\n")

        host = inp.readline()

EOF

orig_line_num=0
if [ -f $1 ]; then
    orig_line_num=`cat pl_log.txt | wc -l`
fi

mkdir data
wget -O data/tmplog http://twoswarm.cs.washington.edu:31337/?djaangM4v=mevivaeidethea
echo curled
python change_timestamp_format.py data/tmplog > data/pl_log.txt
echo timestampformatchanged
viz_file=data/`python convert_to_viz.py data/pl_log.txt $1 TIMESTAMP`
let new_lines=`cat data/pl_log.txt | wc -l`-$orig_line_num
echo $new_lines
echo $viz_file
tail -${new_lines} ${viz_file} > data/tmp
filename=data/`head -1 data/tmp | cut -f2`.txt
echo $filename
mv data/tmp $filename
