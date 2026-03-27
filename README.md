# docker-compose

collection for docker-compose

> 仅供个人学习使用

## 镜像源

### 腾讯云

[文档](https://cloud.tencent.com/document/product/1207/45596)

执行以下命令，打开 `/etc/docker/daemon.json` 配置文件

``` bash
vim /etc/docker/daemon.json
```

按 i 切换至编辑模式，添加以下内容，并保存。

``` bash
{
    "registry-mirrors": [
        "https://mirror.ccs.tencentyun.com"
    ]
}
```

执行以下命令，重启 Docker 即可。示例命令以 CentOS 7 为例。

``` bash
sudo systemctl restart docker

sudo docker info
```

## 工具

- [composerize](https://www.composerize.com/)

## 资料

- [Using Claude Code with GitHub Copilot Subscription](https://dev.to/allentcm/using-claude-code-with-github-copilot-subscription-2obj)
