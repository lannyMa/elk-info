## begin end

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl4x5ke5cj20ue01wac2)
- beginning 记录了 读取到了哪行
- end 每次都从尾巴来读
- beginning每次从 sincdb位置开始读


- end参数
无论如何,记录从该时间点开始到以后的日志.
 
- beginning:
下面文件帮该参数记录位置.从位置点开始读日志,如果清理掉下面文件,则无意义.
```
[root@linux-node1 ~]# ls .sincedb*
.sincedb_d883144359d3b4f516b37dba51fab2a2
 
begin:
./logstash/bin/logstash -f test02.conf
rm -f ~/.sincedb*
./logstash/bin/logstash -f test02.conf
./logstash/bin/logstash -f test02.conf

```