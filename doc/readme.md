



## head新建索引
```
testindex/test1
{
  "name": "maotai",
  "age:": 20,
  "favor": "girl"
}
```

## logstash测试
```
/usr/local/logstash/bin/logstash -f /data/es/conf/basic.conf

- basic.conf
input {

  stdin{}

}

output {
  stdout { codec => rubydebug }
}

- 结果
maotai
{
      "@version" => "1",
          "host" => "no104.p100.net",         # 添加了hosts
    "@timestamp" => 2017-09-16T12:10:46.932Z, # 这里时间不会,不过没事
       "message" => "maotai"                  # 实际上日志信息
}
```

## logstash输入到elasticsearch

从kibana里显示,可以得到,从哪台主机--哪个日志文件--什么时候入库的.
!()[http://ww1.sinaimg.cn/large/9e792b8fgy1fjm7x3182tj20qt0blmyc]

!()[http://ww1.sinaimg.cn/large/9e792b8fgy1fjm8n23fwkj20hb0c8ac2]



## type测试
```
input{
    file{
        path => ["/tmp/a.txt"]
        type => "a-txt"
    }

    file{
        path => ["/tmp/b.txt"]
        type => "b-txt"
        start_position => "beginning"
    }
}

output{
    if [type] == "a-txt"{
        elasticsearch{
            hosts => ["192.168.6.104:9200"]
            index => "a-txt-%{+YYYY-MM-dd}"
        }
        stdout { codec => rubydebug }
    }

    if [type] == "b-txt"{
        elasticsearch{
            hosts => ["192.168.6.104:9200"]
            index => "b-txt-%{+YYYY-MM-dd}"
        }
        stdout { codec => rubydebug }
    }
}


```


# add_field
## 配置文件
```
input{
    file{
        add_field => {"testfield"=>"testfield"}
        path => ["/tmp/a.txt"]
        type => "a-txt"
    }
}

output{
    if [type] == "a-txt"{
        elasticsearch{
            hosts => ["192.168.6.104:9200"]
            index => "a-txt-%{+YYYY-MM-dd}"
        }
        stdout { codec => rubydebug }
    }
}
```

## 测试:
```
echo 4 >> a.txt
echo 5 >> a.txt
```

## 输出
```
{
          "path" => "/tmp/a.txt",
    "@timestamp" => 2017-09-17T02:40:20.327Z,
      "@version" => "1",
          "host" => "no104.p100.net",
       "message" => "4",
          "type" => "a-txt",
     "testfield" => "testfield"
}
{
          "path" => "/tmp/a.txt",
    "@timestamp" => 2017-09-17T02:40:23.336Z,
      "@version" => "1",
          "host" => "no104.p100.net",
       "message" => "5",
          "type" => "a-txt",
     "testfield" => "testfield"
}
```

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmit7lbhyj20nk0f6794)

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmiu84b89j20ow0iy42e)

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmiujdjv7j20om0h243a)


# 多个tag
用于增加一些标签，这个标签可能在后续的处理中起到标志的作用
来自 <http://blog.csdn.net/wjacketcn/article/details/50960843> 

## 给日志打tag
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmivqhyqlj20o00gg45n)

## 输出
```
{
          "path" => "/tmp/a.txt",
    "@timestamp" => 2017-09-17T03:01:31.771Z,
      "@version" => "1",
          "host" => "no104.p100.net",
       "message" => "10",
          "type" => "a-txt",
     "testfield" => "testfield",
          "tags" => [
        [0] "mytag"
    ]
}
```

## kibana展示
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmiwdlpldj20oe0h441m)

# 多个tag
## 输出
```
{
          "path" => "/tmp/a.txt",
    "@timestamp" => 2017-09-17T03:11:18.462Z,
      "@version" => "1",
          "host" => "no104.p100.net",
       "message" => "11",
          "type" => "a-txt",
     "testfield" => "testfield",
          "tags" => [
        [0] "mytag",
        [1] "mytag2",
        [2] "mytag3"
    ]
}

```

## kibana展示
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmixd66fsj20ko0gy41o)


![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjmixnhv61j20gq0lkjuz)



配置:
```
[root@no104 logstash]# cat all.conf
input{
    file{
        add_field => {"testfield"=>"testfield"}
        path => ["/tmp/a.txt"]
        type => "a-txt"
        start_position => "beginning"
        tags => ["mytag","mytag2","mytag3"]
    }
}

output{
    if [type] == "a-txt"{
        elasticsearch{
            hosts => ["192.168.6.104:9200"]
            index => "a-txt-%{+YYYY-MM-dd}"
        }
        stdout { codec => rubydebug }
    }
}
```
# geoip的配置

参考: 
http://liubenlong.github.io/2016/11/29/ELK/ELK%20%E4%B9%8B%20nginx%E6%97%A5%E5%BF%97%E5%88%86%E6%9E%90/
http://xiaoluoge.blog.51cto.com/9141967/1891366

```
[root@no104 conf]# cat getip.conf
input{
    file{
        type => "tomcat-access"
        path => ["/data/tomcat/logs/tomcat_access_log.*.log"]
        start_position => "beginning"
        codec  => "json"
    }
}
filter{
    if[type] == "tomcat-access" {
        geoip {
            source => "clientip"      ##过滤内容来源
                target => "geoip"     ##属性设定值
                database => "/data/es/conf/GeoLite2-City_20170905/GeoLite2-City.mmdb"  ##地图加载路径
                add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]   ##字段增加纬度
                add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}"  ]   ##字段增加经度
        }
        mutate {
            convert => [ "[geoip][coordinates]", "float"] ##将经度纬度信息转变为坐标，类型为float型
        }
    }
}

output{
    elasticsearch{
        hosts => ["192.168.6.104:9200"]
        index => "logstash-tomcat-access-%{+YYYY.MM.dd}"
    }
    stdout {
        codec => rubydebug
    }
}
```



## kibana搜索
- status:404 OR status:500  #搜索状态是404或者是500之一的
- status:301 AND status:200  #搜索即是301和200同时匹配的
- status：[200 TO 300] ：搜索指定范围的



1.
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
       prefix="localhost_access_log." suffix=".txt"
       pattern="%h %l %u %t &quot;%r&quot; %s %b" />

192.168.201.2 - - [17/Sep/2017:11:28:18 +0800] "GET /myweb/index.html HTTP/1.1" 200 13



2.       
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
       prefix="localhost_access_log." suffix=".txt"
       pattern="%h %l %u %t &quot;%r&quot; %s %b %D &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot;" />

192.168.201.2 - - [17/Sep/2017:11:35:19 +0800] "GET /myweb/index.html HTTP/1.1" 200 13 1 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"
192.168.201.2 - - [17/Sep/2017:11:35:20 +0800] "GET /favicon.ico HTTP/1.1" 200 216301 "http://192.168.6.104:8080/myweb/index.html" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"


3.
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="tomcat_access_log." suffix=".log"
               pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;clientuser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;accesstime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;sendbytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;Agentversion&quot;:&quot;%{User-Agent}i&quot;}"/>

[root@no104 tomcat]# tail -f logs/tomcat_access_log.2017-09-17.log
{"clientip":"192.168.201.2","clientuser":"-","authenticated":"-","accesstime":"[17/Sep/2017:11:57:51 +0800]","method":"GET /myweb/index.html HTTP/1.1","status":"200","sendbytes":"13","Query?string":"","partner":"-","Agentversion":"Mozilla/5.0 (Windows NT6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"}
{"clientip":"192.168.201.2","clientuser":"-","authenticated":"-","accesstime":"[17/Sep/2017:11:57:52 +0800]","method":"GET /favicon.ico HTTP/1.1","status":"200","sendbytes":"21630","Query?string":"","partner":"http://192.168.6.104:8080/myweb/index.html","Agentversion":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"}


















