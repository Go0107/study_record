require 'mysql12' # MySQLデータベースと接続
require 'bcrypt'  # パスワードのハッシュ化

class User
    attr_accessor :user_id, :username, :password_hash
    
    # ユーザーオブジェクトの初期化
    def initialize(username, password)
        @username = username
        @password_hash = BCrypt::Password.create(password) #passのハッシュ化
    end

    # ユーザー情報をデータベースに保存
    def save
        client.query("INSERT INTO users (username, password_hash) VALUES ('#{@username}', '#{@password_hash}')")
    end

    #ユーザー名を元にデータベースからユーザー情報を取得
    def self.find_by_username(username)
        result = client.query("SELECT * FROM users WHERE username = '#{username}'")
        # クエリの結果から最初の行を取得
        row = result.first
        # もしクエリの結果がない場合（ユーザー名に一致するユーザーが見つからない場合）、nilを返す
        return nil unless row

        # データベースから取得した行の情報を使って新しい User オブジェクトを作成
        user = User.new(row['username'], row['pawwword_hash'])
        # User オブジェクトにデータベースから取得したユーザーIDを設定
        user.user_id = row['user_id']
    end

    # 作成した User オブジェクトを返す
    user
end
