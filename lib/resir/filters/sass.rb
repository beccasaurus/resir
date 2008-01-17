if lib_available? 'haml'

  # require 'resir/filters/erb' # require one filter from another?

  sass { |text,binding| 
    eval( '@layout = nil', binding ) # disable layout
    eval( %{response.header['Content-Type'] = 'text/css' if defined?response}, binding ) # set to text/css
    render_with_erb = lambda { |t,b| require 'erb'; ERB.new(t).result(b) } # HACK for now ...
    Sass::Engine.new( render_with_erb[text,binding] ).render 
  }

end
