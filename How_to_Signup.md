# ユーザー登録機能の実装

## GemFile

まず、study_recordディレクトリにGemFileを作成します。

記述はそのまま書いてあるので、変更しなくて大丈夫です。

次に、study_recordディレクトリをcdにして、ターミナル上で
```
bundle install
```
を実行します。

すると、GemFile.lockというものができると思います。

準備はこれでOKです。


## Singup.html内のコード変更

pages内にあるsignup.htmlのコードを開きます。

18行目あたりにあるformタグのaction属性を追記します。
```html
<form action="/signup" method="post">
```


## MySQLの準備

MySQLに接続します。（signup.rbと合わせるので、rootユーザーで接続してください）

study_recordのデータベースを作ります

その中に、usersテーブルを作ってください。
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(100) NOT NULL, 
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

この後、mysqlは接続したままの状態にしておいてください。（接続を切るとエラーになる？）


## signup.rbの実行

signup.rbファイルのあるパスを参照（cd）してターミナルを開き、

```ruby
ruby signup.rb
```

で実行してください。（ターミナル上でrubyを開くときと同じ要領）

### コードの一部解説（私も2%くらいしか理解できていません）
```rb
# 割り込みシグナル（例: Ctrl+C）を受け取ってサーバーをGracefullyにシャットダウンする
trap('INT') { server.shutdown }
```
- trap メソッドは、指定されたシグナルが発生したときに実行するブロックを登録します
- ここでは、'INT' シグナル（通常はCtrl+Cが押されたときの割り込みシグナル）が発生したときに、指定されたブロックが実行され、server.shutdown が呼び出されてサーバーがためらかに終了します。
- なめらかなシャットダウンは、サーバーが現在処理しているリクエストを完了させたり、リソースを解放したりしてから終了するプロセスです。

これにより、途中の処理が中断されず、リクエストの一貫性が保たれます。


```rb
# リクエストボディからパラメータを解析
    params = WEBrick::HTTPUtils.parse_query(req.body)
    username = params['name']
    password = params['password']
```

- この部分のコードは、HTTP POSTリクエストのボディからパラメータを解析しています。
- 主に、WEBrick::HTTPUtils.parse_query メソッドを使用してリクエストボディから取得したデータを解析し、それを params という変数に格納しています。
  - HTTPリクエストは、クライアントがサーバーに送信する要求を表します。HTTPリクエストにはヘッダーとボディという二つの主要な部分があります。リクエストボディは、通常、POSTメソッドなどでデータをサーバーに送信するときに使用されます。
- `req.body` は、HTTP POSTリクエストのボディを表します。
- `WEBrick::HTTPUtils.parse_query(req.body)` は、ボディのデータを解析し、パラメータを含むハッシュに変換します。
  - 例えば、name=John&password=secret のようなデータを { 'name' => 'John', 'password' => 'secret' } のようなハッシュに変換します。
- `params['name'] と params['password']` を使って、ユーザーが送信したデータからユーザー名とパスワードの値を取り出しています。

このコードは、ユーザーがサインアップフォームに入力したデータを取得し、それを後続の処理で使用するために変数に格納しています。例えば、ユーザーがフォームに入力したユーザー名は username に、パスワードは password に格納されます。

## Webページの確認

ブラウザのURLに
```
http://localhost:3000
```

と入力すると、「新規登録画面」が出てくるはずです。

また、ユーザー名とパスワード欄に値を入力して「登録する」を押すと、以下の変化が得られます。

1. ウェブページのURLの末尾が/diary-listになる
2. MySQLのusersテーブルを表示すると、入力した値が格納されている
```sql
SELECT * FROM users;
```


