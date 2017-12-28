defmodule Day23 do
  def mul_count(input) do
    input
    |> String.trim
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Day23.run
    |> Enum.count(
      fn(instruction) -> instruction == :mul end
    )
  end

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

  def run2(instructions, registry), do: _run2(instructions, registry, 0)
  defp _run2(instructions, registry, pc) do
    instruction = Enum.at(instructions, pc)

    case instruction do
      nil -> registry
      _ ->
        { registry, pc, _ } = process_instruction(instruction, registry, pc, [])
        _run2(instructions, registry, pc)
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

  def value_of_h do
    b = 106500
    b..(b+17000)
    |> Enum.take_every(17)
    |> Enum.reject(&is_prime/1)
    |> length
  end

  def is_prime(x) do
    (2..x |> Enum.filter(fn a -> rem(x, a) == 0 end) |> length()) == 1
  end
end

{ :ok, input } = File.read "day23-input.txt"

mul_count = input
            |> Day23.mul_count
IO.puts "mul count: #{mul_count}"

value_of_h = Day23.value_of_h
IO.puts "value of h: #{value_of_h}"
