# serverside-elm-sandbox

# :warning: EXPERIMENTAL :warning:

## 説明

Elmでサーバサイドのプログラムも書いてみたやつです。

node.js のhttpモジュールでサーバを建てて入ってきたリクエストをElmのアプリケーションに
渡してRoutingをしたりしてます。

DBに触る部分はnode.js経由でやる必要があるのでportでjsと通信してます。
そのためportがたくさん出てきます。

DBはMockで実装しています。


### 仕様

Todoリストアプリです

| endpoint | method | Description |
|:--------:|:------:|:-----------:|
|/todo/:id |GET     |todoの要素を取得|
|/list     |GET     |全部の要素を取得|
|/todo     |POST    |todoを作成   |
|/todo/:id |PUT     |todoを更新   |
|/todo/:id |DELETE  |todoを削除   |


## ディレクトリ構造

```
.
├── README.md
├── elm.json
├── package-lock.json
├── package.json
└── src
    ├── @types
    │   └── elm.d.ts
    ├── Elm
    │   ├── Backend
    │   │   ├── Main.elm
    │   │   └── Server.elm
    │   ├── Frontend
    │   │   ├── Main.elm
    │   │   └── Request.elm
    │   └── Model.elm
    ├── backend
    │   ├── index.ts
    │   ├── model.ts
    │   ├── repository.ts
    │   └── server.ts
    └── frontend
        ├── index.html
        └── index.ts
```

## 実行方法

1. `npm run dev:server` をするとBuildが走る
2. 別のプロセスで`npm run start:server` をするとServerが起動する
3. `npm run start:client` でクライアントが起動する

