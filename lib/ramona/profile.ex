defmodule Ramona.Profile do
  @moduledoc """
  Update the bot's profile picture and colors used on embedded messages and its own role.
  """

  @colors_path "lib/ramona/assets/colors/"
  @profile_path "lib/ramona/assets/.profile.json"
  @github "https://raw.githubusercontent.com/appositum/ramona/master/"
  @colors Application.fetch_env!(:ramona, :colors)

  def avatar do
    File.read!(@profile_path)
    |> Poison.decode!()
    |> Map.get("picture")
  end

  def color do
    File.read!(@profile_path)
    |> Poison.decode!()
    |> Map.get("color")
    |> Map.get("number")
  end

  @doc """
  Generates a new profile with a randomized color and avatar.
  """
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
