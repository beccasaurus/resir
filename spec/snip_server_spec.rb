require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Snip::Server do

  it 'should load all Snips from a directory' do
    Resir::Snip::Server.new('/some/crazy/dir').snips.should be_empty
    server = Resir::Snip::Server.new(File.dirname(__FILE__) + '/../example_snips')
    puts server.snips.map(&:name).inspect
    server.all_snips.length.should == 5 # retuns old versions, too
    server.snips.length.should == 4 # only returns CURRENT snips
    server.all_snips.map(&:name).sort.should == %w( erb haml sass sass test )
    server.snips.map(&:name).sort.should == %w( erb haml sass test )
  end

end
