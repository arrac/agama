module Agama

  module Keyify
    
    def self.node(node)
      type = node[:type] || Config::DEFAULT_TYPE
      [type, node[:name]].join(Config::NODE_DELIMITOR)      
    end

    def self.edge(edge)
      from = self.node(edge[:from])
      type = edge[:type] || Config::DEFAULT_TYPE
      outgoing, incoming = if edge[:directed] then
                             ["O", "I"]
                           else
                             ["N", "N"]
                           end

      to = self.node(edge[:to])

      key = [from, type, outgoing, to].join(Config::EDGE_DELIMITOR)
      reverse_key = [to, type, incoming, from].join(Config::EDGE_DELIMITOR)

      [key, reverse_key]
    end

    def self.range(params)
      from = self.node(params[:from]) if params[:from]

      type = params[:edge_type]

      if type
        dir = params[:direction]
        if dir
          to_type = params[:to_type]
          if to_type
            [from, type, dir, to_type].join(Config::EDGE_DELIMITOR)
          else
            [from, type, dir, nil].join(Config::EDGE_DELIMITOR)
          end
        else
          [from, type, nil].join(Config::EDGE_DELIMITOR)
        end
      else
        [from, nil].join(Config::EDGE_DELIMITOR)
      end
    end

    def self.parse(key)
      from_key, edge_type, direction, to_key = key.split(Config::EDGE_DELIMITOR)
      type, name = to_key.split(Config::NODE_DELIMITOR)
      directed = true
      directed = false if (direction == "N")
      [{:type => type, :name => name}, edge_type, direction, directed]
    end

    def self.subkey?(subkey, key)
      key [0, subkey.length] == subkey
    end
  end
end

