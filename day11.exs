defmodule Day11 do
  def position(input) do
    input
    |> String.split(",")
    |> Enum.reduce(
      { 0, 0 },
      &move/2
    )
  end

  defp move("n", { m, n }), do: { m, n+2 }
  defp move("ne", { m, n }), do: { m+2, n+1 }
  defp move("se", { m, n }), do: { m+2, n-1 }
  defp move("s", { m, n }), do: { m, n-2 }
  defp move("sw", { m, n }), do: { m-2, n-1 }
  defp move("nw", { m, n }), do: { m-2, n+1 }

  def step_count(input) do
    input
    |> position
    |> _step_count
  end

  defp _step_count({ m, n }) when m >= 0 and n >= 0 do
    cond do
      n <= m/2 ->
        y = (m - 2*n) / 4
        n + 2*y
      n <= 3*m/2 -> (2*n + m)/4
      true -> n/2 + m/4
    end
  end

  defp _step_count({ m, n }) when m >= 0 and n < 0 do
    _step_count({ m, -n })
  end

  defp _step_count({ m, n }) when m <= 0 and n <= 0 do
    _step_count({ -m, -n })
  end

  defp _step_count({ m, n }) when m <= 0 and n > 0 do
    _step_count({ -m, n })
  end

  def furthest(input) do
    { _, max } = input
                 |> String.split(",")
                 |> Enum.reduce(
                   { [], 0 },
                   fn(move, { path, max }) ->
                     new_path = [ move | path ]
                                |> Enum.reverse

                                steps = step_count(Enum.join(new_path, ","))

                                {
                                  Enum.reverse(new_path),
                                  Enum.max([max, steps])
                                }
                   end
                 )

    max
  end
end

{ :ok, input } = File.read "day11-input.txt"

distance = input
           |> String.trim
           |> Day11.step_count
           |> Kernel.trunc
IO.puts "Distance: #{distance}"

furthest = input
           |> String.trim
           |> Day11.furthest
           |> Kernel.trunc
IO.puts "Furthest: #{furthest}"

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day11

  test "#step_count" do
    assert step_count("ne,se") == 2
    assert step_count("ne,ne,se") == 3
    assert step_count("ne") == 1
    assert step_count("ne,n") == 2
    assert step_count("n,n,ne") == 3

    assert step_count("se,se") == 2
    assert step_count("se,se,se,ne") == 4
    assert step_count("s") == 1
    assert step_count("se,s") == 2

    assert step_count("s,s,sw") == 3
  end
end
