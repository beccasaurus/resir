require File.dirname(__FILE__) + '/spec_helper'

describe Resir do

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
    Resir.site_public_directory.should == 'public'
  end

  it "should return an Array of Resir::Site's from *directories"

  it "should return an Array of Resir::Site's from a directory" do
    ambrose = 'examples/ambrose'
    File.directory?(ambrose).should == true
    sites = Resir::sites(ambrose)
    dirs = sites.collect{|s| s.root_directory}
    #     examples/ambrose/
    #       |-- pet_ham
    #     |   `-- public
    #     |-- starmonkey
    #     |   |-- .siterc
    #     |   `-- public
    #     |-- the_elf
    #     `-- trady_blix
    #         `-- pardon_our_mess_folks
    #                 |-- .siterc
    #                         `-- shuffle_right_past_the_little_fellow
    sites.should be_a_kind_of(Array)
    sites.length.should == 2
    dirs.should include("#{ambrose}/starmonkey")
    dirs.should include("#{ambrose}/trady_blix/pardon_our_mess_folks")
  end

  it "should resirize an Array of Resir::Sites"

end

describe Resir::Site do

  it "should act like an indifferent Hash"

end
