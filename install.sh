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
        echo "Loop Stoped :|"
        php ./loop.php & >> log.txt


else
        echo "Loop running :)"
fi' > cron.sh

################################################################
echo '' > users.txt
echo '' > log.txt

#################################################################
echo '<?php

/**
 * @return User[]
 */
function getUsersDetails()
{
    clearstatcache();
    $file = file_get_contents(__DIR__ . "/users.txt");
    $data = explode("\n", $file);
    $users = [];
    foreach ($data as $datum) {
        $users[] = new User($datum);
    }
    return $users;
}

/**
 * @param $id
 * @param $users
 * @return User
 */
function findObjectByUser($id, $users)
{
    foreach ($users as $element) {
        if ($id == $element->user) {
            return $element;
        }
    }

    return false;
}

class User
{
    public $user, $created, $cons;

    public function __construct($data)
    {
        $data = explode(":", $data);
        $this->user = $data[0];
        $this->created = $data[1];
        $this->cons = @$data[2] ?? 1;
    }
}


$i = 0;
while (true) {
    if ($i == 0 or $i % 60 == 0) {
        $users = getUsersDetails();
        print_r($users);
    }
    $i++;
    sleep(1);

    $a = shell_exec("ps aux | grep sshd | cut -d\" \" -f1 | sort | grep -v root | grep -v sshd | uniq -c");
    $a = str_replace("  ", "", $a);
    $b = explode("\n", $a);
    foreach ($b as $c) {
        if (empty($c)) {
            echo "Pass" . PHP_EOL;
            continue;
        }
        $d = explode(" ", $c);
        $user = findObjectByUser($d[1], $users) ?? new User($d[1] . ":123:1");
        if ((int)$d[0] > $user->cons) {
            shell_exec("pkill -u " . $d[1]);
            echo "Go to Fuck" . PHP_EOL;
        }
    }
}' > loop.php

################################################


