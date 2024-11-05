#!/bin/bash

# Results folder creation
name="${1//\//:}"

if [ ! -d "$name-arp-scans" ]; then
  mkdir -p $name-arp-scans
fi

cd $name-arp-scans

start=$(date +%s)

# Online hosts on local network scanning
echo -e "[+]+ Online hosts scanning ..."
arp-scan $1 > active.txt

# Listening ports on found hosts scanning
mapfile -t active_ip < <(grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "active.txt")

echo "Listening ports on found hosts scanning ..."
for ip in "${active_ip[@]}"; do
  nmap -Pn "$ip" | grep 'open' >> "services_$ip.txt"
done

# Processing time
end=$(date +%s)
exec_time=$(($end - $start))

echo "Processing time: $exec_time sec"
echo "Scanning results can be found in the $name-arp-scans folder"

exit
