class Maze
    def initialize(width: 20, height: 15)
        @width = width
        @height = height
        @paths = " ╹╺┗╻┃┏┣╸┛━┻┓┫┳╋"
        @maze = []
        
        height.times do |row|
            @maze[row] = []
            width.times do |column| 
                @maze[row] << Node.new(column: column, row: row)
            end
        end
    end

    attr_accessor :width, :height, :maze

    def random_node
        @maze.sample.sample
    end

    def print_maze
        @maze.each{ |row| puts row.map{ |col| @paths[col.path] }.join }
        # puts "\n"
        # @maze.each{ |row| puts row.map{ |col| "[ #{col.path.to_s(2).rjust(4, "0")} ]" }.join }
    end

    def neighbors(node)
        output = []
        north = neighbor(node.row - 1, node.column, Node::NORTH)
        east  = neighbor(node.row, node.column + 1, Node::EAST)
        south = neighbor(node.row + 1, node.column, Node::SOUTH)
        west  = neighbor(node.row, node.column - 1, Node::WEST)
        
        output << north if north
        output << east  if east 
        output << south if south
        output << west  if west 

        output
    end

    def neighbor(row, column, direction)
        return false unless row.between?(0, @height - 1) && column.between?(0, @width - 1)

        maze_row = @maze[row]
        return false if maze_row.nil?

        node = maze_row[column]
        return false if node.nil? || node.used?

        { node: node, direction: direction }
    end

    def generate_maze
        current_node = random_node
        while true
            neighbors = self.neighbors(current_node)
            if neighbors.any?
                n = neighbors.sample
                current_node.drill_to_node(n[:node], n[:direction])
                current_node = n[:node]
            elsif !current_node.previous_node.nil?
                current_node = current_node.previous_node
            else
                break
            end
            printf "."
        end
        puts "\n\n" + ("-" * @width)
        print_maze
    end
end

class Node
    NORTH = 1
    EAST = 2
    SOUTH = 4
    WEST = 8
    
    def initialize(column: 0, row: 0, path: 0)
        @previous_node = nil
        @path = path
        @column = column
        @row = row
    end
    
    attr_accessor :previous_node, :path, :row, :column

    def drill_to_node(node, direction)
        node.previous_node = self
        self.path += direction
        node.path += invert_direction(direction)
    end

    def invert_direction(direction)
        inverted_directions = {
            NORTH => SOUTH,
            SOUTH => NORTH,
            EAST => WEST,
            WEST => EAST
        }
        inverted_directions[direction] || 0
    end

    def used?
        path != 0
    end

    def unused?
        !used?
    end
end

Maze.new.generate_maze
