module Agama
  class Traverser

    attr_accessor :params

    def initialize(db, graph)
      @cursor = db.e_cursor
      @search_key = ""
      @unset = true
      @graph = graph
      @from = nil
      @params = {}
    end

    def set(params)
      @params.merge!(params)
      self
    end

    def along(edge_type)
      self.set(:edge_type => edge_type)
    end

    def outgoing
      self.set(:edge_type => Config::DEFAULT_TYPE) unless @params[:edge_type]
      self.set(:direction => "O")
    end

    def incoming
      self.set(:edge_type => Config::DEFAULT_TYPE) unless @params[:edge_type]
      self.set(:direction => "I")
    end

    def undirected
      self.set(:edge_type => Config::DEFAULT_TYPE) unless @params[:edge_type]
      self.set(:direction => "N")
    end

    def of_type(node_type)
      self.set(:edge_type => Config::DEFAULT_TYPE) unless @params[:edge_type]
      self.set(:direction => "N") unless @params[:direction]
      self.set(:to_type => node_type)
    end

    def each
      search_key = ""
      from = nil
      if @unset
        search_key = Keyify.range(@params)
        from = @graph.get_node(@params[:from])

        @cursor.jump(search_key)
        @unset = false
      end

      while @cursor.key and Keyify.subkey?(search_key, @cursor.key)
        to, type, direction, directed = Keyify.parse(@cursor.key)

        if @cursor.value
          new_edge = Marshal.load(@cursor.value)
          new_edge[:type] = type
          new_edge[:directed] = directed
          if direction == "I"
            new_edge[:to] = from
            new_edge[:from] = @graph.get_node(to)
          else
            new_edge[:from] = from
            new_edge[:to] = @graph.get_node(to)
          end
          yield new_edge
        end

        @cursor.next
      end
    end

  end
end
