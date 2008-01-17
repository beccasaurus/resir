require File.dirname(__FILE__) + '/spec_helper'

describe 'filters' do

  before do
    reset
  end

  def setup site
     @site = site
     @server = Resir::Server.new "examples/for_filters/#{site}"
     @request = Rack::MockRequest.new @server
  end
  def get path="/#{@site}"
    @request.get(path).body
  end
  def reset
    @server, @request = nil, nil
  end

  # -----------------------------------------------------------

  it "should let a site override (and add new) filters, per site, not globally" do
    site = Resir::Site.new '/examples/siterc_testing/first'
    Resir.filters.keys.should_not include('blah')
    site.filters.keys.should_not include('blah')

    Resir.filters.blah = lambda { |t,b| "hello there" }
    Resir.filters.keys.should include('blah')
    site.filters.keys.should_not include('blah')

    Resir.filters.blah.should_not be_nil
    site.filters.blah.should_not be_nil

    Resir.filters['blah'].should_not be_nil
    site.filters['blah'].should_not be_nil

    Resir.filters.delete 'blah'
    Resir.filters.keys.should_not include('blah')
    site.filters.keys.should_not include('blah')
    Resir.filters.blah.should be_nil
    site.filters.blah.should be_nil
    Resir.filters['blah'].should be_nil
    site.filters['blah'].should be_nil
    
    site.filters.blah = lambda { |t,b| "hi there" }
    site.filters.keys.should include('blah')
    Resir.filters.keys.should_not include('blah')
    site.filters.blah.should_not be_nil
    Resir.filters.blah.should be_nil

    site.filters['blah'].should_not be_nil
    Resir.filters['blah'].should be_nil
  end

  it 'should support erb' do
     setup 'erb'
     get.should == 'hello. misc stuff. /'
  end

# re-enable this later ... i'm going to be re-doing some things and i don't want this dirtying things up ....
=begin
  it 'should NOT support partials, if not required, even if another site previously required them' do
     setup 'erb'
     get.should == 'hello. misc stuff. /'

     reset
     setup 'erb_no_partial'
     get.should_not == 'hello. misc stuff. /'

     reset
     setup 'erb'
     get.should == 'hello. misc stuff. /'
  end
=end

  it 'should support haml' do
     setup 'haml'
     get.should == "<p>hello from haml</p>\n<p>hello there test. /</p>\n<li>hello</li>\n<li>yall</li>"
  end

  it 'should support markaby' do
     setup 'markaby'
     get.should == "<p>markaby says hello</p><strong>example.org</strong><p>!pickaxe!</p>"
  end

  # used partial thingers, Inflector, haml, markdown, markaby, erb, directory_index, and layout
  it 'should support them all, mixed and matched and whatnot (and use Inflector)' do
    setup 'all'
    get.should == "BEGIN\n<h1>welcome to puppies!</h1><p><strong>lander</strong> is <em>the</em> <code>coolest</code></p>\nEND"
  end

  it 'should support them all, mixed and matched and whatnot (and use Inflector)' do
    setup 'all'
    get('/all/styles').should == "body #home {\n  color: blue; }"
  end

  it 'should support an arbitrary require and include from .siterc' do
    # right now, only works if the required file has the methods defined 
    # at the TOPLEVEL ... hrm ... will work on this later
    setup 'require_and_include'
    get.should == 'foo: bar && test ArbitraryHelpers#test'
  end

  it "should support my little helper file with: require 'resir/helper' " do
    setup 'my_helper'
    get.should == "from helper: <script type=\"text/javascript\" src=\"/js/testing123.js\"></script>"
  end

  it "should support rails ActionView::Helpers" do
    setup 'rails_helper'
    get.should == "hi.  <input name=\"name\" type=\"text\" id=\"name\" value=\"john\"></input>"
  end

end
