require 'webrick'
require 'json'

server = WEBrick::HTTPServer.new(
  :ServerName => "localhost",
  :Port => 3000,
  :MimeTypes => WEBrick::HTTPUtils::DefaultMimeTypes.merge({"js"=>"text/javascript"}),
  :DocumentRoot => '.',
  :DocumentRootOptions => { :FancyIndexing => true },
  :SSLEnable  => false,
  :SSLCertName  => [ [ 'CN', WEBrick::Utils::getservername ] ]
)

# ... 既存のマウント処理 ...

server.mount_proc '/delete_entry' do |req, res|
  # POSTリクエストからデータを取得
  data = JSON.parse(req.body)

  # リクエストから削除対象のエントリーIDを取得
  entry_id = data['entryId']

  # ここでデータベースなどからエントリーを削除する処理を実装
  # 例えば、データベースの 'reports' テーブルから該当のエントリーを削除する
  # この部分は実際のデータベースの構造に合わせて変更が必要
  # 以下はあくまで例示です
  client.query("DELETE FROM reports WHERE id = #{entry_id}")

  # 削除が成功した場合、成功を示すJSONを返す
  response_json = { success: true, message: 'エントリーを削除しました' }.to_json
  res.status = 200
  res.body = response_json
end

# ... 既存のトラップ処理 ...

server.start
