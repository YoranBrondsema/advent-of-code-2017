defmodule Day21 do
  def grids(rules, initial_grid, iteration_count) do
    1..iteration_count
    |> Enum.reduce(
      initial_grid,
      fn(count, grid) ->
        IO.puts count

        cond do
          rem(dimension(grid), 2) == 0 ->
            grid
            |> divide_into_small_squares(2)
            |> transform(rules)
            |> merge
          rem(dimension(grid), 3) == 0 ->
            grid
            |> divide_into_small_squares(3)
            |> transform(rules)
            |> merge
        end
      end
    )
  end

  def draw(grid) do
    grid
    |> Enum.with_index
    |> Enum.reduce(
      "",
      fn({value, index}, output) ->
        s = cond do
          rem(index, dimension(grid)) == 0 -> "\n"
          true -> ""
        end

        case value do
          :on -> "#{output}#{s}#"
          :off -> "#{output}#{s}."
        end
      end
    )
  end

  def merge(small_squares) do
    time("merge", &_merge/1, [small_squares])
  end

  def _merge(small_squares) do
    large_dim = dimension(small_squares)

    small_squares
    |> Enum.with_index
    |> Enum.reduce(
      Map.new,
      fn({square, index}, grid) ->
        row = div(index, large_dim)
        col = rem(index, large_dim)

        dim = dimension(square)

        square
        |> Enum.with_index
        |> Enum.reduce(
          grid,
          fn({value, index_within_square}, acc) ->
            row_within_square = div(index_within_square, dim)
            col_within_square = rem(index_within_square, dim)

            x = row*dim + row_within_square
            y = col*dim + col_within_square

            index = x * (dim * large_dim) + y


            Map.put(acc, index, value)
          end
        )
      end
    )
    |> without_positions
  end

  def transform(small_squares, rules) do
    time("transform", &_transform/2, [small_squares, rules])
  end

  def _transform(small_squares, rules) do
    small_squares
    |> pmap(
      fn(small_square) ->
        find_rule_for_square(small_square, rules)
      end
    )
  end

  def find_rule_for_square(square, rules) do
    rules
    |> Map.get(square)
  end

  def time(name, function, args) do
    {time, result} = :timer.tc(function, args)
    IO.puts "#{name}: #{div(time, 1000000)}s"
    result
  end

  def divide_into_small_squares(square, dim) do
    time("divide", &_divide_into_small_squares/2, [square, dim])
  end

  def _divide_into_small_squares(square, dim) do
    nr_in_row = div(dimension(square), dim)

    square
    |> with_positions
    |> Enum.reduce(
      Map.new,
      fn({ {x,y}, value }, small_squares) ->
        col = div(y, dim)
        row = div(x, dim)
        index = nr_in_row * row + col

        square = small_squares
                 |> Map.get(index, [])

        small_squares
        |> Map.put(index, [value | square])
      end
    )
    |> Enum.sort(
      fn({index1, _}, {index2, _}) -> index1 <= index2 end
    )
    |> pmap(
      fn({ _, square }) ->
        Enum.reverse(square)
      end
    )
  end

  def extract_square(square_with_positions, nr_in_row, index, dim) do
    row = rem(index, nr_in_row)
    col = div(index, nr_in_row)

    x_values = (dim*col)..(dim*(col+1)-1)
    y_values = (dim*row)..(dim*(row+1)-1)

    positions = for x <- x_values, y <- y_values, do: {x, y}

    square_with_positions
    |> Map.take(positions)
    |> Map.values
  end

  def process_rules(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(
      fn(s) -> s != "" end
    )
    |> Enum.reduce(
      [],
      &process_rule/2
    )
    |> Map.new
  end

  def process_rule(input, rules) do
    [ pre, post ] = input
                    |> String.split(" => ", trim: true)
                    |> Enum.map(&process_pattern/1)

    rules ++ all_combinations(pre, post)
  end

  def all_combinations(pre, post) do
    [
      pre,
      flip_vertical(pre),
      flip_horizontal(pre)
    ]
    |> Enum.reduce(
      [],
      fn(square, acc) ->
        acc ++ [
          { square, post },
          { rotate(square, 1), post },
          { rotate(square, 2), post },
          { rotate(square, 3), post }
        ]
      end
    )
    |> Enum.uniq
  end

  def process_pattern(pattern) do
    pattern
    |> String.trim
    |> String.split("/", trim: true)
    |> Enum.reduce(
      [],
      fn(pattern, pixels) ->
        pattern
        |> String.split("", trim: true)
        |> Enum.reduce(
          pixels,
          fn(symbol, pixels) ->
            case symbol do
              "#" -> [:on | pixels]
              "." -> [:off | pixels]
              _ -> pixels
            end
          end
        )
      end
    )
    |> Enum.reverse
  end

  def with_positions(square) do
    dim = dimension(square)

    square
    |> Enum.with_index
    |> Enum.map(
      fn({ value, index }) ->
        row = div(index, dim)
        col = rem(index, dim)
        { { row, col }, value }
      end
    )
  end

  def without_positions(square) do
    square
    |> Enum.sort(
      fn({pos1,_}, {pos2,_}) -> pos1 <= pos2 end
    )
    |> Enum.map(
      fn({_,value}) -> value end
    )
  end

  def rotate(square, 0), do: square
  def rotate(square, n) do
    case length(square) do
      4 -> rotate(rotate_2(square), n-1)
      9 -> rotate(rotate_3(square), n-1)
    end
  end

  def rotate_2(square) do
    square
    |> with_positions
    |> Enum.map(
      fn({pos, value}) ->
        case pos do
          {0,0} -> {{0,1}, value}
          {0,1} -> {{1,1}, value}
          {1,1} -> {{1,0}, value}
          {1,0} -> {{0,0}, value}
        end
      end
    )
    |> without_positions
  end

  def rotate_3(square) do
    square
    |> with_positions
    |> Enum.map(
      fn({pos, value}) ->
        case pos do
          {0,0} -> {{0,2}, value}
          {0,1} -> {{1,2}, value}
          {0,2} -> {{2,2}, value}
          {1,0} -> {{0,1}, value}
          {1,1} -> {{1,1}, value}
          {1,2} -> {{2,1}, value}
          {2,0} -> {{0,0}, value}
          {2,1} -> {{1,0}, value}
          {2,2} -> {{2,0}, value}
        end
      end
    )
    |> without_positions
  end

  def flip_vertical(square) do
    square
    |> with_positions
    |> Enum.map(
      fn({{x, y}, value}) ->
        {{x, dimension(square) - 1 - y}, value}
      end
    )
    |> without_positions
  end

  def flip_horizontal(square) do
    square
    |> with_positions
    |> Enum.map(
      fn({{x, y}, value}) ->
        {{dimension(square) - 1 - x, y}, value}
      end
    )
    |> without_positions
  end

  def dimension(square) do
    square
    |> length
    |> :math.sqrt
    |> Kernel.trunc
  end

  def number_of_on_pixels(grid) do
    grid
    |> Enum.count(
      fn(value) -> value == :on end
    )
  end

  defp pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end

ExUnit.start()

grid = [
  :off, :on, :off,
  :off, :off, :on,
  :on, :on, :on
]

# input = "
# ../.# => ##./#../...
# .#./..#/### => #..#/..../..../#..#
# "
{ :ok, input } = File.read "day21-input.txt"
rules = Day21.process_rules(input)

result = Day21.grids(rules, grid, 18)

# Day21.draw(result)
# |> IO.puts

IO.puts "Number of on pixels"
IO.inspect Day21.number_of_on_pixels(result)


defmodule ExampleTest do
  use ExUnit.Case
  import Day21

  test "#with_positions" do
    input = [1, 2, 5, 6, 3, 4, 7, 8, 9, 10, 13, 14, 11, 12, 15, 16]
    output = [{{0, 0}, 1}, {{0, 1}, 2}, {{0, 2}, 5}, {{0, 3}, 6}, {{1, 0}, 3}, {{1, 1}, 4}, {{1, 2}, 7}, {{1, 3}, 8}, {{2, 0}, 9}, {{2, 1}, 10}, {{2, 2}, 13}, {{2, 3}, 14}, {{3, 0}, 11}, {{3, 1}, 12}, {{3, 2}, 15}, {{3, 3}, 16}]

    assert with_positions(input) == output
  end

  test "#merge" do
    grid = [
      [1,2,3,4],
      [5,6,7,8],
      [9,10,11,12],
      [13,14,15,16]
    ]
    assert merge(grid) == [1, 2, 5, 6, 3, 4, 7, 8, 9, 10, 13, 14, 11, 12, 15, 16]

    grid = [
      [1,2,3,4,5,6,7,8,9],
      [1,2,3,4,5,6,7,8,9],
      [1,2,3,4,5,6,7,8,9],
      [1,2,3,4,5,6,7,8,9]
    ]
    assert merge(grid) == [
      1,2,3,1,2,3,
      4,5,6,4,5,6,
      7,8,9,7,8,9,
      1,2,3,1,2,3,
      4,5,6,4,5,6,
      7,8,9,7,8,9
    ]
  end

  test "#divide_into_small_squares" do
    input = [1, 2, 5, 6, 3, 4, 7, 8, 9, 10, 13, 14, 11, 12, 15, 16]
    output = [
      [1,2,3,4],
      [5,6,7,8],
      [9,10,11,12],
      [13,14,15,16]
    ]

    assert divide_into_small_squares(input, 2) == output
  end

  test "#grids" do
    grid = [
      :off, :on, :off,
      :off, :off, :on,
      :on, :on, :on
    ]
    input = "
      ../.# => ##./#../...
      .#./..#/### => #..#/..../..../#..#
    "
    rules = Day21.process_rules(input)

    assert Day21.grids(rules, grid, 2) == [:on, :on, :off, :on, :on, :off, :on, :off, :off, :on, :off, :off, :off, :off, :off, :off, :off, :off, :on, :on, :off, :on, :on, :off, :on, :off, :off, :on, :off, :off, :off, :off, :off, :off, :off, :off]
  end
end
