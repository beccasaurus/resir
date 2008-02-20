#! /usr/bin/ruby
%w( rubygems thin ).each { |lib| require lib }

dir     = File.expand_path( ARGV.shift || '.' )
filters = {
  'erb' => lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
}

Thin::Server.start('0.0.0.0', 5000) do 
  use Rack::CommonLogger
  use Rack::ShowExceptions
  run lambda { |env|

    path = (env['PATH_INFO'] == '/') ? '/index' : env['PATH_INFO']
    path = path + '.html' unless path.include? '.'
    file = Dir[ File.join(dir,path) + '*' ].first
    return [ 404, {}, "File Not Found: #{path}" ] unless file

    exts = File.basename( file ).split '.'
    body = File.read file
    exts.map { |ext| filters[ext] }.compact.each { |f| body = f.call body, binding }
    return [ 200, { 'Content-Type' => 'text/html' }, body ]
  }
end

# name = exts.shift ; name += ".#{exts.first}" unless exts.empty? # <= use for BUILD
