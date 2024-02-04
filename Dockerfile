FROM golang:1.21.6-alpine AS builder

# 为镜像设置必要的环境变量
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# 判定 docker 是否能够访问外部网络
RUN ping -c 1 -W 1 google.com > /dev/null \
    && echo "www-ok" \
    || go env -w GOPROXY=https://goproxy.cn,direct

RUN ping -c 1 -W 1 google.com > /dev/null \
    && echo "www-ok" \
    || sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 移动到工作目录：/build
WORKDIR /build

RUN apk add tzdata

# 复制项目中的 go.mod 和 go.sum文件并下载依赖信息
COPY go.mod .
COPY go.sum .
RUN go mod download

# 将代码复制到容器中
COPY . .

# 将代码编译成二进制可执行文件 app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o webdav ./main.go

# 创建一个小镜像
FROM scratch

COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /usr/share/zoneinfo/Asia/Shanghai
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV TZ Asia/Shanghai

# 从builder镜像中把/build/app 拷贝到当前目录
COPY --from=builder /build/webdav /webdav
#COPY ./app /app

EXPOSE 80

CMD ["/webdav"]
