Resir.global_rc_file      ||= '/etc/resirrc'       # path of system-wide config/extension file 
Resir.user_rc_file        ||= '~/.resirrc'         # path of user-specific config/extension file
Resir.filters             ||= {}                   # available filters for rendering templates
Resir.extensions          ||= {}                   # available file extensions for determining filter(s)
Resir.directory_index     ||= %w( index home )     # paths to look for when requesting '/' for a site

# these paths are *relative* to a site's root directory
Resir.site_rc_file        ||= '.siterc'            # path of site-specific config/extension file
Resir.public_directory    ||= 'public'             # where static files go
Resir.template_directory  ||= ''                   # where we look for all files to render
