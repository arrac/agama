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
    
    def load_nodes(file, type)
      case type
      when "tsv"
        tsv_load_nodes(file)
      when "dot"
        dot_load_nodes(file)
      end    
    end
    
    def tsv_load_nodes(file)
      File.open(file).each_line do |l|
        cols = l.chomp.split("\t")
        n = Hash.new
        yield cols, n
        if n.size > 0
          type = node[:type] || Config::DEFAULT_TYPE
          node[:type] = type
          
          key = Keyify.node(node)
          value = Marshal.dump(Keyify.clean_node(node)) #remove key items from value

          @db.n_put(key, value)
        end
      end
    end
  end
end
