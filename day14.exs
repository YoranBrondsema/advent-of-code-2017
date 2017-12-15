defmodule Day14 do
  def to_grid(input) do
    0..127
    |> Enum.map(
      fn(row) -> "#{input}-#{row}" end
    )
    |> pmap(&Day10.knot_hash/1)
    |> Enum.map(&to_binary/1)
  end

  def regions(grid) do
    grid
    |> Enum.with_index
    |> Enum.map(
      fn({row_as_string, row_index}) ->
        row_as_string
        |> String.split("", trim: true)
        |> Enum.with_index
        |> Enum.map(
          fn({value, col_index}) ->
            { {row_index, col_index}, value }
          end
        )
      end
    )
    |> Enum.concat
    |> Enum.reduce(
      MapSet.new,
      &_process_position/2
    )
  end

  defp _process_position({_, "0"}, regions), do: regions
  defp _process_position({{row, col}, "1"}, regions) do
    adjacent_regions = get_adjacent_regions({row, col}, regions)

    merged_region = Enum.concat(adjacent_regions)
                    |> MapSet.new
                    |> MapSet.put({row, col})

    regions
    |> Enum.reject(
      fn(region) -> Enum.member?(adjacent_regions, region) end
    )
    |> MapSet.new
    |> MapSet.put(merged_region)
  end

  defp get_adjacent_regions({row, col}, regions) do
    adjacent_positions = [
      { row + 1, col },
      { row - 1, col },
      { row, col + 1 },
      { row, col - 1 }
    ]

    regions
    |> Enum.filter(
      fn(region) ->
        adjacent_positions
        |> Enum.any?(
          fn(position) ->
            MapSet.member?(region, position)
          end
        )
      end
    )
  end

  def is_adjacent?({row, col}, {other_row, other_col}) do
    abs(row - other_row) + abs(col - other_col) == 1
  end

  defp pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end

  def used_count_in_grid(grid) do
    grid
    |> Enum.map(&used_count_in_row/1)
    |> Enum.sum
  end

  defp used_count_in_row(row) do
    row
    |> String.split("", trim: true)
    |> Enum.reduce(
      0,
      fn(binary_digit, acc) ->
        case binary_digit do
          "1" -> acc + 1
          "0" -> acc
        end
      end
    )
  end

  defp to_binary(knot_hash) do
    knot_hash
    |> String.split("", trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(
      fn([higher, lower]) -> "#{higher}#{lower}" end
    )
    |> Enum.map(
      fn(hex) -> elem(Integer.parse(hex, 16), 0) end
    )
    |> Enum.map(
      fn(integer) -> Integer.to_string(integer, 2) end
    )
    |> Enum.map(
      fn(binary) -> String.pad_leading(binary, 8, "0") end
    )
    |> Enum.join("")
  end
end

[
  "flqrgnkx",
  "ljoxqyyw"
]
|> Enum.each(
  fn(input) ->
    grid = Day14.to_grid(input)

    used_count = grid
                 |> Day14.used_count_in_grid
    regions_count = grid
                    |> Day14.regions
                    |> MapSet.size

    IO.puts "=== #{input}"
    IO.puts "Used count: #{used_count}"
    IO.puts "Regions count: #{regions_count}"
  end
)
