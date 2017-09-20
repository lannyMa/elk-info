## 安装elk5在centos7上
```
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 65536
elk soft nofile 65536
elk hard nofile 131072
elk soft nproc 2048
elk hard nproc 4096
elk soft memlock unlimited
elk hard memlock unlimited
EOF

sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
sysctl -p
```


```
http.cors.enabled: true
http.cors.allow-origin: "*"
```


## 安装head插件
```
docker run -d -v /etc/localtime:/etc/localtime --restart=always -p 9100:9100 mobz/elasticsearch-head:5
```

## 可选xpack安装破解
```
javac -cp "/usr/local/elasticsearch/lib/elasticsearch-5.6.0.jar:/usr/local/elasticsearch/lib/lucene-core-6.6.0.jar:/usr/local/elasticsearch/plugins/x-pack/x-pack-5.6.0.jar" LicenseVerifier.java

ll /usr/local/elasticsearch/lib/elasticsearch-5.6.0.jar
ll /usr/local/elasticsearch/lib/lucene-core-6.6.0.jar
ll /usr/local/elasticsearch/plugins/x-pack/x-pack-5.6.0.jar



/usr/local/elasticsearch/elasticsearch-plugin/elasticsearch-plugin install file:///usr/local/src/x-pack-5.6.0.zip
/usr/local/kibana/kibana-plugin/kibana-plugin install file:///usr/local/src/x-pack-5.6.0.zip


/usr/local/elasticsearch/bin/elasticsearch-plugin remove x-pack
/usr/local/kibana/bin/kibana-plugin remove remove x-pack

curl -XGET -u elastic:changeme 'http://192.168.6.104:9200/_license'

curl -XPUT -u elastic:changeme 'http://192.168.6.103:9200/_xpack/license?acknowledge=true' -d 
```

## head安装
1,物理机方式

2.容器方式
```
docker run -p 9100:9100 mobz/elasticsearch-head:5
```
https://github.com/mobz/elasticsearch-head


## es常见的curl操作
http://www.cnblogs.com/lishouguang/p/4560930.html


## filebeat的配置使用变量
For example, the following environment variable is set to a list:
```
ES_HOSTS="10.45.3.2:9220,10.45.3.1:9230"
```
You can reference this variable in the config file:
```
output.elasticsearch:
  hosts: '${ES_HOSTS}'
```

## filebeat配置动态加载
To enable dynamic config reloading, you specify the path and reload options in the main filebeat.yml config file. For example:
```
filebeat.config.prospectors:
  path: configs/*.yml
  reload.enabled: true
  reload.period: 10s
```
