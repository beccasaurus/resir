# Dir[ File.dirname(__FILE__) + '/filters/*.rb' ].each { |filter| load filter }
# %w(erb haml markaby markdown sass textile).each { |filter| load File.dirname(__FILE__) + "/filters/#{filter}.rb" }
Resir.load_filters *%w(erb haml markaby markdown sass textile)
