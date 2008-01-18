class Resir
  meta_include IndifferentVariableHash

  #class << self
  #  attr_accessor :filter_maker
  #end

  def self.init_logger
    eval( 'def log; Resir::logger; end', TOPLEVEL_BINDING )
  end

  def self.commands *args, &block
    require 'resir/bin'
    resir_bin = Resir::Bin

    unless args.empty?
      args.each do |command_to_find|
        found = nil
        path = Resir::command_search_path.find { |path| # <--- changed path
          File.file?( File.join( path, command_to_find )) or File.file?( File.join( path, command_to_find + '.rb' ))
        }
        if path
          if File.file?( File.join( path, command_to_find ))
            filepath = File.join path, command_to_find
          else
            filepath = File.join( path, command_to_find + '.rb' )
          end
          resir_bin.instance_eval File.read(filepath) ### <--- see the setting of resir_bin at the top of the method
        else
          puts "Command not found: #{command_to_find}"
        end
      end
    end
    
    unless block.nil?
      resir_bin.instance_eval &block
    end
  end

  # REFACTOR ME!  the file finding in load helpers and filters is a great candidate for refactoring!
  def self.helpers *args, &block
    require 'resir/site'
    require 'resir/responder'
    responder = Resir::Site::Responder

    unless args.empty?
      args.each do |helper_to_find|
        found = nil
        path = Resir::helper_search_path.find { |path| # <--- changed path
          File.file?( File.join( path, helper_to_find )) or File.file?( File.join( path, helper_to_find + '.rb' ))
        }
        if path
          if File.file?( File.join( path, helper_to_find ))
            filepath = File.join path, helper_to_find
          else
            filepath = File.join( path, helper_to_find + '.rb' )
          end
          responder.class_eval File.read(filepath) ### <--- see the setting of responder at the top of the method
        else
          puts "Helper not found: #{helper_to_find}"
        end
      end
    end
    
    unless block.nil?
      responder.class_eval &block
    end
  end

  # wow, refactor me!  ... # IDENTICAL to the one in site
  def self.filters *args, &block
    unless args.empty?
      args.each do |filter_to_find|
        found = nil
        path = Resir::filter_search_path.find { |path| # <--- changed path
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
  class GlobalFilterMaker
    def method_missing name, *args, &block
      Resir.loaded_filters[name.to_s] = block
    end
  end

  def self.load_resirrc
    resirrc = File.expand_path(Resir.user_rc_file)
    eval File.read(resirrc) if File.file?resirrc
  end

  def self.initialize
    @variables ||= {}
    load 'resir/config.rb'
    init_logger unless defined?log
    @filter_maker = GlobalFilterMaker.new
    load_resirrc
  end

  initialize

  def self.get_sites *dirs
    dirs.inject([]){ |all,dir| all + find_site_dirs(dir) }.uniq.collect{ |dir| Resir::Site.new(dir) }
  end
  def self.sites *dirs; get_sites *dirs; end

  def self.find_site_dirs in_this_directory
    Dir[ File.join( in_this_directory, '**', Resir.site_rc_file ) ].collect{|rc| File.dirname rc }  
  end

  def self.get_extensions filename
    self.initialize if Resir.loaded_filters == 0
    filename = File.basename filename
    extensions = filename.split('.')
    without_extensions = extensions.shift
    extensions.reverse
  end

  def self.render_with_filters string, binding, *filters
    rendered = string
    begin
      site = eval 'site', binding
    rescue NameError
      site = Resir if site.nil?
    end
    site = Resir unless site.is_a?Resir::Site
    filters = filters.collect { |name| site.loaded_filters[name] } unless filters.first.respond_to?:call
    filters.select{ |x| not x.nil? }.each { |callable| rendered = callable[rendered,binding] }
    rendered.strip
  end

  def self.render_file filename, binding=binding()
    raise "File not found to render: #{filename}" unless File.file?filename
    render_with_filters File.read(filename).strip, binding, *get_extensions(filename)
  end

  # wow, messy!  but it gets the job done!
  #
  # this puppy "simply" proxies to more specific render methods
  #
  # in a stronly typed language, this would be broken up into abunchof overloads
  #
  # ....... UPDATE this (and all other things that clal Resir.render) to make 
  #         binding optional and the LAST argument, not the second.
  #
  def self.render *args
    if args.first.is_a?String
      if args.length > 2                            # render 'str', *args
        string_to_render = args.shift
        binding = args.shift
        args = args.first if args.first.is_a?Array  # render 'str', ['erb','mkd']

        if args.first.respond_to?:call              # render 'str', filter1 [, filter2 ]
          render_with_filters string_to_render, binding, *args

        elsif args.first.is_a?String                # render 'str', 'erb' [, 'mkd' ]
          render_with_filters string_to_render, binding, *args

        else; raise "don't know how to render: #{args.inspect}"; end

      else
        file_to_render = args.shift                 # render '/my/file.mkd.erb'
        binding = args.shift
        if File.file?file_to_render
          render_file file_to_render, binding

        else; raise "don't know how to render: #{file_to_render}"; end

      end
    else; raise "don't know how to render: #{args.inspect}"; end
  end

end
