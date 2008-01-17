if lib_available? 'redcloth'
  text { |text,binding| RedCloth.new(text).to_html }
end
