defmodule Ramona.Commands.Basic do
  @moduledoc false
  use Alchemy.Cogs
  alias Ramona.Utils
  alias Alchemy.Client
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
  Cogs.def say(s), do: Cogs.say(s)

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
        |> Embed.send("", file: "lib/assets/color.jpg")

        File.rm("lib/assets/color.jpg")
    end
  end
end
