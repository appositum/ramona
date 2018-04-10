use Mix.Config

config :porcelain,
  driver: Porcelain.Driver.Basic

config :alchemy,
  ffmpeg_path: "ffmpeg",
  youtube_dl_path: "youtube-dl"

config :ramona,
  token: System.get_env("TOKEN"),
  prefix: System.get_env("COMMAND_PREFIX") || "r$",
  colors: [
    {0xDD4890, "pink"},       # vol. 1
    {0xC55387, "dark_pink"},  # vol. 2
    {0x3D5CAC, "dark_blue"},  # vol. 3
    {0x01B6AD, "turquoise"},  # vol. 4
    {0xF5865B, "orange"},     # vol. 4
    {0x009CCF, "light_blue"}, # vol. 5
    {0x3C9790, "green"},      # vol. 6
    {0xEB90BC, "light_pink"}  # vol. 6
  ]
