# TODO refactor the identical local_ remote_ or _local _remote methods to method_missing ... args = local/remote_server + method args

class Resir::Snip::Manager

  attr_accessor :local_server, :remote_server

  #
  # local may not be remote !!!
  # remote may not be local !!!
  #
  # i use local and remote because it's easier to code that way,
  # assuming that local will be the local box and remote a remote 
  # server, but keep in mind that the remote server may be a local directory!
  #
  # for certain things, the local repo could even actually be remote!
  # ^ helpful for using snips that you don't have on your local system
  #   and you don't want to install
  #
  def initialize local = Resir::snip_repo, remote = Resir::snip_source
    @local, @remote, = local, remote
  end

  def local_server
    @local_server  ||= Resir::Snip::Server.new @local
  end
  def remote_server
    @remote_server ||= Resir::Snip::Server.new @remote
  end

  def reload_local
    @local_server  = Resir::Snip::Server.new @local
  end

  def install *snips
    raise "Cannot install to a remote local." if local_server.is_remote?
    raise "Cannot install to the same local as your Snip remote" if local_server.source == remote_server.source

    File.makedirs local_server.source unless File.directory? local_server.source
    snips.each do |snip|

      # a bit confusing, with some methods taking string snip names and others taking objects ... CONVENTIONALIZE !!!!
      unless installed?snip
        source = read remote_server, snip
        snip   = remote_server.snips snip
        path   = path_to_snip_for_server local_server, snip
        File.open( path, 'w' ){ |f| f << source }
        puts "installed #{path}" if File.file?path
      else
        puts "#{snip} already installed"
      end
    
    end

    reload_local
  end

  def installed? snip
    snip = local_server.snips( snip )
    false unless snip
  end

  def uninstall *snips
    raise "Cannot uninstall a snip on a remote local." if local_server.is_remote?
    reload_local

    snips.each do |snip|
      path = path local_server, snip
      File.delete( path ) if path and File.file?path
      puts "uninstalled #{path}" if path and not File.file?path
    end

    reload_local
  end

  def search text

  end

  def show *snips

  end

  def path_to_snip_for_server server, snip_object
    File.join server.source, snip_object.filename unless snip_object.nil?
  end
  def path server, snip
    reload_local if server.is_local?
    path_to_snip_for_server server, server.snips(snip)
  end 
  def local_path snip;    path local_server, snip;    end
  def remote_path snip;   path remote_server, snip;   end

  def read server, snip
    if server.is_remote?
      require 'open-uri'
      open( remote_path(snip) ).read
    else
      snip = server.snips( snip )
      snip.full_source unless snip.nil?
    end
  end
  def read_local snip;    read local_server, snip;    end
  def read_remote snip;   read remote_server, snip;   end

  def list server
    server.snips.map { |snip| "#{snip.name} (#{snip.version})" }.join "\n"
  end
  def list_local;         list local_server;          end
  def list_remote;        list remote_server;         end

  # HELPERS
  def is_remote? source
    source.downcase[/^http/]
  end
  def is_local? source
    not is_remote?source
  end

end
