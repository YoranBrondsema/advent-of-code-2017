defmodule Day7 do
  def bottom_program(input) do
    { bottom_program, _ } = to_tree(input)
    bottom_program
  end

  def to_tree(input) do
    [ tree ] = input
               |> String.trim
               |> String.split("\n", trim: true)
               |> Enum.map(&String.trim/1)
               |> Enum.map(&to_name_with_children/1)
               |> Enum.reduce(
                 MapSet.new,
                 &process_line/2
               )
               |> Enum.to_list

    tree
  end

  def process_line(name_with_children, trees) do
    { name, children } = name_with_children

    { new_trees, children_nodes } =
      children
      |> Enum.reduce(
        { trees, MapSet.new },
        &process_child/2
      )

    if has_subtree?(trees, name) do
      new_trees
      |> replace_node(name, { name, children_nodes })
    else
      new_trees
      |> MapSet.put({ name, children_nodes })
    end
  end

  defp process_child(child_name, { trees, children_nodes }) do
    if has_subtree?(trees, child_name) do
      node = find_subtree(trees, child_name)
      {
        MapSet.delete(trees, node),
        MapSet.put(children_nodes, node)
      }
    else
      {
        trees,
        children_nodes
        |> MapSet.put({ child_name, MapSet.new })
      }
    end
  end

  # `trees` is a MapSet of trees
  defp has_subtree?(trees, node_name) do
    trees
    |> Enum.any?(
      fn(tree) -> _has_subtree?(tree, node_name) end
    )
  end
  # `tree` is a node
  defp _has_subtree?({ node_name, _ }, node_name), do: true
  defp _has_subtree?({ _, children }, node_name) do
    children
    |> Enum.any?(fn(child_tree) -> _has_subtree?(child_tree, node_name) end)
  end

  defp replace_node({ node_name, _ }, node_name, replacement), do: replacement
  defp replace_node({ other, children}, node_name, replacement) do
    {
      other,
      replace_node(children, node_name, replacement)
    }
  end
  defp replace_node(trees, node_name, replacement) do
    trees
    |> Enum.map(fn(tree) -> replace_node(tree, node_name, replacement) end)
    |> MapSet.new
  end

  # Finds the subtree that has as root `node_name`
  defp find_subtree({ node_name, children }, node_name) do
    { node_name, children }
  end
  defp find_subtree({ _, children }, node_name) do
    find_subtree(children, node_name)
  end
  defp find_subtree(trees, node_name) do
    trees
    |> Enum.find_value(fn(tree) -> find_subtree(tree, node_name) end)
  end

  # Converts
  # `fwft (72) -> ktlj, cntj, xhth`
  # to
  # { "ftft", ["ktlj", "cntj", "xhth"] }
  defp to_name_with_children(input_line) do
    regex = ~r/(.+) \((?:\d+)\)(?: -> (.+)$)?/

    case Regex.run(regex, input_line) do
      [ _, name ] -> { name, [] }
      [ _, name, children ] -> {
        name,
        children
        |> String.split(", ", trim: true)
      }
    end
  end

end

input = "
  pbga (66)
  xhth (57)
  ebii (61)
  havc (66)
  ktlj (57)
  fwft (72) -> ktlj, cntj, xhth
  qoyq (66)
  padx (45) -> pbga, havc, qoyq
  tknk (41) -> ugml, padx, fwft
  jptl (61)
  ugml (68) -> gyxo, ebii, jptl
  gyxo (61)
  cntj (57)
"

{ :ok, input } = File.read "day7-input.txt"
IO.puts Day7.bottom_program(input)

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day7

  test "#bottom_program" do
    input = "
      pbga (66)
      xhth (57)
      ebii (61)
      havc (66)
      ktlj (57)
      fwft (72) -> ktlj, cntj, xhth
      qoyq (66)
      padx (45) -> pbga, havc, qoyq
      tknk (41) -> ugml, padx, fwft
      jptl (61)
      ugml (68) -> gyxo, ebii, jptl
      gyxo (61)
      cntj (57)
    "

    assert bottom_program(input) == "tknk"
  end
end
