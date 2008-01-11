require File.dirname(__FILE__) + '/spec_helper'

describe Resir do

  it 'should have an initialized variable Hash' do
    Resir::variables.should be_a_kind_of(Hash)
    Resir::vars.should be_a_kind_of(Hash)
  end

  it 'should act like an indifferent Hash' do
    Resir.testing = 123
    Resir::variables['testing'].should == 123
    Resir.variables.testing.should == 123
    Resir.vars.testing.should == 123
    Resir['testing'].should == 123
    Resir.testing.should == 123
  end

  it "should return an Array of Resir::Site's from directories"

end
