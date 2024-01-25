# mysql2というライブラリを使用してMySQLに接続するための記述
require'mysql2'
# erbというHTMLを生成するライブラリを使用するための記述
require 'erb'

# データベースにアクセスするための記述で自分のデータベースに合わせて変えていく
client = Mysql2::Client.new(
    host: "localhost", 
    username: "root", 
    password: '@ZSExdr123', 
    database: 'study_record',
    port: '3000'
)

# test変数にdiary_list.htmlファイルの中身を入れている
test = File.read("../pages/diary_list.html")

# reportsテーブルから全部のデータを取得
result = client.query("SELECT * FROM reports")

# reportsテーブルから持ってきたカラムを配列で取得
date = result.map { |row| row['date'] }
study_time = result.map { |row| row['study_time'] }
created_time = result.map { |row| row['created_at'] }
study_content = result.map { |row| row['study_content'] }
reflection = result.map { |row| row['reflection'] }
report_id = result.map { |row| row['report_id'] }.sort.reverse
username = client.query("SELECT u.username FROM reports r INNER JOIN users u ON r.user_id = u.user_id;").map { |row| row['username'] }

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
                    <li><h4>日付<br><%= date[num] %></h4></li>
                    <li><h4>名前<br><%= username[num] %></h4></li>
                    <li><h4>学習時間<br><%= study_time[num] %></h4></li>
                    <li><h6>投稿日時:<%= created_time[num] %></h6></li>
                    <li><i class="fas fa-heart"></i></h3><span id="times">0</span></li>
                </ul>
                <ul class="right-item">
                    <h3>学習内容<h3>
                    <li><h5><%= study_content[num] %></h5></li>
                </ul>
            </div>
            <div class="bottom-items">
                <div class="text-content">
                    <h3>振り返り</h3>
                    <p><%= reflection[num] %></p>
                </div>
                <div class="buttons">
                    <input class="styled" type="button" value="編集" id="edit">
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
puts report_id

