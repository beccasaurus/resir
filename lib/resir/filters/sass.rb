if lib_available? 'haml'
  require 'resir/filters/erb'
  Resir.filters.sass = lambda { |text,binding| 
    eval( '@layout = nil', binding ) # disable layout
    Sass::Engine.new( Resir.filters.erb[text,binding] ).render }
end
