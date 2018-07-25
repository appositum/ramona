defmodule Ramona.Commands.Random do
  @moduledoc false
  use Alchemy.Cogs
  alias Ramona.Utils
  require Alchemy.Embed, as: Embed

  Cogs.group("random")

  Cogs.def color do
    ("#" <> Utils.color_random())
    |> Utils.color_embed()
    |> Embed.send("", file: "lib/ramona/assets/color.jpg")

    File.rm("lib/ramona/assets/color.jpg")
  end

  Cogs.def cat do
    image_tag =
      HTTPoison.get!("http://random.cat/view/#{Enum.random(1..1677)}").body
      |> Floki.parse()
      |> Floki.find("img#cat")
      |> Enum.at(0)

    {_tag, info, _} = image_tag
    {_, image_link} = Enum.find(info, &match?({"src", _}, &1))

    %Embed{}
    |> Embed.image(image_link)
    |> Embed.send()
  end

  Cogs.def dog do
    image =
      HTTPoison.get!("https://random.dog/woof.json").body
      |> Poison.decode!()
      |> Map.get("url")

    %Embed{}
    |> Embed.image(image)
    |> Embed.send()
  end
end
