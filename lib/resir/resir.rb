class Resir
  meta_include IndifferentVariableHash

  # load ~/.resirrc if it exists ( path is not customizable )
  def self.initialize
    @variables ||= {}
    load 'resir/config.rb'
    resirrc = File.expand_path '~/.resirrc'
    load resirrc if File.file?resirrc
  end
  initialize

  def self.get_sites *dirs
    dirs.inject([]){ |all,dir| all + find_site_dirs(dir) }.uniq.collect{ |dir| Resir::Site.new(dir) }
  end
  def self.sites *dirs; get_sites *dirs; end

  def self.find_site_dirs in_this_directory
    Dir[ File.join( in_this_directory, '**', Resir.site_rc_file ) ].collect{|rc| File.dirname rc }  
  end

  def self.get_extensions filename
    ( filename.split('.') - [ filename[/(\w+)/] ] ).reverse
  end

end
