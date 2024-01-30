# study_record

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

## MySQLの準備

MySQLに接続します。（rootユーザーで接続してください）

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

```sql
CREATE TABLE reports (
      report_id INT PRIMARY KEY AUTO_INCREMENT, 
      user_id INT NOT NULL, 
      date DATE NOT NULL, 
      study_time INT NOT NULL, 
      study_content VARCHAR(100), 
      reflection VARCHAR(500), 
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
      FOREIGN KEY (user_id) REFERENCES users(user_id)
  ); 
```

## 実行方法

ターミナル上で

```ruby
ruby webrick.rb
```

を実行してください。

※MySQLのrootユーザーのパスワードを入力するのを忘れずに！

上手く起動したら、ブラウザ上で


```
http://localhost:3000/top.html

```

にアクセスをして、アカウント作成から行ってください。