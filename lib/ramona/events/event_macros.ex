defmodule Ramona.Events.Macros do
  use Alchemy.Events
  alias Alchemy.Client

  @striking Enum.join [
    "<:striking1:442018988147343360>",
    "<:striking2:442018988181159950>",
    "<:striking3:442018988466241558>",
    "\n<:striking4:442018989103644672>",
    "<:striking5:442018989925990400>",
    "<:striking6:442018990152220673>",
    "\n<:striking7:442018990357872642>",
    "<:striking8:442018990999601162>",
    "<:striking9:442018991297396746>"
  ]

  Events.on_message(:pito)
  Events.on_message(:striking)

  def pito(message) do
    content = "ala tento chupar o proprio pito kkkkkkkkkkkkkkkk"
    trigger = "you can't star your own messages!"

    if String.contains?(message.content, trigger) do
      Client.send_message(message.channel_id, content)
    end
  end

  def striking(message) do
    if String.contains?(message.content, "striking") and
         message.author.id != Alchemy.Cache.user().id do
      if message.content == "r$striking" do
        {:ok, nil} = Client.delete_message(message)
      end

      Client.send_message(message.channel_id, @striking)
    end
  end
end
