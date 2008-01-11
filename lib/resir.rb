$:.unshift File.expand_path(File.dirname(__FILE__))
require 'resir/extensions'

class Resir
  
  # setup Resir variable Hash
  @variables = {}
  class << self
    attr_accessor :variables
    alias vars variables ; alias :vars= :variables=
  end
  def self.method_missing name, *a
    begin
      self.variables.send name, *a
    rescue
      super name, *a
    end
  end 

  # load ~/.resirrc if it exists ( path is not customizable )
  def self.initialize
    resirrc = File.expand_path '~/.resirrc'
    load resirrc if File.file?resirrc
  end
  initialize

end
