require File.dirname(__FILE__) + '/spec_helper'

describe Resir::Site::Responder do

  it "should response to #call" do
    Resir::Site::Responder.new(nil).should respond_to(:call)
  end

end
