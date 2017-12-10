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

  def hash2(input) do
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

lengths = [14,58,0,116,179,16,1,104,2,254,167,86,255,55,122,244]

hash = lengths
       |> Day10.hash(255)

[ first | [second | _] ] = hash
IO.puts "Multiply: #{first * second}"

hash2 = lengths
        |> Enum.map(&Integer.to_string/1)
        |> Enum.join(",")
        |> Day10.hash2
IO.puts "Knot hash: #{hash2}"

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day10

  test "#hash" do
    assert hash([3, 4, 1, 5], 4) == [3, 4, 2, 1, 0]
  end

  test "#get_lengths" do
    assert get_lengths("1,2,3") == [49,44,50,44,51]
  end

  test "#xor" do
    assert xor([65, 27, 9, 1, 4, 3, 40, 50, 91, 7, 6, 0, 2, 5, 68, 22]) == 64
  end

  test "hash2" do
    assert hash2("") == "a2582a3a0e66e6e86e3812dcb672a272"
    assert hash2("AoC 2017") == "33efeb34ea91902bb2f59c9920caa6cd"
    assert hash2("1,2,3") == "3efbe78a8d82f29979031a4aa0b16a9d"
    assert hash2("1,2,4") == "63960835bcdc130f0b66d7ff4f6a5a8e"
  end
end
