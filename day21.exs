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
    large_dim = dimension(small_squares)

    small_squares
    |> Enum.with_index
    |> Enum.reduce(
      [],
      fn({square, index}, grid) ->
        row = div(index, large_dim)
        col = rem(index, large_dim)

        dim = dimension(square)

        cur_square = square
                     |> Enum.with_index
                     |> Enum.map(
                       fn({value, index_within_square}) ->
                         row_within_square = div(index_within_square, dim)
                         col_within_square = rem(index_within_square, dim)

                         {
                           {
                             row*dim + row_within_square,
                             col*dim + col_within_square
                           },
                           value
                         }
                       end
                     )

        grid ++ cur_square
      end
    )
    |> without_positions
  end

  def transform(small_squares, rules) do
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

  def divide_into_small_squares(square, dim) do
    nr_squares = :math.pow(dimension(square) / dim, 2)
                 |> Kernel.trunc

    0..(nr_squares-1)
    |> Enum.reduce(
      [],
      fn(index, divided) ->
        [ extract_square(square, index, dim) | divided]
      end
    )
    |> Enum.reverse
  end

  def extract_square(square, index, dim) do
    nr_in_row = div(dimension(square), dim)

    row = rem(index, nr_in_row)
    col = div(index, nr_in_row)

    square
    |> with_positions
    |> Enum.filter(
      fn({{x,y}, _}) ->
        x >= dim*col and x < dim*(col+1) and
        y >= dim*row and y < dim*(row+1)
      end
    )
    |> without_positions
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
    square
    |> Enum.chunk_every(dimension(square))
    |> Enum.with_index
    |> Enum.reduce(
      [],
      fn({ row, row_index }, square_with_positions) ->
        row
        |> Enum.with_index
        |> Enum.reduce(
          square_with_positions,
          fn({ value, col_index }, square_with_positions) ->
            square_with_positions ++ [{ {row_index, col_index}, value }]
          end
        )
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

Day21.draw(result)
|> IO.puts
#
# IO.puts "Number of on pixels"
# IO.inspect Day21.number_of_on_pixels(result)


ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day21

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
