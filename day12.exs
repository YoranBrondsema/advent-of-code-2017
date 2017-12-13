defmodule Day12 do
  def groups(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> _groups(MapSet.new)
  end

  def _groups(lines, groups) do
    { groups, has_changed } = _do_groups_round(lines, groups)

    case has_changed do
      true -> _groups(lines, groups)
      false -> groups
    end
  end

  defp get_groups_to_be_merged(connected_programs, groups) do
    connected_programs
    |> Enum.reduce(
      MapSet.new,
      fn(program, groups_to_be_merged) ->
        group = groups
                |> Enum.find(
                  fn(group) ->
                    group
                    |> MapSet.member?(program)
                  end
                )

        case group do
          nil ->
            groups_to_be_merged
            |> MapSet.put(MapSet.new([program]))
          _ ->
            groups_to_be_merged
            |> MapSet.put(group)
        end
      end
    )
  end

  defp get_union(groups) do
    groups
    |> Enum.reduce(
      MapSet.new,
      fn(group_to_be_merged, union) ->
        MapSet.union(union, group_to_be_merged)
      end
    )
  end

  def _do_groups_round(lines, initial_groups) do
    lines
    |> Enum.reduce(
      { initial_groups, false },
      fn(connected_programs, { groups, has_changed }) ->
        groups_to_be_merged = get_groups_to_be_merged(
          connected_programs, groups
        )

        union = get_union(groups_to_be_merged)

        new_groups = groups_to_be_merged
                     |> Enum.reduce(
                       groups,
                       fn(group_to_be_merged, groups) ->
                         MapSet.delete(groups, group_to_be_merged)
                       end
                     )
                     |> MapSet.put(union)

        {
          new_groups,
          has_changed || (new_groups !== groups)
        }
      end
    )
  end

  def connected_programs(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> _connected_programs(MapSet.new([0]))
  end

  def _connected_programs(lines, programs) do
    { programs, has_changed } = do_round(lines, programs)

    case has_changed do
      true -> _connected_programs(lines, programs)
      false -> programs
    end
  end

  def do_round(lines, initial_programs) do
    lines
    |> Enum.reduce(
      { initial_programs, false },
      fn(all_programs, { programs, has_changed }) ->
        has_member = all_programs
                     |> any_is_member?(programs)

        case has_member do
          true ->
            new_programs = MapSet.union(programs, MapSet.new(all_programs))

            {
              new_programs,
              has_changed || !is_same_size?(new_programs, programs)
            }
          false -> { programs, has_changed }
        end
      end
    )
  end

  defp any_is_member?(l, map) do
    l
    |> Enum.any?(
      fn(el) -> MapSet.member?(map, el) end
    )
  end

  defp is_same_size?(a, b), do: MapSet.size(a) == MapSet.size(b)

  defp parse_line(line) do
    [_, program, connected_programs] = ~r/(\d+) <-> (.+)/
                                      |> Regex.run(line)

    program = String.to_integer(program)
    connected_programs = connected_programs
                         |> String.split(", ")
                         |> Enum.map(&String.to_integer/1)

    [ program | connected_programs ]
  end
end

{ :ok, input } = File.read "day12-input.txt"

Day12.connected_programs(input)
|> MapSet.size
|> IO.inspect

Day12.groups(input)
|> MapSet.size
|> IO.inspect
