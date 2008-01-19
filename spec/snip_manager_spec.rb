require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Snip::Manager do

  def get_new
    Resir::Snip::Manager.new Resir::snip_repo, File.dirname(__FILE__) + '/../example_snips'
  end

  it 'should complain if you load up your snip directory and try to install TO your snip directory' do
    manager = Resir::Snip::Manager.new Resir::snip_repo, Resir::snip_repo
    lambda { manager.install(:sass) }.should raise_error
  end

  it 'should list snips on remote server' do
    manager = get_new

    manager.list_remote.should include('sass')
    manager.list_remote.should include('haml')
  end

  it 'should list locally installed snips' do
    manager = get_new

    manager.install :sass
    manager.uninstall :haml
    manager.list_local.should include('sass')
    manager.list_local.should_not include('haml')
    manager.uninstall :sass
  end

  it 'should be able to search for snips, searching name (with preference) but also searching the description' do
    manager = get_new

    manager.search( 'filter' ).length.should >= 2
    manager.search( 'filter' ).map(&:name).sort.should == %w( erb haml sass ) # no test
  end

  it "should be able to show a snip's information" do
    sass_show = get_new.show( :sass )
    sass_show.should include('0100')
    sass_show.should include('SASS filter')
    sass_show.should include('Joe Somebody')
    sass_show.should include('joe.somebody@')
  end

  it "should be able to find the full path to the current version of a snip, from its name" do
    get_new.remote_path(:sass).should == File.expand_path( File.dirname(__FILE__) + '/../example_snips/sass.0100.rb' )

    get_new.install :sass
    get_new.local_path(:sass).should == File.expand_path( File.join(Resir::snip_repo, 'sass.0100.rb') )
    get_new.uninstall :sass
    get_new.local_path(:sass).should == nil
  end

  it "should be able install snips and tell if a snip is .installed?" do
    manager = get_new
    manager.uninstall :sass
    manager.installed?(:sass).should == false
    manager.install :sass
    manager.installed?(:sass).should_not == false
    manager.uninstall :sass
    manager.installed?(:sass).should == false
  end

  it "should be able to get logs for an snippet, with pretty '2 hours ago' style dates" do
    log = get_new.log :sass
    log.should include('100')
    log.should include('99')
    log.should include('disabled layout')
    log.should include('first line here')
  end

  it "should be able to read a snip, returning its text, either remotely or locally" do
    manager = get_new

    remote = manager.read_remote( :sass )
    remote.should_not be_nil
    remote.should include('@layout = nil')

    manager.uninstall :sass
    manager.read_local( :sass ).should be_nil

    manager.install :sass
    local = manager.read_local( :sass )
    local.should_not be_nil
    local.should include('@layout = nil')

    manager.uninstall :sass
  end

end
