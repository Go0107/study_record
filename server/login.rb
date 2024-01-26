# require_relative 'top.rb'

# require 'webrick'
# require 'mysql2'
# require 'digest'

# $db_client = Mysql2::Client.new(
#     host: 'localhost',
#     username: 'root',
#     password: '@ZSExdr123',
#     database: 'study_record'
# )

# # ポート3000でWEBrick HTTPサーバーを作成
# server = WEBrick::HTTPServer.new(Port: 3000)

# # '/login'画面
# server.mount_proc '/login' do |req, res|
#     res.content_type = 'text/html'
    
#     html_file_path = '../pages/login.html'  # ファイルの実際のパスに変更してください
#     html_content = File.read(html_file_path)
    
#     res.body = html_content
# end



# # 割り込みシグナルを受け取ってサーバーをシャットダウン
# trap('INT') { server.shutdown }
# # WEBrick HTTPサーバーを起動
# server.start