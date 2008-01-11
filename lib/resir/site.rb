class Resir::Site
  include IndifferentVariableHash

  attr_accessor :root_directory

  def initialize root_dir
    @root_directory = root_dir
    initialize_variables
  end

  def initialize_variables
    @variables = {} # set default variables to all of the Resir.site_* variables
    Resir.keys.grep(/^site_/).each { |key| @variables[key.sub(/^site_/,'')] = Resir[key] }
    siterc = File.join@root_directory, Resir.site_rc_file
    eval File.read(siterc) unless not File.file?siterc # because load can't get to our instance!
  end

end
