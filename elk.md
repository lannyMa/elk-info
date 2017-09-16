

## logstash基本语法
```
[root@linux-node1 application]# cat t.conf 
input {
  stdin{}
}
output {
  stdout { codec => rubydebug }
}
```


```
[root@linux-node1 application]# cat redis-indata.conf 

input {
  stdin{}
}

output{
        redis{
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "system-syslog"
        }
    }
[root@linux-node1 application]# ./logstash/bin/logstash -f redis-indata.conf
```

随便输入
```
redis:
info
....
# Keyspace
db6:keys=1,expires=0,avg_ttl=0  <--创建了db6
192.168.14.136:6379> SELECT 6
OK
192.168.14.136:6379[6]> KEYS *
1) "demo"

192.168.14.136:6379[6]> LINDEX demo -1  <--列表最后一行
"{\"message\":\"adf\",\"@version\":\"1\",\"@timestamp\":\"2016-10-09T16:50:12.740Z\",\"host\":\"linux-node1.example.com\"}"

192.168.14.136:6379[6]> LLEN demo
(integer) 18
```
======
读出来



## messages
messages格式:
```
[root@linux-node1 application]# cat /var/log/messages
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: USB disconnect, device number 6
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: new full speed USB device number 7 using uhci_hcd
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: New USB device found, idVendor=0e0f, idProduct=0008
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: Product: Virtual Bluetooth Adapter
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: Manufacturer: VMware
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: SerialNumber: 000650268328
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: configuration #1 chosen from 1 choice
Oct  5 12:07:05 linux-node1 sz[8488]: [root] nginx_access.conf/ZMODEM: 152 Bytes, 5 BPS
Oct  9 23:05:07 linux-node1 sz[8548]: [root] www.conf/ZMODEM: 658 Bytes, 723 BPS
Oct  9 23:05:27 linux-node1 rz[8555]: [root] no.name/ZMODEM: got error
Oct  9 23:05:39 linux-node1 sz[8557]: [root] www.conf/ZMODEM: 658 Bytes, 215 BPS
Oct  9 23:27:56 linux-node1 kernel: e1000: eth1 NIC Link is Down
Oct  9 23:27:59 linux-node1 kernel: e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
```

logstash处理:
```
[root@linux-node1 application]# ./logstash/bin/logstash -f system-meassges.conf
Settings: Default pipeline workers: 1
Pipeline main started
{
       "message" => "Oct  9 23:27:59 linux-node1 kernel: e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None",
      "@version" => "1",
    "@timestamp" => "2016-10-09T15:58:45.732Z",
          "path" => "/var/log/messages",
          "host" => "linux-node1.example.com",
          "type" => "system"
}

[root@linux-node1 application]# cat system-meassges.conf
input{
    file{
        path => ["/var/log/messages"]
        type => "system"
        start_position => "beginning"
    }
}

output{
    stdout{
        codec => rubydebug{ }
    }
}
```

输入到es
```
[root@linux-node1 application]# cat system-meassges.conf01 
input{
    file{
        path => ["/var/log/messages"]
        type => "system"
        start_position => "beginning"
    }
}

output{
    elasticsearch{
        hosts => ["192.168.14.136:9200"]
        index => "system-%{+YYYY.MM.dd}"
    }
}

```

## multiline-codec
logstash效果:
- 当遇到 [ 时候切割为一条完整日志.<---搜集不规整的日志

```
[root@linux-node1 application]# ./logstash/bin/logstash -f multiline.conf 
Settings: Default pipeline workers: 1
Pipeline main started
sfsafd

sfdaf

sfdsdf
sf
sdfsdf
]
af
sdfsd
fdsf]
[
{
    "@timestamp" => "2016-10-09T16:14:34.406Z",
       "message" => "sfsafd\nsfdaf\nsfdsdf\nsf\nsdfsdf\n]\naf\nsdfsd\nfdsf]",
      "@version" => "1",
          "tags" => [
        [0] "multiline"
    ],
          "host" => "linux-node1.example.com"
}
a
asfa
\
adf
[
{
    "@timestamp" => "2016-10-09T16:14:51.947Z",
       "message" => "[\na\nasfa\n\\\nadf",
      "@version" => "1",
          "tags" => [
        [0] "multiline"
    ],
          "host" => "linux-node1.example.com"
}
```

```
[root@linux-node1 application]# cat multiline.conf 
input{
    stdin{
        codec => multiline{
            pattern => "^\["
            negate => true
            what => "previous"
        }
    }
}

output{
    stdout{
        codec => "rubydebug"
    }
}
```


## elk-nginx
- nginx日志写成json格式:

```
nginx.conf
***************************************************************************
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                 '$status $body_bytes_sent "$http_referer" '
    #                 '"$http_user_agent" "$http_x_forwarded_for"';
    
    #add by lanny
    
    log_format json '{"@timestamp": "$time_iso8601",'
           '"@version": "1",'
           '"client": "$remote_addr",'
		   '"url": "$uri", '
		   '"status": "$status", '
		   '"domain": "$host", '
		   '"host": "$server_addr",'
		   '"size":"$body_bytes_sent", '
		   '"response_time": "$request_time", '
		   '"referer": "$http_referer", '
           '"http_x_forwarded_for": "$http_x_forwarded_for", '
		   '"ua": "$http_user_agent" } ';
    #access_log  /var/log/nginx/access.log  main;
    access_log  /var/log/nginx/access.log json;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;
    include /etc/nginx/conf.d/*.conf;
}
```


- 然后访问看到nginx日志格式:

```
[root@linux-node1 application]# tail -f /app/logs/www1_access.log 
{"@timestamp": "2016-10-09T23:13:04+08:00","@version": "1","client": "192.168.14.1","url": "/index.html", "status": "304", "domain": "www.lanny.com", "host": "192.168.14.136","size":"0", "response_time": "0.000", "referer": "-", "http_x_forwarded_for": "-", "ua": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36" } 
{"@timestamp": "2016-10-09T23:13:04+08:00","@version": "1","client": "192.168.14.1","url": "/index.html", "status": "304", "domain": "www.lanny.com", "host": "192.168.14.136","size":"0", "response_time": "0.000", "referer": "-", "http_x_forwarded_for": "-", "ua": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36" } 
{"@timestamp": "2016-10-09T23:15:38+08:00","@version": "1","client": "192.168.14.1","url": "/index.html", "status": "304", "domain": "www.lanny.com", "host": "192.168.14.136","size":"0", "response_time": "0.000", "referer": "-", "http_x_forwarded_for": "-", "ua": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36" } 
```

- 经过logstash处理

```
[root@linux-node1 application]# ./logstash/bin/logstash -f nginx_access.conf02 
Settings: Default pipeline workers: 1
Pipeline main started
{
              "@timestamp" => "2016-10-09T15:28:50.000Z",
                "@version" => "1",
                  "client" => "192.168.14.1",
                     "url" => "/index.html",
                  "status" => "304",
                  "domain" => "www.lanny.com",
                    "host" => "192.168.14.136",
                    "size" => "0",
           "response_time" => "0.000",
                 "referer" => "-",
    "http_x_forwarded_for" => "-",
                      "ua" => "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36",
                    "path" => "/app/logs/www1_access.log",
}
```
==================================================
```
[root@linux-node1 application]# cat nginx_access.conf02 
input{
    file{
        path => ["/app/logs/www1_access.log"]
        codec => "json"
   }
}

output{
    stdout{
        codec => "rubydebug"
    }
}
```

输入到es
```
[root@linux-node1 application]# cat nginx_access.conf
input{
    file{
        path => ["/app/logs/www1_access.log"]
        codec => "json"
   }
}

output{
    elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "nginx-www-access-%{+YYYY.MM.dd}"
        }
}
```




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

## mysql慢查询日志

### 日志字段拆分:
- 官方提供的grok表达式
https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns 

- grok在线调试
http://grokdebug.herokuapp.com/ 

- 参考:
http://www.cnblogs.com/vovlie/p/4227027.html

- 用ELK处理日志时碰到的几个问题 
来自 <http://liu-xin.me/2016/08/16/%E7%94%A8ELK%E5%A4%84%E7%90%86%E6%97%A5%E5%BF%97%E6%97%B6%E7%A2%B0%E5%88%B0%E7%9A%84%E5%87%A0%E4%B8%AA%E9%97%AE%E9%A2%98/> 


- 学习:
https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html

- 例子:
```
input {
  file {
    path => "/var/log/http.log"
  }
}
filter {
  grok {
    match => { "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}" }
  }
}
After the grok filter, the event will have a few extra fields in it:
	• client: 55.3.244.1 
	• method: GET 
	• request: /index.html 
	• bytes: 15824 
	• duration: 0.043 
```



```
115.182.31.11 - - [02/Aug/2013:08:35:10 +0800] "GET /v2/get?key=0b0c1c5523aa40c3a5dcde4402947693&appid=153&appname=%e6%96%97%e5%9c%b0%e4%b8%bb%e5%8d%95%e6%9c%ba%e7%89%88&uuid=861698005693444&client=1&operator=1&net=2&devicetype=1&adspacetype=1&category=2&ip=117.136.22.36&os_version=2.2.2&aw=320&ah=50&timestamp=1375403699&density=1.5&pw=800&ph=480&Device=ZTE-U%2bV880&sign=1f6fd0992ca09e8525b0f7165a928a2a HTTP/1.1" 200 76 "-" "-" -
117.135.137.180 - - [02/Aug/2013:08:35:10 +0800] "GET /v2/get?Format=json&Key=47378200063c41fe90eff85f11ca4d2f&AppId=324&AppName=%25E5%258D%2595%25E6%259C%25BA%25E6%2596%2597%25E5%259C%25B0%25E4%25B8%25BB&Uuid=b51d63a91da5a4111e6cc1fb2c2538d5&Client=1&Operator=1&Net=2&DeviceType=1&AdSpaceType=1&Category=28&Ip=117.136.7.111&Os_version=4.0.4&Aw=320&Ah=50&TimeStamp=1375403708&Sign=9a00b63a04c165deea70dedd6b747697 HTTP/1.0" 200 776 "-" "-" -
115.182.31.11 - - [02/Aug/2013:08:35:10 +0800] "GET /v2/get?key=0b0c1c5523aa40c3a5dcde4402947693&appid=153&appname=%e6%96%97%e5%9c%b0%e4%b8%bb%e5%8d%95%e6%9c%ba%e7%89%88&uuid=860173017274352&client=1&operator=2&net=3&devicetype=1&adspacetype=1&category=2&ip=120.7.195.5&os_version=2.3.5&aw=320&ah=50&timestamp=1375403700&density=1.5&long=39&lat=0699733%2c116&pw=854&ph=480&Device=MI-ONE%2bPlus&sign=f65a4b2b2681ac489f65acf49e3d8ebd HTTP/1.1" 200 76 "-" "-" -
115.182.31.12 - - [02/Aug/2013:08:35:10 +0800] "GET /v2/get?key=0b0c1c5523aa40c3a5dcde4402947693&appid=153&appname=%e6%96%97%e5%9c%b0%e4%b8%bb%e5%8d%95%e6%9c%ba%e7%89%88&uuid=863802017354171&client=1&operator=1&net=3&devicetype=1&adspacetype=1&category=2&ip=123.121.144.120&os_version=2.3.5&aw=320&ah=50&timestamp=1375403698&density=1.5&long=40&lat=11183975%2c116&pw=854&ph=480&Device=MI-ONE%2bPlus&sign=0c74cf53a4b6adfe5e218f4fab920da3 HTTP/1.1" 200 76 "-" "-" -
115.182.31.8 - - [02/Aug/2013:08:35:10 +0800] "GET /v2/get?key=0b0c1c5523aa40c3a5dcde4402947693&appid=153&appname=%e6%96%97%e5%9c%b0%e4%b8%bb%e5%8d%95%e6%9c%ba%e7%89%88&uuid=868247013598808&client=1&operator=4&net=2&devicetype=1&adspacetype=1&category=2&ip=117.136.20.88&os_version=2.3.5&aw=320&ah=50&timestamp=1375403707&density=1.5&pw=800&ph=480&Device=Lenovo%2bA520GRAY&sign=43d5260eb2b89f5984b513067e074f5e HTTP/1.1" 200 67 "-" "-" -
```

```
cat sample.conf

input {
    file {
        path => "/application/conf/access.log"
        start_position => "beginning" 
    }
}
filter {
    grok {
        match => ["message", "%{IPORHOST:client} (%{USER:ident}|-) (%{USER:auth}|-) \[%{HTTPDATE:timestamp}\] \"(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:http_version})?|-)\" %{NUMBER:response} %{NUMBER:bytes} \"(%{QS:referrer}|-)\" \"(%{QS:agent}|-)\""]
    }
    kv {
                source => "request"
                field_split => "&?"
                value_split => "="
        }
    urldecode {
        all_fields => true
    }
}

output {
    stdout {
        codec => rubydebug{ }
    }
}

```

## elk-all
- es错误日志展示:
```
[root@linux-node1 application]# tail -f /var/log/elasticsearch/oldboy.log
[2016-10-09 23:08:44,147][INFO ][cluster.routing.allocation] [linux-node1] Cluster health status changed from [YELLOW] to [GREEN] (reason: [shards started [[nginx-log-2016.10.09][2]] ...]).
[2016-10-09 23:20:12,497][WARN ][monitor.jvm              ] [linux-node1] [gc][young][19219][87] duration [2.2s], collections [1]/[3s], total [2.2s]/[12.4s], memory [110.1mb]->[46.4mb]/[1015.6mb], all_pools {[young] [63.6mb]->[137.3kb]/[66.5mb]}{[survivor] [5.3mb]->[4.3mb]/[8.3mb]}{[old] [41.1mb]->[41.9mb]/[940.8mb]}
[2016-10-09 23:24:39,758][INFO ][cluster.metadata         ] [linux-node1] [nginx-www-access-2016.10.09] creating index, cause [auto(bulk api)], templates [], shards [5]/[1], mappings []
[2016-10-09 23:24:45,798][WARN ][monitor.jvm              ] [linux-node1] [gc][young][19490][88] duration [2s], collections [1]/[2.5s], total [2s]/[14.4s], memory [110mb]->[50.1mb]/[1015.6mb], all_pools {[young] [63.7mb]->[184.2kb]/[66.5mb]}{[survivor] [4.3mb]->[7.9mb]/[8.3mb]}{[old] [41.9mb]->[41.9mb]/[940.8mb]}
….
```

```
[root@linux-node1 application]# cat all.conf 
input{
    syslog{
        type => "system-syslog"
        host => "192.168.14.136"
        port => "514"
    }
    file{
        path => ["/var/log/messages"]
        type => "system"
        start_position => "beginning"
    }
    
    file{
        path => ["/var/log/nginx/access.log"]
        codec => "json"
        type => "nginx-log"
        start_position => "beginning"
       
    }   
   
    file{
        path => ["/var/log/elasticsearch/oldboy.log"]
        type => "es-error"
        start_position => "beginning"
        codec => multiline{
            pattern => "^\["
            negate => true
            what => "previous"
        }
    }
}

output{
    if [type] == "system-syslog"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "system-syslog-%{+YYYY.MM.dd}"
        }
    }
    if [type] == "system"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "system-%{+YYYY.MM.dd}"
        }
    }
    if [type]  == "nginx-log"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "nginx-log-%{+YYYY.MM.dd}"
        }
    }
    if [type]  == "es-error"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "es-error-%{+YYYY.MM.dd}"
        }
    }
}
```


## elk-redis
- 生产维护脚本

```
echo ' INFO'
echo ' SELECT 6'
echo ' KEYS *'
echo '  LINDEX demo -1'
echo '  LLEN demo'

/usr/local/bin/redis-cli -h 127.0.0.1 -p 52833 -a 362bcadfbb0bfa33
```

```
yum install redis -y
vim /etc/redis
[root@linux-node1 etc]# grep '^[a-z]' /etc/redis.conf
daemonize yes
pidfile /var/run/redis/redis.pid
port 6379
bind 192.168.14.136

/etc/init.d/redis start

redis-cli -h 192.168.14.136
info
```


- 往redis里写数据,通过logstash

```
[root@linux-node1 application]# cat redis-indata.conf 

input {
  stdin{}
}

output{
        redis{
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "system-syslog"
        }
    }
[root@linux-node1 application]# ./logstash/bin/logstash -f redis-indata.conf
```

- 连接redis.输入info

```
redis:
info
....
# Keyspace
db6:keys=1,expires=0,avg_ttl=0  <--自动创建了db6
192.168.14.136:6379> SELECT 6
OK
192.168.14.136:6379[6]> KEYS *
1) "demo"

192.168.14.136:6379[6]> LINDEX demo -1  <--列表最后一行
"{\"message\":\"adf\",\"@version\":\"1\",\"@timestamp\":\"2016-10-09T16:50:12.740Z\",\"host\":\"linux-node1.example.com\"}"

192.168.14.136:6379[6]> LLEN demo
(integer) 18
```


- 从redis读出去:

```
input{
    redis{
        host => "192.168.14.136"
        port => "6379"
        db => "6"
        data_type => "list"
        key => "demo"
    }
}

output{
    elasticsearch{
        hosts => ["192.168.14.136:9200"]
        index => "redis-demo-%{+YYYY.MM.dd}"
    }
}
```

## redis-out
```
[root@linux-node1 application]# cat redis-out.conf 
input{
  stdin{}
}

output{
    redis{
        host => "192.168.14.136"
        port => "6379"
        db => "6"
        data_type => "list"
        key => "demo"
    }
}
=================================
[root@linux-node1 application]# cat all-redis-out.conf 
input{
    syslog{
        type => "system-syslog"
        host => "192.168.14.136"
        port => "514"
    }
    file{
        path => ["/var/log/messages"]
        type => "system"
        start_position => "beginning"
    }
    
    file{
        path => ["/var/log/nginx/access.log"]
        codec => "json"
        type => "nginx-log"
        start_position => "beginning"
       
    }   
   
    file{
        path => ["/var/log/elasticsearch/oldboy.log"]
        type => "es-error"
        start_position => "beginning"
        codec => multiline{
            pattern => "^\["
            negate => true
            what => "previous"
        }
    }
}

filter{
    mutate{
          gsub => [
          "time", "[+]", "T"
                   ]
    } 
    mutate{
          replace => ["time","%{time}+08:00"]
    }
}

output{
    if [type] == "system-syslog"{
        redis{
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "system-syslog"
        }
    }
    if [type] == "system"{
        redis{
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "system"
        }
    }
    if [type]  == "nginx-log"{
        redis{
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "nginx-log"
        }
    }
    if [type]  == "es-error"{
        redis{
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "es-error"
        }
    }
}

```

## redis-in
```
[root@linux-node1 application]# cat redis-in.conf 
input{
    redis{
        host => "192.168.14.136"
        port => "6379"
        db => "6"
        data_type => "list"
        key => "demo"
    }
}

output{
    elasticsearch{
        hosts => ["192.168.14.136:9200"]
        index => "redis-demo-%{+YYYY.MM.dd}"
    }
}
==============================
[root@linux-node1 application]# cat all-redis-in.conf 
input{
        redis{
            type => "system-syslog"
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "system-syslog"
        }
        redis{
            type => "system"
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "system"
        }
        redis{
            type => "nginx-log"
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "nginx-log"
        }
        redis{
            type => "es-error"
            host => "192.168.14.136"
            port => "6379"
            db => "6"
            data_type => "list"
            key => "es-error"
        }
}

filter{
    mutate{
          gsub => [
          "time", "[+]", "T"
                   ]
    } 
    mutate{
          replace => ["time","%{time}+08:00"]
    }
}

output{
    if [type] == "system-syslog"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "system-syslog-%{+YYYY.MM.dd}"
        }
    }
    if [type] == "system"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "system-%{+YYYY.MM.dd}"
        }
    }
    if [type]  == "nginx-log"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "nginx-log-%{+YYYY.MM.dd}"
        }
    }
    if [type]  == "es-error"{
        elasticsearch{
            hosts => ["192.168.14.136:9200"]
            index => "es-error-%{+YYYY.MM.dd}"
        }
    }
}
```


## elk生产部署指南
https://www.elastic.co/guide/en/elasticsearch/guide/current/deploy.html



## begin end

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl4x5ke5cj20ue01wac2)
- beginning 记录了 读取到了哪行
- end 每次都从尾巴来读
- beginning每次从 sincdb位置开始读


- end参数
无论如何,记录从该时间点开始到以后的日志.
 
- beginning:
下面文件帮该参数记录位置.从位置点开始读日志,如果清理掉下面文件,则无意义.
```
[root@linux-node1 ~]# ls .sincedb*
.sincedb_d883144359d3b4f516b37dba51fab2a2
 
begin:
./logstash/bin/logstash -f test02.conf
rm -f ~/.sincedb*
./logstash/bin/logstash -f test02.conf
./logstash/bin/logstash -f test02.conf

```

## kibana使用
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl4ywnlprj21ck0mywrr)
上面展示了8个字段,仅FromData未展示

我们的日志:10个字段
- 内部请求日志

```
{"STATUS":200,"FORM_DATA":"{}","IP":"100.97.15.62","REQUEST_URI":"POST /payGateway/lianlian/wap/recharge/asyncReturn","HTTP_USER_AGENT":"httpcomponents","METRIC":"UserRechargeDetailDao.lockByPayNumber:10.981ms TransactionManager.doCommit:6.775ms TransactionManager.doBegin:1.516ms TransactionManager.doCleanupAfterCompletion:0.041ms RenderJSON:0.014ms TransactionManager.doGetTransaction:2/0.002/0.006/0.008ms ","TOTAL_TIME":"24.114ms","REQUEST_TIME":"2016-10-17T00:00:05.525+08:00","THREAD":"http-bio-8080-exec-38"}
```

- 外部请求日志: 多了一个RESULT字段
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl5a6p304j21kw0ra4qp)





