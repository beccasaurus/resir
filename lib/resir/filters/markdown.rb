if lib_available? 'maruku'
  Resir.filters.mkd = lambda { |text,binding| Maruku.new(text).to_html }
elsif lib_available? 'bluecloth'
  Resir.filters.mkd = lambda { |text,binding| BlueCloth.new(text).to_html }
end
