# webdav

![Build](https://github.com/whyiyhw/webdav/workflows/Tests/badge.svg)
[![Go Report Card](https://goreportcard.com/badge/github.com/hacdias/webdav?style=flat-square)](https://goreportcard.com/report/hacdias/webdav)
[![Version](https://img.shields.io/github/release/hacdias/webdav.svg?style=flat-square)](https://github.com/hacdias/webdav/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/hacdias/webdav)](https://hub.docker.com/r/hacdias/webdav)

## Install

Please refer to the [Releases page](https://github.com/whyiyhw/webdav/releases) for more information. There, you can either download the binaries or find the Docker commands to install WebDAV.

请查看[发布页面](https://github.com/whyiyhw/webdav/releases)获取更多信息。在那里，您可以下载二进制文件，也可以找到安装WebDAV的Docker命令。

## Usage

```webdav``` command line interface is really easy to use so you can easily create a WebDAV server for your own user. By default, it runs on a random free port and supports JSON, YAML and TOML configuration. An example of a YAML configuration with the default configurations:

```webdav``` 命令行界面非常易于使用，因此您可以轻松为自己的用户创建WebDAV服务器。默认情况下，它在随机空闲端口上运行，并支持JSON、YAML和TOML配置。以下是一个包含默认配置的YAML配置示例：

```yaml
# Server related settings
# 服务端相关设置
# 服务端监听地址
address: 0.0.0.0
# 服务端监听端口 0表示随机端口
port: 0
# 是否开启认证
auth: true
# 是否开启TLS
tls: false
# 证书文件
cert: cert.pem
# 私钥文件
key: key.pem
# URL前缀
prefix: /
# 是否开启调试模式
debug: false

# Default user settings (will be merged)
# 默认用户设置（将被合并）
# 用户访问范围
scope: .
# 是否允许修改
modify: true
# 规则
rules: []

# CORS configuration
# 跨域资源共享配置
cors:
  # 是否开启跨域资源共享
  enabled: true
  # 是否允许携带凭证
  credentials: true
  # 允许的请求头
  allowed_headers:
    - Depth
  # 允许的主机
  allowed_hosts:
    - http://localhost:8080
  # 允许的请求方法
  allowed_methods:
    - GET
  # 暴露的响应头
  exposed_headers:
    - Content-Length
    - Content-Range

# 用户
users:
    # 用户名
  - username: admin
    # 密码    
    password: admin
    # 用户访问范围
    scope: /a/different/path
  - username: encrypted
    password: "{bcrypt}$2y$10$zEP6oofmXFeHaeMfBNLnP.DO8m.H.Mwhd24/TOX2MWLxAExXi4qgi"
  - username: "{env}ENV_USERNAME"
    password: "{env}ENV_PASSWORD"
  - username: basic
    password: basic
    modify:   false
    rules:
      - regex: false
        allow: false
        path: /some/file
      - path: /public/access/
        modify: true
```

There are more ways to customize how you run WebDAV through flags and environment variables. Please run `webdav --help` for more information on that.

通过命令行参数和环境变量，你可以更多的定制WebDAV的运行方式 。请运行 `webdav --help` 获取更多信息。

### Systemd

An example of how to use this with `systemd` is on [webdav.service.example](/webdav.service.example).

如何在`systemd`中使用的示例在 [webdav.service.example](/webdav.service.example)。

### CORS

The `allowed_*` properties are optional, the default value for each of them will be `*`. `exposed_headers` is optional as well, but is not set if not defined. Setting `credentials` to `true` will allow you to:

这些`allowed_*`属性是可选的，每个属性的默认值都是`*`。`exposed_headers`也是可选的，但如果未定义，则不会设置。将`credentials`设置为`true`将允许你：

1. Use `withCredentials = true` in javascript.
   - 在javascript中使用`withCredentials = true`。

2. Use the `username:password@host` syntax.
   - 使用`username:password@host`语法。

### Reverse Proxy Service
When you use a reverse proxy implementation like `Nginx` or `Apache`, please note the following fields to avoid causing `502` errors

当你使用反向代理实现，如`Nginx`或`Apache`，请注意以下字段，以避免引起`502`错误
```text
location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }
```
