class Resir::Site::Responder

  attr_accessor :site, :request, :response

  def initialize site
    @site = site
  end

  def call env
    # need to refactor like nobody's business!

    @path = env.PATH_INFO
    @path = @path.sub(self.site.path_prefix,'') unless self.site.path_prefix.nil? or 
      self.site.path_prefix.empty?
    @path = @path.sub(/^\//,'').sub(/\/$/,'')

    @template = (@path.empty?) ? nil : @site.get_template(@path)

    # go thru the urls that start with '/' and see if our current path matches one
    # in which case we should remove that prefix and try again
    if @template.nil? and not @path.nil? and not @path.empty?
      self.site.urls ||= Resir::Server::default_paths( self.site )
      self.site.urls.select{ |url| url[/^\//] }.each do |url|
        url = url.sub /^\//,''
        if @path.index(url) == 0
          @path = @path.sub url, ''
          @template = @site.get_template @path
          break
        end
      end
    end

    # check for directory_index
    if @template.nil? and @path.empty?
      Resir.directory_index.find { |name| @template = @site.get_template name }
    end

    unless @template
      @response.status = 404
      @response.body = "File Not Found: #{@path}"
    else
      @response.body = render_page @template
    end

    @response.finish
  end

  def render_page name
    # define some neato methods ...
    #
    # need to clean up ... and needs to take the template root into account??
    #
    root = @site.root_directory + '/'
    Dir["#{root}*"].collect { |o| o.sub(root,'') }.select { |o| not o.include?'.' }.
    select{|o| File.directory?"#{root}#{o}" }.each do |directory| 
      metaclass.send(:define_method, directory) { |name| render "#{directory}/#{name}" }
      if directory[/s$/]
        metaclass.send(:define_method, directory.sub(/s$/,'')) { |name| render "#{directory}/#{name}" }
      end
    end

    @responder      = self     # required by markaby (so far as i can tell)
    @layout         = 'layout' # make into a Resir/Site variable ... override at global or site level
    @content        = render_template name
    layout_template = @site.get_template(@layout) if @layout
    @content        = render_template layout_template if @layout and layout_template 
    @content
  end

  def render_template name
    name = @site.get_template(name) unless File.file?(File.join(@site.template_rootpath, name))
    Resir::render_file( @site.template_realpath(name), binding() ) 
  end
  alias render render_template

end
