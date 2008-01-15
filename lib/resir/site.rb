class Resir::Site
  include IndifferentVariableHash

  # kill this:
  attr_accessor :path_prefix # set from script running if we want to remove a prefix from path

  attr_accessor :server

  def call env

    if env.has_key?'REQUEST_URI'
      env.PATH_INFO = env.REQUEST_URI
    elsif env.has_key?'PATH_INFO'
      env.REQUEST_URI = env.PATH_INFO
    end

    require 'resir/responder'

    responder          = Resir::Site::Responder.new self
    responder.request  = Rack::Request.new @env
    responder.response = Rack::Response.new

    responder.call env
  end

  def initialize root_dir
    @variables = {}

    self.variables.instance_eval {
      # don't set equal here, just return from Resir.vars if exists there
      def method_missing_with_fallback name, *args
        return method_missing_without_fallback(name, *args) if name.to_s[/=$/]

        super_result = method_missing_without_fallback name, *args
        return super_result if super_result and not super_result.nil?

        name = name.to_s.sub( /=$/, '')
        if Resir.variables.keys.include?name
          Resir.variables[name]
        else
          # can't seem to find anything, so return nil ( which is HELPFUL, so we can check for nil )
          nil
        end
      end
      # alias_method_chain :method_missing, :fallback
      alias method_missing_without_fallback method_missing
      alias method_missing method_missing_with_fallback
    }

    # note: trying to ||= self.vars here gets mighty angry!  see what's going on with that.
    self.root_directory = root_dir
    self.name = File.basename self.root_directory

    siterc = File.join self.root_directory, Resir.site_rc_file
    eval File.read(siterc) unless not File.file?siterc # because load can't get to our instance!
  end

  def render_page name, binding
    # define some neato methods ...
    #
    # need to clean up ... and needs to take the template root into account??
    #
    root = self.root_directory + '/'
    Dir["#{root}*"].collect { |o| o.sub(root,'') }.select { |o| not o.include?'.' }.
    select{|o| File.directory?"#{root}#{o}" }.each do |directory| 
      metaclass.send(:define_method, directory) { |name| render "#{directory}/#{name}" }
      if directory[/s$/]
        metaclass.send(:define_method, directory.sub(/s$/,'')) { |name| render "#{directory}/#{name}" }
      end
    end

    @site = self
    @layout = 'layout' # make into a Resir/Site variable ... override at global or site level
    @content = render_template name, binding
    layout_template = get_template(@layout) if @layout
    @content = render_template(layout_template, binding) if @layout and layout_template 
    @content
  end

  def render_template name, binding
    name = get_template(name) unless File.file?(File.join(template_rootpath, name))
    Resir::render_file template_realpath(name), binding
  end
  alias render render_template

  def get_template name
    return nil if name.nil? or name.empty?
    log.debug { "#{self.name} #get_template '#{name}'" }
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

  def safe_name       # safe for use in url
    self.name.gsub /[^a-zA-Z0-9_.-]/, ''
  end
  def safe_host_name  # safe for use as a host name (safe_name with _ => -)
    self.safe_name.gsub '_', '-'
  end

end
