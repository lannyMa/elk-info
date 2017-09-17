input {  
    file {
        path => ["/root/access_log"]
        type => "apache"
        start_position => "beginning"
    }
  
}

filter {
    grok {
        match => ["message", "%{IP:client} %{HTTPDATE:logdate} %{WORD:method} %{URIPATHPARAM:request} %{WORD:status} %{NUMBER:hits}"]
  }
    date {
        match => ["logdate", "dd/MMM/yyyy:HH:mm:ss Z"]
  }
}

#output {
#    file{
#	path=>"/root/log.txt"
#	codec=>rubydebug
#   }
#    stdout {codec=>plain}
#}

output {
    stdout{ }
}



## 导入
curl -H 'Content-Type: application/json' -XPUT 'http://192.168.6.104:9200/_template/filebeat' -d@/usr/local/filebeat/filebeat.template.json


## 查看
curl -XGET '192.168.6.104:9200/_template/filebeat*?pretty'
curl -XGET '192.168.6.104:9200/_template/template_1,template_2?pretty'


# 启动服务
./filebeat -e -c filebeat.yml -d "publish"

## 导入kibana
/usr/local/filebeat/scripts/import_dashboards -only-index







## Filebeat 与 Logstash 安全通信
https://www.ibm.com/developerworks/cn/opensource/os-cn-elk-filebeat/index.html


## 日志滚动

Filebeat 默认支持 log rotation，但需要注意的是，Filebeat 不支持使用 NAS 或挂载磁盘保存日志的情况。因为在 Linux 系列的操作系统中，Filebeat 使用文件的 inode 信息判断当前文件是新文件还是旧文件。如果是 NAS 或挂载盘，同一个文件的 inode 信息会变化，导致 Filebeat 无法完整读取 log。

虽然 Filebeat 默认支持 log rotation，但是有三个参数的设置需要留意。

registry_file：这个文件记录了当前打开的所有 log 文件，以及每个文件的 inode、当前读取位置等信息。当 Filebeat 拿到一个 log 文件，首先查找 registry_file，如果是旧文件，就从记录的当前读取位置处开始读取；如果是新文件，则从开始位置读取；

close_older：如果某个日志文件经过 close_older 时间后没有修改操作，Filebeat 就关闭该文件的 handler。如果该值过长，则随着时间推移，Filebeat 打开的文件数量很多，耗费系统内存；

scan_frequency：Filebeat 每隔 scan_frequency 时间读取一次文件内容。对于关闭的文件，如果后续有更新，则经过 scan_frequency 时间后，Filebeat 将重新打开该文件，读取新增加的内容。



## 从多路径获取日志
prospectors:
    -
      paths:
         - /home/WLPLog/*.log
      # 其他配置项，具体参考 Elastic 官网
    -
      paths:
         - /home/ApacheLog/*.log
      # 其他配置项，具体参考 Elastic 官网
      
## 区分日志来源
prospectors:
    -
       paths:
          - /home/WLPLog/*.log
       fields:
         log_source: WLP       #类似logstash的add_fields
    -
       paths:
          - /home/ApacheLog/*.log
       fields:
         log_source: Apache

         
## 字段
Filebeat 发送的日志，会包含以下字段：+

beat.hostname beat 运行的主机名
beat.name shipper 配置段设置的 name，如果没设置，等于 beat.hostname
@timestamp 读取到该行内容的时间
type 通过 document_type 设定的内容
input_type 来自 "log" 还是 "stdin"
source 具体的文件名全路径
offset 该行日志的起始偏移量
message 日志内容
fields 添加的其他固定字段都存在这个对象里面


filebeat:
    spool_size: 1024                                    # 最大可以攒够 1024 条数据一起发送出去
    idle_timeout: "5s"                                  # 否则每 5 秒钟也得发送一次
    registry_file: ".filebeat"                          # 文件读取位置记录文件，会放在当前工作目录下。所以如果你换一个工作目录执行 filebeat 会导致重复传输！
    config_dir: "path/to/configs/contains/many/yaml"    # 如果配置过长，可以通过目录加载方式拆分配置
    prospectors:                                        # 有相同配置参数的可以归类为一个 prospector
        -
            fields:
                ownfield: "mac"                         # 类似 logstash 的 add_fields
            paths:
                - /var/log/system.log                   # 指明读取文件的位置
                - /var/log/wifi.log
            include_lines: ["^ERR", "^WARN"]            # 只发送包含这些字样的日志
            exclude_lines: ["^OK"]                      # 不发送包含这些字样的日志
        -
            document_type: "apache"                     # 定义写入 ES 时的 _type 值
            ignore_older: "24h"                         # 超过 24 小时没更新内容的文件不再监听。在 windows 上另外有一个配置叫 force_close_files，只要文件名一变化立刻关闭文件句柄，保证文件可以被删除，缺陷是可能会有日志还没读完
            scan_frequency: "10s"                       # 每 10 秒钟扫描一次目录，更新通配符匹配上的文件列表
            tail_files: false                           # 是否从文件末尾开始读取
            harvester_buffer_size: 16384                # 实际读取文件时，每次读取 16384 字节
            backoff: "1s"                               # 每 1 秒检测一次文件是否有新的一行内容需要读取
            paths:
                - "/var/log/apache/*"                   # 可以使用通配符
            exclude_files: ["/var/log/apache/error.log"]
        -
            input_type: "stdin"                         # 除了 "log"，还有 "stdin"
            multiline:                                  # 多行合并
                pattern: '^[[:space:]]'
                negate: false
                match: after
output:
    ...

https://kibana.logstash.es/content/beats/file.html



