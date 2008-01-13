 require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
      # files = ['README', 'LICENSE', 'CHANGELOG', 'lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
      files = ['lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
      rdoc.rdoc_files.add(files)
      rdoc.main = 'README'
      rdoc.title = 'My RDoc'
      rdoc.template = '/usr/lib/ruby/gems/1.8/gems/allison-2.0.2/lib/allison'
      rdoc.rdoc_dir = 'doc'
      rdoc.options << '--line-numbers' << '--inline-source'
end
