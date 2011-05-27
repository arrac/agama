# [Author] Aditya Rachakonda  (mailto:aditya.rachakonda@gmail.com)

module Agama
# The Agama::Graph class exposes a set of methods to store
# graphs on disk. It's objects are initialised with a database 
# adapter designed to store graphs on a disk.

  class Graph

    #Initialises variables and sets the path

    def initialize(params)
      @db_path  = params[:path] || "./"
      @db       = params[:db]
    end

    #Opens the database for access
    def open
      @db.open(@db_path)

      #Create meta variables if they are absent
      unless @db.m_get("n")
        @db.m_put("n", "0")             #Total node count
        @db.m_put("m", "0")             #Total edge count
        @db.m_put("node#{Config::DEFAULT_TYPE}", 
                  "0")                  #Node count for default type
        @db.m_put("edge#{Config::DEFAULT_TYPE}", 
                  Marshal.dump({:directed => false, :count => 0})) #Edge count for default type
      end

    end

    #Closes the database connection
    def close
      @db.close
    end

    #Creates/Updates a node

    def set_node(node)
      return nil unless node[:name]

      #Get the type of the node
      type = node[:type] || Config::DEFAULT_TYPE
      node[:type] = type

      #Convert the node into Key and Value strings for storage
      key = Keyify.node(node)
      value = Marshal.dump(Keyify.clean_node(node)) #remove key items from value

      #Check if the node type exists, and if so get its count
      count = @db.m_get("node#{type}").to_i if @db.m_get("node#{type}")

      #Check whether the operation is an insert (not an update), if so increment count
      unless @db.n_get(key)
        #Increment type-specific count
        if count
          count += 1
          @db.m_put("node#{type}", count.to_s)
        else
          @db.m_put("node#{type}", "1")
        end

        #Increment global count
        @db.m_put("n", (@db.m_get("n").to_i + 1).to_s ) 
      end

      #Store the node
      if @db.n_put(key, value)
        node
      end
    end

    #Fetches the node requested

    def get_node(node)
      return nil unless node[:name]

      #Convert the node into a Key string and fetch the corresponding data
      key = Keyify.node(node)
      value = @db.n_get(key)

      if value
        new_node        = Marshal.load(value)
        new_node[:name] = node[:name]
        new_node[:type] = node[:type] || Config::DEFAULT_TYPE
        new_node
      end
    end

    #Creates/Updates an edge

    def set_edge(edge)
      return false unless edge
      return false unless edge[:from][:name]
      return false unless edge[:to][:name]

      #Get the type of the edge
      type = edge[:type] || Config::DEFAULT_TYPE
      edge[:type] = type

      #Check if the edge type exists
      etype = Marshal.load(@db.m_get("edge#{type}") || Marshal.dump({})) 

      #Integrity check: Check whether the edge direction is not contradictory
      if edge[:directed]
        if etype[:directed] and etype[:directed] != edge[:directed]
          raise "Edge creation error: edge direction contradicting existing edges"
          return false
        end
      else
        if etype[:directed]
          edge[:directed] = etype[:directed]
        else
          edge[:directed] = false
        end
      end

      #Convert the edge into Key, Reversed Key and Value strings for storage
      key, reverse_key = Keyify.edge(edge)
      value = Marshal.dump(Keyify.clean_edge(edge))

      #Integrity check: Check if the incident nodes are defined
      unless (self.get_node(edge[:from]) and self.get_node(edge[:to]))
        raise "Edge creation error: node(s) not defined"
        return
      end

      #Check whether the operation is an insert (not an update), if so increment count
      unless @db.e_get(key)
        if etype[:count]
          etype[:count] += 1
          pp etype
          @db.m_put("edge#{type}", Marshal.dump(etype))
        else
          @db.m_put("edge#{type}", 
                    Marshal.dump({:directed => edge[:directed], :count => 1}))
        end

        #Increment global count
        @db.m_put("m", (@db.m_get("m").to_i + 1).to_s)
      end

      #Add the edge and the reversed edge
      if @db.e_put(key, value) and @db.e_put(reverse_key, value)
        return edge
      end
    end

    #Fetches the value assigned to the edge from the _from_ node to the _to_ node

    def get_edge(edge)
      return nil unless edge[:from][:name]
      return nil unless edge[:to][:name]

      #Get the type of the edge
      type = edge[:type] || Config::DEFAULT_TYPE
      edge[:type] = type

      #Check if the edge type exists
      etype = Marshal.load(@db.m_get("edge#{type}") || Marshal.dump({})) 
      
      #Integrity check: Check whether the edge direction is not contradictory
      if edge[:directed]
        if etype[:directed] != nil
          if etype[:directed] != edge[:directed]
            return nil
          end
        else
          #If there is no edge of that type then pre-empt the result
          return nil
        end
      else
        if etype[:directed] != nil
          edge[:directed] = etype[:directed]
        else
          #If there is no edge of that type then pre-empt the result
          return 3
        end
      end

      #Convert the edge into a Key string and fetch the corresponding data
      key, reverse_key = Keyify.edge(edge)
      value = @db.e_get(key)

      if value
        new_edge            = Marshal.load(value)
        new_edge[:from]     = self.get_node(edge[:from])
        new_edge[:to]       = self.get_node(edge[:to])
        new_edge[:type]     = edge[:type]
        new_edge[:directed] = etype[:directed] #Pick direction alone from the meta_db for consistency
        new_edge
      end
    end

    def neighbours(node)
      traverser = Traverser.new(@db, self)
      traverser.set(:from => node)
    end


    #def delete_node(node)
      #return nil unless node[:name]

      #key = Key.node(node)

    #end

    #def delete_edge(edge)

    #end

    #Accessors for meta values
    def node_count(type = nil)
      if type
        value = @db.m_get("node#{type}")
        if value
          value.to_i
        end
      else
        @db.m_get("n").to_i
      end
    end

    def edge_count(type = nil)
      if type
        value = @db.m_get("edge#{type}")
        if value
          etype = Marshal.load(value)
          etype[:count]
        end
      else
        @db.m_get("m").to_i
      end
    end

  end

end
