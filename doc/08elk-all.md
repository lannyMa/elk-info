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
