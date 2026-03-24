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

设置目录权限

``` bash
# 1. 创建一个共享组
sudo groupadd sharedgroup
# 2. 将用户1100和其他用户添加到这个组
sudo usermod -a -G sharedgroup filebrowser
# 3. 设置目录权限及新创建的文件/目录会自动继承父目录的组
sudo chgrp -R sharedgroup /data
sudo chmod -R 2775 /data
```

## 检查文件权限

``` bash
# 查看容器内运行的用户
docker exec -it filebrowser id

# 创建测试文件查看权限
touch /path/to/your/data/test.txt
ls -la /path/to/your/data/test.txt
```