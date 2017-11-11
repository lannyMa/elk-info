---
typora-copy-images-to: img
---



## kibana dev工具对es库的CRUD操作

es5可以看做数据库,基于resetful可以很方便的存取数据.

kibana5有Dev Tools一个工具,可以很方便的发get post put delete等http请求.

这篇文章主要介绍这个工具对es的操作.

![1510408910687](img/1510408910687.png)



- 创建/删除索引

  ![1510408974560](C:\Users\ADMINI~1\AppData\Local\Temp\1510408974560.png)



- 创建/更新记录

  ![1510409471489](img/1510409471489.png)

- 创建记录(自动创建了索引, type=user)

  ```
  tt100/user   # 生成的id是随机的
  tt100/user/1 # id是固定的,这样便于更
               # 多次提交,每次version1累加1
  ```

  ![1510409649670](img/1510409649670.png)

- 同一个索引里每个文档的字段可以不同(kibana里各显示个的)

  ​

  ![1510409057164](img/1510409057164.png)



![1510408679945](img/1510408679945.png)

同一个索引里的记录B

![1510408755688](img/1510408755688.png)

