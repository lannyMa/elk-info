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

