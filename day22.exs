defmodule Day22 do
  def move_through_network2(nodes, count) do
    { nodes, _, _, infection_count } = 1..count
                                       |> Enum.reduce(
                                         { nodes, {0,0}, :up, 0 },
                                         fn(_, acc) ->
                                           process_move2(acc)
                                         end
                                       )

    { nodes, infection_count }
  end

  defp process_move2({ nodes, position, direction, infection_count }) do
    case Map.get(nodes, position) do
      nil -> weaken2(nodes, position, direction, infection_count)
      :weakened -> infect2(nodes, position, direction, infection_count)
      :infected -> flag2(nodes, position, direction, infection_count)
      :flagged -> clean2(nodes, position, direction, infection_count)
    end
  end

  def weaken2(nodes, position, direction, infection_count) do
    new_direction = left_of(direction)

    {
      Map.put(nodes, position, :weakened),
      move(position, new_direction),
      new_direction,
      infection_count
    }
  end

  def infect2(nodes, position, direction, infection_count) do
    {
      Map.put(nodes, position, :infected),
      move(position, direction),
      direction,
      infection_count + 1
    }
  end

  def flag2(nodes, position, direction, infection_count) do
    new_direction = right_of(direction)

    {
      Map.put(nodes, position, :flagged),
      move(position, new_direction),
      new_direction,
      infection_count
    }
  end

  def clean2(nodes, position, direction, infection_count) do
    new_direction = reverse(direction)

    {
      Map.delete(nodes, position),
      move(position, new_direction),
      new_direction,
      infection_count
    }
  end


  def move_through_network(infected_nodes, count) do
    { nodes, _, _, infection_count } = 1..count
                                       |> Enum.reduce(
                                         { MapSet.new(infected_nodes), {0,0}, :up, 0 },
                                         fn(_, acc) ->
                                           process_move(acc)
                                         end
                                       )

    { nodes, infection_count }
  end

  defp process_move({ infected_nodes, position, direction, infection_count }) do
    case MapSet.member?(infected_nodes, position) do
      true -> clean(infected_nodes, position, direction, infection_count)
      false -> infect(infected_nodes, position, direction, infection_count)
    end
  end

  def clean(infected_nodes, position, direction, infection_count) do
    new_direction = right_of(direction)

    {
      MapSet.delete(infected_nodes, position),
      move(position, new_direction),
      new_direction,
      infection_count
    }
  end

  def infect(infected_nodes, position, direction, infection_count) do
    new_direction = left_of(direction)

    {
      MapSet.put(infected_nodes, position),
      move(position, new_direction),
      new_direction,
      infection_count + 1
    }
  end

  defp right_of(:up), do: :right
  defp right_of(:right), do: :down
  defp right_of(:down), do: :left
  defp right_of(:left), do: :up

  defp left_of(:up), do: :left
  defp left_of(:right), do: :up
  defp left_of(:down), do: :right
  defp left_of(:left), do: :down

  defp reverse(:up), do: :down
  defp reverse(:right), do: :left
  defp reverse(:down), do: :up
  defp reverse(:left), do: :right

  defp move({x,y}, :up), do: {x,y+1}
  defp move({x,y}, :right), do: {x+1,y}
  defp move({x,y}, :down), do: {x,y-1}
  defp move({x,y}, :left), do: {x-1,y}

  def process_input(input) do
    width = width(input)
    height = height(input)

    input
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.reduce(
      MapSet.new,
      fn({row, row_index}, infected_nodes) ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index
        |> Enum.reduce(
          infected_nodes,
          fn({symbol, col_index}, infected_nodes) ->
            case symbol do
              "#" -> MapSet.put(infected_nodes, {col_index, row_index})
              _ -> infected_nodes
            end
          end
        )
      end
    )
    |> Enum.map(
      fn({x,y}) ->
        {
          x - div(width, 2),
          y - div(height, 2)
        }
      end
    )
    |> Enum.map(fn({x,y}) -> {x, -y} end)
  end

  def process_input2(input) do
    input
    |> process_input
    |> Map.new(
      fn(pos) -> { pos, :infected } end
    )
  end

  def width(input) do
    input
    |> String.split("\n", trim: true)
    |> List.first
    |> String.length
  end

  def height(input) do
    input
    |> String.split("\n", trim: true)
    |> length
  end
end

{ :ok, input } = File.read "day22-input.txt"

{_, infection_count1} = input
                       |> Day22.process_input
                       |> Day22.move_through_network(10000)
IO.puts "Part 1: #{infection_count1}"

{_, infection_count2} = input
                       |> Day22.process_input2
                       |> Day22.move_through_network2(10000000)
IO.puts "Part 2: #{infection_count2}"
