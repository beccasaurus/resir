#! /usr/bin/ruby
%w( rubygems thin ).each { |lib| require lib }

dir     = File.expand_path( ARGV.shift || '.' )
filters = {
  'erb' => lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
}

Rack::Handler::Thin.run lambda { |env|
  begin

    path = (env['PATH_INFO'] == '/') ? '/index' : env['PATH_INFO']
    file = Dir[ File.join(dir,path) + '.*' ].first
    exts = File.basename( file ).split '.'
    name = exts.shift
    body = File.read file

    exts.map { |ext| filters[ext] }.compact.each { |f| body = f.call body, binding }

    [ 200, { 'Content-Type' => 'text/html' }, body ]
  rescue => ex
    [ 200, { 'Content-Type' => 'text/html' }, ex.to_s ]
  end
}
