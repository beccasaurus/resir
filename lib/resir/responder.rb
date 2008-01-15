class Resir::Site::Responder

  attr_accessor :site, :request, :response # try to keep it simple for now ... can get EVERYTHING from these (that i can think of)

  def initialize site
    @site = site
  end

  def call env

    # test instance variable for getting binding working
    @follow_me = "Hello, I am Here!  You've still got me!"
    puts "\n\n#{'-'*50}\n\n[ FIRST ] @follow_me = #{@follow_me}\n\n#{'-'*50}\n\n"

    # need to refactor like nobody's business!
    @env = env

    @path = env.PATH_INFO
    @path = @path.sub(self.site.path_prefix,'') unless self.site.path_prefix.nil? or self.site.path_prefix.empty?
    @path = @path.sub(/^\//,'').sub(/\/$/,'')

    @template = (@path.empty?) ? nil : self.site.get_template(@path)

    # go thru the urls that start with '/' and see if our current path matches one
    # in which case we should remove that prefix and try again
    if @template.nil? and not @path.nil? and not @path.empty?
      self.site.urls ||= Resir::Server::default_paths( self.site )
      self.site.urls.select{ |url| url[/^\//] }.each do |url|
        url = url.sub /^\//,''
        if @path.index(url) == 0
          @path = @path.sub url, ''
          @template = self.site.get_template @path
          break
        end
      end
    end

    # check for directory_index
    if @template.nil? and @path.empty?
      Resir.directory_index.find { |name| @template = self.site.get_template name }
    end

    unless @template
      @response.status = 404
      @response.body = "File Not Found: #{@path}"
    else
      puts "\n\n#{'-'*50}\n\n[ responder, before site#renderpage ] @follow_me = #{@follow_me}\n\n#{'-'*50}\n\n"
      @response.body = @site.render_page( @template, self )
    end

    @response.finish
  end

end
