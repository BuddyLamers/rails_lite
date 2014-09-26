require 'webrick'

server = WEBrick::HTTPServer.new(Port: 8080)

server.mount_proc('/') do |req, res|
  # res.content_type = text/text
  # res.body = req.path
  res.body = "Hello World"
end



trap('INT') do server.shutdown end

server.start