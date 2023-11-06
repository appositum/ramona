defmodule Ramona.Events.Macros do
  use Alchemy.Events
  alias Alchemy.Client

  Events.on_message(:pito)
  def pito(message) do
    content = "ala tento chupar o proprio pito kkkkkkkkkkkkkkkk"
    trigger = "you can't star your own messages!"

    if String.contains?(message.content, trigger) do
      Client.send_message(message.channel_id, content)
    end
  end
end
