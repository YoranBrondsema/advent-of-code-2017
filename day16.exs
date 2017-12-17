defmodule Day16 do
  def dance(dance_moves, initial_state) do
    dance_moves
    |> process_dance_moves
    |> Enum.reduce(
      initial_state,
      fn(move, state) ->
        state
        |> process_move(move)
      end
    )
  end

  defp process_move(state, { "s", spin }), do: spin(state, spin)
  defp process_move(state, { "x", pos_a, pos_b }), do: exchange(state, pos_a, pos_b)
  defp process_move(state, { "p", a, b }), do: partner(state, a, b)

  def get_initial_state do
    0..15
    |> Enum.map(
      fn(i) ->
        [a] = 'a'
        a + i
      end
    )
    |> List.to_string
    |> String.split("", trim: true)
    |> Enum.with_index
    |> Map.new(
      fn({ value, position }) -> { position, value } end
    )
  end

  defp spin(state, n) do
    length = Kernel.map_size(state)
    state
    |> Enum.map(
      fn({position, value}) ->
        { rem(position + n, length), value }
      end
    )
    |> Map.new
  end

  defp exchange(state, pos_a, pos_b) do
    { :ok, a } = Map.fetch(state, pos_a)
    { :ok, b } = Map.fetch(state, pos_b)

    state
    |> Map.put(pos_a, b)
    |> Map.put(pos_b, a)
  end

  defp partner(state, a, b) do
    pos_a = position_of_program(state, a)
    pos_b = position_of_program(state, b)
    exchange(state, pos_a, pos_b)
  end

  defp position_of_program(state, program) do
    { position, _ } = state
                      |> Enum.find(
                        fn({ _, value }) ->
                          value == program
                        end
                      )

    position
  end

  def dance_a_lot(dance_moves, n) do
    { state, _ } = 1..n
                   |> Enum.reduce(
                     { get_initial_state(), MapSet.new },
                     fn(_, { state, all_states }) ->
                       new_state = dance(dance_moves, state)
                       case MapSet.member?(all_states, new_state) do
                         true -> { new_state, all_states }
                         false ->
                           {
                             new_state,
                             MapSet.put(all_states, new_state)
                           }
                       end
                     end
                   )

    state
  end

  def periodicity(dance_moves, initial_state) do
    _periodicity(dance_moves, initial_state, MapSet.new([initial_state]), 1)
  end

  defp _periodicity(dance_moves, state, all_states, period) do
    new_state = dance_moves
                |> dance(state)

    case MapSet.member?(all_states, new_state) do
      true -> period
      _ -> _periodicity(dance_moves, new_state, MapSet.put(all_states, new_state), period + 1)
    end
  end

  defp process_dance_moves(dance_moves) do
    regex_spin = ~r/s(\d+)/
    regex_exchange = ~r/x(\d+)\/(\d+)/
    regex_partner = ~r/p(.+)\/(.+)/

    dance_moves
    |> String.split(",", trim: true)
    |> Enum.map(
      fn(move) ->
        cond do
          Regex.match?(regex_spin, move) ->
            [_, spin] = regex_spin
                        |> Regex.run(move)
            { "s", String.to_integer(spin) }
          Regex.match?(regex_exchange, move) ->
            [_, pos_a, pos_b] = regex_exchange
                                |> Regex.run(move)
            { "x", String.to_integer(pos_a), String.to_integer(pos_b) }
          Regex.match?(regex_partner, move) ->
            [_, a, b] = regex_partner
                        |> Regex.run(move)
            { "p", a, b }
        end
      end
    )
  end
end

{ :ok, dance_moves } = File.read "day16-input.txt"

initial_state = Day16.get_initial_state

IO.puts "After 1 dance"
dance_moves
|> Day16.dance(initial_state)
|> Map.values
|> Enum.join
|> IO.inspect

period = Day16.periodicity(dance_moves, initial_state)
IO.puts "\nPeriod: #{period}"

number_of_dances = rem(1000000000, period)
IO.puts "\nAfter 1 billion dances"
dance_moves
|> Day16.dance_a_lot(number_of_dances)
|> Map.values
|> Enum.join
|> IO.inspect
