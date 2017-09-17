#!/usr/bin/env bash






curl 192.168.6.52/install_jdk1.8.sh|bash
useradd elk

cd /usr/local/src/
tar xf filebeat-5.6.0-linux-x86_64.tar.gz -C /usr/local/
tar xf kibana-5.6.0-linux-x86_64.tar.gz -C /usr/local/
unzip -q logstash-5.6.0.zip -d /usr/local/
unzip -q elasticsearch-5.6.0.zip -d /usr/local/

ln -s /usr/local/elasticsearch-5.6.0 /usr/local/elasticsearch
ln -s /usr/local/logstash-5.6.0 /usr/local/logstash
ln -s /usr/local/kibana-5.6.0-linux-x86_64 /usr/local/kibana
ln -s /usr/local/filebeat-5.6.0-linux-x86_64 /usr/local/filebeat

chown -R elk. /usr/local/elasticsearch
chown -R elk. /usr/local/elasticsearch/
chown -R elk. /usr/local/logstash
chown -R elk. /usr/local/logstash/
chown -R elk. /usr/local/kibana/
chown -R elk. /usr/local/kibana
chown -R elk. /usr/local/filebeat
chown -R elk. /usr/local/filebeat/

mkdir /data/elk/{data,logs} -p
chown -R elk. /data


nohup /bin/su - elk -c "/usr/local/elasticsearch/bin/elasticsearch" > /data/es/es-start.log 2>&1 &


nohup /bin/su - elk -c "/usr/local/kibana/bin/kibana" > /data/es/kibana-start.log 2>&1 &


# todo
/bin/su - elk -c "/usr/local/elasticsearch/bin/elasticsearch"
/bin/su - elk -c "/usr/local/elasticsearch/bin/elasticsearch & > /data/es-start.log"
cd /application/elasticsearch-head && grunt server &


nohup /bin/su - elk -c "/usr/local/elasticsearch/bin/elasticsearch" > /data/es/es-start.log 2>&1 &



## uninstall xpack
cd /usr/local/src/
tar xf filebeat-5.6.0-linux-x86_64.tar.gz -C /usr/local/
tar xf kibana-5.6.0-linux-x86_64.tar.gz -C /usr/local/
unzip -q logstash-5.6.0.zip -d /usr/local/
unzip -q elasticsearch-5.6.0.zip -d /usr/local/

ln -s /usr/local/elasticsearch-5.6.0 /usr/local/elasticsearch-5.6.0
ln -s /usr/local/logstash-5.6.0 /usr/local/logstash
ln -s /usr/local/kibana-5.6.0-linux-x86_64 /usr/local/kibana
ln -s /usr/local/filebeat-5.6.0-linux-x86_64 /usr/local/filebeat


mkdir /root/code/es-backup -p
cd /usr/local/src/
cp -rp /usr/local/elasticsearch/config/elasticsearch.yml /root/code/es-backup
rm -rf /usr/local/elasticsearch-5.6.0
unzip -q elasticsearch-5.6.0.zip -d /usr/local/
chown -R elk. /usr/local/elasticsearch
chown -R elk. /usr/local/elasticsearch/
\cp -rp  /root/code/es-backup/elasticsearch.yml /usr/local/elasticsearch/config/
