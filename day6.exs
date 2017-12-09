defmodule Day6 do
  def redistribution_count(banks) do
    _redistribution_count(banks, MapSet.new, 0)
  end

  defp _redistribution_count(banks, seen_configs, count) do
    next_bank = redistribute(banks)

    cond do
      MapSet.member?(seen_configs, next_bank) -> count + 1
      true ->
        _redistribution_count(
          next_bank,
          MapSet.put(seen_configs, next_bank),
          count + 1
        )
    end
  end

  def cycles_count(banks) do
    _cycles_count(banks, Map.new, 0)
  end

  defp _cycles_count(banks, seen_configs, count) do
    next_bank = redistribute(banks)

    cond do
      Map.has_key?(seen_configs, next_bank) ->
        { :ok, prev_index } = Map.fetch(seen_configs, next_bank)
        (count + 1) - prev_index
      true ->
        _cycles_count(
          next_bank,
          Map.put(seen_configs, next_bank, count + 1),
          count + 1
        )
    end
  end

  defp redistribute(banks) do
    { count, index } = max(banks)

    complete_tours_count = div(count, length(banks))
    remainder = rem(count, length(banks))

    shifted = banks
              |> List.replace_at(index, 0)
              |> shift(-(index+1))

    redistributed_shifted =
      shifted
      |> Enum.with_index
      |> Enum.map(
        fn({ value, index }) ->
          cond do
            index < remainder -> value + complete_tours_count + 1
            true -> value + complete_tours_count
          end
        end
      )

    shift(redistributed_shifted, index+1)
  end

  defp max(banks) do
    max = Enum.max(banks)
    index = Enum.find_index(banks, fn(x) -> x == max end)

    { max, index }
  end

  defp shift(l, n), do: Enum.slice(l, -n..-1) ++ Enum.slice(l, 0..-(n+1))
end

l = "10 3 15  10  5 15  5 15  9 2 5 8 5 2 3 6"
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)

l
|> Day6.redistribution_count
|> IO.puts

l
|> Day6.cycles_count
|> IO.puts
