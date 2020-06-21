if lib_available? 'haml'
  haml { |text,binding| binding ? Haml::Engine.new(text).render(binding) : Haml::Engine.new(text).render }
end
