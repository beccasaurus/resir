require 'bacon'

describe "a chunky test" do

  before do
    @str = "My String"
  end

  it 'should be a string' do
    @str.should.be.a.kind_of String
  end

end
