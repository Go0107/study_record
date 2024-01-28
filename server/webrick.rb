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
        password: '　　　　　',
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
      password: '　　　　　',
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

    # データベース接続
    client = Mysql2::Client.new(
      host: "localhost", 
      username: "root", 
      password: '　　　　　', 
      database: 'study_record',
    )

    # my_page.htmlの中身を一時的に保持する変数
    test = File.read('../pages/my_page.html')

    # reportsテーブルからuser_idに一致するデータを取得
    result = client.query("SELECT * FROM reports WHERE user_id = #{user_id} ORDER BY created_at DESC")

    date = result.map { |row| row['date'] }
    study_time = result.map { |row| row['study_time'] }
    created_time = result.map { |row| row['created_at'] }
    study_content = result.map { |row| row['study_content'] }
    reflection = result.map { |row| row['reflection'] }
    report_id = result.map { |row| row['report_id'] }
    username = 

    # 名前の数から繰り返し処理を何回行うかを決める
    data_count = report_id.length 
    num = 0

    # result_htmlに入っているHTML要素を初期化
    result_html = ""

    while num < data_count do
      result.each do |row|
        html_template = ERB.new('
            <div class="info-list" id="<%= row["report_id"] %>">
                <div class="top-items">
                    <ul class="left-item">
                        <li><h4>日付<br><%= row["date"] %></h4></li>
                        <li><h4>学習時間<br><%= row["study_time"] %></h4></li>
                        <li><h6>投稿日時:<%= row["created_at"] %></h6></li>
                    </ul>
                    <ul class="right-item">
                        <h3>学習内容<h3>
                        <li><h5><%= row["study_content"] %></h5></li>
                    </ul>
                </div>
                <div class="bottom-items">
                    <div class="text-content">
                        <h3>振り返り</h3>
                        <p><%= row["reflection"] %></p>
                    </div>
                    <div class="buttons">
                        <input class="styled edit" type="button" value="編集" id="edit">
                        <input class="styled" type="button" value="削除" id="delete">
                    </div>
                </div>
            </div>
        ')
        result_html += html_template.result(binding)
      end

        num += 1
    end


    # すでに入っているhtmlを初期化する
    test.sub!(/<main>.*?<\/main>/m, '<main><h1 class="title">マイページ</h1></main>')

    # 既存のHTMLに新しいHTMLコードを挿入
    modified_html = test.gsub(/<\/main>/, "#{result_html}</main>")

    # 変更を適用した新しいHTMLを保存
    File.open('../pages/my_page.html', 'w') do |file|
      file.puts modified_html
      
    end
    
    puts 'HTMLを作成しました'
    res.content_type = 'text/html'
    html_file_path = '../pages/my_page.html'  
    html_content = File.read(html_file_path)
    res.body = html_content
  else
    res.status = 400
    res.body = 'Bad Request'
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


# 「編集」が押されたときの処理
server.mount_proc '/get_edit_report' do |req, res|
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
  if cookie_data && cookie_data.value != ""
      # ログインしているユーザーのIDを取得
      user_id = cookie_data.value.to_i

      # クエリパラメータからreport_idを取得
      report_id_to_edit = req.query['report_id']&.to_i

      if report_id_to_edit

          # MySQL接続情報
          client = Mysql2::Client.new(
            host: 'localhost',
            username: 'root',
            password: '　　　　　',
            database: 'study_record'
          )

          # 編集ボタンが属している記事のreport_idに対応するデータを取得
          begin
            result = client.query("SELECT * FROM reports WHERE report_id = #{report_id_to_edit} AND user_id = #{user_id}")

            # 取得したデータを適切に処理する（ここでは単に最初の行を取得している）
            report_data = result.first

            # データが存在する場合
            if report_data
                # 編集ページにリダイレクトするJavaScriptをレスポンスに追加
                res.body = <<-HTML
                  <script>
                    window.location.href = 'http://localhost:3000/edit_diary.html?report_id=#{report_id_to_edit}';
                  </script>
                HTML
            else
                # データが存在しない場合の処理を追加（例えばエラーページを表示するなど）
                res.status = 404
                res.body = 'Report not found.'
            end
          rescue => e
            puts "Error: #{e.message}"
            puts e.backtrace
            res.status = 500
            res.body = 'Internal Server Error.'
          ensure
            # 必ずクライアントをクローズする
            client.close if client
          end
    else
          # report_idが指定されていない場合の処理を追加
          res.status = 400
          res.body = 'Bad Request. report_id is required.'
    end
  else
    # ログインしていない場合の処理を追加（例えばログインページにリダイレクトするなど）
    res.status = 401
    res.body = 'Unauthorized.'
  end
end


# 日報編集画面
server.mount_proc '/edit_diary.html' do |req, res|
  res.content_type = 'text/html'

  # クエリパラメータからreport_idを取得
  @report_id_to_edit = req.query['report_id']&.to_i

  # puts "report_id:#{report_id_to_edit}"

  # MySQL接続情報
  client = Mysql2::Client.new(
    host: 'localhost',
    username: 'root',
    password: '　　　　　',
    database: 'study_record'
  )

  # 編集ボタンが属している記事のreport_idに対応するデータを取得
  result = client.query("SELECT * FROM reports WHERE report_id = #{@report_id_to_edit}")
  row = result.first

   # ユーザー名を取得
   user_id = row['user_id'] 
   username_query = "SELECT username FROM users WHERE user_id = #{user_id}"
   username_result = client.query(username_query)
   username = username_result.first['username']

  # HTML形式でクライアントに返す
  html_response = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <link rel="stylesheet" href="../assets/css/new_diary.css">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Study Record.</title>
  </head>
  <body>
    <div id="header"></div>
    <div class="new-diary-wrapper">
    <div class="container">
      <div class="title">
        <h1>日報を編集する</h1>
      </div>
      <div class="form-wrapper">
        <form action="/post_edit_report" method="post" id="post_diary">
          <div>
            <label class="item-name date" for="name">日にち</label>
            <input class="text" type="date" id="today" name="date" value="#{row['date']}">
          </div>
          <div>
            <label class="item-name" for="username">投稿者名</label>
            <input class="text" type="text" id="username" name="username" value="#{username}" readonly>
          </div>
          <div>
            <label class="item-name" for="study_time">学習時間</label>
            <select name="study_time">
              <option value="0">0</option>
              <option value="1">1</option>
              <option value="2">2</option>
              <option value="3">3</option>
              <option value="4">4</option>
              <option value="5">5</option>
              <option value="6">6</option>
              <option value="7">7</option>
              <option value="8">8</option>
              <option value="9">9</option>
              <option value="10">10</option>
              <option value="11">11</option>
              <option value="12">12</option>
              <option value="13">13</option>
              <option value="14">14</option>
              <option value="15">15</option>
              <option value="16">16</option>
              <option value="17">17</option>
              <option value="18">18</option>
              <option value="19">19</option>
              <option value="20">20</option>
              <option value="21">21</option>
              <option value="22">22</option>
              <option value="23">23</option>
              <option value="24">24</option>
            </select>
            <label class="hours-entity" for="">時間</label>
          </div>
          <div class="textarea-wrapper">
            <label class="item-name textarea_name" for="study_content">学習内容</label>
            <textarea class="text" type="text" id="study-content" name="study_content" maxlength="100" placeholder="100字以内で記述してください">#{row['study_content']}</textarea>
          </div>
          <div class="textarea-wrapper">
            <label class="item-name textarea_name" for="reflection">振り返り</label>
            <textarea class="text" type="text" id="reflection" name="reflection" maxlength="500" placeholder="500字以内で記述してください">#{row['reflection']}</textarea>
          </div>
        </form>
      </div>
      <input class="submit" type="submit" value="投稿する" form="post_diary">
    </div>
    </div>
</body>
</html>
  HTML
  puts "row: #{row.inspect}" # 追加
  puts "row['date']: #{row['date']}" # 追
  res.body = html_response
end


# 編集画面で「投稿する」が押されたときの処理
server.mount_proc '/post_edit_report' do |req, res|
  puts "aaaaa"
  cookie_data = req.cookies.find { |cookie| cookie.name == 'user_id' }
  
  if cookie_data && cookie_data.value != ""
      # ログインしているユーザーのIDを取得
      user_id = cookie_data.value.to_i

      puts "user_id: #{user_id}"
      puts "report_id_to_edit (before conversion): #{req.query['report_id']}"
     
      puts "report_id_to_edit (after conversion): #{@report_id_to_edit}"

      # MySQL接続情報
      client = Mysql2::Client.new(
        host: 'localhost',
        username: 'root',
        password: '　　　　　',
        database: 'study_record'
      )

      params = WEBrick::HTTPUtils.parse_query(req.body)

      # ユーザー名を取得
      username_query = "SELECT username FROM users WHERE user_id = #{user_id}"
      username_result = client.query(username_query)
      username = username_result.first['username']

      # 入力データ
      date = params['date']
      study_time = params['study_time']
      study_content = params['study_content']
      reflection = params['reflection']

      # SQLクエリの作成と実行
      update_query = <<~SQL
      UPDATE reports
      SET
        date = '#{date}',
        study_time = #{study_time},
        study_content = '#{study_content}',
        reflection = '#{reflection}'
      WHERE
        report_id = #{@report_id_to_edit} AND user_id = #{user_id}
      SQL

      puts "update_query: #{update_query}"

      client.query(update_query)
      client.close

      # データの更新が成功したら、diary_list.html にリダイレクト
      res.status = 302
      res['Location'] = '/diary_list.html'
    else
      # ログインしていない場合、edit_diary.html にリダイレクト
      res.status = 302
      res['Location'] = '/top.html'
    end
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
      password: '　　　　　',
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
      password: '　　　　　',
      database: 'study_record'
    )

    params = WEBrick::HTTPUtils.parse_query(req.body)
    puts "user_id:#{user_id}"

    # 入力データ
    date = params['date']
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
      password: '　　　　　', 
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

# もし他にもサーバー関連の処理があれば、ここに追加する

# サーバーを起動する
# server.start


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