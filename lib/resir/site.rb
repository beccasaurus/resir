class Resir::Site
  include IndifferentVariableHash

  def initialize root_dir
    @variables = {}
    self.root_directory = root_dir
    initialize_variables
  end

  def initialize_variables
    # set default variables to all of the Resir.site_* variables
    Resir.keys.grep(/^site_/).each { |key| @variables[key.sub(/^site_/,'')] = Resir[key] }
    siterc = File.join self.root_directory, Resir.site_rc_file
    eval File.read(siterc) unless not File.file?siterc # because load can't get to our instance!
  end

  def get_template name
    looking_for = File.join template_rootpath, name 
    return template_basename(looking_for) if File.file?looking_for
    template_basename Dir["#{looking_for}.*"].sort.select{ |match| File.file?match }.first
  end
  def template_rootpath
    File.join self.root_directory, self.template_directory
  end
  def template_basename name
      name.sub "#{template_rootpath}/", ''
  end

end
