---
title: "自架簡單的 Elasticsearch 服務"
date: 2024-02-09T00:47:20+08:00
tags: [elasticsearch]
---
Elasticsearch 是目前很熱門的分散式搜尋引擎，為了讓自己有個環境方便研究 ，所以整理了一份可以在自己電腦上快速啟動 Elasticsearch 的 `docker-compose.yml`

Elasticsearch 本身提供 RESTful API 做為使用介面，如果想要視覺化的介面，需要再加上 Kibana。

這次建立服務會有 Elasticsearch + Kibana

## 建立 `docker-compose.yml`

完整檔案與設定說明如下

```yaml
version: "3.8"

services:
  es:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.12.1
    volumes:
      - ./es-data:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - bootstrap.memory_lock=true
    ulimits:
      memlock:
        soft: -1
        hard: -1
    deploy:
      resources:
        limits:
          memory: 1GB

  kibana:
    image: docker.elastic.co/kibana/kibana:8.12.1
    volumes:
      - ./kb-data:/usr/share/kibana/data
    ports:
      - 5601:5601
    environment:
      - ELASTICSEARCH_HOSTS=http://es:9200
    deploy:
      resources:
        limits:
          memory: 1GB
```

- 設定為單節點模式

   ```yaml
   environment:
     - discovery.type=single-node
   ```

- 關掉 SSL 加密傳輸 (這是為了讓架服務簡單一點)

   ```yaml
   environment:
     - xpack.security.enabled=false
   ```

- 限制記憶體用量

   ```yaml
   deploy:
     resources:
       limits:
         memory: 1GB
   ```

- 關掉 swap 

   ```yaml
   environment:
     - bootstrap.memory_lock=true
   ulimits:
     memlock:
       soft: -1
       hard: -1
   ```



因為我想要掛載資料夾保存資料，而 Elasticsearch 預設是使用 `elasticsearch` 這個 user 跟 uid:gid 1000:0，所以需要先建立資料夾跟設定權限。不然直接啟動時，會遇到寫檔權限錯誤。

```bash
mkdir es-data
chmod g+rwx es-data
sudo chgrp 0 es-data

mkdir kb-data
chmod g+rwx kb-data
sudo chgrp 0 kb-data
```



### 啟動服務

以上動作都準備好之後，就可以啟動服務了

```bash
docker compose up -d
```



稍等服務啟動，就可以直接點以下連結看服務有沒有成功
- elasticsearch: http://127.0.0.1:9200/
- kibana: http://127.0.0.1:5601/



## 實測 Elasticsearch

打開 Kibana 選單，選 Dev Tools，這裡提供一個 Console 介面讓我們可以方便的測試 Elasticsearch。左側輸入 API 請求，執行結果會出現在右側。



以下提供幾個測試範例:

### 查看 cluster 健康狀態

- Request:
   ```plain
   GET /_cluster/health
   ```

- Response:
   ```plain
   {
     "cluster_name": "docker-cluster",
     "status": "yellow",
     "timed_out": false,
     "number_of_nodes": 1,
     "number_of_data_nodes": 1,
     "active_primary_shards": 38,
     "active_shards": 38,
     "relocating_shards": 0,
     "initializing_shards": 0,
     "unassigned_shards": 3,
     "delayed_unassigned_shards": 0,
     "number_of_pending_tasks": 0,
     "number_of_in_flight_fetch": 0,
     "task_max_waiting_in_queue_millis": 0,
     "active_shards_percent_as_number": 92.6829268292683
   }
   ```



### 新增 document 到 hello index

- Request:
   ```plain
   PUT hello/_doc/1
   {
     "message": "hello, world!",
     "from": "me"
   }
   ```

- Response
   ```plain
   {
     "_index": "hello",
     "_id": "1",
     "_version": 1,
     "result": "created",
     "_shards": {
       "total": 2,
       "successful": 1,
       "failed": 0
     },
     "_seq_no": 0,
     "_primary_term": 1
   }
   ```



### 查詢 hello id 為 1 的 document

- Request
   ```plain
   GET hello/_doc/1
   ```

- Response
   ```plain
   {
     "_index": "hello",
     "_id": "1",
     "_version": 1,
     "_seq_no": 0,
     "_primary_term": 1,
     "found": true,
     "_source": {
       "message": "hello, world!",
       "from": "me"
     }
   }
   ```



### 搜尋 hello 的所有 document

- Request
   ```plain
   GET hello/_search
   {
     "query":{
       "match_all" : {}
     }
   }
   ```

- Response
   ```plain
   {
     "took": 1,
     "timed_out": false,
     "_shards": {
       "total": 1,
       "successful": 1,
       "skipped": 0,
       "failed": 0
     },
     "hits": {
       "total": {
         "value": 1,
         "relation": "eq"
       },
       "max_score": 1,
       "hits": [
         {
           "_index": "hello",
           "_id": "1",
           "_score": 1,
           "_source": {
             "message": "hello, world!",
             "from": "me"
           }
         }
       ]
     }
   }
   ```



### 刪除 hello id 為 1 的 document

- Request
   ```plain
   DELETE hello/_doc/1
   ```

- Response
   ```plain
   {
     "_index": "hello",
     "_id": "1",
     "_version": 2,
     "result": "deleted",
     "_shards": {
       "total": 2,
       "successful": 1,
       "failed": 0
     },
     "_seq_no": 1,
     "_primary_term": 1
   }
   ```

## Reference

- [Install Elasticsearch with Docker | Elasticsearch Guide \[8.11\] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
- [Run Elasticsearch locally | Elasticsearch Guide \[8.11\] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/run-elasticsearch-locally.html)
- [Important Elasticsearch configuration | Elasticsearch Guide \[8.11\] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html#path-settings)
- [elasticsearch/docs/reference/setup/install/docker/docker-compose.yml at 8.11 · elastic/elasticsearch](https://github.com/elastic/elasticsearch/blob/8.11/docs/reference/setup/install/docker/docker-compose.yml)
- [Disable swapping | Elasticsearch Guide \[8.12\] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html)
- [Elasticsearch fails to start in Docker, when `elasticsearch.yml` is bind mount · Issue #85463 · elastic/elasticsearch](https://github.com/elastic/elasticsearch/issues/85463)
