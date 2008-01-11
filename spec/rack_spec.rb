require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Site, 'Rack Adapter' do

  before do
    # >> require 'rack'; site = Resir::Site.new 'examples/ambrose/starmonkey'; request = Rack::MockRequest.new site
    require 'rubygems'
    require 'rack'
    @site = Resir::Site.new 'examples/ambrose/starmonkey'
    @request = Rack::MockRequest.new @site
  end

  it 'should respond to #call' do
    response = @site.call %w(empty environment)
    response.should be_a_kind_of(Array)
    response.length.should == 3
    response.first.should be_a_kind_of(Fixnum)
    response[1].should be_a_kind_of(Hash)
    # response.last.should be_a_kind_of(String) # how to do an OR to, otherwise, check responds_to?:body or something?
  end

  it 'should respont to a Rack::MockRequest' do
    response = @request.get '/some/path'
    response.should be_a_kind_of(Rack::MockResponse)
    response.status.should be_a_kind_of(Fixnum)
    response.headers.should be_a_kind_of(Hash)
    response.body.should be_a_kind_of(String)
  end

end
