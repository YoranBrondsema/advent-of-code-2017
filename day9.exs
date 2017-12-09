defmodule Day9 do
  def get_score(input) do
    { score, _ } = input
                   |> get_commands
                   |> Enum.reduce(
                     { 0, 0 },
                     fn(command, { score, depth }) ->
                       case command do
                         :open -> { score, depth + 1 }
                         :close -> { score + depth, depth - 1 }
                       end
                     end
                   )

    score
  end

  def get_garbage_count(input) do
    String.split(input, "", trim: true)
    |> _get_garbage_count(0, false, false)
  end

  defp _get_garbage_count([], count, _, _), do: count
  # canceled
  defp _get_garbage_count([ _ | tail ], count, is_garbage, true) do
    _get_garbage_count(tail, count, is_garbage, false)
  end
  # cancelation
  defp _get_garbage_count([ "!" | tail ], count, true, _) do
    _get_garbage_count(tail, count, true, true)
  end
  # garbage
  defp _get_garbage_count([ ">" | tail ], count, true, is_canceled) do
    _get_garbage_count(tail, count, false, is_canceled)
  end
  defp _get_garbage_count([ _ | tail ], count, true, is_canceled) do
    _get_garbage_count(tail, count + 1, true, is_canceled)
  end
  # else
  defp _get_garbage_count([ "{" | tail ], count, is_garbage, is_canceled) do
    _get_garbage_count(tail, count, is_garbage, is_canceled)
  end
  defp _get_garbage_count([ "}" | tail ], count, is_garbage, is_canceled) do
    _get_garbage_count(tail, count, is_garbage, is_canceled)
  end
  defp _get_garbage_count([ "<" | tail ], count, _, is_canceled) do
    _get_garbage_count(tail, count, true, is_canceled)
  end
  defp _get_garbage_count([ _ | tail ], count, is_garbage, is_canceled) do
    _get_garbage_count(tail, count, is_garbage, is_canceled)
  end

  def get_commands(input) do
    String.split(input, "", trim: true)
    |> _get_commands([], false, false)
    |> Enum.reverse
  end

  defp _get_commands([], commands, _, _), do: commands
  # canceled
  defp _get_commands([ _ | tail ], commands, is_garbage, true) do
    _get_commands(tail, commands, is_garbage, false)
  end
  # cancelation
  defp _get_commands([ "!" | tail ], commands, true, _) do
    _get_commands(tail, commands, true, true)
  end
  # garbage
  defp _get_commands([ ">" | tail ], commands, true, is_canceled) do
    _get_commands(tail, commands, false, is_canceled)
  end
  defp _get_commands([ _ | tail ], commands, true, is_canceled) do
    _get_commands(tail, commands, true, is_canceled)
  end
  # else
  defp _get_commands([ "{" | tail ], commands, is_garbage, is_canceled) do
    _get_commands(tail, [ :open | commands ], is_garbage, is_canceled)
  end
  defp _get_commands([ "}" | tail ], commands, is_garbage, is_canceled) do
    _get_commands(tail, [ :close | commands ], is_garbage, is_canceled)
  end
  defp _get_commands([ "<" | tail ], commands, _, is_canceled) do
    _get_commands(tail, commands, true, is_canceled)
  end
  defp _get_commands([ _ | tail ], commands, is_garbage, is_canceled) do
    _get_commands(tail, commands, is_garbage, is_canceled)
  end
end

{ :ok, input } = File.read "day9-input.txt"

score = input
        |> Day9.get_score

garbage_count = input
                |> Day9.get_garbage_count

IO.puts "Score: #{score}"
IO.puts "Garbage count: #{garbage_count}"

ExUnit.start()
defmodule ExampleTest do
  use ExUnit.Case
  import Day9

  test "#get_score" do
    assert get_score("{}") == 1
    assert get_score("{{{}}}") == 6
    assert get_score("{{},{}}") == 5
    assert get_score("{{{},{},{{}}}}") == 16
    assert get_score("{<a>,<a>,<a>,<a>}") == 1
    assert get_score("{{<ab>},{<ab>},{<ab>},{<ab>}}") == 9
    assert get_score("{{<!!>},{<!!>},{<!!>},{<!!>}}") == 9
    assert get_score("{{<a!>},{<a!>},{<a!>},{<ab>}}") == 3
  end

  test "#get_garbage_count" do
    assert get_garbage_count("<>") == 0
    assert get_garbage_count("<random characters>") == 17
    assert get_garbage_count("<<<<>") == 3
    assert get_garbage_count("<{!>}>") == 2
    assert get_garbage_count("<!!>") == 0
    assert get_garbage_count("<!!!>>") == 0
    assert get_garbage_count("<{o\"i!a,<{i<a>") == 10
  end
end
