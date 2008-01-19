class Resir::Bin

=begin
  # COMMAND_NAME
  def self.COMMAND_NAME_help
    <<doco
Usage: resir COMMAND_NAME ...

  About:
    ....

  TODO:
    ...

  Summary:
    ....
doco
  end
=end

  # LIST
  def self.list *args
    options = { :where => [], :local => Resir::snip_repo, :remote => Resir::snip_source }
    opts = OptionParser.new do |opts|
      opts.on('--local'){ options[:where] << :local }
      opts.on('--remote'){ options[:where] << :remote }
      opts.on('--source [URL]'){ |url| options[:remote] = url }
    end
    opts.parse!(args)

    options[:where] << :local if options[:where].empty?
    manager = Resir::Snip::Manager.new options[:local], options[:remote]
    options[:where].uniq.each do |where|
      puts "----- [ #{ where.to_s.upcase } ] ----\n\n"
      puts manager.send( "list_#{where}" )
    end
  end

end
