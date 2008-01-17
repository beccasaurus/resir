# include a number of ActionView helpers, for people who're comfy with rails
if lib_available? 'active_support'

  require 'action_view/helpers/tag_helper.rb'
  require 'action_view/helpers/form_tag_helper.rb'
  require 'action_view/helpers/asset_tag_helper.rb'
  require 'action_view/helpers/form_helper.rb'
  require 'action_view/helpers/form_options_helper.rb'
  require 'action_view/helpers/url_helper.rb'
  require 'action_view/helpers/date_helper.rb'
  require 'action_view/helpers/number_helper.rb'
 
# include EVERYWHERE!  sheesh .... *** MOVE TO HELPER ***

#  class Resir::Site::Responder
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::FormTagHelper 
    include ActionView::Helpers::AssetTagHelper 
    include ActionView::Helpers::FormHelper 
    include ActionView::Helpers::FormOptionsHelper 
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper
#  end

end
