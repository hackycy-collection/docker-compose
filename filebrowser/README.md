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
```

设置目录权限

``` bash
# 1. 查看当前用户的组
id 1100
# 2. 将用户1100添加到文件夹所在的组 (组 用户)
sudo usermod -a -G 1100 1100
# 3. 给组设置权限
sudo chmod -R g+rwx /目标文件夹
```

## 检查文件权限

``` bash
# 查看容器内运行的用户
docker exec -it filebrowser id

# 创建测试文件查看权限
touch /path/to/your/data/test.txt
ls -la /path/to/your/data/test.txt
```