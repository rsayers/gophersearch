class GopherClient
  def parseurl(url)
    opts=url.sub('gopher://','').split('/') # split the url by slashes
    host=opts.shift # the first element will be our host
    type=opts.shift # type is second
    if !@types.has_key?(type) then # check to see if a type was provided
      opts.unshift(type) # if not, then its part of the path, put it back
      puts "No type given, assuming 1" # tell them the error of their ways
      type="1" # and assume its a directory
    end
    path = opts.first.nil? ? '/' :  opts.join('/') # if no path is provided, we go to the root
    [host,type,path] # return it!
  end

  def getdoc(url)
    host,type,path=parseurl(url)
    begin
      # getaddrinfo fails immediately,  saving us from waiting for the socket connect to timeout
      Socket.getaddrinfo(host,70)
      t = TCPSocket.new(host,70)
      t.puts path
      t.read
    rescue
      STDERR.puts "Error connecting to "+host
      return false
    end
  end
  
  def initialize
    require 'socket'
    @types ={
      "0"=>"TXT",
      "1"=>"DIR",
      "2"=>"CSO",
      "3"=>"ERR",
      "4"=>"HEX",
      "5"=>"ARC",
      "6"=>"UUE",
      "7"=>"QUE",
      "8"=>"TEL",
      "9"=>"BIN",
      "g"=>"GFX",
      "h"=>"HTM",
      "s"=>"AUD"
    }
  end
end
