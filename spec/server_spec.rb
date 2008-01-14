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
    Resir::Server::default_paths(site).should == ['http://crazy_star_monkey/','/crazy_star_monkey']
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
    server.urls.keys.should include('http://starmonkey/')
    server.urls.keys.should include('/starmonkey')
  end

  it 'should find sites when initialized with one directory' do
    # ambrose/starmonkey
    # ambrose/trady_blix
    # ambrose/the_elf/pet_ham
    server = Resir::Server.new 'examples/ambrose'
    server.sites.length.should == 3
    server.urls.length.should == 6
    server.urls.keys.should include('http://starmonkey/')
    server.urls.keys.should include('/starmonkey')
    server.urls.keys.should include('http://pet_ham/')
    server.urls.keys.should include('/pet_ham')
  end

  it 'should find sites when initialized with many directories (all in same directory)' do
    prefix = 'examples/ambrose'
    server = Resir::Server.new "#{prefix}/starmonkey", "#{prefix}/trady_blix", 
      "#{prefix}/the_elf/pet_ham"
    server.sites.length.should == 3
    server.urls.length.should == 6
    server.urls.keys.should include('http://starmonkey/')
    server.urls.keys.should include('/starmonkey')
    server.urls.keys.should include('http://pet_ham/')
    server.urls.keys.should include('/pet_ham')
  end

  it 'should only have UNIQUE sites passed in (including duplicates and bogus dirs)' do
    prefix = 'examples/ambrose'
    server = Resir::Server.new "#{prefix}/starmonkey", "#{prefix}/the_elf", "#{prefix}/trady_blix", 
      "#{prefix}/the_elf/pet_ham", "#{prefix}", "/i/no/exist", "#{prefix}/starmonkey"
    server.sites.length.should == 3
    server.urls.length.should == 6
    server.urls.keys.should include('http://starmonkey/')
    server.urls.keys.should include('/starmonkey')
    server.urls.keys.should include('http://pet_ham/')
    server.urls.keys.should include('/pet_ham')
  end

  it 'should find sites when initialized with many directories (all over the place)' do
    server = Resir::Server.new 'examples/ambrose', 'examples/for_stories', 'examples/layout_test'
    server.sites.length.should == 5 # ambrose [3], for_stories [1], layout_test [1]
    server.urls.length.should == 10
  end

  #       @site    = Resir::Site.new 'examples/ambrose/starmonkey'
  #       @request = Rack::MockRequest.new @site
  #       response = @site.call Rack::MockRequest::env_for('/some/path')
  #       response = @request.get '/some/path'
  it 'should be callable' do
    server = Resir::Server.new 'examples'
    response = server.call Rack::MockRequest::env_for('/starmonkey')
    response.should_not be_nil
    response.should be_a_kind_of(Array)
    response.first.should be_a_kind_of(Fixnum)
    response[1].should be_a_kind_of(Hash)
  end

  it 'should return 404 on invalid request' do
    server = Resir::Server.new 'examples'
    request = Rack::MockRequest.new server
    response = request.get '/some/crazy/nonexistent/path'
    response.status.should == 404

    response = request.get '/starmonkey/no-home-here'
    response.status.should == 404
  end

  it 'should return 200 on valid request' do
    server = Resir::Server.new 'examples'
    request = Rack::MockRequest.new server

    response = request.get '/starmonkey'
    response.status.should == 200

    response = request.get '/starmonkey/home'
    response.status.should == 200

    puts "TRYING TO CALL starmonkey / home ... "
    response = request.get 'http://starmonkey/home'
    response.status.should == 200
  end

  it 'should run a single site'

  it 'should run multiple sites'

  it 'should display the available sites when hitting any host that does not map to a site'

end
