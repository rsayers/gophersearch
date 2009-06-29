require 'ferret'
require 'gopherclient'

include Ferret
 
$index = Index::Index.new(:path => '/home/rsayers/gindex')
$g=GopherClient.new
$indexed=[]

url = 'gopher://robsayers.com/1/'
q=[]
q << 'robsayers.com/1/'

def spider(q)
  indexable_types=['0','H']
  restrict_hosts=['robsayers.com']
  while q.size > 0
    p q;
    url = q.shift
    lines = $g.getdoc(url)
    if lines then
      lines.each_line do |l|
        linedata = l.split("\t")
        linetype=l[0]
        desc=linedata[0][1,linedata[0].length-1]
        host,type,path=[linedata[2],linetype,linedata[1]]
        docurl = "#{host}/#{type}#{path}"
        if type == "1" && restrict_hosts.include?(host) && !$indexed.include?(url) then
          $indexed << docurl
          puts docurl
          
          q.push(docurl)
        end
        
        if type == "0"
          puts "Indexing #{docurl}"
          $index << {:title => desc, :url => docurl, :host => host, :type => type, :path => path, :content => $g.getdoc(docurl)}
        end
        
      end
    end
  end
end

spider(q)  

