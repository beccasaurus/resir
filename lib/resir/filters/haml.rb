if lib_available? 'haml'
  Resir.filters.haml = lambda { |text,binding| Haml::Engine.new(text).render(binding) }
  Resir.filters.sass = lambda { |text,binding| Sass::Engine.new(text).render }
end
