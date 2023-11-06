defmodule Ramona.Commands.Moderation do
  @moduledoc false
  use Alchemy.Cogs
  alias Alchemy.Client
  alias Ramona.Utils
  require Logger
  require Alchemy.Embed, as: Embed

  @embed_color 0x36393F

  Cogs.def help do
    commands =
      Cogs.all_commands()
      |> Map.keys()
      |> Enum.join("\n")

    %Embed{color: @embed_color, description: commands}
    |> Embed.title("All available commands")
    |> Embed.send()
  end

  @doc """
  Information about the bot.
  """
  Cogs.def info do
    {:ok, app_version} = :application.get_key(:ramona, :vsn)
    {:ok, lib_version} = :application.get_key(:alchemy, :vsn)
    {:ok, guilds} = Client.get_current_guilds()

    memories = :erlang.memory()
    {{_, io_input}, {_, io_output}} = :erlang.statistics(:io)

    mem_format = fn
      mem, :kb -> "#{div(mem, 1000)} KB"
      mem, :mb -> "#{div(mem, 1_000_000)} MB"
    end

    infos = [
      {"Prefix", Application.get_env(:ramona, :prefix)},
      {"Version", "#{app_version}"},
      {"Elixir Version", System.version()},
      {"Library", "[Alchemy #{lib_version}](https://github.com/cronokirby/alchemy)"},
      {"Owner", "[appositum#1888](https://github.com/appositum)"},
      {"Guilds", "#{length(guilds)}"},
      {"Processes", "#{length(:erlang.processes())}"},
      {"Process Memory", mem_format.(memories[:processes], :mb)},
      {"Memory Usage", mem_format.(memories[:total], :mb)},
      {"Code Memory", mem_format.(memories[:code], :mb)},
      {"ETS Memory", mem_format.(memories[:ets], :kb)},
      {"Atom Memory", mem_format.(memories[:atom], :kb)},
      {"IO Input", mem_format.(io_input, :mb)},
      {"IO Output", mem_format.(io_output, :mb)}
    ]

    Enum.reduce(infos, %Embed{color: @embed_color}, fn {n, v}, embed ->
      Embed.field(embed, n, v, inline: true)
    end)
    |> Embed.title("Ramona")
    |> Embed.thumbnail("https://i.imgur.com/B8BmGhu.png")
    |> Embed.url("https://github.com/appositum/ramona")
    |> Embed.footer(text: "Uptime: #{Utils.uptime()}")
    |> Embed.send()
  end
end
