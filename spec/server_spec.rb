require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Server do

  # example sites in 'examples/'
  #
  #      ./partials_test/.siterc
  #      ./foxes/fox_tall/.siterc
  #      ./foxes/fox_small/.siterc
  #      ./layout_test/.siterc
  #      ./for_stories/.siterc
  #      ./ambrose/the_elf/pet_ham/.siterc
  #      ./ambrose/starmonkey/.siterc
  #      ./ambrose/trady_blix/.siterc
  #
  # calling reference:
  #
  #       @site    = Resir::Site.new 'examples/ambrose/starmonkey'
  #       @request = Rack::MockRequest.new @site
  #       response = @site.call Rack::MockRequest::env_for('/some/path')
  #       response = @request.get '/some/path'

  it 'should make the default paths based on the safe name of a site' do 
    site = Resir::Site.new 'examples/ambrose/starmonkey'
    site.name = '*! crazy _ star _ monkey !*'
    site.safe_name.should == 'crazy_star_monkey'
    Resir::Server::default_paths(site).should == ['http://crazy_star_monkey','/crazy_star_monkey']
  end

  it 'should find a single site when passed its directory' do
    server = Resir::Server.new 'examples/ambrose/starmonkey'
    server.sites.length.should == 1
    server.sites.first.name.should == 'starmonkey'
  end

  it 'should default to two urls for each site, one hostname and one path' do 
    server = Resir::Server.new 'examples/ambrose/starmonkey'
    server.sites.length.should == 1
    server.urls.length.should == 2
    server.urls.keys.should include('http://starmonkey')
    server.urls.keys.should include('/starmonkey')
  end

  it 'should find sites when initialized with one directory'

  it 'should find sites when initialized with many directories'

  it 'should be callable'

  it 'should run a single site'

  it 'should run a single site LIKE multiple sites, with URLMap support'

  it 'should run multiple sites'

  it 'should display the available sites when hitting any host or path that does not map to a site'

end
