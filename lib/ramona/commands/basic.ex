defmodule Ramona.Commands.Basic do
  @moduledoc false
  use Alchemy.Cogs
  alias Alchemy.Client
  alias Ramona.Utils
  require Alchemy.Embed, as: Embed

  Cogs.def ping do
    old = Time.utc_now()
    {:ok, message} = Cogs.say("Pong!")
    time = Time.diff(Time.utc_now(), old, :millisecond)
    Client.edit_message(message, "Pong! :ping_pong: took **#{time} ms**")
  end

  @doc """
  Say something!
  """
  Cogs.set_parser(:say, &List.wrap/1)
  Cogs.def say(s) do
    Cogs.say(s)
  end

  Cogs.set_parser(:sayin, &List.wrap/1)
  Cogs.def sayin(s) do
    case String.split(s, "|") |> Enum.map(&String.trim/1) do
      [time, msg] ->
        sec = Utils.time_in_seconds(String.split(time))

        Task.start fn ->
          Process.sleep(sec * 1000)
          Cogs.say(msg)
        end

        Cogs.say ~s(I will say "#{msg}" in #{sec} seconds)

      _ ->
        Cogs.say("Syntax error")
    end
  end

  @doc """
  Get info about a specific color.
  """
  Cogs.def color(hex \\ "") do
    pattern1 = ~r/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
    pattern2 = ~r/^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

    color =
      cond do
        Regex.match?(pattern1, hex) -> hex
        Regex.match?(pattern2, hex) -> "#" <> hex
        true ->
          # named colors
          case CssColors.parse(hex) do
            {:ok, _} -> hex
            {:error, _} -> :error
          end
      end

    case color do
      :error ->
        Cogs.say(":exclamation: **Invalid color**")
      color ->
        Utils.color_embed(color)
        |> Embed.send("", file: "lib/ramona/assets/color.jpg")

        File.rm("lib/ramona/assets/color.jpg")
    end
  end

  Cogs.set_parser(:bigtext, &List.wrap/1)
  Cogs.def bigtext(text) do
    text
    |> String.graphemes()
    |> Enum.map(&String.downcase/1)
    |> Enum.map(fn char ->
      letters = String.graphemes("abcdefghijklmnopqrstuvwxyz")
      cond do
        char == " " -> "     "
        char in letters -> ":regional_indicator_#{char}:"
        true -> char
      end
    end)
    |> Enum.join()
    |> String.replace("10", ":keycap_ten:")
    |> String.graphemes()
    |> Enum.map(fn char ->
      numbers = %{
        "0" => ":zero:",
        "1" => ":one:",
        "2" => ":two:",
        "3" => ":three:",
        "4" => ":four:",
        "5" => ":five:",
        "6" => ":six:",
        "7" => ":seven:",
        "8" => ":eight:",
        "9" => ":nine:"
      }

      cond do
        char in Map.keys(numbers) -> numbers[char]
        true -> char
      end
    end)
    |> Enum.join()
    |> Cogs.say()
  end

  Cogs.def regras do
    {:ok, nil} = Client.delete_message(message)
    %Embed{}
    |> Embed.color(0x01b6ad)
    |> Embed.title("Regras")
    |> Embed.field("**1. Canais**", "Leia as descrições dos canais e tente manter o tópico adequado.")
    |> Embed.field("\n\n2. Sem divulgação", "ta ok respeitar")
    |> Embed.send()
  end

  Cogs.def cargos do
    {:ok, nil} = Client.delete_message(message)
    %Embed{}
    |> Embed.color(0x009CCF)
    |> Embed.title("Cargos")
    |> Embed.field("ᚫ Ansuz", "Administradores")
    |> Embed.field("ᛇ Eihwaz", "Moderadores")
    |> Embed.field("ᛗ Mannaz", "Membro", inline: true)
    |> Embed.send()
  end
end
