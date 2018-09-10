defmodule Ramona.Commands.Macros do
  use Alchemy.Cogs

  Cogs.set_parser(:wrapcode, &List.wrap/1)
  Cogs.set_parser(:wrapmini, &List.wrap/1)
  Cogs.set_parser(:xyproblem, &List.wrap/1)

  Cogs.def wrapcode(_) do
    wrap = "**Formatação de código**"
      <> "\n\nDigite:\n"
      <> "\\`\\`\\`rust\n"
      <> "let mut tokens = Vec::<Token>::new();\n\\`\\`\\`"
      <> "\nPara enviar:\n"
      <> "```rust\n"
      <> "let mut tokens = Vec::<Token>::new();\n```"

      <> "\nOu:\n"
      <> "\\`\\`\\`html\n"
      <> "<ul style=\"list-style:none;\"><li>Cappucino</li></ul>\n\\`\\`\\`"
      <> "\nPara enviar:\n"
      <> "```html\n<ul style=\"list-style:none;\"><li>Cappucino</li></ul>\n```"
      <> "\nNão confunda o acento grave (\\`) com apóstrofo (')!}"

    Cogs.say(wrap)
  end

  Cogs.def wrapmini(_) do
    wrap = "**Substitua `haskell` por java, cpp, python, etc."
      <> " Não deve haver espaços entre os acentos e o nome da linguagem.**"
      <> "\n\n\\`\\`\\`haskell\n"
      <> "safeHead :: SafeList a NonEmpty -> a\n\\`\\`\\`\n"
      <> "```haskell\n"
      <> "safeHead :: SafeList a NonEmpty -> a\n```"

    Cogs.say(wrap)
  end

  Cogs.def xyproblem(_) do
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
