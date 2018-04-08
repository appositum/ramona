defmodule Ramona.Commands.Moderation do
  @moduledoc false
  use Alchemy.Cogs
  alias Alchemy.Client
  alias Ramona.{Profile, Utils}
  require Alchemy.Embed, as: Embed

  @embed_color Profile.update_color()
  @profile_avatar Profile.update_avatar()

  Cogs.def help do
    commands = Cogs.all_commands()
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
      {"Owner", "[appositum#7545](https://github.com/appositum)"},
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
    |> Embed.thumbnail(@profile_avatar)
    |> Embed.url("https://github.com/appositum/ramona")
    |> Embed.footer(text: "Uptime: #{Utils.uptime()}")
    |> Embed.send()
  end

  # TODO
  Cogs.def kick(user) do
    {:ok, guild} = Cogs.guild()
    user_id = Regex.replace(~r{<|@|>}, user, "")

    Client.kick_member(guild.id, user_id)
    Client.delete_message(message)
  end

  # TODO
  Cogs.def ban(user, days \\ 0) do
    {:ok, guild} = Cogs.guild()
    user_id = Regex.replace(~r{<|@|>}, user, "")

    Client.ban_member(guild.id, user_id, days)
    Client.delete_message(message)
  end

  Cogs.def prune(quantity \\ "") do
    case Integer.parse(quantity) do
      {n, _} ->
        task = Task.async fn ->
          {:ok, msgs} = Client.get_messages(message.channel_id, limit: n+1)
          Client.delete_messages(message.channel_id, msgs)
          ":wastebasket: | **#{message.author.username}** deleted #{n} messages in this channel!"
        end

        {:ok, msg} = Client.send_message(message.channel_id, Task.await(task))
        Process.sleep(3000)
        Client.delete_message(msg)

      :error ->
        Cogs.say(":exclamation: **You need to specify a number of messages to delete!**")
    end
  end
end
