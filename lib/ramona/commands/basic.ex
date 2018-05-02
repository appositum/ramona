defmodule Ramona.Commands.Basic do
  @moduledoc false
  use Alchemy.Cogs
  alias Ramona.{Reminder, Utils}
  alias Alchemy.Client
  require Alchemy.Embed, as: Embed

  Cogs.set_parser(:say, &List.wrap/1)
  Cogs.set_parser(:sayin, &List.wrap/1)

  Cogs.def ping do
    old = Time.utc_now()
    {:ok, message} = Cogs.say("Pong!")
    time = Time.diff(Time.utc_now(), old, :millisecond)
    Client.edit_message(message, "Pong! :ping_pong: took **#{time} ms**")
  end

  @doc """
  Say something!
  """
  Cogs.def say(s) do
    Cogs.say(s)
  end

  Cogs.def sayin(s) do
    case String.split(s, "|") |> Enum.map(&String.trim/1) do
      [time, msg] ->
        sec = Reminder.time_in_seconds(String.split(time))

        Task.start fn ->
          Process.sleep(sec * 1000)
          Cogs.say(msg)
        end

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
end
