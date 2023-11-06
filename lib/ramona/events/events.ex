defmodule Ramona.Events do
  @moduledoc false
  use Alchemy.Events
  alias Ramona.Profile
  alias Alchemy.{Cache, Cogs}
  require Logger

  Events.on_ready(:ready)
  def ready(_, _) do
    Profile.update_file()

    me = "#{Cache.user.username}##{Cache.user.discriminator} (#{Cache.user.id})"
    Logger.info("Logged in as #{me}")
    Logger.info("Ramona is ready!")
  end

  Events.on_message(:command_log)
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
end
