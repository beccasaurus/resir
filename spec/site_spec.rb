require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Site do

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
