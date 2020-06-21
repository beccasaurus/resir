# this is pretty gross ... gotta clean this up ...
#
# HOWEVER ... it works!

if lib_available? 'markaby'

  mab { |text,binding|
  
    assigns = {}
    unless binding.nil?
      eval('instance_variables',binding).each do |name|
        instance_variable_set name, eval(name,binding)
        assigns[ name[1..-1] ] = eval(name,binding)
      end
    end
    
    mab = Markaby::Builder.new(assigns, self)
    
    def mab.method_missing_with_site( name, *args )
       if @responder.respond_to?(name)
         @responder.send( name, *args )
       else
          method_missing_without_site( name, *args )
       end
    end
    
    mab.instance_eval do
      alias method_missing_without_site method_missing
      alias method_missing method_missing_with_site
    end
    
    mab.capture { eval text }
  }

end
