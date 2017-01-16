#
# Created by Yi MIN<minsparky@gmail.com>
# Copyright © 2017 Yi MIN. All rights reserved.
#
# Example of screen page elememts tree:
#                          tree_node             ----Hash  deep 0  path = 0
#                              |
#                   _______children________      ----Array
#                  /   /   /   |   \   \   \
#                 o   o   o    o   o    o   o    ----Hash  deep 1  path = 0/0 0/1 0/2 0/3 0/4 0/5 0/6 
#                /             |       / \   \
#         ___children___       c      c   c  c   ----Array
#        /   /  |   \   \     / \    /\   |  |
#       o   o   o    o   o   o  o   o o   o  o   ----Hash  deep 2  path = 0/0/0 0/0/1 0/0/2 0/0/3 0/0/4 0/0/5 
#      /                              |      |
#  children                           c      c   ----Array
#   / |                               |      |
#  o  o                               o      o   ----Hash  deep = 3  path = 0/0/0/0 0/0/0/1
#
class UIRecorder
  module WDAUIParser
    def tree_node_template
      {
        isEnabled: nil,
        isVisible: nil,
        frame: nil,
        children: nil,
        rect: nil,
        value: nil,
        label: nil,
        type: nil,
        name: nil,
        rawIdentifier: nil,
        path: nil
      }
    end

    def keyboard_nodes_rawIdentifier
      ['shift', 'dictation', 'Return']
    end

    def path_arr(path)
      path.split('/')
    end

    def path_chop(path)
      arr = path.split('/')
      arr = arr[0..arr.length - 2].join('/')
    end

    def go_to_path(path = '0')
      @path = path
      path_tree_tmp = @page_elements
      if path == '0'
        @parse_count += 1
        @parent_path = 0
        return path_tree_tmp
      else
        @parent_path = path_chop(path)
        path = path.split('/')
        path.shift  # Remove Tree root, to prevent not using it as index
        path.each_with_index do |c, i|
          index = c.to_i
          @parent_node = path_tree_tmp['children'][index] if i == path.length - 2
          path_tree_tmp = path_tree_tmp['children'][index]
        end
        return path_tree_tmp
      end
    end

    def wda_dup_node(tree_node)
      @total_elements_count += 1
      node_tmp = {}
      has_children_node = false
      @parent_node = tree_node
      @parent_path = @path
      if @path == ''
        @path = '0'
      else
        @path = @path + '/' + @children_node_index.to_s
        # binding.pry if @exclude_type.include?(tree_node['type']) && @path == "0/0/0/0/1/0/0/0/0/1"
        tree_node = go_to_path(@path)
        if tree_node.nil?
          tree_node = go_to_path(@parent_path)
        end
      end

      if !tree_node['type'].nil?
        # binding.pry if @exclude_type.include?(tree_node['type']) && @path == "0/0/0/0/1/0/0/0/0/1"
        if @exclude_type.include?(tree_node['type'])
          @logger.debug "Skip node with type #{tree_node['type']}"
          if !tree_node["children"].nil? 
            if tree_node["children"].length == 0
              has_children_node = false
            else
              has_children_node = true 
            end
          end
        elsif tree_node['type'] == 'Keyboard' && @skip_keyboard
          @keyboard_path = @path
          @logger.debug"Skip Keyboard at path #{@path}"
          has_children_node = true if !tree_node["children"].nil?
        elsif @keyboard_path != '' && @path.start_with?(@keyboard_path) && @skip_keyboard
          @logger.debug"Skip Keyboard key at path #{@path}"
        else
          tree_node.each_pair do |key, value|
            if key == "children" && value != []
              has_children_node = true
            else
              node_tmp.merge!(key => value)
            end
          end
          @parsed_nodes.merge!(@path => node_tmp)
          @saved_elements_count += 1
        end
      end

      if has_children_node
        @children_node_index = 0
        self.wda_dup_node(go_to_path(@path)["children"][0])
      else  

        # There are still others children parsed_nodes in same parent node
        # @children_node_index <= last child node index
        if path_arr(@path)[-1].to_i + 1 <= @parent_node['children'].length - 1 
          @children_node_index = path_arr(@path)[-1].to_i + 1
          @path = path_chop(@path)
          self.wda_dup_node(@parent_node['children'][@children_node_index])
        else
          # @children_node_index reachs last child node of same parent node. 
          # Get it back to last branch node. if @children_node_index > @parent_node['children'].length - 1
          go_to_path(@parent_path)  # Go back to parent node
          
          @children_node_index = path_arr(@path)[-1].to_i + 1
          while (@parent_node['children'].length == 1 ||
            @parent_node['children'].length > 1 && @children_node_index == @parent_node['children'].length ) &&
            path_arr(@parent_path).length > 1 do
            go_to_path(@parent_path) # Go back to parent node
            @children_node_index = path_arr(@path)[-1].to_i + 1 # Current node index in parent node
          end

          if !(path_arr(@path)[-1].to_i + 1 == @page_elements['children'].length && @parent_path == '0')  
            self.wda_dup_node(go_to_path(@parent_path)['children'][@children_node_index])            
          end
        end
      end
    end 
  end
end