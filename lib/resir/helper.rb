# misc helper methods / modules / extensions

# EXTENSIONS

# extend Hash to be 'indifferent' - h[:x] = 5 or h.x = 5
#
class Hash
  def method_missing(m,*a)
    m.to_s =~ /=$/ ? (self[$`] = a[0]) : (a==[] ? self[m.to_s] : super)
  end
end

# metaid.rb [http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html]
#
class Object
  # The hidden singleton lurks behind everyone
  def metaclass; class << self; self; end; end
  def meta_eval &blk; metaclass.instance_eval &blk; end

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end

  # Defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end

# variables used by methods ... 
# should probably be on a class or module ...
class Helpers
  # basically, if the method coming in 
  # is like Helpers::image_dir= then 
  # let's go ahead and make a Helpers::image_dir
  # variable for you, and set it!
  def self.method_missing name, *a
    if name.to_s[/=$/]
      name = name.to_s.sub '=',''
      meta_eval { attr_accessor name }
      instance_variable_set "@#{name}", a.first
    else
      super name, *a
    end
  end
end

# HELPER VARIABLES

Helpers::js_dir    = '/js/'
Helpers::css_dir   = '/css/'
Helpers::image_dir = '/img/'
Helpers::flash_dir = '/flash/'

# HELPER METHODS

# method for getting any HTML tag
#
# usage:
#   tag 'img', :src => '/images/my_image.png'
#
# mostly to be used, internally, by html helper
# methods like `img`
#
def tag name, options = {}, &block
  if options[:self_closing]
    self_closing = true ; options.delete :self_closing
  end
  out = "<#{name}"
  options.each { |k,v| out << %{ #{k}="#{v}"} }
  if block_given?
    out << '>' + yield + "</#{name}>"
  else
    if self_closing
      out << ' />'
    else
      out << "></#{name}>"
    end
  end
  out
end

# creates an html link
#
# first argument is the text for the 
# link, however, if a block is given, 
# the output of the block will be used 
# as the link text instead
#
#   a 'hello!', :href => 'http://www.google.com'
#
#   a( nil, :href => 'http://www.google.com' ) do
#     img 'my_image.png'
#   end
#
def a text, options = {}, &block
  if block_given?
    tag('a', options){ yield }
  else
    tag('a', options){ text }
  end
end

# creates an image tag
#
#   img 'my_image.png'
#   # => '<img src="/img/my_image.png" />'
#
# to change the image directory prefix, 
# change Helpers::image_dir
#
def img file, options = {}
  file = file[/^http/] ? file : Helpers::image_dir + file
  options.src = file; options[:self_closing] = true
  tag 'img', options
end

# creates a link to a stylesheet OR in-line css
# depending on what it thinks you want
#
#   css 'my_sheet'  # => returns `stylesheet 'my_sheet'`
#   css '#home { border: 1px; }'  # => returns inline css
#
# also accepts an array of any combination of inline css 
# or stylesheets
def css *files_or_inline
  files_or_inline = files_or_inline.first unless files_or_inline.length > 1
  if files_or_inline.is_a?Array
   files_or_inline.inject('') { |all,this| all + "\n" + css(this) } 
  else
    if files_or_inline.include?'{'
      %{ <style type="text/css">#{files_or_inline}</style> }.strip
    else
      stylesheet files_or_inline
    end
  end
end

# creates a stylesheet link (will auto-append .css if not included)
#
#   stylesheet 'my_styles'  # => <link href="css/my_styles.css" ...
#
# to change the stylesheets directory prefix,
# change Helpers::css_dir
#
def stylesheet file
  file = "#{file}.css" unless file.include?'.css'
  file = file[/^http/] ? file : Helpers::css_dir + file
  %{ <link href="#{file}" rel="stylesheet" type="text/css" /> }.strip
end

def js *files_or_inline
  files_or_inline = files_or_inline.first unless files_or_inline.length > 1
  if files_or_inline.is_a?Array
    files_or_inline.inject('') { |all,this| all + js(this) + "\n" } 
  else
    if files_or_inline.include?';'
      %{ <script type="text/javascript">#{files_or_inline}</script> }.strip
    else
      javascript files_or_inline
    end
  end
end

def javascript file
  file = "#{file}.js" unless file.include?'.js'
  file = file[/^http/] ? file : Helpers::js_dir + file
  %{ <script type="text/javascript" src="#{file}"></script> }.strip
end

# creates an object tag to include a flash swf in the page
#
# TODO add option to support using javascript to move object 
# into a DIV, if flash is supported.  better accessibility.
# and lets you see a 'loading content ...' message in the div
#
#   swf 'header', :width => 500, :height => 350
#   # => <object ... src="/flash/header.swf" ...
#
# to change the flash directory prefix,
# change Helpers::flash_dir
#
# TODO add custom options to support FlashVars and 
# enabling or disabling transparency
#
# TODO use reverse-merge for options, so things like bgcolor 
# and allowScriptAccess, etc, call all be easily customized
#
def swf file, options = { :height => '100', :width => '100' }
  file = file.sub /\.swf$/, ''
  id_and_name = file.gsub('/','').gsub(' ','_')
  %{ <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="#{options[:width]}" height="#{options[:height]}" id="#{id_and_name}" name="#{id_and_name}" align="middle">
        <param name="allowScriptAccess" value="sameDomain" />
        <param name="movie" value="#{Helpers::flash_dir}#{file}.swf" />
        <param name="quality" value="high" />
        <param name="bgcolor" value="#ffffff" />
        <param name="FlashVars" value="" />
  <embed src="#{Helpers::flash_dir}#{file}.swf" quality="high" bgcolor="#ffffff" width="#{options[:width]}" height="#{options[:height]}" name="#{id_and_name}" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
</object> }.strip
end

# the meta content type tag
def meta_content_type
  %{<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />}
end
def meta_description content, path = @full_path
  tag 'meta', 'http-equiv' => path, :name => 'description', :content => content
end
def meta_keywords content, path = @full_path
  tag 'meta', 'http-equiv' => path, :name => 'keywords', :content => content
end

def google_analytics account_id = @google_analytics_id
  js 'http://www.google-analytics.com/urchin.js', "_uacct = \"#{account_id}\"; urchinTracker();"
end

# FILTERS

# tidies up html, to make it pretty xml
#
# probably pretty slow, so only use when using page caching
#
# requires tidy to be installed on server
# ( not sure which did it, but i installed:
#   tidy, libtidy, libtidy-dev, libtidy-ruby )
# 
# quietly returns the passed html on failure
#
def make_tidy html, options = { :debug => true }
  begin
    require 'tidy'
    Tidy.path = '/usr/lib/libtidy.so'
    xml = Tidy.open( :show_warnings => true ) do |tidy|
      
      # for option reference: http://tidy.sourceforge.net/docs/quickref.html
      tidy.options.indent          = true
      tidy.options.indent_spaces   = 4
      tidy.options.output_xml      = false
      tidy.options.wrap            = 150
      tidy.options.show_warnings   = true
      tidy.options.tidy_mark       = false # enable to show created by tidy in meta
      tidy.options.indent_cdata    = true # disable is this makes css/javascript angry
      tidy.options.clean           = false
      tidy.options.hide_comments   = true
      tidy.options.output_xhtml    = true # or output_html or output_xml
      tidy.options.replace_color   = true # fun, replaces #ffffff with white, etc
      tidy.options.break_before_br = true # sure, puts a \n before <br />
      tidy.options.vertical_space  = true # trying out - adds some lines for readability
      # tidy.options.doctype         = :transitional # or auto, omit, strict, user

      xml = tidy.clean(html)
      
      #errors = tidy.errors
      # diagnostics = tidy.diagnostics
      #if options[:debug]
      #  xml << '<br /><hr /><h3>Tidy Errors:</h3><ul>'
      #  errors.first.split("\n").each { |error| xml << "<li>#{error}</li>" }
      #  xml << '</ul>'
      #end
    end

    # my personal tweaks
    xml.gsub! "\n</script>", "</script>"
    xml.gsub! %{<script type="text/javascript"}, %{\t<script type="text/javascript"}

    xml

  rescue Exception => ex
    "<h1>TIDY FAILED</h1><h2>#{ex}</h2>" + html
    # html
  end
end
