#! /usr/bin/ruby
%w( rubygems thin mime/types ).each { |lib| require lib }

dir     = File.expand_path( ARGV.shift || '.' )
filters = {
  'erb' => lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
}

Thin::Server.start('0.0.0.0', 5000) do 
  use Rack::CommonLogger
  use Rack::ShowExceptions

  run lambda { |env|
    request  = Rack::Request.new env
    response = Rack::Response.new

    path = (env['PATH_INFO'] == '/') ? '/index' : env['PATH_INFO']
    path = path + '.html' unless path.include? '.'
    file = Dir[ File.join(dir,path) + '*' ].first
    return [ 404, {}, "File Not Found: #{path}" ] unless file

    exts = File.basename( file ).split '.'
    name = exts.shift ; name += ".#{exts.first}" unless exts.empty?
    response.headers['Content-Type'] = (MIME::Types.type_for(name) || 'text/plain').to_s

    response.body = File.read file
    exts.map { |ext| filters[ext] }.compact.each { |f| response.body = f.call response.body, binding }

    response.finish
  }
end

