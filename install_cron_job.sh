#!/bin/bash

#install the task as a cron job with root account
#sudo su -
cd /root
pwd
mkdir server_monitoring
cp /home/ylee/server_monitoring/resources_monitoring.sh server_monitoring

crontab -l > ./tmp_cron.txt
echo >> ./tmp_cron.txt
echo "# run every 20 minutes" >> ./tmp_cron.txt
echo "#*/20 * * * * /root/server_monitoring/resources_monitoring.sh 80 90 72 ylee@mtc.ca.gov,gmingming@mtc.ca.gov,emichaels@mtc.ca.gov > /dev/null" >> ./tmp_cron.txt

echo >> ./tmp_cron.txt
echo "# Testing portion. Remove this when done. run every 20 minutes" >> ./tmp_cron.txt
echo "*/20 * * * * /root/server_monitoring/resources_monitoring.sh 1 50 72 ylee@mtc.ca.gov,ylee_95116@yahoo.com > /dev/null" >> ./tmp_cron.txt

crontab ./tmp_cron.txt
crontab -l

rm -f ./tmp_cron.txt