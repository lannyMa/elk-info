## elk-syslog
配置:
- 客户端:

```
cat -n /etc/rsyslog.conf

79	*.* @@192.168.14.136:514
```

- 服务端:

```
[root@linux-node1 application]# cat syslog.conf 
input{
    syslog{
        type => "system-syslog"
        host => "192.168.14.136"
        port => "514"
    }
}

output{
    stdout{
        codec => "rubydebug"
    }
}
```

- 效果测试:

```
./logstash/bin/logstash -f syslog.conf   -->同时客户端执行: logger hehe等.

…rsyslog输出样式…

{
           "message" => "(root) CMD (/usr/sbin/ntpdate time.windows.com >/dev/null 2 >&1)\n",
          "@version" => "1",
        "@timestamp" => "2016-10-09T15:40:01.000Z",
              "type" => "system-syslog",
              "host" => "192.168.14.155",
          "priority" => 78,
         "timestamp" => "Oct  9 23:40:01",
         "logsource" => "linux-node2",
           "program" => "CROND",
               "pid" => "3884",
          "severity" => 6,
          "facility" => 9,
    "facility_label" => "clock",
    "severity_label" => "Informational"
}
```

## tcp
```
[root@linux-node1 application]# cat tcp.conf 
input{
    tcp{
        host => "192.168.14.136"
        port => "6666"
    }
}

output{
    stdout{
      codec => "rubydebug"
    }
}
```

- 客户端发数据到服务端的6666

```
yum install nc -y
nc 192.168.14.136 6666 < /etc//resolv.conf
echo "hello jeffery" |nc 192.168.14.136 6666

或者:echo "hello lanny" > /dev/tcp/192.168.14.136/6666
```

- 客户端数据:

```
[root@linux-node2 ~]# cat /etc/resolv.conf
; generated by /sbin/dhclient-script
search localdomain example.com
nameserver 114.114.114.114
```

- 服务器效果

```
[root@linux-node1 application]# ./logstash/bin/logstash -f tcp.conf
Settings: Default pipeline workers: 1
Pipeline main started
{
       "message" => "; generated by /sbin/dhclient-script",
      "@version" => "1",
    "@timestamp" => "2016-10-09T16:08:46.585Z",
          "host" => "192.168.14.155",
          "port" => 35274
}
{
       "message" => "search localdomain example.com",
      "@version" => "1",
    "@timestamp" => "2016-10-09T16:08:46.587Z",
          "host" => "192.168.14.155",
          "port" => 35274
}
{
       "message" => "nameserver 114.114.114.114",
      "@version" => "1",
    "@timestamp" => "2016-10-09T16:08:46.587Z",
          "host" => "192.168.14.155",
          "port" => 35274
}
{
       "message" => "hello jeffery",
      "@version" => "1",
    "@timestamp" => "2016-10-09T16:08:47.467Z",
          "host" => "192.168.14.155",
          "port" => 35275
}

```