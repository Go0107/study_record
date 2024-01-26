require 'webrick'

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

server.mount_proc '/signup.html' do |req, res|
  res.content_type = 'text/html'
  
  html_file_path = '../pages/signup.html'  # ファイルの実際のパスに変更してください
  html_content = File.read(html_file_path)
  
  res.body = html_content
end

server.mount_proc '/home.html' do |req, res|
    res.content_type = 'text/html'    
    
  html_file_path = '../pages/home.html'  # ファイルの実際のパスに変更してください
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
    load 'new_diary.rb'   # load処理だと、webrickが上手く読み込めていない可能性もあるらしい…
    res.content_type = 'text/html'  
    
    html_file_path = '../pages/new_diary.html'  # ファイルの実際のパスに変更してください
    html_content = File.read(html_file_path)
    
    res.body = html_content
end  


# new_diary.rb内に書いてあった処理をこちらに記述
server.mount_proc '/post_report' do |req, res|

  # MySQL接続情報
  client = Mysql2::Client.new(
    host: 'localhost',    # データベースのホスト名
    username: 'root',     # データベースのユーザー名
    password: '', # データベースのパスワード
    database: 'study_record' # データベース名
  )

  params = WEBrick::HTTPUtils.parse_query(req.body)

  puts params

  # 入力データ
  date = params['date']
  username = params['username']
  study_time = params['study_time']
  study_content = params['study_content']
  reflection = params['reflection']
  created_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  # 日付のフォーマットが正しいか確認
  begin
    Date.parse(date)
  rescue ArgumentError
    res.body = "エラーが発生しました: 無効な日付形式です。"
    next
  end

  # SQLクエリの作成と実行
  query = "INSERT INTO reports (user_id, date, study_time, study_content, reflection, created_at) VALUES (1, '#{date}', #{study_time.to_i}, '#{study_content}', '#{reflection}', '#{created_at}')"
  
  begin
    result = client.query(query)
    res.body = "データが正常に挿入されました。"
  rescue => e
    res.body = "エラーが発生しました: #{e.message}"
  end
  # この処理を実行後に、diary_list.htmlに飛ぶ
  res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/diary_list.html')
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

server.mount_proc '/delete_request' do |req, res|
  # クエリパラメータからinfoListIdを取得
  info_list_id = req.query['id']

  # mysql2というライブラリを使用してMySQLに接続するための記述
  require'mysql2'

  # データベースにアクセスするための記述で自分のデータベースに合わせて変えていく
  client = Mysql2::Client.new(
      host: "localhost", 
      username: "root", 
      password: '@ZSExdr123', 
      database: 'study_record',
      port: '3000'
  )
  client.query("DELETE FROM reports WHERE report_id = #{info_list_id}")

end

server.mount_proc '/diary-list' do |req, res|
  # /diary_list パスへのリクエストがあった場合、new_diary.rbをロードする
  load File.join(__dir__, 'new_diary.rb')
  
  # new_diary.rb内の処理でデータベースへの挿入が行われるため、ここでは何もしない
  res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/diary_list.html')
  
end

trap('INT') { server.shutdown }

server.start