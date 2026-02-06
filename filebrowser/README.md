# 部署前置准备

## 确定合适的用户ID

在宿主机上运行以下命令查看可用用户：

``` bash
# 查看当前用户ID
id

# 查看系统用户列表
cat /etc/passwd | grep -E "(1000|1001|1002)"
```

## 创建专用用户

创建新用户和组

``` bash
sudo groupadd -g 1001 filebrowser
sudo useradd -u 1001 -g filebrowser -s /bin/false filebrowser
```

设置目录权限

``` bash
sudo chown -R 1001:1001 /path/to/data
```

## 检查文件权限

``` bash
# 查看容器内运行的用户
docker exec -it filebrowser id

# 创建测试文件查看权限
touch /path/to/your/data/test.txt
ls -la /path/to/your/data/test.txt
```