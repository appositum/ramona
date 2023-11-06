defmodule Ramona.Utils do
  @moduledoc """
  Collection of functions to serve as tools for some Cogs.
  """
  alias Alchemy.Client
  require Logger
  require Alchemy.Embed, as: Embed

  @appos "146367028968554496"
  @ansuz "429110513117429780"
  @eihwaz "429111918297612298"
  @unleashed_gid "429110044525592578"

  @type color_hex :: String.t()
  @type message :: String.t()

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

  @spec color_embed(color_hex, String.t()) :: %Alchemy.Embed{}
  def color_embed(color_hex, filename) do
    # color struct
    color = CssColors.parse!(color_hex)

    hue = trunc(CssColors.hsl(color).hue)
    lightness = trunc(CssColors.hsl(color).lightness * 100)
    saturation = trunc(CssColors.hsl(color).saturation * 100)
    hsl = "#{hue}, #{lightness}%, #{saturation}%"
    rgb = "#{trunc(color.red)}, #{trunc(color.green)}, #{trunc(color.blue)}"

    %Mogrify.Image{path: "#{filename}.jpg", ext: "jpg"}
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
    |> Embed.thumbnail("attachment://#{filename}.jpg")
  end

  @spec gen_hash :: String.t()
  def gen_hash do
    salt = fn x ->
      :crypto.hash(:md5, "#{x + Enum.random 1..60000}")
    end

    DateTime.utc_now()
    |> DateTime.to_unix()
    |> salt.()
    |> Base.encode16()
  end

  @spec parse_color(String.t(), boolean, boolean) :: {:ok, color_hex} | :error
  def parse_color(hex, named_color?, hashtag?) do
    pattern1 = ~r/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
    pattern2 = ~r/^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

    cond do
      Regex.match?(pattern1, hex) ->
        {:ok, hex}

      Regex.match?(pattern2, hex) ->
        if hashtag? do
          {:ok, "#" <> hex}
        else
          {:ok, hex}
        end

      true ->
        if named_color? do
          case CssColors.parse(hex) do
            {:ok, _} -> {:ok, hex}
            {:error, _} -> :error
          end
        else
          :error
        end
    end
  end

  @spec escape_prefix(String.t()) :: String.t()
  def escape_prefix(message) do
    prefix = Application.fetch_env!(:ramona, :prefix)
    String.replace(message, prefix, "\\#{prefix}")
  end

  @spec invite_match?(String.t()) :: nil | boolean
  def invite_match?(str) do
    Regex.run(~r{discord\.gg\/[a-zA-Z0-9]*}, str) ||
    Regex.run(~r{discordapp\.com\/invite\/[a-zA-Z0-9]*}, str)
  end

  @spec catch_invites(%Regex{}, message) :: list
  def catch_invites(patt, message) do
    Regex.scan(patt, message)
    |> Enum.flat_map(& &1)
  end

  @spec not_a_mod(String.t()) :: boolean
  def not_a_mod(user_id) do
    case Client.get_member(@unleashed_gid, user_id) do
      {:ok, member} ->
        @ansuz not in member.roles and @eihwaz not in member.roles
      {:error, reason} ->
        Logger.warn "Couldn't get member (mod check):\n\t#{reason}"
        false
    end
  end

  @spec not_an_admin(String.t()) :: boolean
  def not_an_admin(user_id) do
    case Client.get_member(@unleashed_gid, user_id) do
      {:ok, member} ->
        @ansuz not in member.roles or user_id != @appos
      {:error, reason} ->
        Logger.warn "Couldn't get member (admin check):\n\t#{reason}"
        false
    end
  end
end
