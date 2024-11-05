#!/bin/bash

# Directory creation for scans
if [ ! -d "$1-nmap-scans" ]; then
  mkdir $1-nmap-scans
fi

cd $1-nmap-scans

start=$(date +%s)

# active IPs on local network scanning
echo -e "[+]+ Online IP addresses scanning ..."
nmap -sn $1 -oG active.txt

if ! grep -q "Up" "active.txt"; then
  echo "No IP address found on network"
  exit 0
fi

# Listening ports on found addresses
mapfile -t active_ip < <(awk '/Up$/{print $2}' "active.txt")

echo "Listening ports on active IPs detection ..."
for ip in "${active_ip[@]}"; do
  nmap -Pn "$ip" | grep "open" >> "services_$ip.txt"
done

# Time processing
end=$(date +%s)
tps_exec=$(($end - $start))

echo "Processing time: $tps_exec sec"
echo "Results can be found in the $1-nmap-scans folder"

exit
