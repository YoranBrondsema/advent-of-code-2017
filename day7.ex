defmodule Day7 do
  def bottom_program(input) do
    input
    |> process_input
    |> Map.keys
    |> List.first
  end

  def process_input(input) do
    input
    |> String.trim
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&process_input_line/1)
    |> Enum.reduce(%{}, &process_line/2)
  end

  defp process_input_line(input_line) do
    regex = ~r/(.+) \((\d+)\)(?: -> (.+)$)?/

    case Regex.run(regex, input_line) do
      [ _, name, _ ] -> { name, [] }
      [ _, name, _, children ] -> {
        name,
        children
        |> String.split(", ", trim: true)
      }
    end
  end

  def process_line({ name, children }, tree) do
    children_from_tree = children
                         |> Enum.map(
                           fn(child) ->
                             case find_subtree_of_node(tree, child) do
                               nil -> { child, %{} }
                               a -> { child, a }
                             end
                           end
                         )
                         |> Map.new

    tree_without_children = children
                            |> Enum.reduce(
                              tree,
                              fn(child, tree) ->
                                filter(
                                  tree,
                                  fn({ node, _ }) -> node != child end
                                )
                              end
                            )

    case find_subtree_of_node(tree_without_children, name) do
      nil -> Map.put(tree_without_children, name, children_from_tree)
      _ -> replace(tree_without_children, name, children_from_tree)
    end
  end

  def filter(tree, fun) do
    tree
    |> Enum.filter(fun)
    |> Enum.map(fn({k, v}) -> {k, filter(v, fun)} end)
    |> Map.new
  end

  def replace(tree, _, _) when tree == %{}, do: %{}
  def replace(tree, node, new_node) do
    case tree do
      %{ ^node => _ } -> Map.replace(tree, node, new_node)
      _ ->
        tree
        |> Enum.map(
          fn({ k, v }) ->
            { k, replace(v, node, new_node) }
          end
        )
        |> Map.new
    end
  end

  def find_subtree_of_node(tree, node) do
    tree
    |> Enum.find_value(
      fn({k, v}) ->
        case k do
          ^node -> v
          _ -> find_subtree_of_node(v, node)
        end
      end
    )
  end
end

{ :ok, input } = File.read "day7-input.txt"
IO.puts Day7.bottom_program(input)

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day7

  test "#find_subtree_of_node" do
    assert find_subtree_of_node( %{ "fwft" => %{} }, "fwft") == %{}
    assert find_subtree_of_node( %{ "fwft" => %{} }, "gfds") == nil
    assert find_subtree_of_node( %{ "fwft" => %{ "abcd" => %{}, "gfde" => %{} } }, "fwft") == %{ "abcd" => %{}, "gfde" => %{} }
    assert find_subtree_of_node( %{ "fwft" => %{ "abcd" => %{}, "gfde" => %{} } }, "abcd") == %{}

    tree = %{
      "tknk" => %{
        "ugml" => %{
          "gyxo" => %{},
          "ebii" => %{},
          "jptl" => %{}
        },
        "padx" => %{
          "pbga" => %{},
          "havc" => %{},
          "qoyq" => %{}
        },
        "fwft" => %{
          "ktlj" => %{},
          "cntj" => %{},
          "xhth" => %{}
        }
      }
    }
    assert find_subtree_of_node(tree, "gyxo") == %{}
  end

  test "#replace" do
    assert replace(%{ "abcd" => %{} }, "abcd", %{ "edfg" => %{} }) == %{ "abcd" => %{ "edfg" => %{} } }
  end

  test "#filter" do
    assert filter(%{"a" => %{}}, fn({k, _}) -> k != "a" end) == %{}
    assert filter(%{"a" => %{}}, fn({k, _}) -> k != "b" end) == %{ "a" => %{}}
  end

  test "#process_input" do
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
    assert process_input(input) == %{
      "tknk" => %{
        "ugml" => %{
          "gyxo" => %{},
          "ebii" => %{},
          "jptl" => %{}
        },
        "padx" => %{
          "pbga" => %{},
          "havc" => %{},
          "qoyq" => %{}
        },
        "fwft" => %{
          "ktlj" => %{},
          "cntj" => %{},
          "xhth" => %{}
        }
      }
    }
  end

  test "#process_line" do
    tree = %{
      "ebii" => %{},
      "tknk" => %{
        "ugml" => %{},
        "padx" => %{
          "pbga" => %{},
          "havc" => %{},
          "qoyq" => %{}
        },
        "fwft" => %{
          "ktlj" => %{},
          "cntj" => %{},
          "xhth" => %{}
        },
      },
      "jptl" => %{}
    }

    assert process_line({ "ugml", ["gyxo", "ebii", "jptl"] }, tree) == %{
      "tknk" => %{
        "ugml" => %{
          "gyxo" => %{},
          "ebii" => %{},
          "jptl" => %{}
        },
        "padx" => %{
          "pbga" => %{},
          "havc" => %{},
          "qoyq" => %{}
        },
        "fwft" => %{
          "ktlj" => %{},
          "cntj" => %{},
          "xhth" => %{}
        }
      }
    }
  end
end
