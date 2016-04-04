This script is used to monitor the disk space's and memory's usage in a Linux server. The user invokes this script by providing monitoring threshold values for both the disk space and memory in the command. The script will send out an email to the users when the server's disk space or memory usage go over its provided limit. The script also optionally takes a number which indicates the number of time to skip sending out an email notification to the user. For example, if this value is set to a 100, the script will only send out an email once every 100 times upon running the script and the server's resources go over its provided threshold limit. This essentially gives the user an option to configure the frequency of receiving an email notification when setting this script in a cron job. The default value for this frequency/counter value is 1.



To run this script, type  sudo ./resources_monitoring.sh disk_monitoring memory_monitoring [notify_frequncy_counter] [people_emails] [resource_names] [mem_mon_flag]. Value inside [] is optional.

Example: sudo ./resources_monitoring.sh 80 85 100 ylee@mtc.ca.gov,gmingming@mtc.ca.gov,emichaels@mtc.ca.gov '/ /boot /home' off