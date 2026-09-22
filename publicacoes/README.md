# Página de Publicações

Listagem de publicações do grupo em formato de **cards** (Quarto listing),
com filtros por **tipo** e **ano**, busca textual e ordenação. Sem página
individual por publicação.

## Arquivos

- `index.qmd` — a página do listing (gerada automaticamente).
- `itens/*.qmd` — um arquivo curto por publicação, só com metadados no YAML.
  São indexados pela busca do Quarto (título, autores, veículo).
- `publicacoes.css` — estilo dos cards (borda-guia colorida por tipo).
- `publicacoes.js` — pinta a borda por tipo e trata os links dos cards.
- `links.js` — mapa `slug → URL` dos DOIs/links (gerado; vazio por enquanto).

## Como adicionar ou editar publicações (no RStudio)

Tudo é gerado por um único script R na raiz do repositório:
`gerar_publicacoes.R` (base R, sem pacotes extras).

1. Abra `gerar_publicacoes.R` e edite a lista `registros`. Cada entrada é um
   vetor com 6 campos, nesta ordem:
   ```r
   c("Autor 1 ; Autor 2", "2025", "Título", "Veículo, v. X, n. Y", "Artigo", "")
   ```
   - autores: separados por " ; ".
   - tipo: "Artigo", "Livro", "Capítulo" ou "Trabalho".
   - último campo: o DOI/URL (ex.: "https://doi.org/...") ou "" se não houver.
     Quando há link, o card ganha um botão **Acessar** que abre a URL.
2. No console do R (com o projeto .Rproj aberto, ou o working dir na raiz):
   ```r
   source("gerar_publicacoes.R")
   ```
   Isso recria `itens/`, `index.qmd` e `links.js`.
3. Renderize (botão Render/Build, ou `quarto render` no Terminal),
   faça commit + push — a GitHub Action publica.

Não é preciso R na renderização do site: a página só usa metadados YAML e o
listing do Quarto. O R serve apenas para gerar os arquivos.
