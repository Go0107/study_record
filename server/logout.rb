require 'webrick'

server = WEBrick::HTTPServer.new(Port: 3000)

trap('INT') { server.shutdown }

# '/logout'エンドポイントへのGETリクエストを処理
server.mount_proc('/logout') do |req, res|
    # ログアウトの処理を実行（セッションのクリアなど）
    cookies.push(WEBrick::Cookie.new('user_id', '') { |c| c.expires = Time.now - 3600 })
    # ログアウトが完了したらトップページにリダイレクト
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top')
end