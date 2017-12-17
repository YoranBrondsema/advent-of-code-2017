defmodule Day16 do
  def dance(dance_moves) do
    dance_moves
    |> String.split(",", trim: true)
    |> Enum.reduce(
      get_initial_state(),
      fn(move, state) ->
        state
        |> process_move(move)
      end
    )
    |> Enum.join
  end

  def process_move(state, move) do
    [
      process_spin(state, move),
      process_exchange(state, move),
      process_partner(state, move)
    ]
    |> Enum.find(
      fn(state) -> state != nil end
    )
  end

  def process_spin(state, move) do
    case Regex.run(~r/s(\d+)/, move) do
      nil -> nil
      [_, spin] -> spin(state, String.to_integer(spin))
    end
  end

  def process_exchange(state, move) do
    case Regex.run(~r/x(\d+)\/(\d+)/, move) do
      nil -> nil
      [_, pos_a, pos_b] -> exchange(state, String.to_integer(pos_a), String.to_integer(pos_b))
    end
  end

  def process_partner(state, move) do
    case Regex.run(~r/p(.+)\/(.+)/, move) do
      nil -> nil
      [_, a, b] -> partner(state, a, b)
    end
  end

  defp get_initial_state do
    0..15
    |> Enum.map(
      fn(i) ->
        [a] = 'a'
        a + i
      end
    )
    |> List.to_string
    |> String.split("", trim: true)
  end

  def spin(state, n), do: shift(state, n)

  def exchange(state, pos_a, pos_b) do
    a = Enum.at(state, pos_a)
    b = Enum.at(state, pos_b)

    state
    |> List.replace_at(pos_a, b)
    |> List.replace_at(pos_b, a)
  end

  def partner(state, a, b) do
    pos_a = position_of_program(state, a)
    pos_b = position_of_program(state, b)
    exchange(state, pos_a, pos_b)
  end

  def position_of_program(state, program) do
    state
    |> Enum.find_index(
      fn(p) -> p == program end
    )
  end

  defp shift(l, n), do: Enum.slice(l, -n..-1) ++ Enum.slice(l, 0..-(n+1))
end

{ :ok, dance_moves } = File.read "day16-input.txt"

dance_moves
|> Day16.dance
|> IO.inspect
