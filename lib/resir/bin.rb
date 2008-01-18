class Resir::Bin

  class << self
    attr_accessor :default_command
  end

  # main method for executing
  # eg.
  #     Resir::Bin ARGV
  def self.call command_line_arguments
    command = command_line_arguments.shift
    command = command.gsub('-','') unless command.nil? # replace all dashes, to help catch -h / --help
    
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

  # 
  # SETS DEFAULT COMMAND
  #
  set_default :create_or_preview

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
    `#{cmd}`
  end

  # default commands --------------------------------------------------------------------------

  def self.version *no_args
    puts Resir::VERSION::STRING
  end

  def self.create dir
    path = File.expand_path dir
    unless File.exist? path
      puts "Creating new site: #{path}\n\n"
      system_command "mkdir '#{path}'"
      system_command "touch '#{File.join( path, Resir::site_rc_file )}'"
    else
      "File already exists: #{path}"
    end
  end

  def self.serve *dirs
    server = Resir::Server.new *dirs
    unless server.sites.empty?
      get_rack_handler.run server
    else
      puts "\nNo sites found.\n"
      print_help :create_or_serve
    end
  end

  def self.create_or_serve *dirs
    # if we pass in something that doesn't exist
    if dirs.length == 1 and not File.exist?File.expand_path(dirs.first)
      create( dirs.first )

    # if we pass in anything else (probably a directory, or list of directories)
    else
      serve *dirs

    end
  end

  # print out commands and their summaries
  #
  # only commands with help doco are printed!
  def self.commands *no_args
    commands = self.methods.grep( /_help/ ).collect{ |help_method| help_method.gsub( /(.*)_help/ , '\1' ) } - ['resir']
    commands.sort!
    before_spaces = 4
    after_spaces  = 18
    text = commands.inject(''){ |all,cmd| all << "\n#{' ' * before_spaces}#{cmd}#{' ' * (after_spaces - cmd.length)}#{summary_for(cmd)}" }
    puts <<doco
resir commands are:

    DEFAULT COMMAND   #{@default_command}
#{text}

For help on a particular command, use 'resir help COMMAND'.
doco
#
#[NOT YET IMPLEMENTED:]
#Commands may be abbreviated, so long as they are unumbiguous.
#e.g. 'resir h commands' is short for 'resir help commands'.
#doco
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

  # -----------------------
  def self.resir_help
    <<doco

  resir == %{ Ridiculously Easy Site's In Ruby }
                        by remi                

    Usage:
      resir -h/--help
      resir -v/--version
      resir command [arguments...] [options...]
      resir [arguments...] [options...] # calls #{@default_command}

    Examples:
      resir ~/my_new_site       # create site
      resir ~/my_existing_site  # run site

    Further help:
      resir help commands       list all 'resir' commands
      resir help <COMMAND>      show help on COMMAND
                                  (e.g. 'resir help help')
    Further information:
      http://resir.rubyforge.org
doco
  end

  # -----------------------
  def self.help_help
    <<doco
Usage: resir help COMMAND

  Summary:
    Provide help on the 'resir' command
doco
  end

  # -----------------------
  def self.commands_help
    <<doco
Usage: resir commands

  Summary:
    List all 'resir' commands
doco
  end

  
  # -----------------------
  def self.preview_help
    <<doco
Usage: resir preview SITE_DIR [, SITE_DIR]

  About:
    Will recursively search all of the directories given
    for resir sites (looking for .siterc files) and will 
    start a local webserver to preview the sites

    Currently, uses Thin (if available) otherwise 
    Mongrel (if available) otherwise Webrick

  TODO:
    Accept --server option to force particular handler
    Accept --port option to force partucular port

  Summary:
    Start a server to preview the site(s) passed in
doco
  end

  # -----------------------
  def self.create_help
    <<doco
Usage: resir create SITE_DIRECTORY_TO_CREATE

  About:
    Will create a new directory with the name given
    and will touch an empty .siterc file within it.

  TODO:
    Use template in ~/.resir/template (or overriden dir)

  Summary:
    Create a new resir site
doco
  end

  # -----------------------
  def self.create_or_preview_help
    <<doco
Usage: resir create_or_preview NEW_OR_EXISTING_SITE_DIR

  About:
    This will call 'resir create' or 'resir preview'
    depending on whether or not the argument(s) passed 
    in exist.

  Examples:
    resir create_or_preview ~/i-dont-exist  # will create dir/site
    resir create_or_preview ~/i-dont-exist  # will preview new site

  Summary:
    Creates or previews a site, depending on if it exists yet
doco
  end

end
