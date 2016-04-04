#!/bin/bash

#dsk_vol="/boot"
#df -h | awk -v ck_vol=$dsk_vol '$NF==ck_vol{if (NF==6)printf "Current Disk Usage: %s/%s. It is %d percent full. Available size is %s.\n", $3, $2, $5, $4; else printf "%s", "abcdf"}'


for dsk_vol in "/boot" "/"
do
  echo $dsk_vol
  df -h | awk -v ck_vol=$dsk_vol '$NF==ck_vol{if (NF==6)printf "Current Disk Usage: %s/%s. It is %d percent full. Available size is %s.\n", $3, $2, $5, $4; else printf "Current Disk Usage: %s/%s. It is %d percent full. Available size is %s.\n", $2,$1,$4, $3}'
  echo;echo
  
  a=${dsk_vol//\/}
  file_name="mon_ctr_$a.txt"
  echo "a: $file_name"
done