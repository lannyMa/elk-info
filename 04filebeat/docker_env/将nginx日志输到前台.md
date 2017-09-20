

## 日志搜集

- 探究nginx日志输出到前台
```
docker ps -a

/var/lib/docker/containers/
```
- 将nginx前台运行
CMD ["nginx", "-g", "daemon off;"]
nginx -g daemon off

## 将nginx日志关联到stdout
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

## 查看版本

curl -XGET localhost:9200

curl http://es.pp100.net/_cat/health?v



