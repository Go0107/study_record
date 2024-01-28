# require_relative 'top.rb'

# require 'webrick'
# require 'mysql2'
# require 'digest'

# db_client = Mysql2::Client.new(
#   host: 'localhost',       # 全員、localhostでOKです
#   username: 'root',        # ひとまず、権限を一番持っているrootユーザーにしました
#   password: 'aaa',   # 自身のmysqlのrootユーザーのパスワードをここに入力します
#   database: 'study_record' # 全員、study_recordでOKです（自身のPCにstudy_recordのデータベースを作成してください）
# )

# # ユーザ情報をデータベースに保存するメソッドを定義
# def save_user_to_database(username, password)
#   if username.empty? || password.empty?
#     puts "未入力の項目があります"
#     return false
#   else
#     # 'users'テーブルにユーザデータを挿入するSQLクエリを構築し実行（How_to_Signupで解説）
#     hashed_password = Digest::SHA256.hexdigest(password)
#     insert_query = "INSERT INTO users (username, password) VALUES (?, ?)"
#     db_client.query(insert_query, username, password)
#     return true
#   end
# end

# # ポート3000でWEBrick HTTPサーバーを作成
# server = WEBrick::HTTPServer.new(Port: 3000)

# # 割り込みシグナル（例: Ctrl+C）を受け取ってサーバーをなめらかに？シャットダウンする（How_to_Signupで解説）
# trap('INT') { server.shutdown }

# # ERB（Embedded Ruby）ハンドラを使用してsignupページを提供
# server.mount('/signup.html', WEBrick::HTTPServlet::ERBHandler, 'study_record/pages/signup.html')

# # 'assets'ディレクトリから静的なアセット（例: CSS、画像）を提供
# server.mount('/assets', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, 'assets'))
# # '/signup'エンドポイントへのPOSTリクエストを処理
# server.mount_proc('/signup') do |req, res|
#   if req.request_method == 'POST'
#     # リクエストボディからパラメータを解析
#     params = WEBrick::HTTPUtils.parse_query(req.body)
#     username = params['name']
#     password = params['password']

#     # save_user_to_databaseメソッドを呼び出してユーザデータをデータベースに挿入
#     if save_user_to_database(username, password)
#       # サインアップの処理が成功したら'/home'のURLにリダイレクト
#       res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/home.html')
#     else
#       # ユーザー名またはパスワードが空の場合は前のページにリダイレクト
#       res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
#     end
#   else
#     # リクエストメソッドがPOSTでない場合はエラーレスポンスを設定
#     res.body = '無効なリクエストです'
#   end
# end

# # WEBrick HTTPサーバーを起動
# server.start
