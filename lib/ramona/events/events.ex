defmodule Ramona.Events do
  @moduledoc false
  use Alchemy.Events
  alias Ramona.Utils
  alias Alchemy.{Cache, Client}
  require Logger
  require Alchemy.Cogs, as: Cogs

  @invite_log "430374864906354710"
  @moderation_cat "430410176328368150"

  Events.on_ready(:ready)
  Events.on_message(:everyone)
  Events.on_message(:command_log)
  Events.on_message(:block_invites)

  def ready(_, _) do
    me = "#{Cache.user().username}##{Cache.user().discriminator} (#{Cache.user().id})"
    Logger.info("Logged in as #{me}")
    Logger.info("Ramona is ready!")
  end

  def command_log(message) do
    prefix = Application.fetch_env!(:ramona, :prefix)

    if String.starts_with?(message.content, prefix) do
      command =
        with m <- message.content |> String.split() |> List.first() do
          String.slice(m, String.length(prefix), String.length(m))
        end

      if command in Map.keys(Cogs.all_commands()) do
        id = message.author.id
        username = message.author.username
        tag = message.author.discriminator

        ~s/Command "#{message.content}" called by <@#{id}> (#{username}##{tag})/
        |> Logger.info()
      end
    end
  end

  def everyone(message) do
    if message.author.id != Cache.user.id
    and Utils.not_an_admin(message.author.id)
    do
      patt = :binary.compile_pattern(["@everyone", "@here"])

      if String.contains?(message.content, patt) do
        police = "lib/ramona/assets/polar_bear_police.gif"
        Client.send_message(message.channel_id, "***STOP***", file: police)
      end
    end
  end

  def block_invites(message) do
    if Utils.invite_match?(message.content) do
      {:ok, channel} = Client.get_channel(message.channel_id)

      if message.author.id != Cache.user.id
      and Utils.not_a_mod(message.author.id)
      and channel.parent_id != @moderation_cat
      do
        msg = message.content
        author_username = message.author.username
        author_discrim = message.author.discriminator
        author_id = message.author.id

        with {:ok, nil} <- Client.delete_message(message) do
          patt1 = ~r{discord\.gg\/[a-zA-Z0-9]*}
          patt2 = ~r{discordapp\.com\/invite\/[a-zA-Z0-9]*}
          invites =
            with inv1 <- Utils.catch_invites(patt1, msg),
                 inv2 <- Utils.catch_invites(patt2, msg), do: inv1 ++ inv2

          warning =
            "Blocked invite in ##{channel.name} (#{channel.id}) from "
            <> "`#{author_username}##{author_discrim}` "
            <> "(#{author_id}):"
            <> ~s/\n\t#{Enum.join(invites, "\n")}/

          Logger.warn(warning)

          Client.send_message(@invite_log, warning)
        else
          {:error, reason} -> Logger.error(reason)
        end
      end
    end
  end
end
