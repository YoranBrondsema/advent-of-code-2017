defmodule Day5 do
  def step_count1(instructions) do
    to_map(instructions)
    |> _step_count(0, 0, &new_instruction1/1)
  end

  def step_count2(instructions) do
    to_map(instructions)
    |> _step_count(0, 0, &new_instruction2/1)
  end

  defp _step_count(instructions, position, count, new_instruction_f) do
    case Map.fetch(instructions, position) do
      { :ok, instruction } ->
        _step_count(
          Map.replace(instructions, position, new_instruction_f.(instruction)),
          position + instruction,
          count + 1,
          new_instruction_f
        )

      :error -> count
    end
  end

  defp new_instruction1(instruction), do: instruction + 1

  defp new_instruction2(instruction) when instruction >= 3, do: instruction - 1
  defp new_instruction2(instruction), do: instruction + 1

  defp to_map(list) do
    list
    |> Enum.with_index
    |> Enum.map(fn {value, index} -> {index, value} end)
    |> Map.new
  end
end

{ :ok, input } = File.read "day5-input.txt"

instructions = String.split(input, "\n", trim: true)
|> Enum.map(&String.to_integer/1)

IO.puts "step_count1: #{Day5.step_count1(instructions)}"
IO.puts "step_count2: #{Day5.step_count2(instructions)}"
