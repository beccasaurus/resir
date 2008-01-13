require File.dirname(__FILE__) + '/story_helper'

with_steps_for(:example_website) do

  run_local_story 'simple_story'
  run_local_story 'simple_stories_from_specs'

end
