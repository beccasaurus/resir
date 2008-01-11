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

    sites.select {|s| s.root_directory == "#{ambrose}/starmonkey" }.site_public_directory.should == 'public'
    sites.select {|s| s.root_directory == "#{ambrose}/the_elf/pet_ham" }.site_public_directory.should == 'public'
    sites.select {|s| s.root_directory == "#{ambrose}/trady_blix" }.site_public_directory.should == 'pardon_our_mess_folks/shuffle_right_past_the_little_fellow'
  end

  it "should resirize an Array of Resir::Sites"

end

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
