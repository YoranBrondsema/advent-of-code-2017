defmodule Day24 do
  def strongest_bridge(components), do: max_by(components, &strength/1)
  def longest_bridge(components), do: max_by(components, &length_and_strength/1)

  defp max_by(components, max_by) do
    _max_by([], components, max_by)
    |> elem(0)
  end

  defp _max_by(bridge, components, max_by) do
    additions = pick_additions_for(bridge, components)

    case additions do
      [] -> { bridge, max_by.(bridge) }
      _ ->
        additions
        |> Enum.map(fn(addition) -> [ addition | bridge ] end)
        |> Enum.map(
          fn(new_bridge) -> _max_by(new_bridge, components, max_by) end
        )
        |> Enum.max_by(fn({ _, value }) -> value end)
    end
  end

  def pick_additions_for([], components) do
    components
    |> Enum.filter(
      fn({left, right}) -> left == 0 or right == 0 end
    )
  end
  def pick_additions_for(bridge, components) do
    possibilities = filter_out_common_components(bridge, components)
    [{{l,r}, dir} | _] = add_directions(bridge)

    port = case dir do
      :ltr -> r
      :rtl -> l
    end

    possibilities
    |> Enum.filter(
      fn({l,r}) -> l == port or r == port end
    )
  end

  def filter_out_common_components(bridge, components) do
    components
    |> Enum.filter(
      fn(component) ->
        !Enum.member?(bridge, component)
      end
    )
  end

  def add_directions(bridge) do
    bridge
    |> Enum.reverse
    |> Enum.reduce(
      [],
      fn(component, acc) -> [set_direction(component, acc) | acc] end
    )
  end

  def set_direction({0, r}, []), do: { {0, r}, :ltr }
  def set_direction({r, 0}, []), do: { {r, 0}, :rtl }
  def set_direction(component, [ p | _ ]) do
    port = case p do
      { {_,r}, :ltr } -> r
      { {l,_}, :rtl } -> l
    end

    case component do
      { ^port, r } -> { {port, r}, :ltr }
      { l, ^port } -> { {l, port}, :rtl }
    end
  end

  def length_and_strength(bridge) do
    { length(bridge), strength(bridge) }
  end

  def strength(bridge) do
    bridge
    |> Enum.reduce(
      0,
      fn({left, right}, acc) -> acc + left + right end
    )
  end

  def process_input(input) do
    input
    |> String.trim
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(
      fn(line) ->
        [_, left, right] = ~r/(.+)\/(.+)/
          |> Regex.run(line)

          [left, right] = [left, right]
                          |> Enum.map(
                            fn(s) ->
                              {i, _} = Integer.parse(s)
                              i
                            end
                          )

                          { left, right }
      end
    )
  end
end

{ :ok, input } = File.read "day24-input.txt"

components = input
             |> Day24.process_input

IO.puts "Strongest bridge:"
components
|> Day24.strongest_bridge
|> Day24.strength
|> IO.inspect

IO.puts "Longest bridge:"
components
|> Day24.longest_bridge
|> Day24.strength
|> IO.inspect

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day24

  test "#strength" do
    assert strength([{0,2}, {10,1}]) == 13
  end

  test "#strongest_bridge" do
    components = [{0, 2}, {2, 2}, {2, 3}, {3, 4}, {3, 5}, {0, 1}, {10, 1}, {9, 10}]
    assert strongest_bridge(components) == [{9, 10}, {10, 1}, {0, 1}]
  end

  test "#pick_additions_for" do
    components = [{0, 2}, {2, 2}, {2, 3}, {3, 4}, {3, 5}, {0, 1}, {10, 1}, {9, 10}]

    assert pick_additions_for([], components) == [{0, 2}, {0, 1}]
    assert pick_additions_for([{0,2}], components) == [{2, 2}, {2, 3}]
    assert pick_additions_for([{10,1}, {0,1}], components) == [{9,10}]
  end

  test "#filter_out_common_components" do
    components = [{0, 2}, {2, 2}, {2, 3}, {3, 4}, {3, 5}, {0, 1}, {10, 1}, {9, 10}]
    assert filter_out_common_components([{0,1}], components) == [{0, 2}, {2, 2}, {2, 3}, {3, 4}, {3, 5}, {10, 1}, {9, 10}]
  end

  test "#set_direction" do
    assert set_direction({0, 2}, []) == { {0, 2}, :ltr }
    assert set_direction({2, 0}, []) == { {2, 0}, :rtl }
    assert set_direction({2, 5}, [{{0,2},:ltr}]) == { {2, 5}, :ltr }
    assert set_direction({5, 2}, [{{0,2},:ltr}]) == { {5, 2}, :rtl }
  end

  test "#add_directions" do
    assert add_directions([{2,5}, {2,0}]) == [ {{2,5},:ltr}, {{2,0},:rtl} ]
  end
end
