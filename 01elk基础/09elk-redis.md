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
