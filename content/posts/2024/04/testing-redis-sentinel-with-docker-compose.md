---
title: "使用 Docker Compose 測試 Redis Sentinel"
date: 2024-04-06T02:02:34+08:00
tags: [redis]
---

## 什麼是 Redis Sentinel

- redis sentinel 讓 redis 擁有高可用性 (high availability)。
- sentinel 會監控 redis 服務，在主節點 (master) 異常時啟動容錯移轉 (failover)，將複製節點 (replica) 提升成主節點，並告知跟 sentinel 建立連線的客戶端。

要實測一個最簡單的 redis sentinel 服務，我們需要 3 個 redis + 3 個 sentinel 的架構。使用 docker compose 可以直接在一台電腦上建出這樣的環境。

## 設定 Sentinel 配置檔

啟動 sentinel 需要準備配置檔 `sentinel.conf` 範例如下:
```bash
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 180000
sentinel parallel-syncs mymaster 1
sentinel resolve-hostnames yes
```

以下依序說明每行配置的作用:
```bash
sentinel monitor <master-name> <ip> <port> <quorum>
```
設定 sentinel 監控對象
- master-name: 對監控的 master node 設計一個名稱
- ip: master node ip
- port: master node port
- quorum: 判定 master 異常的 sentinel 數量

```bash
sentinel down-after-milliseconds mymaster 5000
```
sentinel 判定連不到 master 的時間，這邊我們設定 5 秒


```bash
sentinel failover-timeout mymaster 180000
```
容錯移轉 (failover) 逾時的時間

```bash
sentinel parallel-syncs mymaster 1
```
容錯移轉 (failover) 後同時可以重新配置使用新的 master 的數量

```bash
sentinel resolve-hostnames yes
```
讓 sentinel 支援 DNS/hostnames

## 程式連 Redis Sentinel

同時我也用 go 寫一個簡單程式，使用 go-redis 的 NewFailoverClient() 連 redis。FailoverClient 使用 sentinel 來連 redis 主服務，達到 failover 的效果。

程式會用 ping 跟 client info 來印出目前程式的連線狀況。
```go
package main

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()

	cli := redis.NewFailoverClient(&redis.FailoverOptions{
		MasterName: "mymaster",
		SentinelAddrs: []string{
			"sentinel-1:26379",
			"sentinel-2:26379",
			"sentinel-3:26379",
		},
	})

	for {
		result, err := cli.Ping(ctx).Result()
		fmt.Println("redis ping", result, err)

		info := cli.ClientInfo(ctx).Val()
		if info != nil {
			fmt.Println("client info addr", info.Addr)
			fmt.Println("client info laddr", info.LAddr)
		}

		time.Sleep(2 * time.Second)
	}
}
```

## Docker Compose

完整的 `docker-compose.yml` 如下:
```yaml
version: '3.8'

services:
  redis-master:
    image: redis:7.0.15

  redis-slave1:
    image: redis:7.0.15
    command: redis-server --slaveof redis-master 6379
    depends_on:
      - redis-master

  redis-slave2:
    image: redis:7.0.15
    command: redis-server --slaveof redis-master 6379
    depends_on:
      - redis-master
      - redis-slave1

  sentinel-1:
    image: redis:7.0.15
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    volumes:
      - ./sentinel/sentinel1.conf:/usr/local/etc/redis/sentinel.conf
    depends_on:
      - redis-master

  sentinel-2:
    image: redis:7.0.15
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    volumes:
      - ./sentinel/sentinel1.conf:/usr/local/etc/redis/sentinel.conf
    depends_on:
      - redis-master

  sentinel-3:
    image: redis:7.0.15
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    volumes:
      - ./sentinel/sentinel1.conf:/usr/local/etc/redis/sentinel.conf
    depends_on:
      - redis-master

  app:
    image: golang:1.21.3
    working_dir: /app
    command: go run main.go
    volumes:
      - ./:/app
    depends_on:
      - redis-master

```

## 啟動 Redis Sentinel

輸入 `docker compose up -d` 啟動，等服務都是 running 後，我們來看一下 redis 跟 sentinel 的狀態。

查看 redis-master replication 資訊:
```bash
docker compose exec redis-master redis-cli info replication
# Replication
role:master
connected_slaves:2
slave0:ip=172.26.0.7,port=6379,state=online,offset=332361,lag=0
slave1:ip=172.26.0.8,port=6379,state=online,offset=332361,lag=0
master_failover_state:no-failover
master_replid:5fddecc88cfc92eafb11d449e343d8228443c45b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:332496
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:332496
```
- role 是 master
- 有兩台 slave

查看 sentinel-1 資訊:
```bash
docker compose exec sentinel-1 redis-cli -p 26379 info sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_tilt_since_seconds:-1
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=172.26.0.2:6379,slaves=2,sentinels=3
```
- mymaster 目前是 172.26.0.2:6379 (redis-master)

查看 sentinel-1 log:
```bash
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 15:56:41.813 # Sentinel ID is 8d6bf48cae2f8253311d505494ce82b90baef62e
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 15:56:41.813 # +monitor master mymaster 172.26.0.2 6379 quorum 2
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 15:56:43.808 * +sentinel sentinel c1e780b5117fb4a224733ddad07a2e9af7ec3eef 172.26.0.4 26379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 15:56:43.833 * +sentinel sentinel f649283af8d6254a29f80072b19a3f20d52ea221 172.26.0.3 26379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 15:56:51.994 * +slave slave 172.26.0.7:6379 172.26.0.7 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 15:56:52.134 * +slave slave 172.26.0.8:6379 172.26.0.8 6379 @ mymaster 172.26.0.2 6379
```
- sentinel 連到 redis-master
- 接著收到另外兩台 sentinel 的資料以及 slave 的資料


查看程式 log:
```bash
docker compose logs -f app
redis-sentinel-lab-app-1  | redis: 2024/04/05 16:32:26 sentinel.go:736: sentinel: discovered new sentinel="172.26.0.4:26379" for master="mymaster"
redis-sentinel-lab-app-1  | redis: 2024/04/05 16:32:26 sentinel.go:736: sentinel: discovered new sentinel="172.26.0.3:26379" for master="mymaster"
redis-sentinel-lab-app-1  | redis: 2024/04/05 16:32:26 sentinel.go:700: sentinel: new master="mymaster" addr="172.26.0.2:6379"
redis-sentinel-lab-app-1  | redis ping PONG <nil>
redis-sentinel-lab-app-1  | client info addr 172.26.0.5:52730
redis-sentinel-lab-app-1  | client info laddr 172.26.0.2:6379
```
- sentinel 提供了目前的 master node ip: 172.26.0.2:6379 (redis-master)
- 程式依照 sentinel 提供的 ip 順利的連到 redis



## 容錯移轉 (Failover) 測試

直接下指令故意關掉 redis master
```bash
docker compose stop redis-master
```

等服務中斷後，我們再來看一下 redis 跟 sentinel 的狀態。


查看 redis-slave1 的 replication 資訊:
```bash
docker compose exec redis-slave1 redis-cli info replication
# Replication
role:slave
master_host:172.26.0.8
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_read_repl_offset:872011
slave_repl_offset:872011
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
...
```
- role 還是 slave
- master host 指到另一台 slave



查看 redis-slave2 的 replication 資訊:
```bash
docker compose exec redis-slave2 redis-cli info replication
# Replication
role:master
connected_slaves:1
slave0:ip=172.26.0.7,port=6379,state=online,offset=877304,lag=1
master_failover_state:no-failover
master_replid:de8d7834c30c4ba42f26587d4b617ec65126dc6c
master_replid2:5fddecc88cfc92eafb11d449e343d8228443c45b
master_repl_offset:877304
second_repl_offset:835557
...
```
- role 變成 master



查看 sentinel-1 資訊:
```bash
docker compose exec sentinel-1 redis-cli -p 26379 info sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_tilt_since_seconds:-1
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=172.26.0.8:6379,slaves=2,sentinels=3
```
- master 變成 172.26.0.8:6379 (redis-slave2) 了



查看 sentinel-1 log:
```bash
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:38.170 # Failed to resolve hostname 'redis-master'
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.136 # +sdown master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.202 # +odown master mymaster 172.26.0.2 6379 #quorum 2/2
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.203 # +new-epoch 1
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.203 # +try-failover master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.278 # +vote-for-leader 8d6bf48cae2f8253311d505494ce82b90baef62e 1
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.281 # c1e780b5117fb4a224733ddad07a2e9af7ec3eef voted for c1e780b5117fb4a224733ddad07a2e9af7ec3eef 1
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:42.317 # f649283af8d6254a29f80072b19a3f20d52ea221 voted for c1e780b5117fb4a224733ddad07a2e9af7ec3eef 1
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:43.402 # +config-update-from sentinel c1e780b5117fb4a224733ddad07a2e9af7ec3eef 172.26.0.4 26379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:43.403 # +switch-master mymaster 172.26.0.2 6379 172.26.0.8 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:43.405 * +slave slave 172.26.0.7:6379 172.26.0.7 6379 @ mymaster 172.26.0.8 6379
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:43.413 # Failed to resolve hostname 'redis-master'
redis-sentinel-lab-sentinel-1-1  | 1:X 05 Apr 2024 17:06:43.413 * +slave slave :6379  6379 @ mymaster 172.26.0.8 6379
```
- 無法解析 redis-master 這個 hostname，sentinel 開始判定 master 服務中斷。
- 達到兩台 sentinel 判定 master 服務中斷後，開始容錯移轉的程序。
- 先投票選出主要負責容錯移轉的 sentinel 服務，再由主責的 sentinel 切換 master ip，其他的 sentinel 則是跟主責的 sentinel 同步 config 即可。



查看 sentinel-2 的 log:
```bash
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.278 # +vote-for-leader c1e780b5117fb4a224733ddad07a2e9af7ec3eef 1
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.281 # 8d6bf48cae2f8253311d505494ce82b90baef62e voted for 8d6bf48cae2f8253311d505494ce82b90baef62e 1
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.314 # f649283af8d6254a29f80072b19a3f20d52ea221 voted for c1e780b5117fb4a224733ddad07a2e9af7ec3eef 1
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.357 # +elected-leader master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.357 # +failover-state-select-slave master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.430 # +selected-slave slave 172.26.0.8:6379 172.26.0.8 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.431 * +failover-state-send-slaveof-noone slave 172.26.0.8:6379 172.26.0.8 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:42.488 * +failover-state-wait-promotion slave 172.26.0.8:6379 172.26.0.8 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:43.364 # +promoted-slave slave 172.26.0.8:6379 172.26.0.8 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:43.364 # +failover-state-reconf-slaves master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:43.400 * +slave-reconf-sent slave 172.26.0.7:6379 172.26.0.7 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.451 # -odown master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.457 * +slave-reconf-inprog slave 172.26.0.7:6379 172.26.0.7 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.457 * +slave-reconf-done slave 172.26.0.7:6379 172.26.0.7 6379 @ mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.525 # +failover-end master mymaster 172.26.0.2 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.525 # +switch-master mymaster 172.26.0.2 6379 172.26.0.8 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.528 * +slave slave 172.26.0.7:6379 172.26.0.7 6379 @ mymaster 172.26.0.8 6379
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.535 # Failed to resolve hostname 'redis-master'
redis-sentinel-lab-sentinel-2-1  | 1:X 05 Apr 2024 17:06:44.535 * +slave slave :6379  6379 @ mymaster 172.26.0.8 6379
```
這台就是被選為主責切換 master 的 sentinel，可以看到整個過程
- 挑一台 slave 提升為 master
- 重新設定 slave
- 將 mymaster ip 設成新的 master ip





查看程式 log:
```bash
redis-sentinel-lab-app-1  | redis ping PONG <nil>
redis-sentinel-lab-app-1  | client info addr 172.26.0.5:52730
redis-sentinel-lab-app-1  | client info laddr 172.26.0.2:6379
redis-sentinel-lab-app-1  | redis: 2024/04/05 17:06:43 sentinel.go:700: sentinel: new master="mymaster" addr="172.26.0.8:6379"
redis-sentinel-lab-app-1  | redis ping PONG <nil>
redis-sentinel-lab-app-1  | client info addr 172.26.0.5:32854
redis-sentinel-lab-app-1  | client info laddr 172.26.0.8:6379
```
- 程式從 sentinel 拿到新的 master ip，下一個指令就連到新的 ip 了



## 寫在最後

以上是對 redis sentinel 的小型測試。測試過程讓我們了解 redis sentinel 是如何實現容錯移轉 (failover) 機制以滿足高可用性。


測試檔案都放到我的 github repository 裡: [nyogjtrc/redis-sentinel-lab](https://github.com/nyogjtrc/redis-sentinel-lab)


## Reference

- <https://redis.io/docs/management/sentinel/>

- [Redis (六) - 主從複製、哨兵與叢集模式 - HackMD](https://hackmd.io/@tienyulin/redis-master-slave-replication-sentinel-cluster)

- <https://github.com/880831ian/docker-compose-redis-sentinel>
