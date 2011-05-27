require 'tokyocabinet'
include TokyoCabinet

module Agama
  module Adapters
    class TC
   
      def initialize(params = {})
        @e_tune  = params[:e_tune]  || nil
        @e_cache = params[:e_cache] || nil
        @n_tune  = params[:n_tune]  || nil
        @n_cache = params[:n_cache] || nil
      end
          
      def open (path)
        @meta = HDB::new        
        # open the meta database
        if !@meta.open(path + "/meta.tch", HDB::OWRITER | HDB::OCREAT)
          ecode = @meta.ecode
          raise "Error opening meta_db: #{@meta.errmsg(ecode)}"
        end

        @nodes = HDB::new        
        
        @nodes.tune(@n_tune[0], @n_tune[1], @n_tune[2], @n_tune[3]) if @n_tune      
        @nodes.setcache(@n_cache[0]) if @n_cache

        # open the nodes database
        if !@nodes.open(path + "/nodes.tch", HDB::OWRITER | HDB::OCREAT)
          ecode = @nodes.ecode
          raise "Error opening nodes_db: #{@nodes.errmsg(ecode)}"
        end
        
        @edges = BDB::new       
        
        @edges.tune(@e_tune[0], @e_tune[1], @e_tune[2], @e_tune[3], @e_tune[4], @e_tune[5]) if @e_tune      
        @edges.setcache(@e_cache[0], @e_cache[1]) if @e_cache
        
        # open the edges database
        if !@edges.open(path + "/edges.tcb", BDB::OWRITER | BDB::OCREAT)
          ecode = @edges.ecode
          raise "Error opening edges_db: #{@edges.errmsg(ecode)}"
        end
      end


      
      def close
        if !@meta.close
          ecode = @meta.ecode
          raise "Error closing meta_db: #{@meta.errmsg(ecode)}"
        end
        if !@nodes.close
          ecode = @nodes.ecode
          raise "Error closing nodes_db: #{@nodes.errmsg(ecode)}"
        end
        if !@edges.close
          ecode = @edges.ecode
          raise "Error closing edges_db: #{@edges.errmsg(ecode)}"
        end
      end



      
      def m_put (key, value)
        unless @meta.put(key, value)
          ecode = @meta.ecode
          raise "Error inserting meta_db: #{@meta.errmsg(ecode)}"
        end
      end
      
      def m_get (key)
        return @meta.get(key)
      end
      
      def m_del (key)
        unless @meta.out(key)
          ecode = @meta.ecode
          raise "Error deleting from meta_db: #{@meta.errmsg(ecode)}"
        end
      end




      def n_put (key, value)
        unless @nodes.put(key, value)
          ecode = @nodes.ecode
          raise "Error inserting into nodes_db: #{@nodes.errmsg(ecode)}"
        end
        
        true
      end
      
      def n_get (key)
        return @nodes.get(key)
      end
      
      def n_del (key)
        unless @nodes.out(key)
          ecode = @nodes.ecode
          raise "Error deleting from nodes_db: #{@nodes.errmsg(ecode)}"
        end
        
        true
      end
      
      
      def e_put (key, value)
        unless @edges.put(key, value)
          ecode = @edges.ecode
          raise "Error inserting into edges_db: #{@edges.errmsg(ecode)}"
        end
        
        true
      end
      
      def e_get (key)
        return @edges.get(key)
      end
      
      def e_del (key)
        unless @edges.out(key, value)
          ecode = @edges.ecode
          raise "Error deleting from edges_db: #{@edges.errmsg(ecode)}"
        end
        
        true
      end
      
      def e_cursor
        return TCCursor.new(@edges, "edge")
      end
      
    end
    
    class TCCursor
      def initialize(bptree, type)
        @c = BDBCUR::new(bptree)
        @t = type
      end
      
      def first
        @c.first
      end
      
      def last
        @c.last
      end
      
      def jump(key)
        @c.jump(key)
      end
      
      def prev
        @c.prev
      end
      
      def next
        @c.next
      end
      
      def key
        @c.key
      end
      
      def value
        @c.val
      end      
    end
  end
end
