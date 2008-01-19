
# TODO refactor the identical local_ remote_ or _local _remote methods to method_missing ... args = local/remote_server + method args

class Resir::Snip::Manager

  attr_accessor :local, :remote
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
    @local  = local
    @remote = remote
  end

  def local_server
    @local_server  ||= Resir::Snip::Server.new @local
  end
  def remote_server
    @remote_server ||= Resir::Snip::Server.new @remote
  end

  def local_snips
    local_server.snips
  end
  def remote_snips
    remote_server.snips
  end

  def install *snips
    raise "Cannot install to a remote local." if is_remote? @local
    raise "Cannot install to the same local as your Snip remote" if @local == @remote

    # ...
  end

  def uninstall *snips

  end

  def search text

  end

  def show *snips

  end

  def local_path snip
    path local_server, snip
  end
  def remote_path snip
    path remote_server, snip
  end
  def path server, snip
    File.join server.source, server.snips(snip).filename
  end 

  def read_local snip
    
  end
  def read_remote snip

  end
  def read snip

  end

  def list_local
    list local_snips
  end
  def list_remote
    list remote_snips
  end
  def list snips
    snips.map { |snip| "#{snip.name} (#{snip.version})" }.join "\n"
  end

  # HELPERS
  def is_remote? source
    source.downcase[/^http/]
  end
  def is_local? source
    not is_remote?source
  end

end
