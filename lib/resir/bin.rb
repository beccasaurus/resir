class Resir::Bin

  #
  # I don't actually use optparse for the primary parser,
  # instead we just call a method with the name of the first 
  # argument, else fall back to calling the default_command
  #
  # Simple, eh?
  #
  # Regardless, you might wanna use optparse for your commands
  # so this is required ( i use it for some of the commands )
  #
  require 'optparse'

  # RESIR
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

  class << self
    # default_command will be run if you specify resir with something like:
    #
    #     resir /some/directory --an-option
    #
    # where the first argument given (/some/directory) doesn't match up to 
    # any valid resir commands ... so the arguments get passed to whatever 
    # command is set as the 'default command'
    #
    # to override:
    #
    #     # untested, but should work:
    #     commands {
    #       set_default :my_cooler_command
    #     }
    #
    attr_accessor :default_command
  end

  # main method for executing
  # eg.
  #     Resir::Bin ARGV
  def self.call command_line_arguments
    original = command_line_arguments.shift
    command  = original.gsub('-','') unless original.nil? # replace all dashes, to help catch -h / --help
    
    if command.nil?
      help
    elsif self.respond_to?command.to_sym
      self.send(command, *command_line_arguments)
    elsif @default_command
      self.send(@default_command, *( [original] + command_line_arguments ))
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

  # HELP
  def self.version_help
    <<doco
Usage: resir version

  Summary:
    Outputs the current version of resir
doco
  end
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

  # HELP
  def self.help_help
    <<doco
Usage: resir help COMMAND

  Summary:
    Provide help on the 'resir' command
doco
  end
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

  # VERSION
  def self.version_help
    <<doco
Usage: resir version

  Summary:
    Display the current version of resir
doco
  end
  def self.version *no_args
    puts Resir::VERSION::STRING
  end

  # shortcuts to support calling -h / -v for help/version
  class << self
    alias h help
    alias v version
  end

  #
  #  ^ resire bin core
  #

  # require more commands (simple extensions to Resir::Bin)
  #
  %w( commands console create_and_preview snips ).each { |cmd| require File.dirname(__FILE__) + "/commands/#{cmd}" }

end
