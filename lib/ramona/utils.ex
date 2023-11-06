defmodule Ramona.Utils do
  @moduledoc """
  Collection of functions to serve as tools for some Cogs.
  """
  require Alchemy.Embed, as: Embed

  @type color_hex :: String.t()

  def uptime do
    {time, _} = :erlang.statistics(:wall_clock)
    min = div(time, 1000 * 60)
    {hours, min} = {div(min, 60), rem(min, 60)}
    {days, hours} = {div(hours, 24), rem(hours, 24)}

    Stream.zip([min, hours, days], ["m", "h", "d"])
    |> Enum.reduce("", fn
      {0, _glyph}, acc -> acc
      {t, glyph}, acc -> " #{t}" <> glyph <> acc
    end)
  end

  def time_in_seconds(lst) do
    Enum.map(lst, &Integer.parse/1)
    |> Enum.map(fn
      {n, "h"} -> n * 60 * 60
      {n, "m"} -> n * 60
      {n, "s"} -> n
    end)
    |> Enum.sum()
  end

  @doc """
  Generate a random color in hexadecimal.

  ## Examples
      iex> Thonk.Utils.color_random()
      "FCFB5E"
  """
  @spec color_random() :: color_hex
  def color_random do
    color_random([])
    |> Enum.map(&to_string/1)
    |> Enum.join()
  end

  defp color_random(list) do
    case length(list) do
      6 ->
        list

      _ ->
        hex_digit = Enum.random(0..15) |> Integer.to_charlist(16)
        color_random([hex_digit | list])
    end
  end

  @spec color_embed(color_hex) :: %Alchemy.Embed{}
  def color_embed(color_hex) do
    # color struct
    color = CssColors.parse!(color_hex)

    hue = trunc(CssColors.hsl(color).hue)
    lightness = trunc(CssColors.hsl(color).lightness * 100)
    saturation = trunc(CssColors.hsl(color).saturation * 100)
    hsl = "#{hue}, #{lightness}%, #{saturation}%"
    rgb = "#{trunc(color.red)}, #{trunc(color.green)}, #{trunc(color.blue)}"

    %Mogrify.Image{path: "color.jpg", ext: "jpg"}
    |> Mogrify.custom("size", "80x80")
    |> Mogrify.canvas(to_string(color))
    |> Mogrify.create(path: "lib/ramona/assets/")

    # Remove "#" symbol
    color_hex =
      with c <- to_string(color) do
        String.slice(c, 1, String.length(c))
      end

    # color number for the embed
    {color_integer, _} = Code.eval_string("0x#{color_hex}")

    %Embed{color: color_integer, title: to_string(color)}
    |> Embed.field("RGB", rgb)
    |> Embed.field("HSL", hsl)
    |> Embed.thumbnail("attachment://color.jpg")
  end
end
