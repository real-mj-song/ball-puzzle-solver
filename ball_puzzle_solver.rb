#!/usr/local/bin/ruby

$height = 4
$colors = 12
$seen = []
$cal = 0

class BallPuzzleSolver

  def self.stack_solved?(stack)
    stack.uniq.size == 1 && stack.size == $height
  end

  def self.solved?(state)
    solved_count = 0
    non_empty_state = state.filter {|stack| !stack.empty?}
    non_empty_state.each do |stack|
      if self.stack_solved?(stack)
        solved_count += 1
      else
        return false
      end
    end
    return solved_count == $colors
  end

  def self.solve(state, trace)
    # When the problem is solved, publish the result
    if solved?(state)
      puts "Solutions:========"
      p state, trace
      p "Number of ops: #{$cal}"
      exit
    end

    state.each_with_index do |stack, idx|
      new_state = Marshal.load(Marshal.dump(state))
      # pick the last/top element from the selected stack
      picked = new_state[idx].pop
      # Ignore empty stacks
      if picked
        (0..(state.size-1)).each do |i|
          $cal += 1
          # Don't need to put it into the current stack
          next if i == idx
          # Can't insert into a full stack
          next if new_state[i].size == $height
          # ignore meaningless from one empty/homogeneous stack to the other empty stack
          next if stack.uniq.size == 1 && new_state[i].empty?
          # color has to match
          next if !new_state[i].last.nil? && new_state[i].last != picked
          new_state[i].push(picked)
          if $seen.include? new_state
            next
          else
            $seen << new_state
            solve(new_state, trace + ["Item #{picked} moved from the #{idx+1}th stack to #{i+1}th stack."])
          end
        end
      end
    end
  end
end

empty_stack_num = 2
# pink 1, dark green 2, teal 3, green 4, blue 5, yellow 6, red 7, purple 8, aqua 9, white 10, peach 11, orange 12
input = [[2,3,2,1],[5,6,5,4],[8,7,2,4],[5,3,7,1],[10,6,2,9],[4,11,9,6],[12,5,11,7],[10,1,3,8],[4,10,6,12],[8,7,1,3],[11,9,11,8],[10,9,12,12]]
empty_stack_num.times do |i|
  input << []
end

BallPuzzleSolver.solve(input, [])
