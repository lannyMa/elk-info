
## kibana使用
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl4ywnlprj21ck0mywrr)
上面展示了8个字段,仅FromData未展示

我们的日志:10个字段
- 内部请求日志

```
{"STATUS":200,"FORM_DATA":"{}","IP":"100.97.15.62","REQUEST_URI":"POST /payGateway/lianlian/wap/recharge/asyncReturn","HTTP_USER_AGENT":"httpcomponents","METRIC":"UserRechargeDetailDao.lockByPayNumber:10.981ms TransactionManager.doCommit:6.775ms TransactionManager.doBegin:1.516ms TransactionManager.doCleanupAfterCompletion:0.041ms RenderJSON:0.014ms TransactionManager.doGetTransaction:2/0.002/0.006/0.008ms ","TOTAL_TIME":"24.114ms","REQUEST_TIME":"2016-10-17T00:00:05.525+08:00","THREAD":"http-bio-8080-exec-38"}
```

- 外部请求日志: 多了一个RESULT字段
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl5a6p304j21kw0ra4qp)


- 过滤字段
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl5yqq10bj21080ni7aa)


- 保存搜索结果,以便于下次用
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl5zz57c5j21kw09fq5m)

- 通过kibana查看es节点状态
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl60rcjjaj21kw0qfjyj)


- 做dashboard
整体效果:
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl620mdytj21kw0pe472)


![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl62rr72cj21kw0pwgt7)

- 先搞个mardown来记录下值班人
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl63i748ij20s80jgq90)

- 饼图--判断状态码
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6ctnbuej21kw0oite7)

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6dhx1mmj20z40gkwkd)


- 柱状图-网站前10名
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6e5ncpej21kw0qv0x1)


- 折线图-html响应时间
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6gmz4nmj20gm0l0abn)

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6gwpld3j20ce0cymyt)

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6h66gbxj20ky02idgq)

![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6hias5cj21740hsjwj)
注:不要是双引号的

- 统计日志数量
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6f36kjhj20oi0l2wjp)


![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjl6fllztvj21h80iywgp)