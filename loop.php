<?php
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
        if (!empty($datum))
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
            if ($element->start == 0)
                $element->start();
            return $element;
        }
    }

    return null;
}

class User
{
    public $data, $user, $created, $cons;
    public $start = 0;

    public function __construct($data)
    {
        $this->data = $data;
        $data = explode(":", $data);
        $this->user = $data[0];
        $this->created = $data[1];

        if (!@$data[2]) {
            $this->cons = 1;
            $this->update();
        } else
            $this->cons = $data[2];

        $this->start = @$data[3] ?? 0;
        $this->suspend();
    }

    public function start()
    {
        $this->start = time();
        $this->update();
    }

    public function update()
    {
        $str = $this->getStr();
        shell_exec("sed -i 's/{$this->data}/{$str}/g' " . __DIR__ . "/users.txt");
        $this->data = $str;
        echo "Updated {$str}" . PHP_EOL;
    }

    public function suspend()
    {
        if ($this->start > 0)
            if ($this->start + 2592000 <= time()) {
                shell_exec("pkill -u {$this->user}");
                shell_exec("deluser {$this->user}");
                shell_exec("sed -i 's/{$this->data}//g' " . __DIR__ . "/users.txt");
                shell_exec("echo '$this->data:" . time() . "' >> suspended.txt");
                echo "Suspended " . $this->user . PHP_EOL;
            }
    }

    public function getStr()
    {
        $str = "{$this->user}:{$this->created}:{$this->cons}";
        if ($this->start > 0) {
            $str .= ":" . $this->start;
        }
        return $str;
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
            continue;
        }
        $d = explode(" ", $c);
        $user = findObjectByUser($d[1], $users);
        if ($user and (int)$d[0] > $user->cons) {
            shell_exec("pkill -u " . $d[1]);
            echo "Go to Fuck " . $d[1] . PHP_EOL;
        }
    }
}