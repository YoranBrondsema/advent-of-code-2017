defmodule Day3 do
  def manhattan_distance(n) do
    row = row_for_number(n)
    col = col_for_number(n)

    abs(row) + abs(col)
  end

  def row_for_number(n) do
    circle(n)
    |> rows_for_circle
    |> Enum.at(index_in_circle(n))
  end

  def col_for_number(n) do
    circle(n)
    |> cols_for_circle
    |> Enum.at(index_in_circle(n))
  end

  def circle(n) do
    Kernel.trunc(
      Float.floor(
        (:math.sqrt(n-1) + 1) / 2
      )
    ) + 1
  end

  def index_in_circle(n) do
    numbers_before_circle = Kernel.trunc(
      :math.pow((2 * circle(n) - 3), 2) + 1
    )
    n - numbers_before_circle
  end

  def cols_for_circle(n) do
    shift(rows_for_circle(n), -(2*n - 2))
  end

  def rows_for_circle(n) do
    Enum.map(
      0..(8*n-8-1),
      fn(i) ->
        cond do
          i < 2*n - 3 ->
            -n + 2 + i
          i < 4*(n - 1) ->
            n - 1
          i < 6*(n - 1) - 1 ->
            5*n - 6 - i
          true ->
            1 - n
        end
      end
    )
  end

  defp shift(l, n) do
    Enum.slice(l, -n..-1) ++ Enum.slice(l, 0..-(n+1))
  end
end

IO.puts Day3.manhattan_distance(277678)

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day3

  test "#circle" do
    assert circle(1) == 1

    assert circle(2) == 2
    assert circle(9) == 2

    assert circle(10) == 3
    assert circle(25) == 3

    assert circle(26) == 4
  end

  test "#index_in_circle" do
    assert index_in_circle(2) == 0
    assert index_in_circle(3) == 1
    assert index_in_circle(9) == 7

    assert index_in_circle(10) == 0
    assert index_in_circle(25) == 15

    assert index_in_circle(26) == 0
  end

  test "#rows_for_circle" do
    assert rows_for_circle(2) == [0, 1, 1, 1, 0, -1, -1, -1]
    assert rows_for_circle(3) == [
      -1, 0, 1,
      2, 2, 2, 2, 2,
      1, 0, -1,
      -2, -2, -2, -2, -2
    ]
  end

  test "#cols_for_circle" do
    assert cols_for_circle(2) == [1, 1, 0, -1, -1, -1, 0, 1]
    assert cols_for_circle(3) == [
      2, 2, 2, 2,
      1, 0, -1,
      -2, -2, -2, -2, -2,
      -1, 0, 1,
      2
    ]
  end

  test "#row_for_number" do
    assert row_for_number(30) == 2
  end

  test "#manhattan_distance" do
    assert manhattan_distance(1) == 0
    assert manhattan_distance(12) == 3
    assert manhattan_distance(23) == 2
    assert manhattan_distance(1024) == 31
    assert manhattan_distance(277678) == 475
  end
end
