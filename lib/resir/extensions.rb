#Dir[ File.dirname(__FILE__) + '/extensions/*.rb' ].each { |extension| load extension }
%w(metaid inflector inflections hash).each { |extension| load File.dirname(__FILE__) + "/extensions/#{extension}.rb" }

# misc extensions / top-level methods with no homes

def lib_available? lib
  begin
    require lib
    true
  rescue LoadError
    false
  end
end

# out good friend, Symbol#to_proc ... ( borrowed from active_support )
class Symbol  
  # ["foo", "bar"].map &:reverse #=> ['oof', 'rab']
  def to_proc
     Proc.new{|*args| args.shift.__send__(self, *args)}
   end 
end

class Module
  # for, you know ... aliasing methods!  ( borrowed from active_support )
  def alias_method_chain(target, feature)
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1 ; yield(aliased_target, punctuation) if block_given?
    with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"
    alias_method without_method, target ; alias_method target, with_method
    case
      when public_method_defined?(without_method)    ; public target
      when protected_method_defined?(without_method) ; protected target
      when private_method_defined?(without_method)   ; private target
    end 
  end 
end

# make a class act like an indifferent hash with a static 'variables' hash
module IndifferentVariableHash
    attr_accessor :variables
    alias vars variables ; alias :vars= :variables=

    def method_missing name, *a
      begin
        self.variables.send name, *a
      rescue
        super name, *a
      end
    end 
end

# "6 days ago" style time ... taken from another project of mine ... borrowed from 'Wit' ... borrowed from gitweb
def timeago(time, options = {})
  start_date = options.delete(:start_date) || Time.new
  date_format = options.delete(:date_format) || :default
  delta_minutes = (start_date.to_i - time.to_i).floor / 60
  if delta_minutes.abs <= (8724*60) # eight weeks… I’m lazy to count days for longer than that
    distance = distance_of_time_in_words(delta_minutes);
    if delta_minutes < 0 
      "#{distance} from now"
    else
      "#{distance} ago"
    end 
  else
    return "#{time}" # "on #{system_date.to_formatted_s(date_format)}"
  end 
end

def distance_of_time_in_words(minutes)
  case
    when minutes < 1 
      "less than a minute"
    when minutes < 50
      "#{minutes} minutes" + (minutes > 1 ? 's' : '') 
    when minutes < 90
      "about one hour"
    when minutes < 1080
      "#{(minutes / 60).round} hours"
    when minutes < 1440
      "one day"
    when minutes < 2880
      "about one day"
    else
      "#{(minutes / 1440).round} days"
  end 
end
