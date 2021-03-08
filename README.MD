# Welcome to use

> Note: This version corresponds to v1.0.1 of vagrant box, Problems found during use, welcome issues

[中文文档](https://github.com/pucoder/cluster/blob/master/README-ZH_CN.MD)

### Clone the project

```shell
git clone https://github.com/pucoder/cluster.git
```

### Enter the project

```shell
cd cluster
```

### Initialization

```shell
./init.bat
```

### Configure the cluster.yaml file

> configure according to your needs
- source (Configure the software source of the virtual machine, this is a global configuration, the default is [archive.ubuntu.com])

- name (Set the name of the virtual machine, can not be renamed)
- active (Whether to start the current virtual machine)
- ip (Network ip: Configure according to your virtual machine, there must be no conflict)
- cpus (Set the number of virtual machine CPU)
- memory (Set the amount of virtual machine memory)
- ports (Set up virtual machine port forwarding)
  - send (Local port)
  - to (Virtual machine port)
- proxys (Set up nginx proxy)
  - map (visit domain)
  - sites (proxy site)
    - send (proxy domain name)
    - to (proxy ip,unique value required)
    - weight (Proxy weight, The default is 1)
- folders (Set up folder sharing)
  - map (Local folder path)
  - to (The path of the virtual machine)
- sites (Set up the apache site)
  - map (Domain name)
  - to (Site path)
  - port (Site port, configure when needed)
  - default (whether the default site, only the first site in the front will take effect, configure when needed[true])
  - alias (Site alias, configure if needed)
- databases (set up the database)
  - cluster (create a <cluster> database)
- features (The functional service that needs to be installed, currently supports [nginx,apache2,mysql8,redis5,php7.4,composer])
  - apache2 (Install apache 2 service in the virtual machine)

### start vagrant

```shell
vagrant up
```

### Set up the hosts file

```
192.168.10.20 www.cluster.com
192.168.10.21 www.domain1.com
192.168.10.22 www.domain2.com
```

### account information

- Linux (vagrant:vagrant)
- MySQL (root:password;cluster:password)
- Redis (root:"")Due to permission issues, the default configuration was used when redis was installed. If you need to connect to redis remotely, Please modify the configuration of /etc/redis/redis.conf by yourself
