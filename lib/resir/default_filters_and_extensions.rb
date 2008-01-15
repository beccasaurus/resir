def lib_available? lib
  begin
    require lib
    true
  rescue LoadError
    false
  end
end

if lib_available? 'erb'
  Resir.filters.erb = lambda { |text,binding| ERB.new(text).result(binding) } 
end

if lib_available? 'maruku'
  Resir.filters.mkd = lambda { |text,binding| Maruku.new(text).to_html }
elsif lib_available? 'bluecloth'
  Resir.filters.mkd = lambda { |text,binding| BlueCloth.new(text).to_html }
end

if lib_available? 'redcloth'
  Resir.filters.text = lambda { |text,binding| RedCloth.new(text).to_html }
end

if lib_available? 'haml'
  Resir.filters.haml = lambda { |text,binding| Haml::Engine.new(text).render(binding) }
  Resir.filters.sass = lambda { |text,binding| Sass::Engine.new(text).render }
end

if lib_available? 'markaby'
  Resir.filters.mab = lambda { |text,binding|
    assigns = {}
    eval('instance_variables',binding).each do |name|
      instance_variable_set name, eval(name,binding)
      assigns[ name[1..-1] ] = eval(name,binding)
    end
    mab = Markaby::Builder.new(assigns, self)
    def mab.method_missing_with_site( name, *args )
       if @site.respond_to?(name)
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
