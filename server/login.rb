require_relative 'top.rb'

require 'webrick'
require 'mysql2'
require 'digest'

$db_client = Mysql2::Client.new(
    host: 'localhost',
    username: 'root',
    password: '0606araki',
    database: 'study_record'
)

# パスワードをハッシュ化するメソッド
def hash_password(password)
    Digest::SHA256.hexdigest(password)
end

# データベースからユーザーを検索するメソッド
def find_user(username, password)
    hashed_password = hash_password(password)
    query = "SELECT * FROM users WHERE username = ? AND password = ?"
    result = $db_client.query(query, username, hashed_password)
    result.first
end

# ポート3000でWEBrick HTTPサーバーを作成
server = WEBrick::HTTPServer.new(Port: 3000)

# 割り込みシグナルを受け取ってサーバーをシャットダウン
trap('INT') { server.shutdown }

# ERBハンドラを使用してloginページを提供
server.mount('/login.html', WEBrick::HTTPServlet::ERBHandler, 'study_record/pages/login.html')

# 'assets'ディレクトリから静的なアセットを提供
server.mount('/assets', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, '../assets'))

# '/login'エンドポイントへのPOSTリクエストを処理
server.mount_proc('/login') do |req, res|
    puts "aaa"
    if req.request_method == 'POST'
        # リクエストボディからパラメータを解析
        params = WEBrick::HTTPUtils.parse_query(req.body)
        username = params['name']
        password = params['password']

        # データベースからユーザーを検索
        user = find_user(username, password)

        if user
        # ログイン成功時の処理
        res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/home')
        else
        # ログイン失敗時の処理
        res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top')
        end
    else
        # リクエストメソッドがPOSTでない場合はエラーレスポンスを設定
        res.body = '無効なリクエストです'
    end
end

# WEBrick HTTPサーバーを起動
server.start
