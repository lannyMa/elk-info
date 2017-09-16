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