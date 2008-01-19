require 'time'

# Respresent a snip or snippet of code for resir
#
# Snips are basically shared .resirrc and/or .siterc files
#
# A snip could be your personal .resirrc and would allow for someone 
# else to include your .resirrc in theirs (instead of having to copy/paste)
#
class Resir::Snip

  attr_accessor :full_source, :author, :dependencies, :changelog, :date, :source, :description, :name, :version

  def initialize file_or_text = nil

    if File.file?file_or_text
      @full_source = File.read file_or_text
      name_parts   = /(.*)\.([\d]{0,10})\.\w{0,4}/.match File.basename( file_or_text )
      @name        = name_parts[1] if name_parts
      @version     = name_parts[2] if name_parts
    else
      @full_source = file_or_text
    end
    
    set_defaults
    parse
  end

  def set_defaults
    @dependencies = []
  end

  def source
    @full_source[/\n^[^#].*/m]
  end

  def header
    @full_source.gsub /\n^[^#].*/m , ''
  end

  def header_vars
    return @header_vars if @header_vars
      
    @header_vars = {}
    current_header_var = nil

    self.header.each_line do |line|
      
      line = line.chomp.gsub /^#/, ''
      match = /^[\s]?(\w+):(.*)$/.match line
      
      if match
        current_header_var               = match[1].strip.downcase
        @header_vars[current_header_var] = match[2].strip  
      elsif not current_header_var.nil?
        @header_vars[current_header_var] << ( "\n" + line )
      end

    end

    @header_vars
  end

  def author_name
    author ? author.gsub( /<(.*)>/, '' ).strip : nil
  end

  def author_email
    match = /<(.*)>/.match(author)
    match ? match[1] : nil
  end

  def changelog_summary
    changelog ? changelog.strip[/.*/] : nil
  end

  def parse
    %w( author changelog date dependencies description ).each do |var|
      instance_variable_set "@#{var}", header_vars[var] if header_vars.keys.include?var
    end
    @dependencies = @dependencies.gsub( /[,;]/ , ' ').split if @dependencies and @dependencies.is_a?String
    @date = Time.parse @date if @date and @date.is_a?String
  end

  def self.parse obj
    return ( obj.to_s.strip.empty? ) ? nil : Resir::Snip.new( obj.to_s )
  end

end
