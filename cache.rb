class Cache
  def self.file(url)
    File.join('.','cache', Digest::MD5.hexdigest(url))
  end

  def self.exists_for?(url) 
    File.exists?(file(url))
  end

  def self.store(data, cache_file)
    File.open(cache_file, 'w') {
      |f| f.write(data) 
    }
  end
end
