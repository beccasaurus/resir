class Resir::Site
  include IndifferentVariableHash

  def call env
    require 'rubygems'
    require 'rack'

    @env = env
    @request = Rack::Request.new @env
    @response = Rack::Response.new # http://rack.rubyforge.org/doc/classes/Rack/Response.html

    @path = @env.PATH_INFO.sub(/^\//,'').sub(/\/$/,'')
    unless @path.empty?
      @template = get_template @path
    else
      Resir.directory_index.find { |name| @template = get_template name }
    end

    unless @template
      @response.status = 404
      @response.body = "File Not Found: #{@path}"
    else
      @response.body = render_page @template
    end

    # @response['Content-Type'] = 'text/html'
    @response.finish
  end

  def initialize root_dir
    @variables = {}
    self.root_directory = root_dir
    initialize_variables
  end

  def initialize_variables
    # set default variables to all of the Resir.site_* variables
    Resir.keys.grep(/^site_/).each { |key| @variables[key.sub(/^site_/,'')] = Resir[key] }
    siterc = File.join self.root_directory, Resir.site_rc_file
    eval File.read(siterc) unless not File.file?siterc # because load can't get to our instance!
  end

  def render_page name
    @site = self
    @layout = 'layout' # make into a Resir/Site variable ... override at global or site level
    @content = render_template name
    layout_template = get_template(@layout) if @layout
    @content = render_template(layout_template) if @layout and layout_template 
    @content
  end

  def render_template name
    rendered = File.read template_realpath(name)
    Resir::get_extensions(name).each do |ext|
      rendered = Resir.extensions[ext].call(rendered,binding) if Resir.extensions.include?ext and Resir.extensions[ext].respond_to?:call
    end
    rendered.strip
  end

  def get_template name
    looking_for = File.join template_rootpath, name 
    return template_basename(looking_for) if File.file?looking_for
    template_basename Dir["#{looking_for}.*"].sort.select{ |match| File.file?match }.first
  end
  def template_rootpath
    File.join( self.root_directory, self.template_directory ).sub /\/$/,''
  end
  def template_basename name
    return name if name.nil? or name.empty?
    name.sub "#{template_rootpath}/", ''
  end
  def template_realpath name
    "#{template_rootpath}/#{name}"
  end

end
