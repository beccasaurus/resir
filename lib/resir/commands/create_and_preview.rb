class Resir::Bin

  set_default :create_or_preview

  def self.get_rack_handler
    if lib_available? 'thin'
      Rack::Handler::Thin
    elsif lib_available? 'mongrel'
      Rack::Handler::Mongrel
    elsif lib_available? 'webrick'
      Rack::Handler::Webrick
    end
  end

  # CREATE
  def self.create_help
    <<doco
Usage: resir create SITE_DIRECTORY_TO_CREATE

  About:
    Will create a new directory with the name given
    and will touch an empty .siterc file within it.

  TODO:
    Use template in ~/.resir/template (or overriden dir)

  Summary:
    Create a new resir site
doco
  end
  def self.create dir
    path = File.expand_path dir
    unless File.exist? path
      puts "Creating new site: #{path}\n\n"
      system_command "mkdir '#{path}'"
      system_command "touch '#{File.join( path, Resir::site_rc_file )}'"
    else
      "File already exists: #{path}"
    end
  end

  # PREVIEW
  def self.preview_help
    <<doco
Usage: resir preview SITE_DIR [, SITE_DIR]

  About:
    Will recursively search all of the directories given
    for resir sites (looking for .siterc files) and will 
    start a local webserver to preview the sites

    Currently, uses Thin (if available) otherwise 
    Mongrel (if available) otherwise Webrick

  TODO:
    Accept --server option to force particular handler
    Accept --port option to force partucular port

  Summary:
    Start a server to preview the site(s) passed in
doco
  end
  def self.preview *dirs
    server = Resir::Server.new *dirs
    unless server.sites.empty?
      get_rack_handler.run server
    else
      puts "\nNo sites found.\n"
      print_help :create_or_preview
    end
  end

  # CREATE OR PREVIEW
  def self.create_or_preview_help
    <<doco
Usage: resir create_or_preview NEW_OR_EXISTING_SITE_DIR

  About:
    This will call 'resir create' or 'resir preview'
    depending on whether or not the argument(s) passed 
    in exist.

  Examples:
    resir create_or_preview ~/i-dont-exist  # will create dir/site
    resir create_or_preview ~/i-dont-exist  # will preview new site

  Summary:
    Creates or previews a site, depending on if it exists yet
doco
  end
  def self.create_or_preview *dirs
    # if we pass in something that doesn't exist
    if dirs.length == 1 and not File.exist?File.expand_path(dirs.first)
      create( dirs.first )

    # if we pass in anything else (probably a directory, or list of directories)
    else
      preview *dirs

    end
  end

end
