if lib_available? 'erubis'

  Resir::erb_variable = '_buf'
  erb { |text,binding| Erubis::Eruby.new(text).result(binding) }

elsif lib_available? 'erb'

  Resir::erb_variable = '_erbout'
  erb { |text,binding| ERB.new(text).result(binding) }

end
