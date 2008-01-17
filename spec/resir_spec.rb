require File.dirname(__FILE__) + '/spec_helper'

describe Resir do

  it 'should have the path to the gem directory and helpers and filters' do
    resir_dir   = File.expand_path(File.dirname(__FILE__) + '/..')
    helper_path = File.join resir_dir, 'lib/resir/helpers'
    filter_path = File.join resir_dir, 'lib/resir/filters'

    Resir::path_to_resir.should == resir_dir
    Resir::helper_search_path.should include(helper_path)
    Resir::filter_search_path.should include(filter_path)

    Resir::helper_search_path.should include('.')
    Resir::filter_search_path.should include('.')

    Resir::helper_search_path.should include('~/.resir')
    Resir::filter_search_path.should include('~/.resir')

    Resir::helper_search_path.should include('~/.resir/helpers')
    Resir::filter_search_path.should include('~/.resir/filters')
  end

  it 'should get file extensions for filenames, from last to first' do
    Resir::get_extensions('index.mkd.erb').should == %w(erb mkd)
    Resir::get_extensions('index').should == []
    Resir::get_extensions('index.index').should == ['index']
    Resir::get_extensions('haml-test.haml').should == ['haml']
    Resir::get_extensions('haml-test.mkd.html.haml').should == %w(haml html mkd)
  end

  it "should have an initialized variable Hash" do
    Resir::variables.should be_a_kind_of(Hash)
    Resir::vars.should be_a_kind_of(Hash)
  end

  it "should act like an indifferent Hash" do
    Resir.testing = 123
    Resir::variables['testing'].should == 123
    Resir.variables.testing.should == 123
    Resir.vars.testing.should == 123
    Resir['testing'].should == 123
    Resir.testing.should == 123
  end

  it "should be able to clear and re-initialize" do
    Resir.length.should > 0
    Resir.clear
    Resir.length.should == 0
    Resir.initialize
    Resir.length.should > 0
  end

  it "should have default config settings" do
    Resir.site_rc_file.should == '.siterc'
    Resir.public_directory.should == 'public'
  end

  it "should allow me to render a template string String (including arguments of extension names)" do
    Resir.loaded_filters.erb = lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
    Resir::render('hello <%= "there" %>', binding, 'erb').should == 'hello there'
  end
  
  it "should allow me to render a template string String (including an array of extension names)" do
    Resir.loaded_filters.erb = lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
    Resir::render('hello <%= "there" %>', binding, ['erb']).should == 'hello there'
  end

  it "should allow me to render a template string String (including a #callable filter/extension)" do
    my_filter = lambda { |text,b| ">>>>#{text}<<<<" }
    Resir::render("hi there", binding, my_filter).should == '>>>>hi there<<<<'
  end

  it "should allow me to render a template string String (including a an array of #callable filters/extensions)" do
    my_filter = lambda { |text,b| ">>>>#{text}<<<<" }
    my_other_filter = lambda { |text,b| "[ #{text} ]" }
    Resir::render("hi there", binding, [my_filter, my_other_filter]).should == '[ >>>>hi there<<<< ]'
  end

  it "should allow me to render a template string String (including arguments of #callable filters/extensions)" do
    my_filter = lambda { |text,b| ">>>>#{text}<<<<" }
    my_other_filter = lambda { |text,b| "[ #{text} ]" }
    Resir::render("hi there", binding, my_filter, my_other_filter ).should == '[ >>>>hi there<<<< ]'
  end

  it "should return an Array of Resir::Site's from a directory" do
    ambrose = 'examples/ambrose'
    File.directory?(ambrose).should == true
    sites = Resir::sites(ambrose)
    dirs = sites.collect{|s| s.root_directory}
    sites.should be_a_kind_of(Array)
    sites.length.should == 3
    dirs.should include("#{ambrose}/starmonkey")
    dirs.should include("#{ambrose}/the_elf/pet_ham")
    dirs.should include("#{ambrose}/trady_blix")

    sites.find {|s| s.root_directory == "#{ambrose}/starmonkey" }.public_directory.should == 'public'
    sites.find {|s| s.root_directory == "#{ambrose}/the_elf/pet_ham" }.public_directory.should == 'public'
    sites.find {|s| s.root_directory == "#{ambrose}/trady_blix" }.public_directory.should == 'pardon_our_mess_folks/shuffle_right_past_the_little_fellow'
  end

end
