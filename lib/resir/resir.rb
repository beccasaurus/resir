class Resir
  meta_include IndifferentVariableHash

  def self.init_logger
    eval( 'def log; Resir::logger; end', TOPLEVEL_BINDING )
  end

  def self.initialize
    @variables ||= {}
    load 'resir/config.rb'
    init_logger unless defined?log
    load File.expand_path(Resir.user_rc_file) if File.file?File.expand_path(Resir.user_rc_file)
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
    self.initialize if Resir.filters == 0
    filename = File.basename filename
    extensions = filename.split('.')
    without_extensions = extensions.shift
    extensions.reverse
  end

  def self.render_with_filters string, binding, *filters
    rendered = string
    filters = filters.collect { |name| Resir.filters[name] } unless filters.first.respond_to?:call
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
