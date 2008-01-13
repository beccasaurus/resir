require 'rack'

def setup_site site_directory
    @site = Resir::Site.new "#{site_directory}"
    @request = Rack::MockRequest.new @site
end
def request_path path, options = { :method => 'get' }
  @response = @request.send options[:method], path
end

steps_for(:example_website) do

  Given( "I goto site:? $site" ) do |site|
    setup_site "examples/#{site}"
  end
  
  When( "I visit $path" ) do |path|
    request_path path
  end
  
  Then( "I should see '$output'" ) do |output|
    @response.body.downcase.should include(output.downcase)
  end

  Then( "the output should be '$output'" ) do |output|
    @response.body.should == "#{output}"
  end

  Then( "the status should be $status" ) do |status|
    @response.status.should == status.to_i
  end

end
