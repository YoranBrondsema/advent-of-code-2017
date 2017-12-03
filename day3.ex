defmodule Day3 do
  # PART 1
  def manhattan_distance(n) do
    row = row_for_number(n)
    col = col_for_number(n)

    abs(row) + abs(col)
  end

  defp row_for_number(n) do
    circle(n)
    |> rows_for_circle
    |> Enum.at(index_in_circle(n))
  end

  defp col_for_number(n) do
    circle(n)
    |> cols_for_circle
    |> Enum.at(index_in_circle(n))
  end

  defp circle(n) do
    Kernel.trunc(
      Float.floor(
        (:math.sqrt(n-1) + 1) / 2
      )
    ) + 1
  end

  defp index_in_circle(n) do
    numbers_before_circle = Kernel.trunc(
      :math.pow((2 * circle(n) - 3), 2) + 1
    )
    n - numbers_before_circle
  end

  defp cols_for_circle(n) do
    shift(rows_for_circle(n), -2*(n - 1))
  end

  defp rows_for_circle(n) do
    Enum.map(
      0..(8*(n-1)-1),
      fn(i) -> row(i, n) end
    )
  end 
  defp row(i, n) when i < 2*n - 3, do: -n + 2 + i
  defp row(i, n) when i < 4*(n - 1), do: n - 1
  defp row(i, n) when i < 6*(n - 1) - 1, do: 5*n - 6 - i
  defp row(_, n), do: 1 - n

  defp shift(l, n) do
    Enum.slice(l, -n..-1) ++ Enum.slice(l, 0..-(n+1))
  end

  # PART 2
  def sums_until(n) do
    [{_, _, value} | _] = _sums_until(n, [{0, 0, 1}])
    value
  end

  defp _sums_until(n, [{row, col, value} | tail]) when value > n do
    [{row, col, value} | tail]
  end
  defp _sums_until(n, l) do
    [{row, col, _ } | _] = l

    { next_row, next_col } = next_position({row, col})

    next_value = Enum.map(
      surrounding_positions({ next_row, next_col }),
      fn({ row, col }) ->
        value_for_position({ row, col }, l)
      end
    )
    |> Enum.sum

    _sums_until(n, [ {next_row, next_col, next_value} | l])
  end

  defp value_for_position({ row, col}, l) do
    entry = Enum.find(
      l,
      fn(el) ->
        elem(el, 0) == row && elem(el, 1) == col
      end
    )

    case entry do
      { _, _, value } -> value
      _ -> 0
    end
  end

  defp next_position(pos) do
    case pos do
      { row, col } when row <= 0 and col == -row -> { row, col+1 }
      { row, col } when col > 0 and abs(row) < abs(col) -> { row+1, col }
      { row, row } when row > 0 -> { row, row-1 }
      { row, col } when row > 0 and col > -row -> { row, col-1 }
      { row, col } when row > 0 and col == -row -> { row-1, col }
      { row, col } when col < 0 and row > col -> { row-1, col }
      { row, row } when row < 0 -> { row, row+1 }
      { row, col } when row < 0 and col < -row -> { row, col+1 }
    end
  end

  defp surrounding_positions({ row, col }) do
    for i <- [-1, 0, 1], j <- [-1, 0, 1],
      { row + i, col + j } != { row, col },
      do: { row + i, col + j}
  end
end

IO.puts Day3.manhattan_distance(277678)
IO.puts Day3.sums_until(277678)

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day3

  test "#manhattan_distance" do
    assert manhattan_distance(277678) == 475
  end

  test "#sums_until" do
    assert sums_until(277678) == 279138
  end
end
