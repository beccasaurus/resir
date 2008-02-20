#! /usr/bin/ruby
%w( rubygems thin mime/types ).each { |lib| require lib }

dir     = File.expand_path( ARGV.shift || '.' )
filters = {
  'erb' => lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
}
find_file = lambda { |path| Dir[ File.join(dir,path) + '*' ].first }
name_exts = lambda { |file| 
  exts = File.basename( file ).split '.'
  name = exts.shift
  name += ".#{exts.first}" unless exts.empty?
  return name, exts
}
render_with_exts = lambda { |text, exts, binding| 
  exts.map { |ext| filters[ext] }.compact.each { |f| text = f.call text, binding }
  text
}

Thin::Server.start('0.0.0.0', 5000) do 
  use Rack::CommonLogger
  use Rack::ShowExceptions

  run lambda { |env|
    request  = Rack::Request.new env
    response = Rack::Response.new
    layout   = 'layout'

    path = (env['PATH_INFO'] == '/') ? '/index' : env['PATH_INFO']
    path = path + '.html' unless path.include? '.'
    file = find_file.call path
    return [ 404, {}, "File Not Found: #{path}" ] unless file

    name, exts = name_exts.call file
    response.headers['Content-Type'] = (MIME::Types.type_for(name) || 'text/plain').to_s
    response.body = render_with_exts.call File.read(file), exts, binding

    layout = find_file.call layout if layout
    if layout and response.headers['Content-Type'] == 'text/html'
      content = response.body
      response.body = render_with_exts.call File.read(layout), name_exts[layout].last, binding
    end

    response.finish
  }
end
