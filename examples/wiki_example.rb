require 'rubygems'
require 'agama'
require 'agama/adapters/tokyocabinet'
require 'pp'


graph = Agama::Graph.new( :path => "/tmp", 
                          :db   => Agama::Adapters::TC.new)
                          
                          
                          
graph.open


#Inserting Nodes

na = graph.set_node(:name => "a", :type => "triangle", :importance => 1)
nb = graph.set_node(:name => "b", :type => "square", :importance => 6)
nc = graph.set_node(:name => "c", :type => "circle", :importance => 3)
nd = graph.set_node(:name => "d", :type => "square", :importance => 2)
ne = graph.set_node(:name => "e", :type => "circle", :importance => 4)
nf = graph.set_node(:name => "f", :type => "square", :importance => 7)
ng = graph.set_node(:name => "g", :type => "circle", :importance => 2)
nh = graph.set_node(:name => "h", :type => "triangle", :importance => 6)
ni = graph.set_node(:name => "i", :type => "triangle", :importance => 8)
nj = graph.set_node(:name => "j", :type => "circle", :importance => 3)
nk = graph.set_node(:name => "k", :type => "circle", :importance => 5)

#Fetching Nodes
=begin
na = graph.get_node(:name => "a", :type => "rhombus")

nb = graph.get_node(:name => "b", :type => "circle")

nc = graph.get_node(:name => "c", :type => "circle")

nd = graph.get_node(:name => "d", :type => "rhombus")

ne = graph.get_node(:name => "e", :type => "square")

p na[:importance], nb[:importance], nc[:importance], nd[:importance], ne[:importance]
p na, nb, nc, nd, ne
p graph.node_count
#graph.close
=end

#Inserting Edges

graph.set_edge(:from => nb,
               :to => na,
               :type => "dotted",
               :directed => true,
               :weight => 1)          
graph.set_edge(:from => nc,
               :to => nb,
               :type => "dotted",
               :directed => true,
               :weight => 5)
graph.set_edge(:from => nc,
               :to => nd,
               :type => "line",
               :directed => false,
               :weight => 3)
graph.set_edge(:from => na,
               :to => nk,
               :type => "line",
               :weight => 4)
graph.set_edge(:from => nd,
               :to => ne,
               :type => "dotted",
               :directed => true,
               :weight => 9)
graph.set_edge(:from => nb,
               :to => ne,
               :type => "dotted",
               :directed => true,
               :weight => 7)
graph.set_edge(:from => nk,
               :to => nb,
               :type => "dotted",
               :directed => true,
               :weight => 6)
graph.set_edge(:from => nj,
               :to => nk,
               :type => "dotted",
               :directed => true,
               :weight => 1)
graph.set_edge(:from => nj,
               :to => nb,
               :type => "line",
               :directed => false,
               :weight => 3)
graph.set_edge(:from => ni,
               :to => nj,
               :type => "dotted",
               :directed => true,
               :weight => 2)
graph.set_edge(:from => ni,
               :to => nh,
               :type => "dotted",
               :directed => true,
               :weight => 2)
graph.set_edge(:from => ne,
               :to => ni,
               :type => "line",
               :directed => false,
               :weight => 6)
graph.set_edge(:from => nb,
               :to => ni,
               :type => "dotted",
               :directed => true,
               :weight => 11)
graph.set_edge(:from => nf,
               :to => ne,
               :type => "dotted",
               :directed => true,
               :weight => 8)
graph.set_edge(:from => ng,
               :to => ne,
               :type => "line",
               :directed => false,
               :weight => 8)
graph.set_edge(:from => ng,
               :to => nf,
               :type => "dotted",
               :directed => true,
               :weight => 6)
graph.set_edge(:from => nh,
               :to => ng,
               :type => "line",
               :directed => false,
               :weight => 5)
graph.close

=begin
#Fetching edges

eab = graph.get_edge(:from => na, :to => nb, :type => "dotted")

ecb = graph.get_edge(:from => nb, :to => nc, :type => "line") #Note: Direction reversed

ebd = graph.get_edge(:from => nb, :to => nd)

ede = graph.get_edge(:from => nd, :to => ne)

#p eab[:weight], ecb[:weight], ebd[:weight], ede[:weight] 
p eab, ecb, ebd, ede
p graph.edge_count
=end

graph.neighbours(ni).each do |edge|
	p edge
end

puts "\n---------------------------------------\n"

graph.neighbours(ni).along("dotted").each do |edge|
	p edge
end

puts "\n---------------------------------------\n"

graph.neighbours(ni).along("dotted").outgoing.each do |edge|
	p edge
end

puts "\n---------------------------------------\n"

graph.neighbours(ni).along("dotted").outgoing.of_type("circle").each do |edge|
	p edge
end
puts "\n---------------------------------------\n"

p graph.node_count
p graph.node_count("square")
p graph.edge_count

graph.close

