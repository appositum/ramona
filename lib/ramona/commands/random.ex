defmodule Ramona.Commands.Random do
  @moduledoc false
  use Alchemy.Cogs
  alias Ramona.Utils
  require Alchemy.Embed, as: Embed

  Cogs.group("random")

  Cogs.def color do
    hash = Utils.gen_hash()

    ("#" <> Utils.color_random())
    |> Utils.color_embed(hash)
    |> Embed.send("", file: "lib/ramona/assets/#{hash}.jpg")

    File.rm("lib/ramona/assets/#{hash}.jpg")
  end

  Cogs.def cat do
    image_link = request_animal("https://aws.random.cat/meow", "file")

    %Embed{}
    |> Embed.image(image_link)
    |> Embed.send()
  end

  Cogs.def dog do
    image_link = request_dog("https://random.dog/woof.json")

    %Embed{}
    |> Embed.image(image_link)
    |> Embed.send()
  end

  defp request_dog(link) do
    url = request_animal(link, "url")

    # ignore video files
    if Regex.match?(~r/.*\.(jpg|png|gif)/, url) do
      url
    else
      request_dog(link)
    end
  end

  defp request_animal(link, json_attribute_name) do
    HTTPoison.get!(link).body
    |> Poison.decode!()
    |> Map.get(json_attribute_name)
  end
end
