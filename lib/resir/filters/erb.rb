if lib_available? 'erubis'
  erb { |text,binding| Erubis::Eruby.new(text).result(binding) }
elsif lib_available? 'erb'
  erb { |text,binding| ERB.new(text).result(binding) }
end
