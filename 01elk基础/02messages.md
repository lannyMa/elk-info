messages格式:
```
[root@linux-node1 application]# cat /var/log/messages
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: USB disconnect, device number 6
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: new full speed USB device number 7 using uhci_hcd
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: New USB device found, idVendor=0e0f, idProduct=0008
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: Product: Virtual Bluetooth Adapter
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: Manufacturer: VMware
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: SerialNumber: 000650268328
Oct  5 12:00:11 linux-node1 kernel: usb 2-2.1: configuration #1 chosen from 1 choice
Oct  5 12:07:05 linux-node1 sz[8488]: [root] nginx_access.conf/ZMODEM: 152 Bytes, 5 BPS
Oct  9 23:05:07 linux-node1 sz[8548]: [root] www.conf/ZMODEM: 658 Bytes, 723 BPS
Oct  9 23:05:27 linux-node1 rz[8555]: [root] no.name/ZMODEM: got error
Oct  9 23:05:39 linux-node1 sz[8557]: [root] www.conf/ZMODEM: 658 Bytes, 215 BPS
Oct  9 23:27:56 linux-node1 kernel: e1000: eth1 NIC Link is Down
Oct  9 23:27:59 linux-node1 kernel: e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
```

logstash处理:
```
[root@linux-node1 application]# ./logstash/bin/logstash -f system-meassges.conf
Settings: Default pipeline workers: 1
Pipeline main started
{
       "message" => "Oct  9 23:27:59 linux-node1 kernel: e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None",
      "@version" => "1",
    "@timestamp" => "2016-10-09T15:58:45.732Z",
          "path" => "/var/log/messages",
          "host" => "linux-node1.example.com",
          "type" => "system"
}

[root@linux-node1 application]# cat system-meassges.conf
input{
    file{
        path => ["/var/log/messages"]
        type => "system"
        start_position => "beginning"
    }
}

output{
    stdout{
        codec => rubydebug{ }
    }
}
```

输入到es
```
[root@linux-node1 application]# cat system-meassges.conf01 
input{
    file{
        path => ["/var/log/messages"]
        type => "system"
        start_position => "beginning"
    }
}

output{
    elasticsearch{
        hosts => ["192.168.14.136:9200"]
        index => "system-%{+YYYY.MM.dd}"
    }
}

```