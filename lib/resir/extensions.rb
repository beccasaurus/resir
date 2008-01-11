# general object extensions
#
# when / if this grows to be too long, extract to multiple files

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

# extend Hash to be 'indifferent' to make config variables easy
# ( borrowed from Camping [http://code.whytheluckystiff.net/camping/] )
class Hash
  def method_missing(m,*a)
    m.to_s =~ /=$/ ? (self[$`] = a[0]) : (a==[] ? self[m.to_s] : super)
  end

  # borrowed from active_support ( to help with 'named parameters' )
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end
  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end 
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty? 
  end
end

# metaid.rb [http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html]
# for metaprogramming awesomeness ( thanks _why! )
class Object
  # The hidden singleton lurks behind everyone
  def metaclass; class << self; self; end; end 
  def meta_eval &blk; metaclass.instance_eval &blk; end 

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end 

  # Defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end
