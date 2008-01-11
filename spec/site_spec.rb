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

end
