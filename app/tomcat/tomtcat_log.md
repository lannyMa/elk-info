tomcat访问日志:
192.168.201.2 - - [17/Sep/2017:11:28:18 +0800] "GET /myweb/index.html HTTP/1.1" 200 13


安装tomcat
创建web
echo maotaiweb!! > /data/tomcat/webapps/myweb/index.html

访问:--->产生如上日志
![](http://ww1.sinaimg.cn/large/9e792b8fgy1fjml0fclnhj20gk04874q)


用ELK处理日志时碰到的几个问题 

```
ruby {
    init => "@kname = ['time_local', 'remote_addr', 'remote_user', 'http_user_agent', 'request_method', 'uri', 'request_time', 'upstream_response_time', 'request_length', 'bytes_sent', 'connection', 'connection_request', 'status', 'upstream_status', 'body_bytes_sent', 'http_referer', 'ssl_protocol', 'ssl_cipher', 'upstream_addr']"
    code => "
      new_event = LogStash::Event.new(Hash[@kname.zip(event['message'].split('|'))])
      new_event.remove('@timestamp')
      event.append(new_event)
    "
    remove_field => ["message"]
  }

ruby {
    init => "@kname = ['remote_addr', 'http_referer', 'http_user_agent', 'upstream_response_time', 'request_time', 'client_hostname', 'client_username', 'user_authed', 'time_local', 'request_method_uri', 'status', 'body_bytes_sent']"
    code => "
      new_event = LogStash::Event.new(Hash[@kname.zip(event['message'].split('|'))])
      new_event.remove('@timestamp')
      event.append(new_event)
    "
    remove_field => ["message"]
  }

<Context path="" docBase="/data/web/elc/" />
          <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="pp100_access_log." suffix=".txt" pattern='%{X-Forwarded-For}i | %{Referer}i | %{User-Agent}i | %D | %F | %h | %l | %u | %t | "%r" | %s | %b' resolveHosts="false"/>
          
          

pattern='%{X-Forwarded-For}i | %{Referer}i | %{User-Agent}i | %D | %F | %h | %l | %u | %t | "%r" | %s | %b'


116.22.119.241, 113.107.238.147 | - | Scrapy/1.0.5 (+http://scrapy.org) | 18 | 18 | 100.97.14.9 | - | - | [08/Oct/2016:00:00:00 +0800] | "GET /front/invest/investHome?currPage=1366&pageSize=&bidStatus=2&period=0&apr=0&searchType=0 HTTP/1.0" | 302 | -
116.22.119.241, 113.107.238.147 | - | Scrapy/1.0.5 (+http://scrapy.org) | 19 | 19 | 100.97.14.8 | - | - | [08/Oct/2016:00:00:00 +0800] | "GET /front/invest/investHome?currPage=11251&pageSize=&bidStatus=2&period=0&apr=0&searchType=0 HTTP/1.0" | 302 | -
116.22.119.241, 113.107.238.147 | - | Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36 | 17 | 17 | 100.97.14.10 | - | - | [08/Oct/2016:00:00:00 +0800] | "GET /front/invest/investHome?currPage=560&pageSize=&bidStatus=2&period=0&apr=0&searchType=0 HTTP/1.0" | 302 | -
112.17.245.23, 111.13.147.201 | - | Dalvik/2.1.0 (Linux; U; Android 5.1.1; vivo X6S A Build/LMY47V) | 336 | 336 | 100.97.15.28 | - | - | [08/Oct/2016:00:00:01 +0800] | "GET /app/services?OPT=65&_t=1475856000089&body=&deviceType=1&userid=DF1C80B137A9D5694BD21BB17A0A4FA10708A3BCB739C099F94D76515C1BA156061FB7BB6F7801DC0A7FFE3FC64CD48F6d85401b&versionCode=13&_s=4e6484692500ac425cf167d9214e444d HTTP/1.0" | 200 | 509



%{xxx}i – 记录客户端请求中带的HTTP头xxx(incoming headers) 

%{Referer}i – Referer URL
%{User-Agent}i – User agent 

%D – 处理请求所耗费的毫秒数 (Time taken to process the request, in millis)                  %D - 处理请求的时间，以毫秒为单位
%h – 远程主机名 (Remote host name)                                                          %h – 远端主机名(如果resolveHost=false，远端的IP地址）
%l – 远程用户名，始终为 ‘-’ (Remote logical username from identd (always returns ‘-’))      %l - 从identd返回的远端逻辑用户名（总是返回 '-'）
%u – 已经验证的远程用户 (Remote user that was authenticated                                 %u - 认证以后的远端用户（如果存在的话，否则为'-'）
%t – 访问日期和时间                                                                         %t - 日志和时间，使用通常的Log格式
%r – HTTP请求中的第一行                                                                     %r - 请求的第一行，包含了请求的方法和URI
%s – HTTP状态码                                                                             %s - 响应的状态码
%b – 发送字节数，不包含HTTP头(0字节则显示 ‘-’)                                              %b - 发送的字节数，不包括HTTP头，如果为0，使用"－"


%a - 远端IP地址
%A - 本地IP地址

pattern属性值由字符串常量和pattern标识符加上前缀"%"组合而成。pattern标识符加上前缀"%"，用来代替当前请求/响应中的对应的变量值。目前支持如下的pattern： 
%a - 远端IP地址
%A - 本地IP地址
%b - 发送的字节数，不包括HTTP头，如果为0，使用"－"
%B - 发送的字节数，不包括HTTP头
%h - 远端主机名(如果resolveHost=false，远端的IP地址）
%H - 请求协议
%l - 从identd返回的远端逻辑用户名（总是返回 '-'）
%m - 请求的方法（GET，POST，等）
%p - 收到请求的本地端口号
%q - 查询字符串(如果存在，以 '?'开始)
%r - 请求的第一行，包含了请求的方法和URI
%s - 响应的状态码
%S - 用户的session ID
%t - 日志和时间，使用通常的Log格式
%u - 认证以后的远端用户（如果存在的话，否则为'-'）
%U - 请求的URI路径
%v - 本地服务器的名称
%D - 处理请求的时间，以毫秒为单位
%T - 处理请求的时间，以秒为单位
```



```
<Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
	<!-- Access log processes all example.
	 Documentation at: /docs/config/valve.html
	 Note: The pattern used is equivalent to using pattern="common" -->
	<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"  prefix="localhost_access_log." suffix=".txt"   pattern="%h %l %u %t &quot;%r&quot; %s %b %D &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot;" />

</Host>



directory表示访问日志存储在Tomcat的logs目录中。
prefix表示日志文件名以localhost_access_log.开头。
suffix表示日志文件名以.txt截尾。
```












