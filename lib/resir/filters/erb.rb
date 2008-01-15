if lib_available? 'erb'
  Resir.filters.erb = lambda { |text,binding| ERB.new(text).result(binding) } 
end
