#!/bin/bash

# Check if running as root
[ "$EUID" -ne 0 ] && echo "Please run as root." && exit

# Check if the user enters a valid IP address
read -p "Please enter the network ID (e.g. 192.168.0.0/24): " network_id
while [[ ! $network_id =~ ^(([0-9]|[0-9]{2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[0-9]{2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])/(([1-9])|([1-2][0-9])|(3[0-2]))$ ]]
do
        echo "Please enter a valid IP address."
        read -p "Please enter the network ID (e.g. 192.168.0.0/24): " network_id
done

# Create a directory for this network and cd into it
folder=$(echo $network_id | cut -d "/" -f 1)
[ ! -d $folder ] && mkdir $folder; cd $folder

# Collect all alive hosts in the network
echo "Using fping to find alive hosts..."
ips_file="IPs.txt"
fping -aqg $network_id | awk '{print $1}' | sort -t . -k 3,3n -k 4,4n > $ips_file 2>&1

# ----------------------------------------------------------------------
# Get SMB info using crackmapexec and check rpcclient access to those IP
netbios="NETBIOS.txt"
rpc="rpc.txt"

echo "Gathering info from $network_id using crackmapexec and writing to $netbios."
crackmapexec smb $network_id | sort -t . -k 3,3n -k 4,4n > $netbios

declare -a accessed=()

echo "Checking rpcclient access..."

for ip in $(cat $netbios | awk '{print $2}')
do
        rpcclient $ip -U ''%'' --command quit 2>/dev/null
        [[ $? == 0 ]] && accessed+=($ip)
done

if (( ${#accessed[@]} ))
then
        echo "Accessed those IPs with rpcclient ($rpc):"

        for i in ${accessed[@]}
        do
                echo "$i" >> $rpc
        done

        cat $rpc
else
        echo "Could not accessed any IP."
fi
# -----------------------------------------------------------------------

ips=$(wc -l $ips_file | awk '{print $1}')
i=0
nmap_folder="nmap"

# Create nmap directory for this specific subnet if does not exists already
[ ! -d $nmap_folder ] && mkdir $nmap_folder

while ((i++)); IFS= read -r line
do
        echo -e "Scanning $line ($i/$ips)..."
        ports=$(nmap -p- --open $line | grep "[0-9]*/tcp" | grep -v "unknown" | cut -d "/" -f 1 | tr "\n" "," | sed s/,$//)

        # If no open ports discovered, skip that IP
        [ -z $ports ] && echo "No open ports discovered for this machine." > $nmap_folder/$line.out && continue

        [[ $ports == *"445,"* ]] && nmap -O -sVC -p$ports --script="smb-vuln-*" $line -v0 -oN $nmap_folder/$line.out && continue

        nmap -O -sVC -p$ports $line -v0 -oN $nmap_folder/$line.out 
done < $ips_file

echo -e "\nScan done."