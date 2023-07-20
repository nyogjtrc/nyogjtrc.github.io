---
title: "使用 Colima 取代 Docker Desktop"
date: 2023-07-20T21:31:37+08:00
tags: [colima, docker, mac, kubernetes]
---

Colima (https://github.com/abiosoft/colima) 是一個目標成為在 MacOS 上最簡單的 container 環境工具，可以視為 Docker Desktop 的替代方案。

- 基於 [Lima](https://github.com/lima-vm/lima) 這個 VM 上
- 本身只有簡單的 CLI，沒有 GUI
- 支援 Docker 跟 Containerd 還有 Kubernetes

## 移除 Docker Desktop

如果你原本有安裝 Docker Desktop 可以移除了，看是要把 App 拉進垃圾筒或是 `brew uninstall`。

特別記得移除 docker config 讓後續的安裝是乾淨的 config
```
$ rm ~/.docker/config.json
```

## 安裝 Colima

使用 **brew** 可以直接安裝好
```
$ brew install colima
$ brew install docker
$ brew install docker-compose
```

安裝 `docker-compose` 後，會有以下提示:
```
Compose is now a Docker plugin. For Docker to find this plugin, symlink it:
  mkdir -p ~/.docker/cli-plugins
  ln -sfn /usr/local/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
```
這是 `docker-compose` 改版到 v2 會以 docker plugin 的方式運作，只要依照提示建立 link 就可以了。

## 啟動 Colima 並開始使用 Docker

以預設值啟動 `Colima`
```
$ colima start
```

可以用 `list` 指令查詢 vm 的資訊，預設的資源配置是 2 cores 2 GB
```
$ colima list
PROFILE    STATUS     ARCH      CPUS    MEMORY    DISK     RUNTIME    ADDRESS
default    Running    x86_64    2       2GiB      60GiB    docker
```

或是用參數自訂 vm 的資源，ex. 啟動一個 4 cores 4 GB 的 vm
```
$ colima start --cpu 4 --memory 4
```

也可以 ssh 登入 vm，直接操作 vm
```
$ colima ssh
```

colima vm 啟動後，就可以正常使用 `docker` 指令了
```
$ docker run --rm -p 8080:80 nginx
```

## 啟動 Kubernetes 環境
要啟動 kubernetes cluster 也很簡單，`start` 指令加上 `--kubernetes` 參數就可以啟動了
```
$ colima start --kubernetes
```

安裝 `kubectl` 來操作 k8s

```
$ brew install kubectl
```

以下用簡單的 nginx sample 來測試 k8s

準備 nginx 的 deployment 檔案 my-nginx.yml 內容如下:
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
```

apply 到 k8s
```
$ kubectl apply -f my-nginx.yml
deployment.apps/my-nginx created
```

用 get pod 指令，可以看到 pod 建立
```
$ kubectl get pod
NAME                        READY   STATUS              RESTARTS   AGE
my-nginx-646554d7fd-xj4g4   0/1     ContainerCreating   0          5s
my-nginx-646554d7fd-n6jnp   0/1     ContainerCreating   0          5s
```

準備 NodePort service 檔案 my-service.yml 內容如下:
```yml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    run: my-nginx
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 80
```

用 apply 設定進 k8s:
```
$ kubectl apply -f my-service.yml
service/my-service created
```

用 get service 可以看到服務 forward 到 port 30715
```
kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP          3d3h
my-service   NodePort    10.43.167.243   <none>        8080:30715/TCP   7s
```

用 curl 試試看能不能正常用到 nginx 服務
```
$ curl localhost:30715
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
成功，Welcome to nginx!


## 總結
網路上有不少人實測了 Colima vs Docker Desktop，測試數據顯非在 Disk IO 跟 CPU loading 上，Colima 效能是比較好的。

我自己初步使用上體感有比較順暢，雖然一樣是用 Linux VM 來建立 container 環境，但是 Colima 佔用的 CPU 跟 Memory 感覺是有比較少。

之後有時間或許可以再研究 Colima 的設定，進一步再做一些調校。

## Reference
- https://github.com/abiosoft/colima
- https://jacobtomlinson.dev/posts/2022/goodbye-docker-desktop-for-mac-hello-colima/
- https://kumojin.com/en/colima-alternative-docker-desktop/
- https://blog.wu-boy.com/2023/06/how-to-create-kubernetes-cluster-in-local/
