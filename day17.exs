defmodule Day17 do
  def spinlock2(input) do
    { _, after_0 } = 1..50000000
                     |> Enum.reduce(
                       { 0, nil },
                       fn(step, { cur_pos, after_0 }) ->
                         insert_at = get_insertion_position(cur_pos, step, input)

                         after_0 = case insert_at do
                           1 -> step
                           _ -> after_0
                         end

                         {
                           insert_at,
                           after_0
                         }
                       end
                     )

    after_0
  end

  def spinlock(input) do
    1..2017
    |> Enum.reduce(
      { [0], 0 },
      fn(step, acc) ->
        process_step(step, acc, input)
      end
    )
  end

  def process_step(step, { buffer, cur_pos }, input) do
    insert_at = get_insertion_position(cur_pos, length(buffer), input)

    {
      List.insert_at(buffer, insert_at, step),
      insert_at
    }
  end

  defp get_insertion_position(cur_position, buffer_length, input) do
    rem(cur_position + input, buffer_length) + 1
  end
end

{ buffer, position } = Day17.spinlock(316)

part1 = buffer
        |> Enum.at(position + 1)

part2 = Day17.spinlock2(316)

IO.puts "Part 1: #{part1}"
IO.puts "Part 2: #{part2}"
