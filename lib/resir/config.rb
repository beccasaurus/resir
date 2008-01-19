Resir.global_rc_file      ||= '/etc/resirrc'       # path of system-wide config/extension file 
Resir.user_rc_file        ||= '~/.resirrc'         # path of user-specific config/extension file
Resir.loaded_filters             ||= {}                   # available filters for rendering templates
Resir.directory_index     ||= %w( index home )     # paths to look for when requesting '/' for a site

# these paths are *relative* to a site's root directory
Resir.site_rc_file        ||= '.siterc'            # path of site-specific config/extension file
Resir.public_directory    ||= 'public'             # where static files go
Resir.template_directory  ||= ''                   # where we look for all files to render

Resir.logger              ||= Logger.new STDOUT

Resir::path_to_resir      ||= File.expand_path(File.dirname(__FILE__) + '/../..')
Resir::path_to_resir_lib  ||= File.join Resir::path_to_resir, 'lib'

Resir::helper_search_path ||= ['.', '~/.resir', '~/.resir/helpers']
Resir::helper_search_path << File.join(Resir::path_to_resir_lib, 'resir/helpers')

Resir::filter_search_path ||= ['.', '~/.resir', '~/.resir/filters']
Resir::filter_search_path << File.join(Resir::path_to_resir_lib, 'resir/filters')

Resir::command_search_path ||= ['.', '~/.resir', '~/.resir/commands']
Resir::command_search_path << File.join(Resir::path_to_resir_lib, 'resir/commands')

Resir::snip_repo           ||= '~/.resir/snips'
Resir::snip_source         ||= 'http://localhost'
