require File.dirname(__FILE__) + '/spec_helper'

describe 'filters' do

  it 'should support erb' do
     server = Resir::Server.new 'examples/for_filters/erb'
     request = Rack::MockRequest.new server
     request.get('/erb').body.should == 'hello. misc stuff. /'
  end

  it 'should support haml' do
     server = Resir::Server.new 'examples/for_filters/haml'
     request = Rack::MockRequest.new server
     request.get('/haml').body.should == "<p>hello from haml</p>\n<p>hello there test. /</p>"
  end

end
