require 'webrick'

server = WEBrick::HTTPServer.new(Port: 3000)

trap('INT') { server.shutdown }

# '/logout'エンドポイントへのGETリクエストを処理
server.mount_proc('/logout') do |req, res|
    # Cookieの削除（user_idを保持するCookieを削除）
    res.cookies << WEBrick::Cookie.new("user_id", "") # 空文字列で上書き スペ-ス
    # ログアウトが完了したらトップページにリダイレクト
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/top')
end