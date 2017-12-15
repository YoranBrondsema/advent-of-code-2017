defmodule Day10 do
  use Bitwise

  def hash(lengths, max) do
    initial_state = { Enum.to_list(0..max), 0, 0 }

    { hash, _, _ } = lengths
                     |> do_round(initial_state)

    hash
  end

  def do_round(lengths, initial_state) do
    lengths
    |> Enum.reduce(
      initial_state,
      &process_length/2
    )
  end

  defp process_length(length, { hash, position, skip_size }) do
    shifted = shift(hash, -position)

    { to_reverse, untouched } = Enum.split(shifted, length)

    new_hash = Enum.reverse(to_reverse) ++ untouched
               |> shift(position)

    new_position = rem(
      position + length + skip_size,
      length(hash)
    )

    { new_hash, new_position, skip_size + 1 }
  end

  def shift(l, 0), do: l
  def shift(l, n), do: Enum.slice(l, -n..-1) ++ Enum.slice(l, 0..-(n+1))

  def knot_hash(input) do
    lengths = get_lengths(input) ++ [17, 31, 73, 47, 23]
    initial_hash = Enum.to_list(0..255)

    { hash, _, _ } = (1..64)
                     |> Enum.reduce(
                       { initial_hash, 0, 0 },
                       fn(_, state) ->
                         do_round(lengths, state)
                       end
                     )

    hash
    |> Enum.chunk_every(16)
    |> Enum.map(&xor/1)
    |> Enum.map(fn(n) -> Integer.to_string(n, 16) end)
    |> Enum.map(&String.downcase/1)
    |> Enum.map(
      fn(s) ->
        case String.length(s) do
          1 -> "0#{s}"
          _ -> s
        end
      end
    )
    |> Enum.join
  end

  def xor(l) do
    l
    |> Enum.reduce(
      fn(n, acc) -> bxor(n, acc) end
    )
  end

  def get_lengths(s) do
    s
    |> String.to_charlist
  end
end
