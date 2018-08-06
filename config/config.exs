use Mix.Config

config :porcelain,
  driver: Porcelain.Driver.Basic

config :alchemy,
  ffmpeg_path: "ffmpeg",
  youtube_dl_path: "youtube-dl"

config :ramona,
  token: System.get_env("TOKEN"),
  prefix: System.get_env("COMMAND_PREFIX") || ";",
  invite: "https://discord.gg/cTHuPFC"
