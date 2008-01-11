require File.dirname(__FILE__) + '/spec_helper'

describe Resir, 'filters' do

  it 'should be initialized' do
    Resir.filters.should_not be_nil
  end

end

describe Resir, 'extensions' do

  it 'should be initialized' do
    Resir.extensions.should_not be_nil
  end

  it 'should get the extensions for a filename' do
    Resir::get_extensions('file').should == []
    Resir::get_extensions('file.mkd').should == %w(mkd)
    Resir::get_extensions('file.mkd.erb').should == %w(erb mkd)
    Resir::get_extensions('file.mkd.erb.erb').should == %w(erb erb mkd)
    Resir::get_extensions('file.mkd.erb.erb.txt.html').should == %w(html txt erb erb mkd)
  end

end
