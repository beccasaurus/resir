def lib_available? lib
  begin
    require lib
    true
  rescue LoadError
    false
  end
end

if lib_available? 'erb'
  Resir.filter_and_extension.erb = lambda { |text,binding| 
  puts "rendering ERB ... instance vars: #{instance_variables.inspect}"
    puts "site: #{@site}"
  ERB.new(text).result(binding) } 
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
  Resir.filter_and_extension.haml = lambda { |text,binding| Haml::Engine.new(text).render(binding) }
  Resir.filter_and_extension.sass = lambda { |text,binding| Sass::Engine.new(text).render }
end

if lib_available? 'markaby'
  Resir.filter_and_extension.mab = lambda { |text,binding|
    assigns = {}
    @site = eval('@site',binding)
    eval('instance_variables',binding).each do |name|
      assigns[ name[1..-1] ] =  instance_variable_get(name)
    end
    mab = Markaby::Builder.new(assigns, self)
    def mab.method_missing_with_site name, *args
       if @site.respond_to?name
         @site.send( name, *args )
       else
          method_missing_without_site( name, *args )
       end
    end
    mab.instance_eval do
      # alias_method_chain :method_missing, :site
      alias method_missing_without_site method_missing
      alias method_missing method_missing_with_site
    end
    mab.capture { eval text }
  }
end
