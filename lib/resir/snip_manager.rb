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
    end

    reload_local
  end

  # i need to stop with all this local/remote checking!  tho that's what the manager is, really ...
  # something to tie together a 'local' and a 'remote' repo ... hrm ...
  def log snip_name
    snips = local_server.all_snips( snip_name )
    snips = remote_server.all_snips( snip_name ) if snips.nil? or snips.empty?
    snips.sort! { |a,b| b.version.to_i <=> a.version.to_i }
    snips.collect { |snip| "[#{timeago snip.date}] (v #{snip.version.to_i}) #{snip.changelog_summary}".gsub('[] ','').gsub('(v ) ','')  }.join "\n"
  end

  # TOTALLY un-optimized ... like all of this!
  #
  # need to start tracking and watching whenever a remote server reloads
  #
  # local server too
  def search text

    # snip.name => snip
    name_matches = {}
    description_matches = {}

    local_server.snips.each do |snip|
      name_matches[snip.name] = snip if snip.name.downcase.include?text
      description_matches[snip.name] = snip if snip.description.downcase.include?text
    end
    remote_server.snips.each do |snip|
      name_matches[snip.name] = snip if snip.name.downcase.include?text
      description_matches[snip.name] = snip if snip.description.downcase.include?text
    end

    name_matches.keys.each do |name_match|
      description_matches.delete(name_match) if description_matches.keys.include?name_match
    end

    snips  = name_matches.values
    snips += description_matches.values
    snips

  end

  def show snip_name
    snip = local_server.snips( snip_name )
    snip = remote_server.snips( snip_name ) if snip.nil?
    snip.info
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
    snips = server.snips
    snips.sort! { |a,b| "#{a.name} #{a.version}" <=> "#{b.name} #{b.version}" }
    snips.collect { |snip| "#{snip.name} \t(v #{snip.version.to_i}) \t#{snip.description}".gsub('[] ','').gsub('(v ) ','') }.
      select { |item| not item.strip.empty? }.join("\n").to_s
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
