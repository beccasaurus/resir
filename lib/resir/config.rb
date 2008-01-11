# default configuration options for Resir & Resir::Site

# SITE_* SETTINGS
# 
# these get loaded into Resir::Sites with the same name (minus site_)
# and are generally meant to be overriden (as needed) although
# site_rc_file is an exception (cannot override)

# name of file to look for in a site directory to load site options
# ( relative to the root of the site directory, as with public dir )
Resir.site_rc_file           = '.siterc'

# name of directory to use as public directory, served staticly by
# web servers, when serving / configuring / resirizing Resir sites
Resir.site_public_directory  = 'public'

# name of directory where templates should live
# defaults to the root directory of the site
Resir.site_template_directory = ''

# filters are used to filter templates.
# they need to implement: #call |text|
# 
# example:
#   Resir.filters.upcase = lambda { |text| text.upcase }
#
#   Resir.filters.upcase.call "my text"
Resir.filters = {}

# extensions determine how to handle certain file extensions
# they need to implement: #call |text|
# more than not, these will leverage Resir.filters
#
# example:
#   Resir.extensions.erb = lambda { |text| Resir.filters.erb.call text }
#
#   output = Resir.extensions.erb.call File.read('my_file.erb')
#
# extensions are seperate from filters so it's easy to make 
# special extensions that, for example, render something with 
# ERB then Markdown then SmartyPants, all with one file extension
# instead of having to name the file my_file.sp.mkd.erb (or whatever)
Resir.extensions = {}
