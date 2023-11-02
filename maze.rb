# frozen_string_literal: true

# Maze
class Maze
  def initialize(width: 25, height: 20)
    @width = width
    @height = height
    @paths = ' ╹╺┗╻┃┏┣╸┛━┻┓┫┳╋'
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
    puts "\n╭#{'─' * @width}╮"
    @maze.each { |row| puts "│#{row.map { |col| @paths[col.path] }.join}│" }
    puts "╰#{'─' * @width}╯"
    puts "\n"
    # @maze.each{ |row| puts row.map{ |col| "[ #{col.path.to_s(2).rjust(4, "0")} ]" }.join }
    w = @width - 1
    @maze.each_with_index do |row, i| 
      puts '┏' + row.map{ |col| "━━━#{col.east? ? "━" : "┳" }" }.join[0..-2] + '┓' if i == 0
      puts '┃' + row.map{ |col| " • #{col.east? ? " " : "┃" }" }.join[0..-2] + '┃'
      if i < @height - 1
        line = ""
        row.each_with_index do |col, j|
          line += col.south? ? '┃   ' : '┣━━━' if j == 0
          if j > 0 && j < @width
            p = 15
            p -= Node::NORTH if col.west?
            p -= Node::EAST if col.south?
            p -= Node::SOUTH if @maze[i+1][j].west?
            p -= Node::WEST if row[j-1].south?
            line += "#{@paths[p]}#{col.south? ? '   ' : '━━━'}"
          end
          line += col.south? ? '┃' : '┫' if j == w
        end
        puts line
      end       
      puts '┗' + row.map{ |col| "━━━#{col.east? ? "━" : "┻"}" }.join[0..-2] + '┛' if i == @height - 1
    end
  end

  def neighbors(row, column)
    [neighbor(row - 1, column, Node::NORTH),
     neighbor(row, column + 1, Node::EAST),
     neighbor(row + 1, column, Node::SOUTH),
     neighbor(row, column - 1, Node::WEST)].reject { |n| n == false }
  end

  def neighbor(row, column, direction)
    return false unless row.between?(0, @height - 1) && column.between?(0, @width - 1)

    node = @maze[row][column]
    return false if node.nil? || node.used?

    { node: node, direction: direction }
  end

  def generate_maze
    current_node = random_node
    loop do
      neighbors = self.neighbors(current_node.row, current_node.column)
      break if neighbors.empty? && current_node.previous_node.nil?

      n = neighbors.sample
      next_node = n.nil? ? current_node.previous_node : n[:node]
      current_node.drill_to_node(next_node, n[:direction]) unless n.nil?
      current_node = next_node
    end
  end
end

# Node
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

  def north?
    path.to_s(2).rjust(4,'0')[3] == '1'
  end
  
  def south? 
    path.to_s(2).rjust(4,'0')[1] == '1'
  end 
  
  def east?
    path.to_s(2).rjust(4,'0')[2] == '1'
  end 
  
  def west?
    path.to_s(2).rjust(4,'0')[0] == '1'
  end
end

maze = Maze.new
maze.generate_maze
maze.print_maze

# 00000
# 00000
# 00000
# 00000
# 00000

# Generate Full Maze Array
#   Select Starting Node
#   Loop:
#     Find Neighbor(s)
#     IF Neighbor(s) Exists?
#       Randomly Select Neighbor
#       Create Path to new node
#       Remember previous node
#     ELSIF Has previous node?
#       Go to Previous
#     ELSE
#       Exit Loop
#   Indicate Percentage Completed
# Print Maze
