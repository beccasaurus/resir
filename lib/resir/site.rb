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
    begin
      reply          = responder.new self
      reply.request  = Rack::Request.new env
      reply.response = Rack::Response.new
      reply.call env
    rescue Exception => ex
      [200, {'Content-Type' => 'text/html'}, ex.to_s]
    end
  end

  def site; self; end

  # REFACTOR ME!  the file finding in load helpers and filters is a great candidate for refactoring!
  def helpers *args, &block
    site = self # <-- give code in the main method of the block something to hold onto!
    unless args.empty?
      args.each do |arg|
        helper_to_find = arg.to_s
        found = nil
        path = self.helper_search_path.find { |path|
          File.file?( File.join( path, helper_to_find )) or File.file?( File.join( path, helper_to_find + '.rb' ))
        }
        if path
          if File.file?( File.join( path, helper_to_find ))
            filepath = File.join path, helper_to_find
          else
            filepath = File.join( path, helper_to_find + '.rb' )
          end
          responder.class_eval File.read(filepath)
        else
          puts "Helper not found: #{helper_to_find}"
        end
      end
    end
    
    unless block.nil?
      responder.class_eval &block
    end
  end

  # wow, refactor me!  ...
  def filters *args, &block
    unless args.empty?
      args.each do |arg|
        filter_to_find = arg.to_s
        found = nil
        path = self.filter_search_path.find { |path|
          File.file?( File.join( path, filter_to_find )) or File.file?( File.join( path, filter_to_find + '.rb' ))
        }
        if path
          if File.file?( File.join( path, filter_to_find ))
            filepath = File.join path, filter_to_find
          else
            filepath = File.join( path, filter_to_find + '.rb' )
          end
          @filter_maker.instance_eval File.read(filepath)
        else
          puts "Filter not found: #{filter_to_find}"
        end
      end
    end
    
    unless block.nil?
      @filter_maker.instance_eval &block
    end
  end

  # move this someplace ...
  #
  # it handles making filters from RC files, with a pretty syntax
  class FilterMaker
    attr_accessor :site # so you can get to the site from your filters {} block
    def initialize site
      @site = site
    end
    # filter?
    # filters?
    # helpers?
    def method_missing name, *args, &block
      @site.loaded_filters[name.to_s] = block
    end
  end

  # root_dir:: absolute or relative path to site's root directory  
  def initialize root_dir
    require 'resir/responder'
    @responder = Resir::Site::Responder.clone
    @filter_maker = FilterMaker.new self # required for pretty RC load_filter syntax

    init_variables
    init_filters

    self.root_directory      = root_dir
    self.real_root_directory = File.expand_path self.root_directory
    self.name                = File.basename self.root_directory

    init_search_paths
    load_siterc
  end

  def load_siterc
    siterc = File.join self.root_directory, Resir.site_rc_file
    begin
      eval File.read(siterc) if File.file?siterc
    rescue NameError => ex
      puts "got crazy NameError, trying to eval #{siterc} ... [#{ex}]"
    end
  end

  def init_search_paths
    self.helper_search_path = []
    self.helper_search_path << self.real_root_directory
    self.helper_search_path << File.join( self.real_root_directory, '.site' )
    self.helper_search_path += Resir::helper_search_path

    self.filter_search_path = []
    self.filter_search_path << self.real_root_directory
    self.filter_search_path << File.join( self.real_root_directory, '.site' )
    self.filter_search_path += Resir::filter_search_path
  end

  def init_filters
    # initially, filters was one of the sites' normal variables that
    # falls back to Resir, but filters need to live on their own.
    filter_hash = {}
    filter_hash.instance_eval {
      def []( key )
        unless keys.include?key
          Resir.loaded_filters[key] # we don't have it - ask Resir for it
        else
          super # self[key] # we seem to have this value - go ahead and return it
        end
      end
      def method_missing name, *args
        if name.to_s[/=$/] # trying to SET value
          name = name.to_s.sub( /=$/, '' )

          self[name] = args.first # nomatter what, if we're SETTING, we set it locally

        else # trying to GET value
          name = name.to_s

          unless keys.include?name
            Resir.loaded_filters[name] # we don't have it - ask Resir for it
          else
            self[name] # we seem to have this value - go ahead and return it
          end

        end
      end
    }
    self.loaded_filters = filter_hash
  end

  def init_variables
    # makes variables an empty hash and sets them up with method_missing
    # to fall back to Resir if it has something that the site doesn't
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
