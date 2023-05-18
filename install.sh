#!/bin/bash
apt update
apt install php -y
echo '#!/bin/bash
useradd -m -s /usr/sbin/nologin $1                                                                                                                              
echo "$1:$2" | chpasswd
DATE=`date +%s`
echo "$1:$DATE:$3" >> users.txt
' > bake.sh



###########################################################################################
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
PWD=`pwd`
echo "* * * * * sh $PWD/cron.sh" >> mycron
#install new cron file
crontab mycron
rm mycron
##########################################################################################


echo '#!/bin/bash
STATUS=`ps -ef | grep loop.php | grep -v grep | wc -l`
PWD=`pwd`
if [ $STATUS != 1 ];then
        echo "Loop Stopped :|"
        php ./loop.php & >> log.txt
else
        echo "Loop running :)"
fi' > cron.sh

################################################################
echo '' > users.txt
echo '' > suspended.txt
echo '' > log.txt

#################################################################

curl https://raw.githubusercontent.com/alisoleimanii/ssh-management/master/loop.php > loop.php

################################################

echo 'ps aux | grep sshd | cut -d" " -f1 | sort | grep -v root | grep -v sshd | uniq -c' > online.sh

#################################################
echo '
      pkill -u $1
      deluser $1
      ' > suspend.sh

#################################################
PWD=`pwd`
echo '
function v8-online(){
    sh '$PWD'/online.sh
}
function v8-suspend(){
    sh '$PWD'/suspend.sh $@
}
function v8-make(){
    sh '$PWD'/bake.sh $@
}
' >> ~/.bashrc

bash
################################################

