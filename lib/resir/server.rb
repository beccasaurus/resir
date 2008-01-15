class Resir::Server

  attr_accessor :sites, :urls, :site_index

  def self.default_paths( site )
    [ "http://#{site.safe_host_name}/", "/#{site.safe_name}" ]
  end
  
  def initialize *dirs

    @sites = Resir::get_sites *dirs
    @sites.each { |site| site.server = self }
    log.info { "server initialized with #{dirs.length} dirs [#{@sites.length} sites found]" }

    # enable / setup site_index ( you can set to nil to disable )
    self.site_index = default_site_index

    @urls = {}
    @sites.each do |site|
      site_paths = site.urls || Resir::Server::default_paths(site)
      site_paths.each do |path|
        @urls.merge!({ path => site })
      end
    end

    @call_handler = Rack::URLMap.new @urls
  end

  def default_site_index
    lambda { |env|
      
      if @urls.length > 0
        sites_available = '<h3>Sites Available</h3><ul>'
        # we only display relative '/path' style urls, atleast for now, because
        # host-based urls won't work on localhost without some system configuration
        @urls.select { |url,app| not url.include?'http' }.each do |url_app|
          url, app = url_app.first, url_app.last
          sites_available << %{\n\t<li><a href="#{url}">#{app.name}</a></li>}
        end
        sites_available << "\n</ul>"
      else
        site_available = '<h3>No Sites Available</h3>'
      end 

      [ 200, { 'Content-Type' => 'text/html' },  
        "<html><head><title>Site Index</title></head><body>#{sites_available}</body></html>" ]
    }
  end

  def call *args
    response = @call_handler.call *args
    
    if self.site_index and self.site_index.respond_to?:call
      # check for http://[unknown host like 'localhost']/ (to show site index)
      status = (response.is_a?Array) ? response.first.to_i : response.status

      if status == 404
      env    = args.first
        path   = (env.REQUEST_URI)     ? env.REQUEST_URI     : env.PATH_INFO
        # host = (env.HTTP_HOST)       ? env.HTTP_HOST       : env.SERVER_NAME
        
        if path == '/'
          return self.site_index.call(*args)
        end
      end
    end

    response
  end

end
