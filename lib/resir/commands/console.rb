class Resir::Bin

  # CONSOLE
  def self.console_help
    <<doco
Usage: resir console [*site_directories]

  About:
    Launches an interactive console with access
    to all of Resir's classes, etc.

    When you launch it with site directories, 
    it will bind the $server and $sites to 
    variables so you can easily test your code!

  TODO:
    Integrate MockRequest.  $site.first.get('/')

  Summary:
    Launch interactive console to test your sites

doco
  end
  def self.console *dirs
    unless dirs.nil? or dirs.empty?
      $server = Resir::Server.new *dirs
      $sites  = $server.sites
      puts "resir console started\n\n"
      puts "variables:"
      puts "  $server:   the loaded Resir::Server"
      puts "  $sites:    the loaded Resir::Site's\n\n"
    else
      puts "resir console started\n\n"
      puts "use `resir console my-site` to start console with sites\n\n"
    end

    require 'irb'
    ARGV.clear
    IRB.start
  end

end
