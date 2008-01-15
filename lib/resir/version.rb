class Resir

  module VERSION
    MAJOR = 0
    MINOR = 3
    TINY  = 0
    
    SCM = 61
    
    # ^ SCM set via script : `git log --pretty=oneline | wc -l`.strip

    STRING = [MAJOR, MINOR, TINY, SCM].join('.')
  end

end
