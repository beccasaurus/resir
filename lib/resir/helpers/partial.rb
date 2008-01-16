# 
# auto creates partial-esque helper methods for each subdirectory in your site
#
# if you have these directories:
#     ./partials
#     ./puppies
#
# then, if you require 'resir/helpers/partial', you'll you can:
#     <%= partial :nav %>
#     <%= puppy :rover %>
#
class Resir::Site::Responder

  def render_page name
    
    unless @site.auto_partials = false
      root = @site.root_directory + '/'
      Dir["#{root}*"].collect { |o| o.sub(root,'') }.select { |o| not o.include?'.' }.
      select{|o| File.directory?"#{root}#{o}" }.each do |directory| 
        unless @site.no_partials and @site.no_partials.include?directory
          metaclass.send(:define_method, directory) { |name| render "#{directory}/#{name}" }
          inflected = Inflector.singularize directory
          inflected = Inflector.pluralize directory if inflected == directory
          if inflected != directory
            metaclass.send(:define_method, inflected) { |name| render "#{directory}/#{name}" }
          end
        end
      end
    end

    # alias and call original here ... but right now, just quickly testing ...

    @responder      = self     # required by markaby (so far as i can tell)
    @layout         = 'layout' # make into a Resir/Site variable ... override at global or site level
    @content        = render_template name
    layout_template = @site.get_template(@layout) if @layout
    @content        = render_template layout_template if @layout and layout_template 
    @content
  end

end
