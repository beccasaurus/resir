if lib_available? 'haml'
  haml { |text,binding| Haml::Engine.new(text).render(binding) }
end
