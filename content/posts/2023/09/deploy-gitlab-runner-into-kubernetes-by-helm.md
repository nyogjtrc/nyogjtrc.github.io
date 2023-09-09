---
title: "使用 Helm 部署 Gitlab Runner 到 Kubernetes"
date: 2023-09-09T23:52:20+08:00
tags: [gitlab, gitlab-ci, kubernetes, helm]
---
## 準備工作

在開始部署前，需要準備好以下環境:
- 建立 Kubernetes cluster
- 安裝 kubectl，並設定好可以操作 Kubernetes cluster
- 安裝 Helm

本次測試版本
- kubernetes: v1.27.3-gke.100
- kubectl: v1.27.3
- helm: v3.12.2

## 設定 values.yml

在使用 helm 部署之前需要先建立 `values.yml` 設定你的 Runner 環境。Gitlab Runner 預設的 [values.yml](https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml) 就放在 chart repository

必要的設定如下:
- `gitlabUrl`: 要填入 runner 要註冊的 Gitlab server。ex. `https://gitlab.example.com`
- `rbac: { enable: true }`: 啟用 RBAC，讓 Runner 可以建立 pods 執行 jobs。
- `runnerToken`: 在 Gitlab 建立的 Runner token

## 部署 Runner

設定好 `values.yml` 之後，就可以開始來部署 Runner 了。我們會在 kubernetes 建立名為 runner 的 namespace，將 Runner 部署在裡面。

加入 GitLab Helm repository:
```bash
helm repo add gitlab https://charts.gitlab.io
```

建立要給 runner 部署的 namespace runner:
```bash
kubectl create namespace runner
```

準備好 value部署 gitlab runner 到 Kubernetes cluster:
```bash
helm install --namespace runner gitlab-runner -f values.yml gitlab/gitlab-runner
```

接下來就是等待 Kubernetes 啟動 pod，你就可以在 Gitlab 上看到 Runner 狀態是 ready 的。

如果有更新 values.yml，使用以下指令更新部署 gitlab runner:
```bash
helm upgrade --namespace runner gitlab-runner -f values.yml gitlab/gitlab-runner
```



## 設定 Kubernetes Runner 可以執行 Docker-in-Docker

要讓 Gitlab Runner 可以建立 Docker images 的其中一個方法是使用 Docker-in-Docker

我們需要更新 `values.yml` 的 `runner.config` 加入以下設定
- 啟用 `privileged` 模式
- 掛載憑證資料夾 `/certs/client`

可參考以下設定:
```yaml
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        image = "ubuntu:20.04"
        privileged = true
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"
```

Runner 設定好後，再來是要建立 `.gitlab-ci.yml`，Job 的設定加上有 dind 的 service 跟需要的 variables

參考以下設定:
```yaml
docker-build:
  stage: build
  image: docker:24.0.6
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
    DOCKER_TLS_VERIFY: 1
    DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"
  services:
    - docker:24.0.6-dind
  before_script:
    - docker info
  script:
    - docker build -t $CI_PROJECT_PATH .
    - docker run $CI_PROJECT_PATH
```

設定完成後，Gitlab CI/CD 就能夠建立 docker image 了。

## 其他指令

查詢 runner 版本清單:
```bash
helm search repo -l gitlab/gitlab-runner
```

查詢 kubectl 所有的 cluster 設定
```
kubectl config get-contexts
```

切換 namespace 到 runner:
```
kubectl config set-context --current --namespace runner
```

## 完整版的 value.yml

附上這次測試的完整版 `values.yml`:
```yaml
image:
  registry: registry.gitlab.com
  image: gitlab-org/gitlab-runner

useTini: false

imagePullPolicy: Always

gitlabUrl: https://example.gitlab.com/

runnerToken: "gitlab-runner-token"

terminationGracePeriodSeconds: 3600

concurrent: 10
checkInterval: 10

sessionServer:
  enabled: false

rbac:
  create: true
  rules: []
  clusterWideAccess: false
  podSecurityPolicy:
    enabled: false
    resourceNames:
    - gitlab-runner

metrics:
  enabled: true
  portName: metrics
  port: 9252
  serviceMonitor:
    enabled: false

service:
  enabled: true
  type: ClusterIP

## Configuration for the Pods that the runner launches for each new job
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "{{.Release.Namespace}}"
        image = "alpine:3.18"
        privileged = true
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"
  cache: {}

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  privileged: false
  capabilities:
    drop: ["ALL"]

podSecurityContext:
  runAsUser: 100
  fsGroup: 65533
```

## Reference

- [GitLab Runner Helm Chart | GitLab](https://docs.gitlab.com/runner/install/kubernetes.html)
- [Kubernetes executor | GitLab](https://docs.gitlab.com/runner/executors/kubernetes.html)
- [Use Docker to build Docker images | GitLab](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)
