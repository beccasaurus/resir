require File.dirname(__FILE__) + '/spec_helper'

describe Resir, 'filters and extensions' do

  it 'should be initialized' do
    Resir.filters.should_not be_nil
  end

  it 'should get the extensions for a filename' do
    Resir::get_extensions('file').should == []
    Resir::get_extensions('file.mkd').should == %w(mkd)
    Resir::get_extensions('file.mkd.erb').should == %w(erb mkd)
    Resir::get_extensions('file.mkd.erb.erb').should == %w(erb erb mkd)
    Resir::get_extensions('file.mkd.erb.erb.txt.html').should == %w(html txt erb erb mkd)
  end

end

describe 'default filters' do
  
  before do
    load 'lib/resir/filters.rb'
  end

  it 'should support erb' do
    Resir.render("hi <%= 'there' %>", nil, 'erb').should == 'hi there'
  end

  it 'should support haml' do
    Resir.render("%p hi there", nil, 'haml').should == '<p>hi there</p>'
  end

  it 'should support sass' do
    Resir.render(<<sass, nil, 'sass').should == "#home .special {\n  color: black; }"
#home
  .special
    :color black
sass
  end

  it 'should support markdown' do
    Resir.render('well _hello_ **there**', nil, 'mkd').should == '<p>well <em>hello</em> <strong>there</strong></p>'
  end

  it 'should support markaby' do
    Resir.render('h2("hello there!")', nil, 'mab').should == '<h2>hello there!</h2>'
  end

  it 'should support textile' do
    Resir.render('h4. hello hello', nil, 'text').should == '<h4>hello hello</h4>'
  end

  after do
    Resir.filters.clear
  end

end
