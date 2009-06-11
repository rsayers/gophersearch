require 'ferret'
require 'gopherclient'

include Ferret
 
$index = Index::Index.new(:path => '/home/rsayers/gindex')
$g=GopherClient.new
$indexed=[]

url = 'gopher://robsayers.com/1/'

def spider(url,indent=0)
  indexable_types=['0','H']
  restrict_hosts=['robsayers.com']
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
        puts '-'*indent + docurl
        
        spider(docurl,indent+1)
      end
      
      if type == "0"
        $index << {:title => desc, :url => docurl, :content => $g.getdoc(docurl)}
      end
     
    end
  end
end

#spider(url)  
terms = ARGV.join(' AND ').chomp

$index.search_each('content:('+terms+')') do |id, score|
  puts "Document #{id} - '#{$index[id][:title]}' found with a score of #{score}"

end
