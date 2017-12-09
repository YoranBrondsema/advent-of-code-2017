defmodule Day8 do
  def execute(instructions) do
    instructions
    |> Enum.reduce(
      { %{}, 0 },
      fn(instruction, { registry, all_time_max }) ->
        new_registry = process_instruction(instruction, registry)
        new_all_time_max = [ all_time_max | Map.values(new_registry) ]
                           |> Enum.max

        { new_registry, new_all_time_max }
      end
    )
  end

  defp process_instruction(instruction, registry) do
    [_, register, op, operand, cond_left, cond_op, cond_right] =
      ~r/(.+) (inc|dec) (.+) if (.+) (.+) (.+)/
      |> Regex.run(instruction)

    case evaluate_cond(cond_left, cond_op, cond_right, registry) do
      true ->
        left = Map.get(registry, register, 0)
        right = String.to_integer(operand)
        operation = get_operation(op)

        Map.put(
          registry,
          register,
          operation.(left, right)
        )
      false -> registry
    end
  end

  defp get_operation("inc"), do: &+/2
  defp get_operation("dec"), do: &-/2

  defp evaluate_cond(left, op, right, registry) do
    apply(
      Kernel,
      String.to_atom(op),
      [
        Map.get(registry, left, 0),
        String.to_integer(right)
      ]
    )
  end

  def max(registry) do
    registry
    |> Enum.max_by(fn({_, v}) -> v end)
  end
end

{ :ok, input } = File.read "day8-input.txt"

{ _, all_time_max } = input
|> String.split("\n", trim: true)
|> Day8.execute

IO.puts all_time_max
