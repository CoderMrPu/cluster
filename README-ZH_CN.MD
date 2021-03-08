# 欢迎使用

> 注意：此版本对应 vagrant box 的 v1.0.1，使用中发现问题欢迎issues

### 克隆项目

```shell
git clone https://github.com/pucoder/cluster.git
```

### 进入项目

```shell
cd cluster
```

### 初始化

```shell
./init.bat
```

### 配置Cluster.yaml文件

> 根据自己的需求来配置
- source（配置虚拟机的软件源，这是全局配置，默认是[archive.ubuntu.com]）

- name （设置虚拟机的名称，不能重名）
- ip （网络ip：根据自己虚拟机来配置，不能有冲突）
- cpus （设置虚拟机cpu数）
- memory （设置虚拟机内存量）
- ports （设置虚拟机端口转发）
  - send （本地端口）
  - to （虚拟机的端口）
- proxys （设置nginx代理）
  - map （访问域名）
  - sites（代理站点）
    - send （代理域名）
    - to （代理ip，要求唯一值）
    - weight （代理权重，默认是1）
- folders （设置文件夹共享）
  - map （本地文件夹路径）
  - to （虚拟机的路径）
- sites （设置apache站点）
  - map （站点域名）
  - to （站点路径）
  - port （站点端口，需要时配置）
  - default （是否默认站点，仅最前的第一个站点生效，需要时配置[true]）
  - alias （站点别名，需要时配置）
- databases （设置数据库）
  - cluster （创建《cluster》数据库）
- features （需要安装的功能服务, 目前支持[nginx,apache2,mysql8,redis5,php7.4,composer]）
  - apache2 （在虚拟机中安装apache2服务）
  
### 启动vagrant

```shell
vagrant up
```

### 设置hosts文件

```
192.168.10.20 www.cluster.com
192.168.10.21 www.domain1.com
192.168.10.22 www.domain2.com
```

### 账户信息

- Linux （vagrant：vagrant）
- MySQL （root：password；cluster：password）
- Redis （root：“”）由于权限问题，安装redis的时候使用了默认配置，如果需要远程连接redis，请自行修改/etc/redis/redis.conf的配置
