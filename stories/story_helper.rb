require File.dirname(__FILE__) + '/../lib/resir'
require 'rubygems'
require 'spec/story'

# require steps
Dir[ File.dirname(__FILE__) + "/steps/**/*.rb" ].uniq.each { |step| require step }

def run_local_story story
  run "stories/#{story}"
end

# does this keep .resirrc from being loaded, too ... ?

# i don't want all those messages!
class FakeLogger
  def initialize *a; end
  def method_missing name, *a; true; end
end
def log( &proc ); FakeLogger.new end
