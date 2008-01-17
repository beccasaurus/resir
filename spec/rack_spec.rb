require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Site, 'Rack Adapter' do

  before do
    @site    = Resir::Site.new 'examples/ambrose/starmonkey'
    @request = Rack::MockRequest.new @site
  end

  it 'should respond to #call' do
    response = @site.call Rack::MockRequest::env_for('/some/path')
    response.should be_a_kind_of(Array)
    response.length.should == 3
    response.first.should be_a_kind_of(Fixnum)
    response[1].should be_a_kind_of(Hash)
    # response.last.should be_a_kind_of(String) # how to do an OR to, otherwise, check responds_to?:body or something?
  end

  it 'should respond to a Rack::MockRequest' do
    response = @request.get '/some/path'
    response.should be_a_kind_of(Rack::MockResponse)
    response.status.should be_a_kind_of(Fixnum)
    response.headers.should be_a_kind_of(Hash)
    response.body.should be_a_kind_of(String)
  end

  # move to filters and extensions spec ?
  it 'should render ERB if filter and extension defined' do
    Resir.loaded_filters.delete('erb')
    @site.loaded_filters.delete('erb')
    response = @request.get 'home'
    response.status.should == 200
    response.body.should == %{<%= "hello there!" %>}

    require 'erb'
    Resir.loaded_filters.erb = lambda { |text,binding| ERB.new(text).result(binding) }
    response = @request.get 'home'
    response.status.should == 200
    response.body.should == %{hello there!}
  end

end
