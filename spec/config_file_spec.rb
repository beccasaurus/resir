require File.dirname(__FILE__) + '/spec_helper'

describe 'resirrc config files' do

end

describe 'siterc config files' do

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
