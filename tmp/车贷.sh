#!/usr/bin/env bash



cp sysctl.conf sysctl.conf.default
vim sysctl.conf
ifconfig
/etc/init.d/sshd restart
/etc/init.d/network restart
ifconfig
cd /etc/sysconfig/network
cd /etc/sysconfig/network-scripts/
ls
cat network-functions-ipv6
ls
cat ifcfg-eth1
vim ifcfg-eth1
/etc/init.d/network restart
ls
vi ifcfg-eth1
cat /etc/modprobe.d/disable_ipv6.conf
vim /etc/modprobe.d/disable_ipv6.conf
vi /etc/sysconfig/network
reboot






ifconfig
ls
cd
ls
ifconfig
cd /etc/
cp sysctl.conf sysctl.conf.default
vim sysctl.conf
ifconfig
/etc/init.d/sshd restart
/etc/init.d/network restart
ifconfig
cd /etc/sysconfig/network
cd /etc/sysconfig/network-scripts/
ls
cat /etc/sysconfig/network-scripts/network-functions-ipv6
ls
cat ifcfg-eth1
vim ifcfg-eth1
/etc/init.d/network restart
ls
vi ifcfg-eth1
cat /etc/modprobe.d/disable_ipv6.conf
vim /etc/modprobe.d/disable_ipv6.conf

cat /etc/sysconfig/network-scripts/ifcfg-eth1
/etc/init.d/network restart
ifconfig
ifconfig sit0 up
ifconfig sit0 inet6 tunnel ::216.218.221.6
ifconfig sit1 up
ifconfig sit1 inet6 add 2001:470:18:df0::2/64
route -A inet6 add ::/0 dev sit1
ping qq.com
ping6
ping ipv6.sjtu.edu.cn
ls
ping ipv6.sjtu.edu.cn
route -n
history
ifconfig
ping ipv6.sjtu.edu.cn
ping6 ipv6.sjtu.edu.cn


##  申请账号,获取命令并贴到阿里云ces上
```
https://www.tunnelbroker.net

ifconfig sit0 up
ifconfig sit0 inet6 tunnel ::216.218.221.6
ifconfig sit1 up
ifconfig sit1 inet6 add 2001:470:18:df0::2/64
route -A inet6 add ::/0 dev sit1
```

## 开启阿里云ecs支持ipv6
```
[root@iZwz9bdod77u1emuiu0rb6Z ~]# cat /etc/modprobe.d/disable_ipv6.conf
#alias net-pf-10 off
#options ipv6 disable=1
```


## 安装nginx-->编译ipv6模块
```
./configure --user=nginx --group=nginx --prefix=/usr/local/tengine-2.2.0 --with-http_stub_status_module --with-http_ssl_module --with-ipv6
make && make install
```

## 测试
```
[root@iZwz9bdod77u1emuiu0rb6Z ~]# ping6 ipv6.sjtu.edu.cn
PING ipv6.sjtu.edu.cn(2001:da8:8000:1::80) 56 data bytes
64 bytes from 2001:da8:8000:1::80: icmp_seq=1 ttl=46 time=786 ms


http://ipv6-test.com/validate.php
```


## 参考
https://blog.6ag.cn/1859.html

http://coolnull.com/4476.html
