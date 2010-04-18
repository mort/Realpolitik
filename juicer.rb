class Juicer
  
  def initialize(feed_url)
    @alchemyObj = AlchemyAPI.new();
    
    @feed_url = feed_url
    @api_key = @alchemyObj.loadAPIKey("api_key.txt");
  end
  
  def squeeze!
    feed = Feedzirra::Feed.fetch_and_parse(@feed_url)
    
    feed.entries.each do |e|
      url = e.url
      puts url
      puts e.inspect
      
      s = Story.create(:title => e.title, :url => e.url, :summary => e.summary, :content => e.content, :published_at => e.published)
      
      unless Cache::exists_for?(url)
        data = @alchemyObj.URLGetRankedNamedEntities(url)
        entities = entitify!(data, s)
        
        unless entities.blank?
          entities.each { |e| s.entities << e }
        end
        
        Cache::store(data, Cache::file(url))
        puts data
      else 
        puts '.. cached. Skipping.'
      end
    end
    
  end
  
  private
  
  def entitify!(data, story)
    r = Crack::XML.parse(data)
    puts r.inspect
    puts '--'
    entities = []
    return if r['results']['entities'].nil?
    r['results']['entities']['entity'].each do |ent|
      puts ent
      e = Entity.find_or_create_by_text_and_kind(ent['text'],ent['type'])
      e.relevance = ent['relevance']
      e.count = ent['count']
      entities << e
    end
    
    entities
  end
  

end