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
