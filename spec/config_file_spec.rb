require File.dirname(__FILE__) + '/spec_helper'

describe 'resirrc config files' do

end

describe 'siterc config files' do

  it "it can manually add filters into site.filters" do
    Resir.filters.keys.should_not include('manual')

    site = Resir::Site.new 'examples/siterc_testing/first'
    req  = Rack::MockRequest.new site
    
    site.filters.keys.should include('manual')
    Resir.filters.keys.should_not include('manual')
    
    req.get('/page').body.should == 'manually set this filter in .siterc'
  end

  it "should have access to site (as 'site' or 'self')" do
    site = Resir::Site.new 'examples/siterc_testing/first'

    site.hello.should == 'hello from a new variable added by siterc'
    site.new_site_method.should == 'hello from new site method!'
    site.added_to_site.should == 'added this to var of name site'
  end

  it "can add helper methods by class_eval'ing onto [self.]responder" do
    site = Resir::Site.new 'examples/siterc_testing/first'
    req  = Rack::MockRequest.new site
    req.get('/').body.should == 'calling blah: BLAH'
  end

end
