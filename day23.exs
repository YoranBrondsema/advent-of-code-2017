defmodule Day23 do
  def run(instructions) do
    _run(instructions, Map.new, 0, [])
    |> Enum.reverse
  end

  defp _run(instructions, registry, pc, executed) do
    instruction = Enum.at(instructions, pc)

    case instruction do
      nil -> executed
      _ ->
        { registry, pc, executed } = process_instruction(instruction, registry, pc, executed)
        _run(instructions, registry, pc, executed)
    end
  end

  def process_instruction(instruction, registry, pc, executed) do
    [_, cmd, x, y] = ~r/(set|sub|mul|jnz) (.+) (.+)/
               |> Regex.run(instruction)

    case cmd do
      "set" -> process_set(registry, pc, executed, x, y)
      "sub" -> process_sub(registry, pc, executed, x, y)
      "mul" -> process_mul(registry, pc, executed, x, y)
      "jnz" -> process_jnz(registry, pc, executed, x, y)
    end
  end

  defp process_set(registry, pc, executed, x, y) do
    {
      Map.put(registry, x, get_value(registry, y)),
      pc + 1,
      [ :set | executed ]
    }
  end

  defp process_sub(registry, pc, executed, x, y) do
    val_x = get_value(registry, x)
    val_y = get_value(registry, y)

    {
      Map.put(registry, x, val_x - val_y),
      pc + 1,
      [ :sub | executed ]
    }
  end

  defp process_mul(registry, pc, executed, x, y) do
    val_x = get_value(registry, x)
    val_y = get_value(registry, y)

    {
      Map.put(registry, x, val_x * val_y),
      pc + 1,
      [ :mul | executed ]
    }
  end

  defp process_jnz(registry, pc, executed, x, y) do
    val_x = get_value(registry, x)

    case val_x != 0 do
      true ->
        {
          registry,
          pc + get_value(registry, y),
          [ :jnz | executed ]
        }
      false ->
        {
          registry,
          pc + 1,
          [ :jnz | executed ]
        }
    end
  end

  defp get_value(registry, x) do
    case Integer.parse(x) do
      :error ->
        case Map.get(registry, x) do
          nil -> 0
          value -> value
        end
      { value, _ } -> value
    end
  end
end

{ :ok, input } = File.read "day23-input.txt"

input
|> String.split("\n", trim: true)
|> Day23.run
|> Enum.count(
  fn(instruction) -> instruction == :mul end
)
|> IO.inspect
