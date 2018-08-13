defmodule Ramona.Events do
  @moduledoc false
  use Alchemy.Events
  alias Alchemy.{Cache, Client}
  require Logger
  require Alchemy.Cogs, as: Cogs

  @ansuz "429110513117429780"
  @eihwaz "429111918297612298"
  @moderation_cat "430410176328368150"
  @unleashed_gid "429110044525592578"

  Events.on_ready(:ready)
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

  def block_invites(message) do
    if invite_match?(message.content) do
      {:ok, channel} = Client.get_channel(message.channel_id)

      if message.author.id != Cache.user.id
      and no_invite_permission(message.author.id)
      and channel.parent_id != @moderation_cat
      do
        with {:ok, nil} <- Client.delete_message(message) do
          "Blocked invite in ##{channel.name} (#{channel.id}) from "
          <> "#{message.author.username}##{message.author.discriminator} "
          <> "(#{message.author.id})"
          |> Logger.warn()

          Client.send_message(message.channel_id, "<:blaze:441076828594241537>")
        else
          err -> Logger.error(err)
        end
      end
    end
  end

  defp invite_match?(str) do
    Regex.run(~r{discord\.gg\/[a-zA-Z0-9]*}, str) ||
    Regex.run(~r{discordapp\.com\/invite\/[a-zA-Z0-9]*}, str)
  end

  defp no_invite_permission(user_id) do
    {:ok, member} = Client.get_member(@unleashed_gid, user_id)
    @ansuz not in member.roles and @eihwaz not in member.roles
  end
end
