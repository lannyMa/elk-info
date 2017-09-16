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