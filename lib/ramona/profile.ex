defmodule Ramona.Profile do
  @moduledoc """
  Update the bot's profile picture and colors used on embedded messages and its own role.
  """
  alias Alchemy.Client

  @colors_path "lib/assets/colors/"
  @profile_path "lib/assets/.profile.json"
  @github "https://raw.githubusercontent.com/appositum/ramona/colors/"
  @colors Application.fetch_env!(:ramona, :colors)

  def update_avatar do
    File.read!(@profile_path)
    |> Poison.decode!()
    |> Map.get("picture")
  end

  def update_color do
    File.read!(@profile_path)
    |> Poison.decode!()
    |> Map.get("color")
    |> Map.get("number")
  end

  def update_file do
    # {"color", "path/to/color/"}
    {color_name, color_folder} =
      with folder_name <- Enum.random(File.ls!(@colors_path)) do
        {folder_name, Path.join(@colors_path, folder_name)}
      end

    picture_link =
      with color_file <- File.ls!(color_folder) |> Enum.random() do
        Path.join(@github, Path.join(color_folder, color_file))
      end

    {color_number, color_name} = Enum.find(@colors, &match?({_, ^color_name}, &1))

    content = %{
      "color" => %{
        "name" => color_name,
        "number" => color_number
      },
      "picture" => picture_link
    }

    File.write(@profile_path, Poison.encode!(content, pretty: true))
  end
end
