require 'rubygems'
require 'agama'
require 'agama/adapters/tokyocabinet'
require 'pp'

def printl
  puts "\n---------------------------------------\n"  
end

graph = Agama::Graph.new( :path => "/tmp", 
                          :db   => Agama::Adapters::TC.new)
graph.open

# Inserting Data

# Nodes
File.open("data/nodes").each_line do |l|
  cols = l.chomp.split("\t")
  graph.set_node( :name       => cols[1],
                  :type       => cols[0],
                  :importance => cols[2].to_i )
end
puts "Loaded nodes"

# Edges
File.open("data/edges").each_line do |l|
  cols = l.chomp.split("\t")
  directed = ["I", "O"].include? cols[5]
  graph.set_edge( :from     => {:name => cols[2], :type => cols[1]},
                  :to       => {:name => cols[4], :type => cols[3]},
                  :type     => cols[0],
                  :directed => directed,
                  :weight   => cols[6].to_i )
end
puts "Loaded edges"

# Fetching Data

# Nodes
node_i = graph.get_node(:name => "i", :type => "triangle")
node_j = graph.get_node(:name => "j", :type => "circle")
pp node_i, node_j
printl

# Edges
edge_ij = graph.get_edge(:from => node_i, :to => node_j, :type => "dotted")
pp edge_ij
printl

# Neighbours
graph.neighbours(node_i).each do |edge|
	pp edge
end
printl

graph.neighbours(node_i).along("dotted").each do |edge|
	p edge
end
printl

graph.neighbours(node_i).along("dotted").outgoing.each do |edge|
	p edge
end
printl

graph.neighbours(node_i).along("dotted").outgoing.of_type("circle").each do |edge|
	p edge
end
printl

# Other properties 
pp graph.node_count
pp graph.node_count("square")
pp graph.edge_count

graph.close





