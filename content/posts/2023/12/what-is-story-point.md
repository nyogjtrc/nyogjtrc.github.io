---
title: "什麼是估點"
date: 2023-12-04T23:18:15+08:00
tags: [story point]
---
> 在 [團隊的估點(Story Point)經歷 | Nyo's Study Book](https://nyogjtrc.github.io/posts/2022/05/a-story-of-the-team-using-story-point/) 這篇分享過一些估點的經驗，今天回頭過來介紹什麼是估點

軟體開發往往會遇到評估開發時程的難題，直覺上多數人都會以「工時」進行估計。但現實是開發過程總是會遇到各式各樣的問題，讓估計跟現實有很大的差距。

## 估點的出現

在敏捷的 Scrum 框架中，會使用 Story Point 估算 Story 復雜度，取代傳統的工時估計。
ps. Story Point 的概念一開始是在 XP(極限開發) 框架中出現的。



使用 Story Point 估算 Story 復雜度的好處
- 以「相對」的復雜度來估計，會比「絕對」的工時來得簡單
- 會議上可以聚焦在討論「Story Point」的差異，避免個人的經驗差異，而對工時的斤斤計較
- 「Story Point」只是單純的估計值，不像「工時」跟實際開發時間直接的連結，被誤會成對「工時」的承諾



## 如何進行估點

### 時間
在 Scrum 框架裡，會在 Planning Meeting 時進行估點

### 成員
參與估點的成員只會有要開發團隊，另外還要有 PO/PM 來跟開發團隊說明 Story。沒有要參與開發的角色就旁聽就好，避免影響估點的因素。

### 估點工具: Planning Poker
- 由費氏數列組成的 Story Point 卡片「0, 1, 2, 3, 5, 8, 13, 20, 40, 100」
- 費氏數列越後面的數字差距越大，估點的情況也是，越大的 Story，估算的準確度會越差
- 如果 Story 出現很大的數字，可能要看看 Story 是不是可以切小
- ps. 也有其他的工具 ex. T-Shirt Size，或是團隊可以自己設計

### 準備好的 Backlog
- Story 內容清楚，並且經過充分的討論
- 排好優先順序

### 會議流程
1. PO 說明 Story 內容，讓團隊成員了解
2. 設定基準 Story Point
   - 找一個大家覺得適合的 Story，設定 Story Point 為 1
3. 團隊成員先各自思考 Story Point 應該為多少，先蓋牌。等所有人都決定好 Point 大小後，再公開結果。
4. 就 Point 的差異進行討論，接著重新思考 Point 大小 ，最終團隊達成一定的共識。
   - 如果對內容有一定的共職，但是點數卻沒辦法完全一樣的話，可以選擇算平均值或是取最大值。
5. 進行下一個 Story。
6. 當討論的 Story 量已經足夠時，或是設定的 Timebox 已到，就可以結束會議了。



## 總結

估點的出現解決了過往估算工時的種種問題，在使用這個很棒的工具同時，也要時常的回頭看看是不是有走歪了。例如主管為了增進團隊產能，把工時的那套做法帶入 Story Point 裡面。

如果估點對團隊沒有幫助，就不要使用。

估點除了讓我們對 Story 的復雜度有個概念，過程也相當重要。每一次思考 Point 大小以及討論，讓團隊有充分的交流，取得一定的共識，聚焦在交付更高的價值。


## Reference
- [Scrum Estimation－如何估算專案時程 | In 91 - 點部落](https://dotblogs.com.tw/hatelove/2015/12/19/scrum-project-schedule-estimation)
- [Agile Summit 2019 - 咕唧咕唧，估計估計](https://engineering.linecorp.com/zh-hant/blog/agile-summit-2019)
