require 'webrick'
require 'mysql2'

$db_client = Mysql2::Client.new(
  host: 'localhost',       # 全員、localhostでOKです
  username: 'root',        # ひとまず、権限を一番持っているrootユーザーにしました
  password: '　　　',   # 自身のmysqlのrootユーザーのパスワードをここに入力します
  database: 'study_record' # 全員、study_recordでOKです（自身のPCにstudy_recordのデータベースを作成してください）
)

# ユーザ情報をデータベースに保存するメソッドを定義
def save_user_to_database(username, password)

  #ユーザをデータベースに挿入（なくてもいいかも）
  puts "ユーザーデータをデータベースに挿入中です: #{username}, #{password}"

  # 'users'テーブルにユーザデータを挿入するSQLクエリを構築し実行（How_to_Signupで解説）
  insert_query = "INSERT INTO users (username, password) VALUES ('#{username}', '#{password}')"
  $db_client.query(insert_query)
end

# ポート3000でWEBrick HTTPサーバーを作成
server = WEBrick::HTTPServer.new(Port: 3000)

# 割り込みシグナル（例: Ctrl+C）を受け取ってサーバーをなめらかに？シャットダウンする（How_to_Signupで解説）
trap('INT') { server.shutdown }

# ERB（Embedded Ruby）ハンドラを使用してsignupページを提供
server.mount('/', WEBrick::HTTPServlet::ERBHandler, '../pages/signup.html')

# 'assets'ディレクトリから静的なアセット（例: CSS、画像）を提供
server.mount('/assets', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, '../assets'))

# '/signup'エンドポイントへのPOSTリクエストを処理
server.mount_proc('/signup') do |req, res|
  if req.request_method == 'POST'
    
    # リクエストボディからパラメータを解析
    params = WEBrick::HTTPUtils.parse_query(req.body)
    username = params['name']
    password = params['password']

    # save_user_to_databaseメソッドを呼び出してユーザデータをデータベースに挿入
    save_user_to_database(username, password)

    # サインアップの処理が成功したら'/diary-lsit'のURLにリダイレクト（今はページがないので、URLだけが変化するはず）
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/diary-list')
  else

    # リクエストメソッドがPOSTでない場合はエラーレスポンスを設定
    res.body = '無効なリクエストです'
  end
end

# WEBrick HTTPサーバーを起動
server.start
