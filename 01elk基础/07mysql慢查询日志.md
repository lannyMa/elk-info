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
