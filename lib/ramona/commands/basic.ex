defmodule Ramona.Commands.Basic do
  @moduledoc false
  use Alchemy.Cogs
  alias Alchemy.{Cache, Client}
  alias Ramona.Utils
  require Logger
  require Alchemy.Embed, as: Embed

  @appos "146367028968554496"

  Cogs.def ping do
    old = Time.utc_now()
    {:ok, message} = Cogs.say("Pong!")
    time = Time.diff(Time.utc_now(), old, :millisecond)
    Client.edit_message(message, "Pong! :ping_pong: took **#{time} ms**")
  end

  Cogs.set_parser(:say, &List.wrap/1)
  Cogs.def say(str) do
    patt = :binary.compile_pattern(["@everyone", "@here"])

    if message.author.id != Cache.user.id
    and not String.contains?(message.content, patt)
    and Utils.invite_match?(message.content) == nil
    do
      str
      |> Utils.escape_prefix()
      |> Cogs.say()
    end
  end

  Cogs.set_parser(:saydel, &List.wrap/1)
  Cogs.def saydel(str) do
    if message.author.id == @appos do
      Client.delete_message(message)

      str
      |> Utils.escape_prefix()
      |> Cogs.say()
    end
  end

  Cogs.set_parser(:sayin, &List.wrap/1)
  Cogs.def sayin(s) do
    if message.author.id != Cache.user.id
    and Utils.invite_match?(message.content) == nil
    do
      case String.split(s, "|", parts: 2) |> Enum.map(&String.trim/1) do
        [time, msg] ->
          sec = Utils.time_in_seconds(String.split(time))

          Task.start fn ->
            Process.sleep(sec * 1000)
            Utils.escape_prefix(msg) |> Cogs.say()
          end

          Cogs.say ~s/I will say "#{msg}" in #{sec} seconds/

        _ ->
          Cogs.say("Syntax error")
      end
    end
  end

  @doc """
  Get info about a specific color.
  """
  Cogs.def color(hex \\ "") do
    hash = Utils.gen_hash()

    case Utils.parse_color(hex, true, true) do
      :error ->
        Cogs.say(":exclamation: **Invalid color**")

      {:ok, color} ->
        color
        |> Utils.color_embed(hash)
        |> Embed.send("", file: "lib/ramona/assets/#{hash}.jpg")

        File.rm("lib/ramona/assets/#{hash}.jpg")
    end
  end

  Cogs.def mixcolors(hex1, hex2) do
    with {:ok, color1} <- Utils.parse_color(hex1, false, true),
         {:ok, color2} <- Utils.parse_color(hex2, false, true)
    do
      hash = Utils.gen_hash()

      CssColors.parse!(color1)
      |> CssColors.mix(CssColors.parse!(color2))
      |> to_string()
      |> Utils.color_embed(hash)
      |> Embed.send("", file: "lib/ramona/assets/#{hash}.jpg")

      File.rm("lib/ramona/assets/#{hash}.jpg")
    else
      :error ->
        Cogs.say "That's not a valid color"
    end
  end

  Cogs.set_parser(:bigtext, &List.wrap/1)
  Cogs.def bigtext(text) do
    {:ok, nil} = Client.delete_message(message)

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

  Cogs.set_parser(:polar, &List.wrap/1)
  Cogs.def polar(arg) do
    {:ok, nil} = Client.delete_message(message)

    file =
      case arg do
        "police" -> "polar_bear_police.gif"
        "socks" -> "polar_bear_socks.gif"
        "birthday" -> "polar_bear_birthday.gif"
        "gang" -> "polar_bear_gang.gif"
        _ -> "polar_bear.gif"
      end

    Client.send_message(message.channel_id, "", file: "lib/ramona/assets/#{file}")
  end

  Cogs.set_parser(:reverse, &List.wrap/1)
  Cogs.def reverse(msg) do
    patt = :binary.compile_pattern(["@everyone", "@here"])

    if message.author.id != Cache.user.id
    and not String.contains?(message.content, patt)
    and Utils.invite_match?(message.content) == nil
    and Utils.invite_match?(String.reverse message.content) == nil
    do
      msg
      |> String.reverse()
      |> Utils.escape_prefix()
      |> Cogs.say()
    end
  end

  Cogs.set_parser(:invite, &List.wrap/1)
  Cogs.def invite(_) do
    case Application.fetch_env(:ramona, :invite) do
      {:ok, invite} ->
        Cogs.say(invite)
        :error ->
          Cogs.say("There's no invite set")
    end
  end

  Cogs.set_parser(:thieves, &List.wrap/1)
  Cogs.def thieves(_) do
    Cogs.say "https://discord.gg/tX8a2mD"
  end

  defp xkcd_comic?(number) do
    case HTTPoison.get("https://xkcd.com/#{number}") do
      {:ok, res} -> res.status_code != 404
      {:error, reason} ->
        Logger.error reason
        false
    end
  end

  defp xkcd_latest do
    res = HTTPoison.get!("https://xkcd.com/info.0.json")
    res.body
    |> Poison.decode!()
    |> Map.get("num")
  end

  defp xkcd_random do
    case HTTPoison.get("https://c.xkcd.com/random/comic/") do
      {:ok, res} ->
        res.headers
        |> Enum.find(&match?({"Location", _link}, &1))
        |> elem(1)

      {:error, err} ->
        Logger.error inspect(err)
        "So yeah, for some reason I couldn't get anything. Sorry. Check the logs."
    end
  end

  Cogs.def xkcd do
    Cogs.say xkcd_random()
  end

  Cogs.def xkcd(n) do
    case Integer.parse(n) do
      {n,_} ->
        if xkcd_comic?(n) do
          Cogs.say "https://xkcd.com/#{n}"
        else
          Cogs.say "Can't find any comic with that number"
        end

      :error ->
        Cogs.say "That's not a number"
    end
  end

  Cogs.def xkcd(n, m) do
    with {a, _} <- Integer.parse(n),
         {b, _} <- Integer.parse(m),
         latest <- xkcd_latest()
    do
      cond do
        a > latest and b > latest ->
          Cogs.say xkcd_random()
        a > latest ->
          Cogs.say ""
          Cogs.say "https://xkcd.com/#{Enum.random abs(a)..latest}"
        b > latest ->
          Cogs.say "https://xkcd.com/#{Enum.random latest..abs(b)}"
        a == 0 and b == 0 ->
          Cogs.say xkcd_random()
        a == 0 ->
          Cogs.say "https://xkcd.com/#{Enum.random 1..b}"
        b == 0 ->
          Cogs.say "https://xkcd.com/#{Enum.random a..1}"
        true ->
          Cogs.say "https://xkcd.com/#{Enum.random a..b}"
      end
    end
  end

  Cogs.set_parser(:cowsay, &List.wrap/1)
  Cogs.def cowsay(s) do
    "```\n#{Cowsay.say(s)}```"
    |> Cogs.say()
  end

  Cogs.set_parser(:top, &List.wrap/1)
  Cogs.def top(_) do
    Cogs.say "<:topkk1:486252311279304714><:topkk2:486252311325310976><:topkk3:486252311312859137><:topkk4:486252311459659816><:topkk5:486252311434231810>"
  end

  Cogs.set_parser(:flip, &List.wrap/1)
  Cogs.def flip("") do
    Cogs.say Enum.random(["heads", "tails"])
  end

  Cogs.def flip(choices) do
    String.split(choices, "|", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(& Utils.invite_match?(&1) == nil)
    |> Enum.random()
    |> Cogs.say()
  end

  Cogs.set_parser(:chupapito, &List.wrap/1)
  Cogs.def chupapito(_) do
    {:ok, nil} = Client.delete_message(message)
    Cogs.say "ala tento chupar o proprio pito kkkkkkkkkkkkkkkk"
  end
end
