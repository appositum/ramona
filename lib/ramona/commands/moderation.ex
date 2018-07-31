defmodule Ramona.Commands.Moderation do
  @moduledoc false
  use Alchemy.Cogs
  alias Alchemy.Client
  alias Ramona.Utils
  require Logger
  require Alchemy.Embed, as: Embed

  @embed_color 0x36393F

  Cogs.set_parser(:wrapcode, &List.wrap/1)
  Cogs.set_parser(:wrapmini, &List.wrap/1)

  Cogs.def help do
    commands =
      Cogs.all_commands()
      |> Map.keys()
      |> Enum.join("\n")

    %Embed{color: @embed_color, description: commands}
    |> Embed.title("All available commands")
    |> Embed.send()
  end

  @doc """
  Information about the bot.
  """
  Cogs.def info do
    {:ok, app_version} = :application.get_key(:ramona, :vsn)
    {:ok, lib_version} = :application.get_key(:alchemy, :vsn)
    {:ok, guilds} = Client.get_current_guilds()

    memories = :erlang.memory()
    {{_, io_input}, {_, io_output}} = :erlang.statistics(:io)

    mem_format = fn
      mem, :kb -> "#{div(mem, 1000)} KB"
      mem, :mb -> "#{div(mem, 1_000_000)} MB"
    end

    infos = [
      {"Prefix", Application.get_env(:ramona, :prefix)},
      {"Version", "#{app_version}"},
      {"Elixir Version", System.version()},
      {"Library", "[Alchemy #{lib_version}](https://github.com/cronokirby/alchemy)"},
      {"Owner", "[appositum#1888](https://github.com/appositum)"},
      {"Guilds", "#{length(guilds)}"},
      {"Processes", "#{length(:erlang.processes())}"},
      {"Process Memory", mem_format.(memories[:processes], :mb)},
      {"Memory Usage", mem_format.(memories[:total], :mb)},
      {"Code Memory", mem_format.(memories[:code], :mb)},
      {"ETS Memory", mem_format.(memories[:ets], :kb)},
      {"Atom Memory", mem_format.(memories[:atom], :kb)},
      {"IO Input", mem_format.(io_input, :mb)},
      {"IO Output", mem_format.(io_output, :mb)}
    ]

    Enum.reduce(infos, %Embed{color: @embed_color}, fn {n, v}, embed ->
      Embed.field(embed, n, v, inline: true)
    end)
    |> Embed.title("Ramona")
    |> Embed.thumbnail("https://i.imgur.com/B8BmGhu.png")
    |> Embed.url("https://github.com/appositum/ramona")
    |> Embed.footer(text: "Uptime: #{Utils.uptime()}")
    |> Embed.send()
  end

  Cogs.def wrapcode(_) do
    wrap =
      ~s{**Formatação de código**\n\nDigite:\n\\`\\`\\`rust\nlet mut tokens = Vec::<Token>::new();\n\\`\\`\\`\nPara enviar:\n```rust\nlet mut tokens = Vec::<Token>::new();\n```\n\nOu:\n\\`\\`\\`html\n<ul style=\"list-style:none;\"><li>Cappucino</li></ul>\n\\`\\`\\`\nPara enviar:\n```html\n<ul style=\"list-style:none;\"><li>Cappucino</li></ul>\n```\nNão confunda o acento grave (\\`) com apóstrofo (')!}

    Cogs.say(wrap)
  end

  Cogs.def wrapmini(_) do
    wrap =
      ~s{**Substitua "linguagem" por java, cpp, python, etc. Não deve haver espaços entre os acentos e o nome da linguagem.**\n\n\\`\\`\\`haskell\nsafeHead :: SafeList a NonEmpty -> a\n\\`\\`\\`\n```haskell\nsafeHead :: SafeList a NonEmpty -> a\n```}

    Cogs.say(wrap)
  end

  Cogs.def regras do
    Client.delete_message(message)

    %Embed{}
    |> Embed.color(@embed_color)
    |> Embed.title("Regras")
    |> Embed.field("1. Canais", "Leia as descrições dos canais e tente manter o tópico adequado.")
    |> Embed.field("\n\n2. Sem divulgação", "ta ok respeitar")
    |> Embed.send()
  end

  Cogs.def cargos do
    Client.delete_message(message)

    %Embed{}
    |> Embed.color(@embed_color)
    |> Embed.title("Cargos")
    |> Embed.field("ᚫ Ansuz", "Administradores", inline: true)
    |> Embed.field("ᛇ Eihwaz", "Moderadores", inline: true)
    |> Embed.field("ᛗ Mannaz", "Membro", inline: true)
    |> Embed.send()
  end

  Cogs.def xyproblem do
    xy = "**O problem XY**"
      <> "\nPerguntar sobre a sua tentativa de solução ao invés de perguntar sobre o real problema. (<http://xyproblem.info/>)\n"

      <> "\n**Exemplo 1**\n"
      <> "```\n<n00b> Como eu printo os últimos 3 caracteres do nome de um arquivo?"
      <> "\n<feline> Se estiver dentro de uma variável: echo ${foo: -3}"
      <> "\n<feline> Pq 3 caracteres? O que você quer EXATAMENTE?"
      <> "\n<feline> Você quer a extensão?"
      <> "\n<n00b> Sim."
      <> "\n<feline> Então PERGUNTE PELO QUE VOCÊ QUER!"
      <> "\n<feline> Não tem garantia de que todo nome de arquivo tenha uma extensão de 3 letras,\n<feline> então só pegar os últimos 3 caracteres não resolve o problema."
      <> "\n<feline> echo ${foo##*.}```"

      <> "\n**Exemplo 2**\n"
      <> "Se Angela só tivesse explicado que ela queria previnir que os outros detectassem seu sistema operacional, essa poderia ter sido uma discussão muito mais curta e produtiva."

      <> "```\nAngela: 'nmap -O -A 127.0.0.1' retorna algumas linhas começando com 'OS:'. Como eu mudo isso?"
      <> "\nObama: Veja no código fonte do nmap, entenda como ele descobre essa parte do Linux, e depois reprograme o seu stack TCP/IP pra operar de uma forma que o nmap não consiga detectar."
      <> "\nAngela: Sim, mas eu não sei nada sobre a api do linux."
      <> "\nObama: O fingerprint do nmap é baseado na forma que o TCP/IP funciona, entao nao tem nenhuma outra forma além de reescrever essas partes do stack."
      <> "\nAngela: Eu queria evitar essas mensagens. Será que o iptables funciona?"
      <> "\nObama: Então não use detecção de OS ou scanner de versão"
      <> "\nAngela: Eu quero evitar que os outros saibam o tipo do meu OS```"

    Cogs.say(xy)
  end
end
