#!/bin/bash

# Folder creation for scan results
name="${1//\//:}"

if [ ! -d "$name-netdiscover-scans" ]; then
  mkdir -p $name-netdiscover-scans
fi

cd $name-netdiscover-scans

start=$(date +%s)

# IP Network scanning
echo -e "[+]+ Online IP addresses scanning ..."
netdiscover -r $1 -P -N > active.txt

# Listening ports on found hosts scanning
mapfile -t active_ip < <(awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $1}' "active.txt")

echo "Listening ports on hosts scanning ..."
for ip in "${active_ip[@]}"; do
  nmap -Pn "$ip" | grep 'open' >> "services_$ip.txt"
done

# Processing time
end=$(date +%s)
exec_time=$(($end - $start))

echo "Processing time: $exec_time sec"
echo "Results can be found in the $name-netdiscover-scans folder"

exit
