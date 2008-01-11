require File.dirname(__FILE__) + '/../lib/resir'

# when load gets called to load in our ~/.resirrc, don't let it!
def load_with_ignorance *args
  if args.first == File.expand_path('~/.resirrc')
    true
  else
    load_without_ignorance *args
  end
end
Module.alias_method_chain :load, :ignorance
