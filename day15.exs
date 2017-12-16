defmodule Day15 do
  use Bitwise

  def judge_count(iterations, a, b) do
    _judge_count(iterations, a, b, 0, 0)
  end

  def _judge_count(iterations, _, _, count, iterations), do: count
  def _judge_count(iterations, { cur_a, factor_a }, { cur_b, factor_b }, count, cur_iter) do
    next_a = next(cur_a, factor_a)
    next_b = next(cur_b, factor_b)

    next_count = case (lower16(next_a) == lower16(next_b)) do
      true -> count + 1
      false -> count
    end

    _judge_count(iterations, { next_a, factor_a }, { next_b, factor_b }, next_count, cur_iter + 1)
  end

  defp next(cur, factor), do: rem(cur * factor, 2147483647)

  def judge_count2(iterations, a, b) do
    _judge_count2(iterations, a, b, 0, 0)
  end

  def _judge_count2(iterations, _, _, count, iterations), do: count
  def _judge_count2(iterations, { cur_a, factor_a, divider_a }, { cur_b, factor_b, divider_b }, count, cur_iter) do
    next_a = next2(cur_a, factor_a, divider_a)
    next_b = next2(cur_b, factor_b, divider_b)

    next_count = case (lower16(next_a) == lower16(next_b)) do
      true -> count + 1
      false -> count
    end

    _judge_count2(iterations, { next_a, factor_a, divider_a }, { next_b, factor_b, divider_b }, next_count, cur_iter + 1)
  end

  defp next2(cur, factor, divider) do
    next = rem(cur * factor, 2147483647)

    case rem(next, divider) do
      0 -> next
      _ -> next2(next, factor, divider)
    end
  end

  defp lower16(n), do: n &&& 65535
end

Day15.judge_count(
  40000000,
  { 289, 16807 },
  { 629, 48271 }
)
|> IO.puts

Day15.judge_count2(
  5000000,
  { 289, 16807, 4 },
  { 629, 48271, 8 }
)
|> IO.puts
