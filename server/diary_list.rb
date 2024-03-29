# mysql2というライブラリを使用してMySQLに接続するための記述
require'mysql2'
# erbというHTMLを生成するライブラリを使用するための記述
require 'erb'

# データベースにアクセスするための記述で自分のデータベースに合わせて変えていく
client = Mysql2::Client.new(
    host: "localhost", 
    username: "root", 
    password: '　　　　　　', 
    database: 'study_record',
)

# test変数にdiary_list.htmlファイルの中身を入れている
test = File.read("../pages/diary_list.html")

# reportsテーブルから全部のデータを取得
result = client.query("SELECT * FROM reports ORDER BY report_id DESC")

# reportsテーブルから持ってきたカラムを配列で取得
report_id = result.map { |row| row['report_id'] } # 編集ボタンを対応させるために追加
date = result.map { |row| row['date'] }
study_time = result.map { |row| row['study_time'] }
created_time = result.map { |row| row['created_at'] }
study_content = result.map { |row| row['study_content'] }
reflection = result.map { |row| row['reflection'] }
report_id = result.map { |row| row['report_id'] }

# ユーザー名の取得
# user_idに対応するユーザー名を取得するように修正
username_query = "SELECT u.username FROM reports r INNER JOIN users u ON r.user_id = u.user_id ORDER BY r.report_id DESC"
username_result = client.query(username_query)
username = username_result.map { |row| row['username'] }


# 名前の数から繰り返し処理を何回行うかを決める
data_count = report_id.length 
num = 0

# result_htmlに入っているHTML要素を初期化
result_html = ""

while num < data_count do
    html_template = ERB.new('
        <div class="info-list" id="<%= report_id[num] %>">
            <div class="top-items">
                <ul class="left-item">
                    <li><h4>【日付】<br><%= date[num] %></h4></li>
                    <li><h4>【名前】<br><%= username[num] %></h4></li>
                    <li><h4>【学習時間】<br><%= study_time[num] %></h4></li>
                    <li><h6>【投稿日時】:<%= created_time[num] %></h6></li>
                </ul>
                <ul class="right-item">
                    <h3>【学習内容】<h3>
                    <li><h5><%= study_content[num] %></h5></li>
                </ul>
            </div>
            <div class="bottom-items">
                <div class="text-content">
                    <h3>【振り返り】</h3>
                    <p><%= reflection[num] %></p>
                </div>
                <div class="buttons">
                <input class="styled edit" type="button" value="編集" data-report-id="<%= report_id[num] %>">
                <input class="styled" type="button" value="削除" id="delete">
                </div>
            </div>
        </div>
    ')
    result_html += html_template.result(binding)
    
    num += 1
end

# すでに入っているhtmlを初期化する
test.sub!(/<main>.*?<\/main>/m, '<main><h1 class="title">日報一覧</h1></main>')

# 既存のHTMLに新しいHTMLコードを挿入
modified_html = test.gsub(/<\/main>/, "#{result_html}</main>")

# 変更を適用した新しいHTMLを保存
File.open('../pages/diary_list.html', 'w') do |file|
    file.puts modified_html
end

puts 'HTMLを作成しました'

