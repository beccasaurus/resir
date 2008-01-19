class Resir::Snip::Server

  attr_accessor :source, :all_snips

  def initialize source
    @source = source

    # remote server - we read the yaml (snips / snipz) into snips
    if source[/^http/]

      source     = source.gsub /\/$/, '' # remove trailing slash, if there
      url, index = first_valid_response_from_urls *%w( snips/snipz snipz snips/snips snips ).collect { |url| "#{source}/#{url}" }
      if url and index
        @source = url.sub /\/snip[zs]$/, '' # hold onto the url so we know where to get the files - they should be in the same dir as the snips/z file
        index  = Resir::Snip::Server.decompress(index) if url[/z$/] # decompress if snipZ (ends with z, for zlib compression, like *.Z)
        require 'yaml'
        @all_snips = YAML::load( index )
      end

    # local server - we read the files into snips
    else
      if File.directory?source
        puts "directory: #{source}"
        snips = Dir[ File.join(source, '*.rb') ].select { |file| file[Resir::Snip.snip_file_regex] }
        @all_snips = snips.collect { |snip| Resir::Snip.new snip }.select { |snip| snip.header_vars.length > 0  }
      else
        @all_snips = []
      end
    end
  end

  def snips matcher=nil
    return self[matcher] if matcher

    current = {}
    @all_snips.each do |snip|
      unless current.keys.include?snip.name and current[snip.name].version.to_i > snip.version.to_i
        current[snip.name] = snip
      end
    end
    current.values
  end

  def all_snips snip_matcher=nil
    return @all_snips unless snip_matcher

    snip_matcher = snip_matcher.to_s if snip_matcher.is_a?Symbol
    if snip_matcher.is_a?Regexp
      @all_snips.select { |snip| snip.name[snip_matcher] }
    else
      @all_snips.select { |snip| snip.name == snip_matcher }
    end
  end

  def [] snip_matcher
    snip_matcher = snip_matcher.to_s if snip_matcher.is_a?Symbol
    if snip_matcher.is_a?Regexp
      snips.select { |snip| snip.name[snip_matcher] }
    else
      snips.select { |snip| snip.name == snip_matcher }.first # you expect to get snip when you say:  server.snip :sass
    end
  end

  def first_valid_response_from_urls *urls
    require 'open-uri'
    valid_url = nil
    response  = nil
    urls.find do |url| 
      begin
        response  = open(url).read
        valid_url = url
        true
      rescue OpenURI::HTTPError
        false
      end
    end
    return valid_url, response
  end

  def generate_index dir = @source
    if dir[/^http/] or not File.directory?dir
      raise "I don't know how to generate an index that saves to a remote server at this time - sorry!"
    end

    plain_path      = File.join dir, 'snips'
    compressed_path = File.join dir, 'snipz'

    plain      = plain_text_index
    compressed = self.compress plain

    File.open( plain_path,      'w' ){ |f| f << plain      }
    File.open( compressed_path, 'w' ){ |f| f << compressed }
  end

  def plain_text_index
    require 'yaml'
    @snips.to_yaml
  end

  def self.compress text
    require 'zlib'
    Zlib::Deflate.deflate text
  end

  def self.decompress text
    require 'zlib'
    Zlib::Inflate.inflate text
  end

end
