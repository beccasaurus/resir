require File.dirname(__FILE__) + '/../lib/resir'
require 'rubygems'
require 'spec/story'

# require steps
Dir[ File.dirname(__FILE__) + "/steps/**/*.rb" ].uniq.each { |step| require step }

def run_local_story story
  run "stories/#{story}"
end
