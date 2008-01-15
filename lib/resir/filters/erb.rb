if lib_available? 'erubis'
  Resir.filters.erb = lambda { |text,binding| Erubis::Eruby.new(text).result(binding) }
elsif lib_available? 'erb'
  Resir.filters.erb = lambda { |text,binding| ERB.new(text).result(binding) }
end
