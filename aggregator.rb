require 'rp'

['http://www.elpais.com/rss/feed.html?feedId=1002', 'http://estaticos.elmundo.es/elmundo/rss/espana.xml'].each do |f|
  feed = Juicer.new(f)
  feed.squeeze!
end





