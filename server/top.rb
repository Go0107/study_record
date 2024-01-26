# # top.rb

# require 'webrick'

# server = WEBrick::HTTPServer.new(Port: 3000)

# trap('INT') { server.shutdown }

# # ERBハンドラを使用してtopページを提供
# server.mount('/', WEBrick::HTTPServlet::ERBHandler, '../pages/top.html')

# server.mount('/signup.html', WEBrick::HTTPServlet::ERBHandler, '../pages/signup.html')

# server.mount('/login.html', WEBrick::HTTPServlet::ERBHandler, '../pages/login.html')

# # 'assets'ディレクトリから静的なアセットを提供
# server.mount('/assets', WEBrick::HTTPServlet::FileHandler, File.join(Dir.pwd, '../assets'))

# server.start
