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

# i don't want all those messages!
class FakeLogger
  def initialize *a; end
  def method_missing name, *a; true; end
end
def log( &proc ); FakeLogger.new end
