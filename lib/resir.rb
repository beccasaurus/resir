$:.unshift File.dirname(__FILE__)

# dependencies
require 'rubygems'
require 'logger'
require 'rack'

require 'resir/version'
require 'resir/extensions'  # pre-requisite to most of our code
require 'resir/resir'       # required by Resir::Site
require 'resir/site'        # require by config (and Resir, but not on require)
load    'resir/config.rb'   # requires Resir and Resir::Site (loads because Resir can re-load)
