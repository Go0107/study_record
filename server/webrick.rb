require 'webrick'
require 'mysql2'

server = WEBrick::HTTPServer.new(
  :ServerName => "localhost",
  :charset    => "UTF-8",
  :Port => 3000,
  :MimeTypes => WEBrick::HTTPUtils::DefaultMimeTypes.merge({"js"=>"text/javascript"}),
  :DocumentRoot => '.',
  :DocumentRootOptions => { :FancyIndexing => true },
  :SSLEnable  => false,
  :SSLCertName  => [ [ 'CN', WEBrick::Utils::getservername ] ]
)


# 'assets'ディレクトリから静的なアセットを提供
server.mount('/assets', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, '../assets'))
server.mount('/js', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, '../js'))

# server.mount_proc '/' do |req, res| 
#   res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
# http://localhost:3000 にアクセスしたときにtopページを表示したかったけど他のページにも悪影響
# end

# server.mount_proc '/top' do |req, res|
#   res.content_type = 'text/html'
  
#   html_file_path = '../pages/top.html'  # ファイルの実際のパスに変更してください
#   html_content = File.read(html_file_path)
  
#   res.body = html_content
# end


# トップ画面
server.mount_proc '/top.html' do |req, res|
  res.content_type = 'text/html'
  
  html_file_path = '../pages/top.html'  # ファイルの実際のパスに変更してください
  html_content = File.read(html_file_path)
  
  res.body = html_content
end

server.mount_proc '/login.html' do |req, res|
  res.content_type = 'text/html'
  
  html_file_path = '../pages/login.html'  # ファイルの実際のパスに変更してください
  html_content = File.read(html_file_path)
  
  res.body = html_content
end 


# ログイン処理
server.mount_proc('/login') do |req, res| #form actionに対応
  if req.request_method == 'POST'
      # リクエストボディからパラメータを解析
      params = req.body.split('&').map { |pair| pair.split('=') }.to_h #むず処理
      username = params['username']
      password = params['password']
      
      # MySQL2に接続
    client = Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '　　　　',
      database: 'study_record'
    )
      
      # データベースからユーザーを検索 クエリをバインド変数を使用して構築
      stmt = client.prepare("SELECT * FROM users WHERE username = ? AND password = ?")
      result = stmt.execute(username, password) 

      if result.count == 1
          # ログイン成功時の処理
          user = result.first

          # CookieにユーザーIDを保存
          res.cookies << WEBrick::Cookie.new("user_id", user['user_id'].to_s)
          

          # 確認のためにputsを使用してコンソールに表示
          # puts "Cookie added: user_id=#{user['user_id'].to_s}" 

          res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/home.html')
      else
          # ログイン失敗時の処理
          res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
      end
  else
      res.status = 400
      res.body = 'Bad Request'
  end
end


# アカウント作成画面
server.mount_proc '/signup.html' do |req, res|
  res.content_type = 'text/html'
  
  html_file_path = '../pages/signup.html'
  html_content = File.read(html_file_path)
  
  res.body = html_content
end

server.mount_proc '/signup' do |req, res|
  if req.request_method == 'POST'
    params = req.body.split('&').map { |pair| pair.split('=') }.to_h #むず処理
    username = params['username']
    password = params['password']

    # MySQL2に接続
    client = Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '　　　　',
      database: 'study_record',
      encoding: 'utf8' # 追加
    )

    # データベースに新しいユーザーを挿入
    stmt = client.prepare("INSERT INTO users (username, password) VALUES (?, ?)")
    stmt.execute(username, password)

    # レスポンスの設定（新規登録成功時は適切なリダイレクトを行う）
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
  else
    res.status = 400
    res.body = 'Bad Request'
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
  end
end


# ログイン後のトップ画面
server.mount_proc '/home.html' do |req, res|
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
  if cookie_data && cookie_data.value != "" # && 以降はログアウト機能と対応　逆に書かない！
    user_id = cookie_data.value.to_i

    res.content_type = 'text/html'    

    html_file_path = '../pages/home.html' 
    html_content = File.read(html_file_path)

    res.body = html_content
  else
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
  end
end    

# server.mount_proc '/home' do |req, res|
#   cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
#   if cookie_data && cookie_data.value != "" # && 以降はログアウト機能と対応　逆に書かない！
#     user_id = cookie_data.value.to_i
    
#     res.content_type = 'text/html'    
    
#     html_file_path = '../pages/home.html' 
#     html_content = File.read(html_file_path)
    
#     res.body = html_content
#   else
#     res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
#   end
# end


# マイページ画面
server.mount_proc '/my_page.html' do |req, res|
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
  if cookie_data && cookie_data.value != "" # && 以降はログアウト機能と対応　逆に書かない！
    user_id = cookie_data.value.to_i

    res.content_type = 'text/html'    
      
    html_file_path = '../pages/my_page.html'  
    html_content = File.read(html_file_path)
    
    res.body = html_content
  else
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
  end
end


# 日報一覧画面
server.mount_proc '/diary_list.html' do |req, res|
  load 'diary_list.rb'
  res.content_type = 'text/html'    
  
  html_file_path = '../pages/diary_list.html'  # ファイルの実際のパスに変更してください
  html_content = File.read(html_file_path)
  
  res.body = html_content
end    


# 新規投稿画面
server.mount_proc '/new_diary.html' do |req, res|
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
  if cookie_data && cookie_data.value != ""
    # ログインしているユーザーのIDを取得
    user_id = cookie_data.value.to_i

    # MySQL接続情報
    client = Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '　　　',
      database: 'study_record'
    )

    # ユーザー名を取得
    username_query = "SELECT username FROM users WHERE user_id = #{user_id}"
    username_result = client.query(username_query)
    username = username_result.first['username']

    # ファイルの実際のパスに変更してください
    html_file_path = '../pages/new_diary.html'
    html_content = File.read(html_file_path)

    # ユーザー名を投稿者名のinput欄に挿入
    html_content.sub!('<input class="text" type="text" id="username" name="username">', "<input class=\"text\" type=\"text\" id=\"username\" name=\"username\" value=\"#{username}\" readonly>")

    res.content_type = 'text/html'
    res.body = html_content
  else
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
  end
end


# 新規投稿したデータをデータベースに保管する処理
server.mount_proc '/post_report' do |req, res|
  # cookiesからログインしているuser_idを取得
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }

  if cookie_data && cookie_data.value != ""
    # cookieデータから取り出したユーザーのIDを数値に変換
    user_id = cookie_data.value.to_i

    puts "user_id:#{user_id}"
    # MySQL接続情報
    client = Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '　　　　',
      database: 'study_record'
    )

    params = WEBrick::HTTPUtils.parse_query(req.body)
    puts "user_id:#{user_id}"

    # 入力データ
    date = params['date']
    puts date
    study_time = params['study_time']
    puts study_time
    study_content = params['study_content']
    puts study_content
    reflection = params['reflection']
    puts reflection
    created_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts created_at

    # 日付のフォーマットが正しいか確認
    begin
      Date.parse(date)
    rescue ArgumentError
      res.body = "エラーが発生しました: 無効な日付形式です。"
      next
    end
    # SQLクエリの作成と実行
    query = "INSERT INTO reports (user_id, date, study_time, study_content, reflection, created_at) VALUES (#{user_id}, '#{date}', #{study_time.to_i}, '#{study_content}', '#{reflection}', '#{created_at}')"
    puts query
    result = client.query(query)
    res.body = "データが正常に挿入されました。"     
    # データの挿入が成功したら、diary_list.html にリダイレクト
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/diary_list.html')
  else
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top.html')
  end
end


# ログイン前のヘッダー
server.mount_proc '/before_header.html' do |req, res|
    res.content_type = 'text/html'
    
    html_file_path = '../header/before_header.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end


# ログイン後のヘッダー
server.mount_proc '/after_header.html' do |req, res|
    res.content_type = 'text/html'
    
    html_file_path = '../header/after_header.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end


# 削除処理
server.mount_proc '/delete_request' do |req, res|
  # クエリパラメータからinfoListIdを取得
  info_list_id = req.query['id']
  # cookiesからログインしているuser_idを取得
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
  
  if cookie_data && cookie_data.value != ""
      # cookieデータから取り出したユーザーのIDを数値に変換
      user_id = cookie_data.value.to_i

      # データベースにアクセスするための記述で自分のデータベースに合わせて変えていく
      client = Mysql2::Client.new(
          host: "localhost", 
          username: "root", 
          password: '　　　　', 
          database: 'study_record',
      )

    # 対象の投稿記事のuser_idを取得
    result = client.query("SELECT user_id FROM reports WHERE report_id = #{info_list_id}").first
    if result.nil?
      # 該当する投稿記事が存在しない場合はエラーレスポンスを返す
      res.status = 404
      res.body = 'Not Found'
    elsif result['user_id'] != user_id
      # ログインしているユーザーのIDと投稿記事のユーザーIDが一致しない場合はエラーレスポンスを返す
      res.status = 403
      res.body = 'Forbidden'
    else
      # DELETE文を実行
      client.query("DELETE FROM reports WHERE report_id = #{info_list_id}")

      # 成功した場合は正常なレスポンスを返す
      res.status = 200
      res.body = 'Delete successful'
    end
  else
    # ログインしていない場合はエラーレスポンスを返す
    res.status = 401
    res.body = 'Unauthorized'
  end
end

# server.mount_proc '/diary-list' do |req, res|
#   # /diary_list パスへのリクエストがあった場合、new_diary.rbをロードする
#   load File.join(__dir__, 'new_diary.rb')
  
#   # new_diary.rb内の処理でデータベースへの挿入が行われるため、ここでは何もしない
#   res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/diary_list.html')
  
# end


# ログアウト処理
server.mount_proc '/logout' do |req, res|
  # ログアウトの処理が必要ならここに記述
  res.cookies << WEBrick::Cookie.new("user_id", "")

  # ダイアログ表示用のHTMLを送信
  res.content_type = 'text/html'
  res.body = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>ログアウト</title>
      <script>
        function confirmLogout() {
          var result = confirm("本当にログアウトしますか？?");
          if (result) {
            window.location.href = "/top.html";  // OKが押されたらリダイレクト
          } else {
            history.go(-1);
          }
        }
      </script>
    </head>
    <body onload="confirmLogout()">
    </body>
    </html>
  HTML
end

trap('INT') { server.shutdown }

server.start