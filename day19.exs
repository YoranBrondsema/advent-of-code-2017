defmodule Day19 do
  def traverse(grid) do
    { start, _ } = get_start(grid)

    { letters, step_count } =_traverse(grid, start, :down, [], 0)

    letters = letters
              |> Enum.reverse
              |> Enum.join

    { letters, step_count }
  end

  defp _traverse(grid, pos, dir, letters, step_count) do
    case get_next_position(grid, pos, dir) do
      { next_pos, next_dir } ->
        letters = get_next_letters(grid, pos, letters)
        _traverse(grid, next_pos, next_dir, letters, step_count + 1)
      nil -> { letters, step_count }
    end
  end

  defp get_next_letters(grid, pos, letters) do
    { :ok, symbol } = Map.fetch(grid, pos)

    case symbol do
      "+" -> letters
      "-" -> letters
      "|" -> letters
      _ -> [ symbol | letters ]
    end
  end

  defp get_next_position(grid, pos, direction) do
    case Map.fetch(grid, pos) do
      { :ok, symbol } ->
        case symbol do
          "+" ->
            coming_from = get_opposite(direction)
            next_dir = get_next_direction(grid, pos, coming_from)
            { get_neighbour(pos, next_dir), next_dir }
          _ -> { get_neighbour(pos, direction), direction }
        end
      :error -> nil
    end
  end

  defp get_next_direction(grid, pos, coming_from) do
    [:down, :up, :left, :right]
    |> List.delete(coming_from)
    |> Enum.find(
      fn(direction) ->
        grid
        |> Map.has_key?(get_neighbour(pos, direction))
      end
    )
  end

  defp get_neighbour({x, y}, :down), do: {x, y+1}
  defp get_neighbour({x, y}, :up), do: {x, y-1}
  defp get_neighbour({x, y}, :left), do: {x-1, y}
  defp get_neighbour({x, y}, :right), do: {x+1, y}

  defp get_opposite(:down), do: :up
  defp get_opposite(:up), do: :down
  defp get_opposite(:left), do: :right
  defp get_opposite(:right), do: :left

  defp get_start(grid) do
    grid
    |> Enum.find(
      fn({{_, y}, _}) -> y == 0 end
    )
  end

  def process_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.reduce(
      Map.new,
      fn({ row, row_index }, grid) ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index
        |> Enum.reduce(
          grid,
          fn({ value, col_index }, grid) ->
            cond do
              value != " " -> Map.put(grid, { col_index, row_index }, value)
              true -> grid
            end
          end
        )
      end
    )
  end
end

{ :ok, input } = File.read "day19-input.txt"

grid = input
       |> Day19.process_input

{ letters, step_count } = Day19.traverse(grid)

IO.puts "Letters: #{inspect letters}"
IO.puts "Step count: #{inspect step_count}"
