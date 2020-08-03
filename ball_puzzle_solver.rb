#!/usr/local/bin/ruby

$cal = 0

class BallPuzzleSolver
  COLOR_CODING = {pink: 1, dark_green: 2, teal: 3, green: 4, blue: 5, yellow: 6, red: 7, purple: 8, aqua: 9, white: 10, peach: 11, orange: 12}
  @@inverted_color_coding = nil

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

  def initialize(colored_state, n_empty_stacks)
    self.class.input_validator(colored_state)

    @@inverted_color_coding = COLOR_CODING.invert
    @state = color_encode(colored_state)
    @n_colors = @state.flatten.uniq.count
    @n_empty_stacks = n_empty_stacks
    @height = colored_state.first.length
    @seen = []
    # # of empty stacks in the current config
    n_empty_stacks.times { |i| @state << [] }
  end

  # Convert from two-dimensinoal color string arr to
  # two-dimensional color int arr.
  private def color_encode(two_d_arr)
    two_d_arr.each do |stack|
      stack.map! do |colored_ball|
        COLOR_CODING[colored_ball.to_sym]
      end
    end
  end

  # Convert from two-dimensinoal color int arr to
  # two-dimensional color string arr.
  private def color_decode(two_d_arr)
    result = []
    two_d_arr.each_with_index do |stack, i|
      result << stack.map do |colored_ball|
        @@inverted_color_coding[colored_ball]
      end
    end
    result
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
      puts "Solved:========"
      p color_decode(curr_state)
      puts "Steps:========"
      trace.each_with_index {|step, i| puts "#{i+1}: #{step}" }

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
            solve_recur(new_state, trace + ["Item #{@@inverted_color_coding[picked]} moved from the #{idx+1}th stack to #{i+1}th stack."])
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
# lv21
medium = [%w(green red green yellow),
          %w(red purple yellow green),
          %w(orange purple purple yellow),
          %w(blue purple blue yellow),
          %w(blue aqua red green),
          %w(orange blue aqua aqua),
          %w(aqua orange red orange)]

# BallPuzzleSolver.new(easy, 2).solve
BallPuzzleSolver.new(medium, 2).solve
