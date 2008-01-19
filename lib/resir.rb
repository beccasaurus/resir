$:.unshift File.dirname(__FILE__)

# dependencies
require 'rubygems'
require 'logger'
require 'rack'

# resir files
require 'resir/version'     # version number ( smallest revision gets automatically updated )
require 'resir/extensions'  # pre-requisite to most of our code
require 'resir/resir'       # required by Resir::Site
require 'resir/site'        # require by config (and Resir, but not on require)
require 'resir/responder' 
load    'resir/config.rb'   # requires Resir and Resir::Site (loads because Resir can re-load)
require 'resir/server'      # utilizes the other classes, none of them require it
require 'resir/bin'         # utilized the other classes, none of them require it
require 'resir/snip'        # 
require 'resir/snip_server' #
