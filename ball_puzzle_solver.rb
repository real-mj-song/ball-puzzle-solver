#!/usr/local/bin/ruby

$cal = 0

class BallPuzzleSolver
  def initialize(encoding, n_colors, n_empty_stacks)
    @state = encoding
    @n_colors = n_colors
    @n_empty_stacks = n_empty_stacks
    @height = encoding.first.length
    @seen = []
    # # of empty stacks in the current config
    n_empty_stacks.times { |i| @state << [] }
  end

  private def stack_solved?(stack)
    stack.uniq.size == 1 && stack.size == @height
  end

  private def solved?(curr_state)
    solved_count = 0
    non_empty_state = curr_state.filter {|stack| !stack.empty?}
    non_empty_state.each do |stack|
      if stack_solved?(stack)
        solved_count += 1
      else
        return false
      end
    end
    return solved_count == @n_colors
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
      new_state = Marshal.load(Marshal.dump(curr_state))
      # pick the last/top element from the selected stack
      picked = new_state[idx].pop
      # Ignore empty stacks
      if picked
        (0..(curr_state.size-1)).each do |i|
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
easy = [[5,7,6,6],[5,7,5,7],[6,5,7,6]]
# hard = [[2,3,2,1],[5,6,5,4],[8,7,2,4],[5,3,7,1],[10,6,2,9],[4,11,9,6],[12,5,11,7],[10,1,3,8],[4,10,6,12],[8,7,1,3],[11,9,11,8],[10,9,12,12]]

BallPuzzleSolver.new(easy, 3, 2).solve
