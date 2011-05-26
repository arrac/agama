module Agama
  class Loader
    def initialize(params)
      @db_path  = params[:path] || "./"
      @db       = params[:db]
    end

    def open
      @db.open(@db_path)
    end

    def close
      @db.close
    end
    
    def load_nodes(file)
      File.open(file).each_line do |l|
        cols = l.chomp.split("\t")
        node = Hash.new
        yield cols, node
        if node.size > 0
          type = node[:type] || Config::DEFAULT_TYPE
          node[:type] = type
          
          key = Keyify.node(node)
          value = JSON.generate(Keyify.clean_node(node)) #remove key items from value

          @db.n_put(key, value)
        end
      end
    end

    def load_edges(file)
      File.open(file).each_line do |l|
        cols = l.chomp.split("\t")
        edge = Hash.new
        yield cols, edge
        if edge.size > 0 and edge[:from][:name] and edge[:to][:name] 
          type = edge[:type] || Config::DEFAULT_TYPE
          edge[:type] = type
          raise "Unknown edge direction" unless (["I", "O", "N"].include?(edge[:direction]))
          rev = false
          if edge[:direction] == "I"
            tmp         = edge[:from]
            edge[:from] = edge[:to]
            edge[:to]   = tmp
            rev = true 
          end
          
          if ["I", "O"].include? edge[:direction]
            edge[:directed] = true
          else
            edge[:directed] = false            
          end
          edge.delete(:direction)
          
          key, rev_key  = Keyify.edge(edge)
          value         = JSON.generate(Keyify.clean_edge(edge)) #remove key items from value

          if rev
            @db.e_put(rev_key, value)
          else
            @db.e_put(key, value)
          end
        end
      end
    end

  end
end
