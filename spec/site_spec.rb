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

end
