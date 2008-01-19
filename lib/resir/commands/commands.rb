class Resir::Bin

  # COMMANDS
  def self.commands_help
    <<doco
Usage: resir commands

  Summary:
    List all 'resir' commands
doco
  end
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

If you've made a command and it's not showing up here, you
need to make help method named 'COMMAND_help' that returns 
your commands help documentation.
doco
#
#[NOT YET IMPLEMENTED:]
#Commands may be abbreviated, so long as they are unumbiguous.
#e.g. 'resir h commands' is short for 'resir help commands'.
#doco
  end

end
