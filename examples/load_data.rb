require 'rubygems'
require 'agama'
require 'agama/adapters/tokyocabinet'
require 'pp'

g = Agama::Loader.new(:path => "/tmp", 
                      :db   => Agama::Adapters::TC.new)

g.open
                      
g.load_nodes("data/nodes") do |cols, hash|
  hash[:name]   = cols[0]
  hash[:weight] = cols[1]
end

g.load_edges("data/bulk_edges") do |cols, hash|
  #pp cols
  hash[:from]         = Hash.new
  hash[:to]           = Hash.new
  hash[:directed]     = false
  hash[:from][:name]  = cols[0]
  hash[:to][:name]    = cols[1]
  hash[:direction]    = cols[2]
  hash[:weight]       = cols[3]
end

g.close
