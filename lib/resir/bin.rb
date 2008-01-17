class Resir::Bin

  class << self
    attr_accessor :default_action
  end

  def self.call command_line_arguments
    action = command_line_arguments.shift
    
    if action.nil?
      help
    elsif self.respond_to?action.to_sym
      self.send(action, *command_line_arguments)
    elsif @default_action
      self.send(@default_action, *( [action] + command_line_arguments ))
    else
      puts "not sure what to do.  please set_default :action"
    end
  end

  def self.set_default action
    @default_action = action.to_sym
  end
  set_default :create_or_serve

  def self.help_for action
    help_method = "#{action}_help".to_sym
    self.send( help_method ) if self.respond_to?help_method
  end

  def self.help *action
    action = action.shift
    if action.nil?
      puts help_for( :resir )
    elsif (doco = help_for action)
      puts doco
    else
      puts "No documentation found for action: #{action}"
    end
  end

  # call a system command (returning the results) but puts the command before executing
  def self.system_command cmd
    puts cmd
    # `#{cmd}`
  end

  # default actions

  def self.create_or_serve *dirs
    if dirs.length == 1 and not File.exist?File.expand_path(dirs.first) # resir ~/myapps/my_app
      path = File.expand_path(dirs.first)
      puts "Creating new site: #{path}\n\n"
      system_command "mkdir '#{path}'"
      system_command "touch '#{File.join( path, Resir::site_rc_file )}'"

    else

      server = Resir::Server.new *dirs
      unless server.sites.empty?
        get_rack_handler.run server
      else
        puts "\nNo sites found.\n"
        print_help :create_or_serve
      end

    end
  end

  # helper methods

  def self.get_rack_handler
    if lib_available? 'thin'
      Rack::Handler::Thin
    elsif lib_available? 'mongrel'
      Rack::Handler::Mongrel
    elsif lib_available? 'webrick'
      Rack::Handler::Webrick
    end
  end

  # help / usage docs

  def self.resir_help
    "default documentation for resir here!"
  end

end
