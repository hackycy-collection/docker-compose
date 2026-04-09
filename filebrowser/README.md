# 部署前置准备

## 确定合适的用户ID

在宿主机上运行以下命令查看可用用户：

``` bash
# 查看当前用户ID
id

# 查看系统用户列表
cat /etc/passwd | grep -E "(1000|1001|1100)"
```

## 创建专用用户

创建新用户和组

``` bash
sudo groupadd -g 1100 filebrowser
sudo useradd -u 1100 -g filebrowser -s /bin/false filebrowser

chmod -R 777 /opt/filebrowser/
```

使用`ACL`访问控制列表，安装`ACL`

``` bash
# Debian/Ubuntu
sudo apt update && sudo apt install acl

# CentOS/RHEL
sudo yum install acl
```

给当前目录设置 ACL（用 UID，不是用户名）

``` bash
# 给当前目录设置权限
sudo setfacl -R -m u:1100:rwx /opt
sudo setfacl -R -m u:1100:rwx /home

# 给新文件设置继承
sudo setfacl -R -d -m u:1100:rwx /opt
sudo setfacl -R -d -m u:1100:rwx /home
```

给 "Others"（其他用户）赋予权限。这意味着系统上任何用户都能访问这些目录，安全性较差。

``` bash
sudo chown -R 1100:1100 /opt /home
```

> 建议在启动 Docker 容器前，先手动创建需要的目录能够避免权限问题

## 检查文件权限

``` bash
# 验证
getfacl /opt
getfacl /home

# 查看容器内运行的用户
docker exec -it filebrowser id

# 创建测试文件查看权限
touch /path/to/your/data/test.txt
ls -la /path/to/your/data/test.txt
```