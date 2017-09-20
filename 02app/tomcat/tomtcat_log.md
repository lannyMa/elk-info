


## 安装tomcat

$ ls -l /data/tomcat1/logs
catalina.2013-07-03.log              #或者 catalina.out   引擎的日志文件
catalina.out                         #
localhost.2013-07-03.log             #Tomcat下内部代码丢出的日志
manager.2013-07-03.log               #默认manager应用日志
host-manager.2013-07-03.log
localhost_access_log.2017-09-17.txt  #客户端访问日志

日志级别
SEVERE (highest value) > WARNING > INFO > CONFIG > FINE > FINER > FINEST (lowest value)

- 创建app web
echo maotaiweb!! > /data/tomcat/webapps/myweb/index.html

- 访问:--->产生如上的默认日志格式

## tomcat访问日志:

- 默认日志
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
       prefix="localhost_access_log." suffix=".txt"
       pattern="%h %l %u %t &quot;%r&quot; %s %b"/>

192.168.201.2 - - [17/Sep/2017:11:28:18 +0800] "GET /myweb/index.html HTTP/1.1" 200 13


- 修改为json
参考:http://79076431.blog.51cto.com/8977042/1793682

<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
       prefix="tomcat_access_log." suffix=".log"
       pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;clientuser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;accesstime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;sendbytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;Agentversion&quot;:&quot;%{User-Agent}i&quot;}"/>

cat tomcat_access_log.2017-09-17.log
{"clientip":"223.104.63.170","clientuser":"-","authenticated":"-","accesstime":"[17/Sep/2017:13:45:53 +0800]","method":"GET /myweb/index.html HTTP/1.1","status":"200","sendbytes":"13","Query?string":"","partner":"-","Agentversion":"Mozilla/5.0 (iPhone 92; CPU iPhone OS 10_3_3 like Mac OS X) AppleWebKit/603.3.8 (KHTML, like Gecko) Version/10.0 MQQBrowser/7.7.2 Mobile/14G60 Safari/8536.25 MttCustomUA/2 QBWebViewType/1 WKType/1"}


## tomcat日志格式说明
参考:http://ontheway2015.blog.51cto.com/6159377/1246739

<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
       prefix="localhost_access_log." suffix=".txt"
       pattern="%h %l %u %t &quot;%r&quot; %s %b"/>


className      官方文档上说了This MUST be set toorg.apache.catalina.valves.AccessLogValve to use the default access log valve.&<60; 想配置访问日志？这就必须得写成这样
directory      日志存放的位置，默认是logs目录下
prefix         这个是日志文件的名称前缀，我的日志名称为localhost_access_log.2007-09-22.txt，前面的前缀就是这个localhost_access_log
suffix         设置日志的后缀
pattern        对日志输出内容的设置，这个是重点，我们下面详细解释
resolveHosts   如果这个值是true的话，tomcat会将这个服务器IP地址通过DNS转换为主机名，如果是false，就直接写服务器IP地址啦
fileDateFormat 日志的时间格式


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











