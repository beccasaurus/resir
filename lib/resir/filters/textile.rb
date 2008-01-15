if lib_available? 'redcloth'
  Resir.filters.text = lambda { |text,binding| RedCloth.new(text).to_html }
end
