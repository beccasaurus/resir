class Resir
  meta_include IndifferentVariableHash

  # mini-class for handling Resir.filter_and_extension 
  # or Resir.extension_and_filter
  class FilterAndExtension
    def method_missing name, *a
      if name.to_s[/=$/]
        name = name.to_s.sub(/=$/, '')
        Resir.filters[name] = a.first
        Resir.extensions[name] = lambda { |text,binding| Resir.filters[name][text,binding] }
      else
        super
      end
    end
  end
  class << self
    attr_accessor :filter_and_extension
  end
  # alias extension_and_filter filter_and_extension

  def self.initialize
    @variables ||= {}
    load 'resir/config.rb'
    self.filter_and_extension = FilterAndExtension.new

    resirrc = File.expand_path '~/.resirrc'
    load resirrc if File.file?resirrc
  end
  initialize

  def self.get_sites *dirs
    dirs.inject([]){ |all,dir| all + find_site_dirs(dir) }.uniq.collect{ |dir| Resir::Site.new(dir) }
  end
  def self.sites *dirs; get_sites *dirs; end

  def self.find_site_dirs in_this_directory
    Dir[ File.join( in_this_directory, '**', Resir.rc_file ) ].collect{|rc| File.dirname rc }  
  end

  def self.get_extensions filename
    # trick to make sure we get some extensions, if missing them ... try to move this latter ...
    self.initialize if Resir.extensions.length == 0
    filename = File.basename filename
    ( filename.split('.') - [ filename[/(\w+)/] ] ).reverse
  end

  def self.render_with_filters string, binding, *filters
    rendered = string
    filters.each { |callable| rendered = callable[rendered,binding] }
    rendered
  end
  def self.render_with_extensions string, binding, *extensions
    rendered = string
    extensions.each do |ext|
      rendered = Resir.extensions[ext][rendered,binding] if Resir.extensions.include?ext
    end
    rendered
  end
  def self.render_file filename, binding=binding()
    raise "File not found to render: #{filename}" unless File.file?filename
    render_with_extensions File.read(filename).strip, binding, *get_extensions(filename)
  end

  # wow, messy!  but it gets the job done!
  #
  # this puppy "simply" proxies to more specific render methods
  #
  # in a stronly typed language, this would be broken up into abunchof overloads
  def self.render *args
    if args.first.is_a?String
      if args.length > 2                            # render 'str', *args
        string_to_render = args.shift
        binding = args.shift
        args = args.first if args.first.is_a?Array  # render 'str', ['erb','mkd']

        if args.first.respond_to?:call              # render 'str', filter1 [, filter2 ]
          render_with_filters string_to_render, binding, *args

        elsif args.first.is_a?String                # render 'str', 'erb' [, 'mkd' ]
          render_with_extensions string_to_render, binding, *args

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
