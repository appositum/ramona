defmodule Ramona.Events do
  @moduledoc false
  use Alchemy.Events
  alias Alchemy.{Cache, Client}
  require Logger
  require Alchemy.Cogs, as: Cogs

  @ansuz "429110513117429780"
  @eihwaz "429111918297612298"
  @moderation_cat "430410176328368150"

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
          String.slice(m, 2, String.length(m))
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
    {:ok, channel} = Client.get_channel(message.channel_id)

    unless message.author.id == Cache.user.id
    or channel.parent_id == @moderation_cat
    do
      {:ok, guild_id} = Cogs.guild_id()

      case Client.get_member(guild_id, message.author.id) do
        {:error, reason} ->
          "Tried to fetch user (possibly a bot) "
          <> "<@#{message.author.id}>, but failed:\n#{reason}"
          |> Logger.error()

        {:ok, member} ->
          IO.inspect no_permission(member), label: "CU"
          if no_permission(member)
          and Regex.run(~r{discord\.gg\/[a-zA-Z0-9]*}, message.content) do
            with {:ok, channel} <- Alchemy.Client.get_channel(message.channel_id),
                 {:ok, nil} <- Alchemy.Client.delete_message(message)
            do
              "Blocked invite in ##{channel.name} (#{channel.id}) from "
              <> "#{message.author.username}##{message.author.discriminator} "
              <> "(#{message.author.id})"
              |> Logger.warn()
              IO.inspect(message)
            else
              err ->
                IO.inspect err
                Logger.error(err)
            end
          end
      end
    end
  end

  defp no_permission(member) do
    @ansuz not in member.roles and @eihwaz not in member.roles
  end
end
