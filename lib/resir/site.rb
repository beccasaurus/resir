class Resir::Site
  include IndifferentVariableHash

  attr_accessor :root_directory

  def initialize root_dir
    @root_directory = root_dir
    @variables = {}
    self.siterc = File.join@root_directory Resir.site_rc_file
    load self.siterc unless not File.file?self.siterc
  end

end
