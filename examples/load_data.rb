require 'rubygems'
require 'agama'
require 'agama/adapters/tokyocabinet'
require 'pp'

g = Agama::Loader.new(:path => "/tmp", 
                      :db   => Agama::Adapters::TC.new)

g.open
                      
g.load_nodes_file("/tmp/n") do |cols, hash|
  hash[:name]   = cols[1]
  hash[:weight] = cols[2]
end

g.close
