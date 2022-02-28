defmodule Ramona.Commands.XVideos do
  use Alchemy.Cogs
  require Alchemy.Embed, as: Embed
  require Logger

  Cogs.def xvideos do
    {title, %{"message" => content, "name" => author, "pic" => picture, "date" => date}} =
      fetch_comment()

    picture =
      if !picture,
        do: "https://static-l3.xvideos-cdn.com/img/profile_default_big.jpg",
        else: picture

    %Embed{color: 0xC52200}
    |> Embed.author(
      name: "XVideos",
      icon_url: "https://apkshadow.com/wp-content/uploads/2019/07/unnamed.png"
    )
    |> Embed.field("Título:", "**`#{escape(title)}`**")
    |> Embed.field("#{escape(author)} comentou:", "#{escape(content)}")
    |> Embed.thumbnail(picture)
    |> Embed.footer(
      text: "#{date} • Requested by #{message.author.username}##{message.author.discriminator}"
    )
    |> Embed.send()
  end

  # grab the href and video title
  defp fetch_video do
    rand = Enum.random(0..20)
    page_number = if rand == 0, do: "", else: rand

    {_tag, [{"href", href}, {"title", title}], _video_info} =
      HTTPoison.get!("https://www.xvideos.com/lang/portugues/#{page_number}").body
      |> Floki.parse_document!()
      |> Floki.find(".thumb-under > p.title > a")
      |> Enum.random()

    Logger.debug("Fetched video: #{href}")
    {title, List.last(Regex.run(~r{/video(\d+)/.*}, href))}
  end

  defp fetch_comment do
    {title, href} = fetch_video()

    comment =
      HTTPoison.get!("https://www.xvideos.com/threads/video-comments/get-posts/top/#{href}/0/0").body
      |> Poison.decode!()
      |> Map.get("posts")
      # yes, the repetition is intended
      |> Map.get("posts")
      |> Enum.take_random(1)

    # unlike `random`, `take_random` returns a list of elements
    # if there are no comments under the video, the list is gonna be empty
    # if it is empty, then we try another video

    case comment do
      [] ->
        Logger.debug("No comments found for #{href}, trying again...")
        fetch_comment()

      [{_id, c}] ->
        {title, Map.take(c, ["name", "message", "date", "pic"])}
    end
  end

  defp escape(string) do
    # remove link tags
    Regex.replace(~r{</?(a|A).*?>}, string, "")
    # gets rid of stuff like &nbsp from HTML
    |> HtmlEntities.decode()
    |> String.replace("<br />", "\n")
  end
end
