#!/bin/bash




#=================================================
#
#
#params: receiving_parties_emails, email_message 
function email_people
{
  
  #The function refers to passed arguments by their position, that is $1, $2, etc. 
  #$0 is the name of the script itself.
  
  receiving_parties_emails=$1
  email_message=$2
  dsk_vol=$3
  
  echo "Sending monitoring email to $receiving_parties_emails."
  host_name=`hostname`
  subject="WARNING: Server resources usage in $host_name is above threshold limit"
  echo "Email is: $email_message"
  echo "Disk Vol is: $dsk_vol"
  
   
  echo "$email_message" > ./tmp.txt
  
  #determine the eamil body
  if [ "$dsk_vol" == "memory" ]
  then
  
    echo >> ./tmp.txt 
    free -m | awk '$1=="Mem:"{printf "Here is the memory usage in meg size. It is %d precent full. It has %d meg available.", (($3-$5-$6-$7)/$2)*100, $4+$5+$6+$7}'  >> ./tmp.txt

    echo >> ./tmp.txt 
    free -m >> ./tmp.txt
  else
  
    df -h | awk -v ck_vol=$dsk_vol '$NF==ck_vol{if (NF==6)printf "Current Disk Usage: %s/%s. It is %d percent full. Available size is %s.\n", $3, $2, $5, $4; else printf "Current Disk Usage: %s/%s. It is %d percent full. Available size is %s.\n", $2,$1,$4, $3}' >> ./tmp.txt
  
  echo >> ./tmp.txt 
  echo "Here is the overall summary of the disk usage:" >> ./tmp.txt 
  du -h $dsk_vol | grep -P '^[0-9\.]+G' | sort -nr >> ./tmp.txt
  
  fi
  
    
  
  mail -s "$subject" "$receiving_parties_emails" < ./tmp.txt
  
  rm -f ./tmp.txt
  
}

####################################################
# 
#params: check_volumn
function get_disk_use_percent
{

  #echo "In get_disk_use_percent"
  
  check_volumn=$1
  
  #echo "In get_disk_use_percent, check_volumn: $check_volumn"
  
  #get the disk space usage
  #using df -h, the fourth field is the pecentage in use

  # if the last field match the string, then do this...
  disk_use_percent=$(df -h | awk -v ck_vol=$check_volumn '$NF==ck_vol{if (NF==6)printf "%d", $5; else printf "%d", $4}')
  
  #return the value to caller
  echo $disk_use_percent
}

####################################################
# 
#params: 
function get_memory_use_percent
{

  check_volumn="Mem:"  
  
  # if the last field match the string, then do this...
  # Formula: mem_actual_used = Used - (shared + buffers + cache)
  # Formula: mem_actual_free = free + shared + buffers
  # Formula: use_percent = mem_actual_used / total_mem
  use_percent=$(free -m | awk -v ck_vol=$check_volumn '$1==ck_vol{printf "%d", (($3-$5-$6-$7)/$2)*100}')
  
  #return the value to caller
  echo $use_percent
}




#######################################################################################################
#
#params: resource_use_percent resource_monitoring_limit notify_frequncy_counter people_emails email_message dsk_vol
#
function check_resource_usage
{

    resource_use_percent=$1
    resource_monitoring_limit=$2
    notify_frequncy_counter=$3
    people_emails=$4
    email_message=$5
    dsk_vol=$6
    
    #echo "In check_resource_usage()"
    #echo "resource_use_percent: $resource_use_percent, resource_monitoring_limit: $resource_monitoring_limit, notify_frequncy_counter: $notify_frequncy_counter, people_emails: $people_emails, email_message: $email_message"
  
   
    #remove all / character in the string
    a=${dsk_vol//\/}
    monitoring_counter_file="./mon_counter_$a.txt"

    if (( $resource_use_percent > $resource_monitoring_limit )) 
    then

      #determine if we need to send the email...
      #only send the email if the monitoring counter reach 5 times, then the counter reset to 0
      monitoring_counter=0

      #email_message="Warning: Disk space usage is above $resource_monitoring_limit%."

      #people_emails="ylee@mtc.ca.gov, ylee_95116@yahoo.com"

      if [ -f "$monitoring_counter_file" ]
      then
        #read the monitoring_counter value from the file
        monitoring_counter=$(awk '{ print $0; }' $monitoring_counter_file)
        if (( $((monitoring_counter % notify_frequncy_counter)) == 0 ))
        then
          #send an email to the dev group     
          email_people "$people_emails" "$email_message" $dsk_vol

          #reset the counter in the file
           echo 1 > $monitoring_counter_file
        else
          #increment the counter and write it to the file
          #Arithmetic operations in bash uses $((...)) syntax.
          monitoring_counter=$((monitoring_counter + 1)) 

          #write the counter to the file
          echo $monitoring_counter > $monitoring_counter_file
        fi
      else
        #send the email and set the counter to 1 in the file

        #send an email to the dev group
        email_people "$people_emails" "$email_message" $dsk_vol

        #reset the counter in the file
        echo 1 > $monitoring_counter_file
      fi

    else
      #check if the monitoring file exists
      if [ -f "$monitoring_counter_file" ]
      then
        rm -f $monitoring_counter_file
      fi


    fi
  
  
  
}




#############################################################################
#
########################################################


#check for the number of argument from the command line
if [ $# -lt 2 ]; then
    script_name=`basename $0`
    echo "Error! You need to provide proper threshold values for both the disk space and memory monitoring limits."
    echo "Usage: sudo ./$script_name disk_monitoring memory_monitoring [notify_frequncy_counter] [people_emails] [resource_names] [mem_mon_flag]. Value inside [] is optional."
    echo "Example: sudo ./$script_name 80 85 100 ylee@mtc.ca.gov,gmingming@mtc.ca.gov,emichaels@mtc.ca.gov '/ /boot /home' off"
    echo;echo
    exit 1
fi


#########################################################################

#get the monitoring limits from the command line params
disk_monitoring_limit=$1
memory_monitoring_limit=$2
notify_frequncy_counter=$3
people_emails=$4
disk_volumns=$5
mem_mon_flag=$6

#echo "Before: Disk mon is $disk_monitoring_limit, Mem mon is $memory_monitoring_limit, Noti counter is $notify_frequncy_counter, people_emails is $people_emails, disk_volumns is $disk_volumns."

# assign default value if user does not provide
if [[ $notify_frequncy_counter == "" ]]
then
  notify_frequncy_counter=1
fi

# assign default value if user does not provide
if [[ $people_emails == "" ]]
then
  people_emails="ylee@mtc.ca.gov,ylee_95116@yahoo.com"
fi

# assign default value if user does not provide
if [[ $disk_volumns == "" ]]
then
  disk_volumns="/"
fi

# assign default value if user does not provide
if [[ $mem_mon_flag == "" ]]
then
  mem_mon_flag="1"
fi




#echo "After: Disk mon is $disk_monitoring_limit, Mem mon is $memory_monitoring_limit, Noti counter is $notify_frequncy_counter, people_emails is $people_emails, disk_volumns is $disk_volumns."


#check the disk usage...

#split string with space into an array
IFS=' ' read -a vol_array <<< "$disk_volumns"

#loop through all the disk volumns which user want to check
for vol in "${vol_array[@]}" ; do
  echo;echo
  echo "Checking disk volumn: $vol"
  
  #get resource usage
  #calling the function and turning the return value into a variable
  disk_resource_usage=$(get_disk_use_percent $vol)
  
  echo "Return value from get_disk_use_percent: $disk_resource_usage"
  
  if [[ $disk_resource_usage == "" ]]
  then
      disk_resource_usage="0"
  fi
  
  #build the email subject 
  email_message="Warning: Disk space usage in $vol is above $disk_monitoring_limit%."
  
  #check the resource usage
  check_resource_usage $disk_resource_usage $disk_monitoring_limit $notify_frequncy_counter "$people_emails" "$email_message" $vol
  
done

if [ $mem_mon_flag == "1" -o $mem_mon_flag == "true" -o $mem_mon_flag == "on" ]
then
    #check the memory usage...
    echo;echo "Checking memory..."
    mem_resource_usage=$(get_memory_use_percent)

    echo "Return value from get_memory_use_percent: $mem_resource_usage"

    if [[ $mem_resource_usage == "" ]]
    then
      mem_resource_usage="0"
    fi

    #build the email subject 
    email_message="Warning: Memory usage is above $memory_monitoring_limit%."

    #check the resource usage
    check_resource_usage $mem_resource_usage $memory_monitoring_limit $notify_frequncy_counter "$people_emails" "$email_message" "memory"
else
  echo "Memory monitoring is turn off. No action taken."
fi









