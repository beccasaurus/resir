require File.dirname(__FILE__) + '/spec_helper'

describe Resir do

  it 'should get file extensions for filenames, from last to first' do
    Resir::get_extensions('index.mkd.erb').should == %w(erb mkd)
    Resir::get_extensions('index').should == []
    Resir::get_extensions('index.index').should == ['index']
    Resir::get_extensions('haml-test.haml').should == ['haml']
    Resir::get_extensions('haml-test.mkd.html.haml').should == %w(haml html mkd)
  end

  it 'should have access to filter(s) and extension(s) (without plural)' do
    Resir.filters.my_test = lambda { |t,b| "hello world" }
    Resir.filters.keys.should include('my_test')
    Resir.filter.keys.should include('my_test')
    Resir.filter.another_test = lambda { |t,b| "hi there" }
    Resir.filter.keys.should include('another_test')
    Resir.filters.keys.should include('another_test')

    Resir.extensions.my_test = lambda { |t,b| "hello world" }
    Resir.extensions.keys.should include('my_test')
    Resir.extension.keys.should include('my_test')
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

  it "should allow me to render a full path to a filename" do
    Resir.filter_and_extension.demo = lambda { |text,b| text.gsub('spam','chunky') }
    Resir.filter_and_extension.test = lambda { |text,b| text.gsub('eggs','bacon') }
    # 'the spam and eggs are yummy'
    file = File.dirname(__FILE__) + '/../examples/misc/render-me.test.demo'
    Resir::render(file,binding).should == 'the chunky and bacon are yummy'
  end

  it "should allow me to render a template string String (including arguments of extension names)" do
    Resir.filter_and_extension.erb = lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
    Resir::render('hello <%= "there" %>', binding, 'erb').should == 'hello there'
  end
  
  it "should allow me to render a template string String (including an array of extension names)" do
    Resir.filter_and_extension.erb = lambda { |text,b| require 'erb'; ERB.new(text).result(b) }
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

  # make a few more example dirs and confirm sites all load (use 1 top lvl and 2/3 subdirs)
  it "should return an Array of Resir::Site's from *directories"

  it "should return an Array of Resir::Site's from a directory" do
    ambrose = 'examples/ambrose'
    File.directory?(ambrose).should == true
    sites = Resir::sites(ambrose)
    dirs = sites.collect{|s| s.root_directory}
    #     examples/ambrose/
    #       |-- starmonkey
    #     |   |-- .siterc
    #     |   `-- public
    #     |-- the_elf
    #     |   `-- pet_ham
    #     |       |-- .siterc
    #     |       `-- public
    #     `-- trady_blix
    #         |-- .siterc
    #             `-- pardon_our_mess_folks
    #                     `-- shuffle_right_past_the_little_fellow
    sites.should be_a_kind_of(Array)
    sites.length.should == 3
    dirs.should include("#{ambrose}/starmonkey")
    dirs.should include("#{ambrose}/the_elf/pet_ham")
    dirs.should include("#{ambrose}/trady_blix")

    sites.find {|s| s.root_directory == "#{ambrose}/starmonkey" }.public_directory.should == 'public'
    sites.find {|s| s.root_directory == "#{ambrose}/the_elf/pet_ham" }.public_directory.should == 'public'
    sites.find {|s| s.root_directory == "#{ambrose}/trady_blix" }.public_directory.should == 'pardon_our_mess_folks/shuffle_right_past_the_little_fellow'
  end

  it "should resirize an Array of Resir::Sites"

end
