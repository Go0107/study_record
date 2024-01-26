require 'webrick'
require 'mysql2'

# # MySQL接続情報を、webrickへ記載
# client = Mysql2::Client.new(
#   host: 'localhost',    # データベースのホスト名
#   username: 'root',     # データベースのユーザー名
#   password: '', # データベースのパスワード
#   database: 'study_record' # データベース名
# )

# new_diary.htmlのパス
new_diary_path = File.join(__dir__, '..', 'pages', 'new_diary.html')

# new_diary.htmlの内容を読み込む
form_html = File.read(new_diary_path, encoding: 'UTF-8')

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc '/new-diary' do |req, res|
  res.body = form_html
  res.content_type = 'text/html; charset=utf-8' # Content-TypeをUTF-8に設定
end

# 'assets'ディレクトリから静的なアセット（例: CSS、画像）を提供
server.mount('/assets', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, '../assets'))

# # 以下の処理をwebrickへ記載
# server.mount_proc '/diary_list' do |req, res|
#   params = WEBrick::HTTPUtils.parse_query(req.body)

#   #  # デバッグ出力
#   #  p params

#   # 入力データ
#   date = params['date']
#   username = params['username']
#   study_time = params['study_time']
#   study_content = params['study_content']
#   reflection = params['reflection']
#   created_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

#   # 日付のフォーマットが正しいか確認
#   begin
#     Date.parse(date)
#   rescue ArgumentError
#     res.body = "エラーが発生しました: 無効な日付形式です。"
#     next
#   end

#   # SQLクエリの作成と実行
#   query = "INSERT INTO reports (user_id, date, study_time, study_content, reflection, created_at) VALUES (1, '#{date}', #{study_time.to_i}, '#{study_content}', '#{reflection}', '#{created_at}')"

#   begin
#     result = client.query(query)
#     res.body = "データが正常に挿入されました。"
#   rescue => e
#     res.body = "エラーが発生しました: #{e.message}"
#   end
# end


trap 'INT' do server.shutdown end

# server.start
