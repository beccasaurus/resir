class Resir::Server

  attr_accessor :sites, :urls

  def self.default_paths( site )
    [ "http://#{site.safe_name}", "/#{site.safe_name}" ]
  end
  
  def initialize *dirs
    @sites = Resir::get_sites *dirs
    log.info { "server initialized with #{dirs.length} dirs [#{@sites.length} sites found]" }

    @urls = {}
    @sites.each do |site|
      site_paths = site.urls || Resir::Server::default_paths(site)
      site_paths.each do |path|
        @urls.merge! ({ path => site })
      end
    end

    @call_handler = Rack::URLMap.new @urls
  end

  def call *args
    @call_handler.call *args
  end

end
