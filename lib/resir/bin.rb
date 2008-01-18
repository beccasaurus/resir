class Resir::Bin

  class << self
    attr_accessor :default_command
  end

  # main method for executing
  # eg.
  #     Resir::Bin ARGV
  def self.call command_line_arguments
    command = command_line_arguments.shift
    command = command.gsub('-','') # replace all dashes, to help catch -h / --help
    
    if command.nil?
      help
    elsif self.respond_to?command.to_sym
      self.send(command, *command_line_arguments)
    elsif @default_command
      self.send(@default_command, *( [command] + command_line_arguments ))
    else
      puts "not sure what to do.  please set_default :command"
    end
  end

  # helper to set/change the default command that resir calls 
  # when an command is not found that matches the first argument
  # eg.
  #   resir command some args
  #
  # resir some args # calls default command with 'some args'
  def self.set_default command
    @default_command = command.to_sym
  end
  set_default :create_or_serve

  # return the help for an command
  #
  # provide a method such as `mycommand_help` that returns a string
  # of documentation (conventionally starting with 'Usage: ...')
  def self.help_for command
    help_method = "#{command}_help".to_sym
    self.send( help_method ) if self.respond_to?help_method
  end

  # grab everything on a line ending with 'Summary:' and use it
  # as the command's summary (to display on `resir commands`)
  def self.summary_for command
    doco = help_for command
    if doco
      match = /Summary:\n*(.*)/.match doco
      if match and match.length > 1
        match[1].strip
      end
    end
  end

  # print out the help for the command provided
  #
  # prints resir_help if no command provided
  def self.help *command
    command = command.shift
    if command.nil?
      puts help_for( :resir )
    elsif (doco = help_for command)
      puts doco
    else
      puts "No documentation found for command: #{command}"
    end
  end

  # call a system command (returning the results) but puts the command before executing
  def self.system_command cmd
    puts cmd
    # `#{cmd}`
  end

  # default commands --------------------------------------------------------------------------

  def self.version *args
    puts Resir::VERSION::STRING
  end

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

  # short aliases (for -v [version] and -h [help])

  class << self
    alias h help
    alias v version
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
    <<doco

  resir == %{ Ridiculously Easy Site's In Ruby }
                        by remi                

    Usage:
      resir -h/--help
      resir -v/--version
      resir command [arguments...] [options...]

    Examples:
      resir ~/my_new_site       # create site
      resir ~/my_existing_site  # run site

    Further help:
      resir help commands       list all 'resir' commands
      resir help examples       show some examples of usage [NYI]
      resir help <COMMAND>      show help on COMMAND
                                  (e.g. 'resir help ...') [<-- add cmd]
    Further information:
      http://resir.rubyforge.org
doco
  end

  def self.help_help
    <<doco
Usage: resir help COMMAND

  Summary:
    Provide help on the 'resir' command
doco
  end

end
