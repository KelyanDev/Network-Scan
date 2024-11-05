#!/bin/bash

# Results folder creation
name="${1//\//:}"

if [ ! -d "$name-ping-scans" ]; then
  mkdir -p $name-ping-scans
fi

cd $name-ping-scans

# Subnet's address and mask separation
base_ip=$(echo $1 | cut -d '/' -f1)
mask=$(echo $1 | cut -d '/' -f2)

IFS=. read -r i1 i2 i3 i4 <<< "base_ip"
host_min=$(( (1 << ( 32 - $mask)) - 2 ))

active_ip=()

# Starting time
start=$(date +%s)

# Online hosts on local network scanning
echo -e "[+]+ Online hosts scanning ..."
for ((i=1; i<=host_min; i++)); do
  ip="$i1.$i2.$i3.$((i4 + i))"
  if ping -c 2 -W 1 "$ip" &> /dev/null; then
    active_ip+=("$ip")
  fi
done

# Listening ports on found hosts scanning
printf "%s \n" "${active_ip[@]}" > active.txt

echo "Listening ports on found hosts scanning ..."
for ip in "${active_ip[@]}"; do
  nmap -Pn "$ip" | grep 'open' >> "services_$ip.txt"
done

# Processing time
end=$(date +%s)
exec_time=$(($end - $start))

echo "Processing time: $exec_time sec"
echo "Scanning results can be found in the $name-ping-scans folder"

exit
