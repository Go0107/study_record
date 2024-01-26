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

server.mount_proc '/top' do |req, res|
  res.content_type = 'text/html'
  
  html_file_path = '../pages/top.html'  # ファイルの実際のパスに変更してください
  html_content = File.read(html_file_path)
  
  res.body = html_content
end

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
      password: '0606araki',
      database: 'study_record'
    )
      
      # データベースからユーザーを検索 クエリをバインド変数を使用して構築
      stmt = client.prepare("SELECT * FROM users WHERE username = ? AND password = ?")
      result = stmt.execute(username, password) 

      if result.count == 1
          # ログイン成功時の処理
          res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/home')
      else
          # ログイン失敗時の処理
          res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top')
      end
  else
      res.status = 400
      res.body = 'Bad Request'
  end
end


server.mount_proc '/signup.html' do |req, res|
  res.content_type = 'text/html'
  
  html_file_path = '../pages/signup.html'  # ファイルの実際のパスに変更してください
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
      password: '0606araki',
      database: 'study_record',
      encoding: 'utf8' # 追加
    )

    # データベースに新しいユーザーを挿入
    stmt = client.prepare("INSERT INTO users (username, password) VALUES (?, ?)")
    stmt.execute(username, password)
    puts username


    # レスポンスの設定（新規登録成功時は適切なリダイレクトを行う）
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/home')
  else
    res.status = 400
    res.body = 'Bad Request'
  end
end

server.mount_proc '/home.html' do |req, res|
    res.content_type = 'text/html'    
    
  html_file_path = '../pages/home.html'  
  html_content = File.read(html_file_path)
  
  res.body = html_content
end    

server.mount_proc '/home' do |req, res|
  res.content_type = 'text/html'    
  
html_file_path = '../pages/home.html' 
html_content = File.read(html_file_path)

res.body = html_content
end

server.mount_proc '/diary_list.html' do |req, res|
  load 'diary_list.rb'
  res.content_type = 'text/html'    
  
  html_file_path = '../pages/diary_list.html'  # ファイルの実際のパスに変更してください
  html_content = File.read(html_file_path)
  
  res.body = html_content
end    

server.mount_proc '/new_diary.html' do |req, res|
    res.content_type = 'text/html'  
    
    html_file_path = '../pages/new_diary.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end  

server.mount_proc '/my_page.html' do |req, res|
    load 'my_page.rb'
    res.content_type = 'text/html'
    
    html_file_path = '../pages/my_page.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end

server.mount_proc '/before_header.html' do |req, res|
    res.content_type = 'text/html'
    
    html_file_path = '../header/before_header.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end

server.mount_proc '/after_header.html' do |req, res|
    res.content_type = 'text/html'
    
    html_file_path = '../header/after_header.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end

server.mount_proc '/delete_entry' do |req, res|
  # POSTリクエストからデータを取得
  data = JSON.parse(req.body)

  # リクエストから削除対象のエントリーIDを取得
  entry_id = data['entryId']

  # ここでデータベースなどからエントリーを削除する処理を実装
  client.query("DELETE FROM reports WHERE id = #{entry_id}")

  # 削除が成功した場合、成功を示すJSONを返す
  response_json = { success: true, message: 'エントリーを削除しました' }.to_json
  res.status = 200
  res.body = response_json
end

trap('INT') { server.shutdown }

server.start