require File.dirname(__FILE__) + '/../lib/resir'

def load_interceptor *args
  if args.first == File.expand_path('~/.resirrc')
    true
  else
    real_load args.first
  end
end
alias real_load load unless defined?real_load
alias load load_interceptor
