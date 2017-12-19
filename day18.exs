defmodule Day18 do
  def duet(instructions) do
    _duet(instructions, { 0, nil, 0, Map.new })
  end

  defp _duet(_, { _, _, rcv, _ }) when rcv > 0, do: rcv
  defp _duet(instructions, state) do
    { pc, _, _, _ } = state
    instruction = Enum.at(instructions, pc)

    _duet(
      instructions,
      process_instruction(instruction, state)
    )
  end

  def process_instruction(instruction, state) do
    [_, cmd] = ~r/(snd|set|add|mul|mod|rcv|jgz)/
               |> Regex.run(instruction)

    case cmd do
      "snd" -> process_snd(instruction, state)
      "set" -> process_set(instruction, state)
      "add" -> process_add(instruction, state)
      "mul" -> process_mul(instruction, state)
      "mod" -> process_mod(instruction, state)
      "rcv" -> process_rcv(instruction, state)
      "jgz" -> process_jgz(instruction, state)
    end
  end

  def process_jgz(instruction, { pc, snd, rcv, registry }) do
    [_, x, y] = String.split(instruction)
    condition = get_value(registry, x)
    jump = get_value(registry, y)

    cond do
      condition > 0 ->
        {
          pc + jump,
          snd,
          rcv,
          registry
        }
      true ->
        {
          pc + 1,
          snd,
          rcv,
          registry
        }
    end
  end

  def process_snd(instruction, { pc, _, rcv, registry }) do
    [_, register] = String.split(instruction)
    value = Map.get(registry, register)

    {
      pc + 1,
      value,
      rcv,
      registry
    }
  end

  def process_mod(instruction, { pc, snd, rcv, registry }) do
    [_, register, y] = String.split(instruction)
    cur_value = Map.get(registry, register)
    new_value = rem(cur_value, get_value(registry, y))

    {
      pc + 1,
      snd,
      rcv,
      Map.put(registry, register, new_value)
    }
  end

  def process_mul(instruction, { pc, snd, rcv, registry }) do
    [_, register, y] = String.split(instruction)
    cur_value = get_value(registry, register)
    new_value = cur_value * get_value(registry, y)

    {
      pc + 1,
      snd,
      rcv,
      Map.put(registry, register, new_value)
    }
  end

  def process_add(instruction, { pc, snd, rcv, registry }) do
    [_, register, y] = String.split(instruction)
    cur_value = get_value(registry, register)
    new_value = cur_value + get_value(registry, y)

    {
      pc + 1,
      snd,
      rcv,
      Map.put(registry, register, new_value)
    }
  end

  def process_set(instruction, { pc, snd, rcv, registry }) do
    [_, register, y] = String.split(instruction)
    value = get_value(registry, y)

    {
      pc + 1,
      snd,
      rcv,
      Map.put(registry, register, value)
    }
  end

  def process_rcv(instruction, { pc, snd, rcv, registry }) do
    [_, register] = String.split(instruction)
    value = get_value(registry, register)

    cond do
      value > 0 ->
        {
          pc + 1,
          snd,
          snd,
          registry
        }
      true ->
        {
          pc + 1,
          snd,
          rcv,
          registry
        }
    end
  end

  def get_value(registry, x) do
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

# input = "
# set a 1
# add a 2
# mul a a
# mod a 5
# snd a
# set a 0
# rcv a
# jgz a -1
# set a 1
# jgz a -2
# "
{ :ok, input } = File.read "day18-input.txt"

input
|> String.split("\n", trim: true)
|> Day18.duet
|> IO.inspect
