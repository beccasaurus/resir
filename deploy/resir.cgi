#! /usr/bin/env ruby
%w(rubygems resir rack).each { |lib| require lib }
ENV['HOME'] = '/root'
site = Resir::get_sites( '/var/www/resir-example' ).first
site.path_prefix = '/resir-example'
Rack::Handler::CGI.run site
