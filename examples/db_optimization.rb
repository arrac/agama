require 'rubygems'
require 'agama'
require 'agama/adapters/tokyocabinet'
require 'pp'

db = Agama::Adapters::TC.new
=begin
e_tune => [lmemb, nmemb, bnum, apow, fpow, opts]

  Set the tuning parameters.
  `lmemb' specifies the number of members in each leaf page. 
    If it is not defined or not more than 0, the default value is specified. The default value is 128.
  `nmemb' specifies the number of members in each non-leaf page. 
    If it is not defined or not more than 0, the default value is specified. The default value is 256.
  `bnum' specifies the number of elements of the bucket array. 
    If it is not defined or not more than 0, the default value is specified. The default value is 32749. 
    Suggested size of the bucket array is about from 1 to 4 times of the number of all pages to be stored.
  `apow' specifies the size of record alignment by power of 2. 
    If it is not defined or negative, the default value is specified. The default value is 4 standing for 2^8=256.
  `fpow' specifies the maximum number of elements of the free block pool by power of 2. 
    If it is not defined or negative, the default value is specified. The default value is 10 standing for 2^10=1024.
  `opts' specifies options by bitwise-or: 
    `TokyoCabinet::BDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, 
    `TokyoCabinet::BDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, 
    `TokyoCabinet::BDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, 
    `TokyoCabinet::BDB::TTCBS' specifies that each record is compressed with TCBS encoding. 
    If it is not defined, no option is specified.
    
e_cache => [lcnum, ncnum]

  Set the caching parameters.
  `lcnum' specifies the maximum number of leaf nodes to be cached. 
    If it is not defined or not more than 0, the default value is specified. The default value is 1024.
  `ncnum' specifies the maximum number of non-leaf nodes to be cached. 
    If it is not defined or not more than 0, the default value is specified. The default value is 512.

n_tune => [bnum, apow, fpow, opts]

  Set the tuning parameters.
  `bnum' specifies the number of elements of the bucket array. 
    If it is not defined or not more than 0, the default value is specified. The default value is 32749. 
    Suggested size of the bucket array is about from 1 to 4 times of the number of all pages to be stored.
  `apow' specifies the size of record alignment by power of 2. 
    If it is not defined or negative, the default value is specified. The default value is 4 standing for 2^8=256.
  `fpow' specifies the maximum number of elements of the free block pool by power of 2. 
    If it is not defined or negative, the default value is specified. The default value is 10 standing for 2^10=1024.
  `opts' specifies options by bitwise-or: 
    `TokyoCabinet::BDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, 
    `TokyoCabinet::BDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, 
    `TokyoCabinet::BDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, 
    `TokyoCabinet::BDB::TTCBS' specifies that each record is compressed with TCBS encoding. 
    If it is not defined, no option is specified.
    
n_cache => [rcnum]
  Set the caching parameters.
  `rcnum' specifies the maximum number of records to be cached. 
    If it is not defined or not more than 0, the record cache is disabled. It is disabled by default.
=end
db = Agama::Adapters::TC.new( :e_tune   => [2048, 4096, 2**40-1, 8, 10, TokyoCabinet::BDB::TLARGE],
                              :e_cache  => [4096, 9192],
                              :n_tune   => [(2**32)-1, 8, 10, 0],
                              :n_cache  => [0]  )

g = Agama::Loader.new(:path => "/tmp", 
                      :db   => db)

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
