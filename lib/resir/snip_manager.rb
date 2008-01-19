class Resir::Snip::Manager

  attr_accessor :repo, :source, :server # server is really what holds onto the snips and gets them for us

  # ONLY set the source ... lazily load snips, when needed
  def initialize repo = Resir::snip_repo, source = Resir::snip_source
    @repo   = repo
    @source = source
  end

  def snips
    @server ||= Resir::Snip::Server.new @source
    @server.snips
  end

end
