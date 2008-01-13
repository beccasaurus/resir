def lib_available? lib
  begin
    require lib
    true
  rescue LoadError
    false
  end
end

if lib_available? 'erb'
  Resir.filter_and_extension.erb = lambda { |text,binding| ERB.new(text).result(binding) } 
end

if lib_available? 'maruku'
  Resir.filter_and_extension.mkd = lambda { |text,binding| Maruku.new(text).to_html }
elsif lib_available? 'bluecloth'
  Resir.filter_and_extension.mkd = lambda { |text,binding| BlueCloth.new(text).to_html }
end

if lib_available? 'redcloth'
  Resir.filter_and_extension.text = lambda { |text,binding| RedCloth.new(text).to_html }
end

if lib_available? 'haml'
  Resir.filter_and_extension.haml = lambda { |text,binding| Haml::Engine.new(text) }
  Resir.filter_and_extension.sass = lambda { |text,binding| Sass::Engine.new(text) }
end

if lib_available? 'markaby'
  def markaby(&proc)
    assigns = {}
      instance_variables.each do |name|
        assigns[ name[1..-1] ] =  instance_variable_get(name)
      end
    Markaby::Builder.new(assigns, self).capture(&proc)
  end
  Resir.filter_and_extension.mab = lambda { |text,binding| markaby { eval text  }}
end
