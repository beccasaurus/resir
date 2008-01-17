require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Site do

  it 'should have the path to the gem directory and helpers and filters and local site' do
    site        = Resir::Site.new 'examples/ambrose/starmonkey'
    site_dir    = File.expand_path(site.root_directory)
    resir_dir   = File.expand_path(File.dirname(__FILE__) + '/..')
    helper_path = File.join resir_dir, 'lib/resir/helpers'
    filter_path = File.join resir_dir, 'lib/resir/filters'

    site.helper_search_path.should include(helper_path)
    site.filter_search_path.should include(filter_path)
    
    site.helper_search_path.should include(site_dir)
    site.filter_search_path.should include(site_dir)

    site.helper_search_path.should include('.')
    site.filter_search_path.should include('.')

    site.helper_search_path.should include(File.join site_dir, '.site')
    site.filter_search_path.should include(File.join site_dir, '.site')
  end

  it "should have access to the server holding it, if run by server" do
    server = Resir::Server.new 'examples'
    server.sites.length.should > 0
    server.sites.first.server.should == server
    server.sites.first.server.should === server
  end

  it "should have a .safe_name and .safe_host_name for using in paths and urls" do
    site = Resir::Site.new 'examples/ambrose/starmonkey'
    site.name = 'Some 5 Wild! .and - Crazy? _ Name:!'
    site.safe_name.should == 'Some5Wild.and-Crazy_Name'
    site.safe_host_name.should == 'Some5Wild.and-Crazy-Name'
  end

  it "should act like an indifferent Hash" do
    site = Resir::Site.new 'examples/ambrose/starmonkey'
    site.testing = 123
    site.variables['testing'].should == 123
    site.variables.testing.should == 123
    site.vars.testing.should == 123
    site['testing'].should == 123
    site.testing.should == 123
  end

  it "should find template files" do
    site = Resir::Site.new 'examples/ambrose/starmonkey'
    site.get_template('home').should == 'home.erb'
    site.get_template('home.mkd').should == 'home.mkd.erb'
    site.get_template('star').should == 'star.html'
    site.get_template('monkey').should == 'monkey.tidy.mkd.erb'
    site.get_template('elf').should == 'elf'
  end

  it 'should fall back to Resir.vars for config variables' do
    site = Resir::Site.new 'examples/ambrose/starmonkey'
    site.vars.delete 'fallback'
    site.vars.keys.should_not include('fallback')
    Resir.fallback = 'Site Should Fall Back To Me'
    site.fallback.should == 'Site Should Fall Back To Me'
    site.fallback = 'this is the SITES fallback'
    site.fallback.should == 'this is the SITES fallback'
    site.variables.delete 'fallback'
    site.fallback.should == 'Site Should Fall Back To Me'
    Resir.delete 'fallback'
    site.fallback = 'new sites fallback'
    site.fallback.should == 'new sites fallback'
  end

end
