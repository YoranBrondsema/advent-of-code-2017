defmodule Day18 do
  def duet(instructions) do
    _duet(
      instructions,
      { 0, 0, 0, Map.new(%{"p" => 0}) },
      [],
      { 1, 0, 0, Map.new(%{"p" => 1}) },
      []
    )
  end

  defp _duet(instructions, state0, queue0, state1, queue1) do
    { _, pc0, _, _ } = state0
    { _, pc1, _, _ } = state1

    instruction0 = Enum.at(instructions, pc0)
    instruction1 = Enum.at(instructions, pc1)

    case (Enum.empty?(queue0) and rcv?(instruction0) and Enum.empty?(queue1) and rcv?(instruction1)) do
      true -> state1
      _ ->
        { state0, queue0, queue1 } = process_instruction(instruction0, state0, queue0, queue1)
        { state1, queue0, queue1 } = process_instruction(instruction1, state1, queue0, queue1)

        _duet(
          instructions,
          state0,
          queue0,
          state1,
          queue1
        )
    end
  end

  defp rcv?(instruction), do: Regex.match?(~r/rcv/, instruction)

  defp process_instruction(_, { id, :waiting, snd_count, registry }, queue0, queue1) do
    {
      { id, :waiting, snd_count, registry },
      queue0,
      queue1
    }
  end
  defp process_instruction(instruction, state, queue0, queue1) do
    [_, cmd] = ~r/(snd|set|add|mul|mod|rcv|jgz)/
               |> Regex.run(instruction)

    result = case cmd do
      "set" -> process_set(instruction, state)
      "add" -> process_add(instruction, state)
      "mul" -> process_mul(instruction, state)
      "mod" -> process_mod(instruction, state)
      "jgz" -> process_jgz(instruction, state)
      "snd" -> process_snd(instruction, state, queue0, queue1)
      "rcv" -> process_rcv(instruction, state, queue0, queue1)
    end

    case result do
      { state, queue0, queue1 } -> { state, queue0, queue1 }
      state -> { state, queue0, queue1 }
    end
  end

  defp process_snd(instruction, { id, pc, snd_count, registry }, queue0, queue1) do
    [_, register] = String.split(instruction)
    value = Map.get(registry, register)

    case id do
      0 ->
        {
          { id, pc + 1, snd_count + 1, registry },
          queue0,
          List.insert_at(queue1, -1, value)
        }
      1 ->
        {
          { id, pc + 1, snd_count + 1, registry },
          List.insert_at(queue0, -1, value),
          queue1
        }
    end
  end

  defp process_rcv(_, { 0, pc, snd_count, registry }, [], queue1) do
    {
      { 0, pc, snd_count, registry },
      [],
      queue1
    }
  end
  defp process_rcv(_, { 1, pc, snd_count, registry }, queue0, []) do
    {
      { 1, pc, snd_count, registry },
      queue0,
      []
    }
  end
  defp process_rcv(instruction, { id, pc, snd_count ,registry }, queue0, queue1) do
    [_, register] = String.split(instruction)

    case id do
      0 ->
        [ value | tail ] = queue0
        {
          { id, pc + 1, snd_count, Map.put(registry, register, value) },
          tail,
          queue1
        }
      1 ->
        [ value | tail ] = queue1
        {
          { id, pc + 1, snd_count, Map.put(registry, register, value) },
          queue0,
          tail
        }
    end
  end

  defp process_jgz(instruction, { id, pc, snd_count, registry }) do
    [_, x, y] = String.split(instruction)
    condition = get_value(registry, x)
    jump = get_value(registry, y)

    cond do
      condition > 0 ->
        {
          id,
          pc + jump,
          snd_count,
          registry
        }
      true ->
        {
          id,
          pc + 1,
          snd_count,
          registry
        }
    end
  end

  defp process_mod(instruction, { id, pc, snd_count, registry }) do
    [_, register, y] = String.split(instruction)
    cur_value = Map.get(registry, register)
    new_value = rem(cur_value, get_value(registry, y))

    {
      id,
      pc + 1,
      snd_count,
      Map.put(registry, register, new_value)
    }
  end

  defp process_mul(instruction, { id, pc, snd_count, registry }) do
    [_, register, y] = String.split(instruction)
    cur_value = get_value(registry, register)
    new_value = cur_value * get_value(registry, y)

    {
      id,
      pc + 1,
      snd_count,
      Map.put(registry, register, new_value)
    }
  end

  defp process_add(instruction, { id, pc, snd_count, registry }) do
    [_, register, y] = String.split(instruction)
    cur_value = get_value(registry, register)
    new_value = cur_value + get_value(registry, y)

    {
      id,
      pc + 1,
      snd_count,
      Map.put(registry, register, new_value)
    }
  end

  defp process_set(instruction, { id, pc, snd_count, registry }) do
    [_, register, y] = String.split(instruction)
    value = get_value(registry, y)

    {
      id,
      pc + 1,
      snd_count,
      Map.put(registry, register, value)
    }
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

{ :ok, input } = File.read "day18-input.txt"

{ _, _, snd_count, _ } = input
                         |> String.split("\n", trim: true)
                         |> Day18.duet

IO.inspect snd_count
