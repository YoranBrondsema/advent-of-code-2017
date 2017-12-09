defmodule Trees do
  def to_node(name) do
    %{ name => %{ children: %{} } }
  end

  def filter(tree, fun) do
    tree
    |> Enum.filter(fun)
    |> Enum.map(
      fn({k, v}) ->
        %{ children: children } = v
        {k, Map.replace(v, :children, filter(children, fun))}
      end
    )
    |> Map.new
  end

  def replace(tree, _, _) when tree == %{}, do: %{}
  def replace(tree, node, new_node) do
    case tree do
      %{ ^node => _ } -> Map.replace(tree, node, new_node)
      _ ->
        tree
        |> Enum.map(
          fn({ k, v}) ->
            %{ children: children } = v
            { k, Map.replace(v, :children, replace(children, node, new_node)) }
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

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Trees

  test "#filter" do
    tree = to_node("a")

    assert filter(tree, fn({k, _}) -> k != "a" end) == %{}
    assert filter(tree, fn({k, _}) -> k != "b" end) == tree
  end

  test "#replace" do
    assert replace(to_node("a"), "a", to_node("b")) == %{ "a" => %{ "b" => %{ children: %{} } } }

    tree = %{
      "a" => %{
        children: %{
          "b" => %{}
        }
      }
    }
    assert replace(tree, "b", %{ "c" => %{} }) == %{ "a" => %{ children: %{ "b" => %{ "c" => %{} } } } }
  end
end
