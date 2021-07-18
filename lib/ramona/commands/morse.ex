defmodule Ramona.Commands.Morse do
  use Alchemy.Cogs
  Cogs.group("morse")

  @table [
    {" ", "/"},
    {"A", ".-"},
    {"B", "-..."},
    {"C", "-.-."},
    {"D", "-.."},
    {"E", "."},
    {"F", "..-."},
    {"G", "--."},
    {"H", "...."},
    {"I", ".."},
    {"J", ".---"},
    {"K", "-.-"},
    {"L", ".-.."},
    {"M", "--"},
    {"N", "-."},
    {"O", "---"},
    {"P", ".--."},
    {"Q", "--.-"},
    {"R", ".-."},
    {"S", "..."},
    {"T", "-"},
    {"U", "..-"},
    {"V", "...-"},
    {"W", ".--"},
    {"X", "-..-"},
    {"Y", "-.--"},
    {"Z", "--.."},
    {"0", "-----"},
    {"1", ".----"},
    {"2", "..---"},
    {"3", "...--"},
    {"4", "....-"},
    {"5", "....."},
    {"6", "-...."},
    {"7", "--..."},
    {"8", "---.."},
    {"9", "----."},
    {".", ".-.-.-"},
    {",", "--..--"},
    {"?", "..--.."},
    {"!", "..--."},
    {":", "---..."},
    {"\"", ".-..-."},
    {"'", ".----."},
    {"=", "-...-"}
  ]

  Cogs.set_parser(:encode, &List.wrap/1)
  Cogs.set_parser(:decode, &List.wrap/1)

  Cogs.def encode(string) do
    encoded =
      string
      |> String.upcase()
      |> String.graphemes()
      |> Enum.map(fn l ->
        {_letter, morse} = Enum.find(@table, &match?({^l, _}, &1))
        morse
      end)
      |> Enum.join(" ")

    Cogs.say("`#{encoded}`")
  end

  Cogs.def decode(morse_string) do
    decoded =
      morse_string
      |> String.split(" ")
      |> Enum.map(fn m ->
        {letter, _morse} = Enum.find(@table, &match?({_, ^m}, &1))
        letter
      end)
      |> Enum.join()

    Cogs.say("`#{decoded}`")
  end
end
