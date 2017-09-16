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


