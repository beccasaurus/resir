if lib_available? 'haml'
  Resir.filters.haml = lambda { |text,binding| Haml::Engine.new(text).render(binding) }
end
