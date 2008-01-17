if lib_available? 'maruku'
  mkd { |text,binding| Maruku.new(text).to_html }
elsif lib_available? 'bluecloth'
  mkd { |text,binding| BlueCloth.new(text).to_html }
end
