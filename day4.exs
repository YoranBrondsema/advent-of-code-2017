defmodule Day4 do
  def is_valid1?(passphrase) do
    l = to_list_of_words(passphrase)

    length(l) == length(Enum.uniq(l))
  end

  def is_valid2?(passphrase) do
    to_list_of_words(passphrase)
    |> _is_valid2?([])
  end

  defp _is_valid2?([], _), do: true
  defp _is_valid2?([ word | tail ], anagrams) do
    case includes?(anagrams, word) do
      true -> false
      false -> _is_valid2?(tail, anagrams ++ anagrams_for_word(word))
    end
  end

  defp includes?(l, value) do
    case Enum.find(l, fn(x) -> x == value end) do
      nil -> false
      _ -> true
    end
  end

  defp to_list_of_words(s), do: String.split(s, " ", trim: true)

  def anagrams_for_word(word) do
    String.split(word, "", trim: true)
    |> permutations
    |> Enum.map(fn(x) -> Enum.join(x, "") end)
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]),
      do: [elem | rest]
  end
end

{ :ok, input } = File.read "day4-input.txt"
passphrases = String.split(input, "\n", trim: true)

valid1 = passphrases
|> Enum.filter(&Day4.is_valid1?/1)
|> length

valid2 = passphrases
|> Enum.filter(&Day4.is_valid2?/1)
|> length

IO.puts "valid1: #{valid1}"
IO.puts "valid2: #{valid2}"
