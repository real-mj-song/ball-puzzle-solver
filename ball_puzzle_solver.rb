#!/usr/local/bin/ruby
# color coding reverse and show the colors
# commit
# Not require the # of colors
# Readme

$cal = 0

class BallPuzzleSolver
  COLOR_CODING = {pink: 1, dark_green: 2, teal: 3, green: 4, blue: 5, yellow: 6, red: 7, purple: 8, aqua: 9, white: 10, peach: 11, orange: 12}

  def self.input_validator(input)
    # All nested stacks should have the same size
    raise ArgumentError.new("All tubes have to be the same size.") unless input.map {|stack| stack.length }.uniq.length == 1
    count = {}
    input.flatten.each do |ball|
      if count[ball]
        count[ball] += 1
      else
        count[ball] = 0
      end
    end
    raise ArgumentError.new("The numbers of same colored balls should be the same.") unless count.values.uniq.length == 1
  end

  def initialize(colored_state, n_colors, n_empty_stacks)
    self.class.input_validator(colored_state)

    @state = color_code(colored_state)
    @n_colors = n_colors
    @n_empty_stacks = n_empty_stacks
    @height = colored_state.first.length
    @seen = []
    # # of empty stacks in the current config
    n_empty_stacks.times { |i| @state << [] }
  end

  # Convert from two-dimensinoal color string arr to
  # two-dimensional color int arr.
  private def color_code(colored_state)
    colored_state.each do |stack|
      stack.map! do |colored_ball|
        COLOR_CODING[colored_ball.to_sym]
      end
    end
  end

  private def stack_solved?(stack)
    stack.uniq.size == 1 && stack.size == @height
  end

  private def solved?(curr_state)
    non_empty_state = curr_state.filter {|stack| !stack.empty?}
    non_empty_state.each do |stack|
      return false unless stack_solved?(stack)
    end
    return true
  end

  def solve_recur(curr_state, trace)
    # When the problem is solved, publish the result
    if solved?(curr_state)
      puts "Solutions:========"
      p curr_state, trace
      p "Number of ops: #{$cal}"
      exit
    end

    curr_state.each_with_index do |stack, idx|
      unless curr_state[idx].empty?
        (0..(curr_state.size-1)).each do |i|
          new_state = Marshal.load(Marshal.dump(curr_state))
          picked = new_state[idx].pop
          $cal += 1
          # Don't need to put it into the current stack
          next if i == idx
          # Can't insert into a full stack
          next if new_state[i].size == @height
          # ignore meaningless from one empty/homogeneous stack to the other empty stack
          next if stack.uniq.size == 1 && new_state[i].empty?
          # color has to match
          next if !new_state[i].last.nil? && new_state[i].last != picked
          new_state[i].push(picked)
          if @seen.include? new_state
            next
          else
            @seen << new_state
            solve_recur(new_state, trace + ["Item #{picked} moved from the #{idx+1}th stack to #{i+1}th stack."])
          end
        end
      end
    end
  end

  def solve
    solve_recur(@state, [])
  end
end
# pink 1, dark green 2, teal 3, green 4, blue 5, yellow 6, red 7, purple 8, aqua 9, white 10, peach 11, orange 12
easy = [%w(blue red yellow yellow),%w(blue red blue red),%w(yellow blue red yellow)] # lv4
medium = [[4,7,4,6],[7,8,6,4],[12,8,8,6],[5,8,5,6],[5,9,7,4],[12,5,9,9],[9,12,7,12]] # lv21
hard = [[2,3,2,1],[5,6,5,4],[8,7,2,4],[5,3,7,1],[10,6,2,9],[4,11,9,6],[12,5,11,7],[10,1,3,8],[4,10,6,12],[8,7,1,3],[11,9,11,8],[10,9,12,12]]

BallPuzzleSolver.new(easy, 3, 2).solve
#BallPuzzleSolver.new(medium, 7, 2).solve
#BallPuzzleSolver.new(hard, 12, 2).solve
