defmodule Day24 do
  def run(program, n) do
    _run(program, n, { :A, 0, %{} })
  end

  def _run(_, 0, machine_state), do: machine_state
  def _run(program, n, { state, position, tape }) do
    value = case tape[position] do
      nil -> 0
      v -> v
    end

    { new_value, direction, new_state } = program[state][value]
    new_tape = Map.put(tape, position, new_value)
    new_position = case direction do
      :right -> position + 1
      :left -> position - 1
    end

    _run(program, n-1, { new_state, new_position, new_tape })
  end

  def checksum(tape) do
    tape
    |> Map.values
    |> Enum.sum
  end
end

# program = %{
#   A: %{
#     0 => { 1, :right, :B },
#     1 => { 0, :left, :B }
#   },
#   B: %{
#     0 => { 1, :left, :A },
#     1 => { 1, :right, :A }
#   }
# }
# n = 6

program = %{
  A: %{
    0 => { 1, :right, :B },
    1 => { 0, :left, :E }
  },
  B: %{
    0 => { 1, :left, :C },
    1 => { 0, :right, :A }
  },
  C: %{
    0 => { 1, :left, :D },
    1 => { 0, :right, :C }
  },
  D: %{
    0 => { 1, :left, :E },
    1 => { 0, :left, :F }
  },
  E: %{
    0 => { 1, :left, :A },
    1 => { 1, :left, :C }
  },
  F: %{
    0 => { 1, :left, :E },
    1 => { 1, :right, :A }
  },
}
n = 12208951

{ _, _, tape } = Day24.run(program, n)

tape
|> Day24.checksum
|> IO.inspect
