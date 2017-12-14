defmodule Day13 do
  def severity_of_trip(layers) do
    layers
    |> catching_layers(0)
    |> Enum.map(&severity/1)
    |> Enum.sum
  end

  def delay(layers), do: _delay(layers, 0)

  # We know from the problem that there is always a delay that will give no
  # catching layers. So we don't need an upper bound on the recursion.
  def _delay(layers, delay) do
    catching_layers = catching_layers(layers, delay)

    case catching_layers do
      [] -> delay
      _ -> _delay(layers, delay + 1)
    end
  end

  def process_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(
      fn(line) ->
        [_, depth, range] = ~r/(\d+): (\d+)/
                            |> Regex.run(line)

        {
          String.to_integer(depth),
          String.to_integer(range)
        }
      end
    )
  end

  defp catching_layers(layers, initial_delay) do
    layers
    |> Enum.filter(
      fn({ depth, range }) ->
        period = 2*(range - 1)
        rem(depth + initial_delay, period) == 0
      end
    )
  end

  defp severity({ depth, range }), do: depth * range
end

{ :ok, input } = File.read "day13-input.txt"

severity = input
           |> Day13.process_input
           |> Day13.severity_of_trip

delay = input
        |> Day13.process_input
        |> Day13.delay

IO.puts "Severity: #{severity}"
IO.puts "Delay: #{delay}"
