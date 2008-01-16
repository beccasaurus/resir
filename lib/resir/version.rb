class Resir

  module VERSION
    MAJOR = 0
    MINOR = 4
    TINY  = 0
    
    SCM = 67
    
    # ^ SCM set via script : `git log --pretty=oneline | wc -l`.strip

    STRING = [MAJOR, MINOR, TINY, SCM].join('.')
  end

end
