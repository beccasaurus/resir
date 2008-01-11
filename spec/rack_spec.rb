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
    response = @site.call Rack::MockRequest::env_for('/some/path')
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

  it 'should 200 if file found' do
    response = @request.get 'elf'
    response.status.should == 200
    response.body.should include('hello from the elf')
  end

  it 'should 200 if file found (with leading slash)' do
    response = @request.get '/elf'
    response.status.should == 200
    response.body.should include('hello from the elf')
  end

  it 'should 200 if file found (with trailing slash)' do
    response = @request.get 'elf/'
    response.status.should == 200
    response.body.should include('hello from the elf')
  end

  it 'should support directory_index' do
    require 'erb'
    Resir.filters.erb = lambda { |text| ERB.new(text).result(binding) }
    Resir.extensions.erb = lambda { |text| Resir.filters.erb.call text }
    response = @request.get '/'
    response.status.should == 200
    response.body.should == %{Hello From Index\n}
  end

  # move to filters and extensions spec ?
  it 'should render ERB if filter and extension defined' do
    Resir.filters.delete('erb')
    Resir.extensions.delete('erb')
    response = @request.get 'home'
    response.status.should == 200
    response.body.should == %{<%= "hello there!" %>\n}

    require 'erb'
    Resir.filters.erb = lambda { |text| ERB.new(text).result(binding) }
    response = @request.get 'home'
    response.status.should == 200
    response.body.should == %{<%= "hello there!" %>\n}

    Resir.extensions.erb = lambda { |text| Resir.filters.erb.call text }
    response = @request.get 'home'
    response.status.should == 200
    response.body.should == %{hello there!\n}
  end

  it 'should 404 if file not found' do
    response = @request.get 'bacon'
    response.status.should == 404
    response.body.should include('File Not Found')
  end

end
