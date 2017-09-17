#!/bin/bash

set -ex

echo "pod-ip is $POD_IP"
sed -i "s#\#pod-ip#pod-ip: $POD_IP#g" /etc/filebeat/filebeat.yml
filebeat -e -c /etc/filebeat/filebeat.yml