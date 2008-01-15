require File.dirname(__FILE__) + '/spec_helper'

describe 'filters' do

  before do
    @server, @request = nil, nil
  end

  def setup site
     @server = Resir::Server.new "examples/for_filters/#{site}"
     @request = Rack::MockRequest.new @server
  end

  it 'should support erb' do
     setup 'erb'
     @request.get('/erb').body.should == 'hello. misc stuff. /'
  end

  it 'should support haml' do
     setup 'haml'
     @request.get('/haml').body.should == "<p>hello from haml</p>\n<p>hello there test. /</p>"
  end

  it 'should support markaby' do
     setup 'markaby'
     @request.get('/markaby').body.should == "<p>markaby says hello</p><strong>example.org</strong><p>!pickaxe!</p>"
  end

  # used partial thingers, Inflector, haml, markdown, markaby, erb, directory_index, and layout
  it 'should support them all, mixed and matched and whatnot (and use Inflector)' do
    setup 'all'
    @request.get('/all').body.should == "BEGIN\n<h1>welcome to puppies!</h1><p><strong>lander</strong> is <em>the</em> <code>coolest</code></p>\nEND"
  end

end
