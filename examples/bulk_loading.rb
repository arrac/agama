require 'rubygems'
require 'agama'
require 'agama/adapters/tokyocabinet'
require 'pp'

g = Agama::Loader.new(:path => "/tmp", 
                      :db   => Agama::Adapters::TC.new)

g.open
                      
g.load_nodes("data/nodes") do |cols, hash|
  hash[:type]       = cols[0]
  hash[:name]       = cols[1]
  hash[:importance] = cols[2]
end

g.load_edges("data/bulk_edges") do |cols, hash|
  hash[:from]         = Hash.new
  hash[:to]           = Hash.new
  hash[:directed]     = ["I", "O"].include? cols[5]
  hash[:from][:type]  = cols[0]
  hash[:from][:name]  = cols[1]
  hash[:type]         = cols[2]
  hash[:to][:type]    = cols[3]
  hash[:to][:name]    = cols[4]
  hash[:direction]    = cols[5]
  hash[:weight]       = cols[6]
end

g.close
