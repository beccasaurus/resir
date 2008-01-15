Dir['lib/resir/extensions/*.rb'].each { |filter| load filter }

# misc extensions / top-level methods with no homes

def lib_available? lib
  begin
    require lib
    true
  rescue LoadError
    false
  end
end

class Module
  # for, you know ... aliasing methods!  ( borrowed from active_support )
  def alias_method_chain(target, feature)
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1 ; yield(aliased_target, punctuation) if block_given?
    with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"
    alias_method without_method, target ; alias_method target, with_method
    case
      when public_method_defined?(without_method)    ; public target
      when protected_method_defined?(without_method) ; protected target
      when private_method_defined?(without_method)   ; private target
    end 
  end 
end

# make a class act like an indifferent hash with a static 'variables' hash
module IndifferentVariableHash
    attr_accessor :variables
    alias vars variables ; alias :vars= :variables=

    def method_missing name, *a
      begin
        self.variables.send name, *a
      rescue
        super name, *a
      end
    end 
end
