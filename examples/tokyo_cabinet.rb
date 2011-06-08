require 'rubygems'
require 'tokyocabinet'
include TokyoCabinet
require 'pp'
=begin
h = HDB::new
h.open("/tmp/nodes.tch", HDB::OWRITER | HDB::OCREAT)
puts h.size
h.each {|k,v| pp [k, Marshal.load(v)] }
h.close
=end
b = BDB::new
b.open(ARGV[0] + "/edges.tcb", BDB::OWRITER | BDB::OCREAT)
puts b.size
#b.each {|k,v| pp [k, Marshal.load(v)] }
b.close
#=end
h = HDB::new
h.open(ARGV[0] + "/meta.tch", HDB::OWRITER | HDB::OCREAT)
puts h.size
h.each do |k,v|
	if (k[0] == "e"[0]) 
		pp [k, Marshal.load(v)]
	else
		pp [k,v]
	end
end
h.close
