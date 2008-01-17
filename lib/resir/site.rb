#
# Resir::Site represents a single website.
#
# Resir::Site instances are meant to be run by Resir::Server, 
# but they can hold their own.
#
# A Resir::Site can handle a Rack #call, just as Resir::Server can.
#
# The actual responses to #calls are handled by a Resir::Site::Responder
# that is created (and then discarded) for each #call to a site
#
class Resir::Site
  include IndifferentVariableHash

  attr_accessor :server, :responder

  def call env
    reply          = responder.new self
    reply.request  = Rack::Request.new env
    reply.response = Rack::Response.new
    reply.call env
  end

  def site; self; end
  def helpers *args, &block
    unless args.empty?
      puts "i would require these ... #{args.inspect}"
    end
    
    unless block.nil?
      responder.class_eval &block
    end
  end

  # root_dir:: absolute or relative path to site's root directory  
  def initialize root_dir
    require 'resir/responder'
    @responder = Resir::Site::Responder.clone

    # setup variables and set them up to fall back to Resir.variables
    # if not found (not for '=' methods, only when looking up the value)
    @variables = {}
    self.variables.instance_eval {
      def method_missing_with_fallback name, *args
        return method_missing_without_fallback(name, *args) if name.to_s[/=$/]

        super_result = method_missing_without_fallback name, *args
        return super_result if super_result and not super_result.nil?

        name = name.to_s.sub( /=$/, '')
        (Resir.variables.keys.include?name) ? Resir.variables[name] : nil
      end
      alias method_missing_without_fallback method_missing
      alias method_missing method_missing_with_fallback
    }

    self.root_directory = root_dir
    self.name           = File.basename self.root_directory

    siterc = File.join self.root_directory, Resir.site_rc_file
    eval File.read(siterc) unless not File.file?siterc
  end

  def get_template name
    return nil if name.nil? or name.empty?
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
