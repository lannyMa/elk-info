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