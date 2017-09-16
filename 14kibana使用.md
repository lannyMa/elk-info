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


