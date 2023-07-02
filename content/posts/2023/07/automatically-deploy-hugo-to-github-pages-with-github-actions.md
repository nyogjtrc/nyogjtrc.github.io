---
title: "使用 Github Actions 自動部署 Hugo 到 Github Pages"
date: 2023-07-02T21:48:13+08:00
tags: [hugo, github, github actions]
---

上次的 blog 大改造應該是在 [用 Hugo 發佈部落格](/posts/2017/09/publish-blog-with-hugo-generator/) 這時做的，也經過了快 5 年了。

原本我的 nyogjtrc.github.io 發佈方式是另開了一個 repository 存放 markdown，再把 hugo 產生的靜態檔案指定到 nyogjtrc.github.io 這個 repository。Github Pages 設定是選擇從 nyogjtrc.github.io 這個repository 的 master 分支部署。步驟其實不多，但還不是完全的自動發佈。

去年(2022) Github 的文章 [GitHub Pages now uses Actions by default | The GitHub Blog](https://github.blog/2022-08-10-github-pages-now-uses-actions-by-default/) 提到 Github Pages 已經完全使用 Github Actions 進行部署了。

所以現在就來讓我的 Blog 再小小的進步一點，使用 Github Actions 自動部署。

## Github Pages 設定

Github Pages 設定成使用 Github Actions 部署
- 到 repository 畫面，點選 `Settings > Pages`
- 在 **Build and deployment** 的部份 `Source` 選 `Github Actions`


這次的調整我還改用 `main` 做為主要部署分支，所以還需要修改 `Enviroments` 的設定
- 點選 `Settings > Enviroments`
- 在 **Deployment branches** 的部分選擇 `Add deployment branch rule`
- 在 **Branch name pattern** 輸入 `main`，按下 `Add rule`


## 建立 Github Actions

建立檔案 `.github/workflows/github-pages.yml` 輸入內容如下:
```yaml
name: Deploy to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches:
      - main

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.115.0
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
          && sudo dpkg -i ${{ runner.temp }}/hugo.deb
      - name: Install Dart Sass
        run: sudo snap install dart-sass
      - name: Checkout
        uses: actions/checkout@v3
        with:
          submodules: recursive
          fetch-depth: 0
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v3
      - name: Install Node.js dependencies
        run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
      - name: Build with Hugo
        env:
          # For maximum backward compatibility with Hugo modules
          HUGO_ENVIRONMENT: production
          HUGO_ENV: production
        run: |
          hugo \
            --gc \
            --minify \
            --baseURL "${{ steps.pages.outputs.base_url }}/"
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

此外，如果 hugo 的 `config.yml` 有設定 `publishDir` 的話，要移除改使用預設。

檔案修改完成後，就是 commit 跟 push。隨後就可以到 `Actions` 的畫面檢查部署的狀況了！

## Reference
- [Host on GitHub | Hugo](https://gohugo.io/hosting-and-deployment/hosting-on-github/)
- [用 Hugo 發佈部落格 | Nyo's Study Book](/posts/2017/09/publish-blog-with-hugo-generator/)
