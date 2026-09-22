#!/usr/bin/env Rscript
# ---------------------------------------------------------------------------
# gerar_publicacoes.R
#
# Gera a página de Publicações do site do grupo (IEA-USP), em Quarto:
#   - publicacoes/itens/<slug>.qmd  -> um arquivo curto por publicação
#   - publicacoes/index.qmd         -> o listing (grade de cards, filtros)
#   - publicacoes/links.js          -> mapa slug -> DOI/URL (para o botão "Acessar")
#
# Não usa R na RENDERIZAÇÃO do site — só na geração dos arquivos. A busca do
# Quarto funciona porque cada item é um documento real com metadados no YAML.
#
# COMO USAR (no RStudio):
#   1. Abra este arquivo e edite a tabela `pubs` (uma linha por publicação).
#   2. No console:  source("gerar_publicacoes.R")
#   3. Confira em publicacoes/ e faça commit + push.
#
# Rode com o diretório de trabalho na RAIZ do repositório (onde está _quarto.yml).
# No RStudio, se o projeto .Rproj estiver aberto, o working dir já é a raiz.
# ---------------------------------------------------------------------------

# --- localizar a raiz do repositório -------------------------------------
raiz <- getwd()
if (!file.exists(file.path(raiz, "_quarto.yml"))) {
  stop("Rode com o working directory na raiz do repositório (onde está _quarto.yml). ",
       "Working dir atual: ", raiz)
}
pub_dir   <- file.path(raiz, "publicacoes")
itens_dir <- file.path(pub_dir, "itens")

# --- dados: uma linha por publicação -------------------------------------
# Cada elemento de `registros` é um vetor de 6 campos, na ordem:
#   autores (separados por " ; "), ano, titulo, veiculo, tipo, link
#   tipo ∈ {"Artigo","Livro","Capítulo","Trabalho"}
#   link: DOI/URL (ex. "https://doi.org/10.1000/xyz") ou "" se não houver.
#         Quando há link, o card ganha um botão "Acessar".
# Base R apenas (sem tibble/dplyr) — roda em qualquer instalação de R.
registros <- list(

  c("Lourdes Sola ; Cristiane Lucena Carneiro ; Vinícius Rodrigues Vieira", "2024",
    "Federalism and Public Health Governance: the role of state-level horizontal coordination during responses to COVID-19 in Brazil",
    "Desarrollo Económico, v. 64, n. 242", "Artigo", "https://revistas.ides.org.ar/desarrollo-economico/es/article/view/668"),

  c("Lourdes Sola", "2023",
    "Ideias Econômicas, Decisões Políticas: técnicos e políticos no governo da economia (2ª ed. ampliada)",
    "EDUSP", "Livro", "https://www.edusp.com.br/livros/ideias-economicas-decisoes-politicas/"),

  c("Lourdes Sola ; Jorge Caldeira", "2025",
    "The plural dynamics of state institutionalisation in Brazil: the building blocks of the nation's political structures",
    "SCRIPTS – Contestations of the Liberal Script, Working Paper", "Trabalho", "https://www.scripts-berlin.eu/publications/working-paper-series/Working-Paper-53-2025/index.html"),

  c("Eduardo Viola", "2026",
    "A política climática internacional (1992–2026): do globalismo cooperativo à fragmentação geopolítica numa Terra acima de 1,5 °C",
    "In: A integração do Brasil ao mundo no século XXI. CINDES", "Capítulo", "https://cindesbrasil.org/wp-content/uploads/2026/07/CINDES_2026_Final_02_06_26-v2.pdf"),

  c("Vinícius Rodrigues Vieira ; Eduardo Viola", "2026",
    "From the neoliberal utilitarianism to the state strikes back: international political economy and the fate of globalization in the next decades",
    "In: Perspectives on Reglobalization. Springer", "Capítulo", "https://link.springer.com/chapter/10.1007/978-3-032-07236-8_11"),

  c("Eduardo Viola", "2025",
    "Obstruction in the UNFCCC and the Intergovernmental Panel on Climate Change",
    "In: Climate Obstruction: a global assessment. Oxford University Press", "Capítulo", "https://academic.oup.com/book/61469/chapter/534852318"),

  c("Jochen Prantl ; Ana Flávia Barros-Platiau ; Cristina Inoue ; Joana Castro Pereira ; Eduardo Viola", "2024",
    "Building Capabilities for Earth System Governance",
    "Cambridge Elements in Earth System Governance, v. 1", "Livro", "https://www.cambridge.org/core/elements/building-capabilities-for-earth-system-governance/7F1CDA0C47DD04BCB97550E9F5353703"),

  c("Joana Castro Pereira ; Eduardo Viola", "2024",
    "From Protagonist to Laggard, from Pariah to Phoenix: emergence, decline, and re-emergence of Brazilian climate change policy, 2003–2023",
    "Latin American Policy, v. 15", "Artigo", "https://repositorio-aberto.up.pt/handle/10216/161391"),

  c("Christopher A. Hartwell ; Anastassia Obydenkova ; Vinícius Rodrigues Vieira", "2026",
    "Democratization and regional development banks: a cross-continental comparative analysis",
    "Political Research Quarterly (no prelo)", "Artigo", ""),

  c("Vinícius Rodrigues Vieira", "2025",
    "From economic to structural power: agential capitalism, the Belt and Road Initiative, and China's economic statecraft after the 2008 crisis",
    "Journal of Political Power, v. 18, n. 1", "Artigo", "https://www.tandfonline.com/doi/full/10.1080/2158379X.2025.2467987"),

  c("Vinícius Rodrigues Vieira", "2025",
    "The expansion of the BRICS and the future of the world order",
    "In: The Great Decoupling: a new global order/disorder? Palgrave", "Capítulo", "https://link.springer.com/chapter/10.1007/978-981-96-8426-7_7"),

  c("Krishna C. Vadlamannati ; Vinícius Rodrigues Vieira ; T. Song", "2024",
    "Calling the shots through health diplomacy: China's worldwide distribution of anti-COVID vaccines and the international order",
    "International Interactions, v. 50, n. 1", "Artigo", "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4099064"),

  c("Vinícius Rodrigues Vieira", "2023",
    "Shaping Nations and Markets: identity capital, trade, and the populist rage",
    "Routledge", "Livro", "https://www.routledge.com/Shaping-Nations-and-Markets-Identity-Capital-Trade-and-the-Populist-Rage/RodriguesVieira/p/book/9781032386249"),

  c("Cristiane Lucena Carneiro", "2025",
    "La relación bilateral entre Brasil y Estados Unidos",
    "Foreign Affairs Latinoamérica, v. 25, n. 2", "Artigo", ""),

  c("Cristiane Lucena Carneiro", "2025",
    "Institutional Complexity and the Crisis of the Multilateral System",
    "Conjuntura Global, v. 14, n. 2", "Artigo", "https://revistas.ufpr.br/conjgloblal/article/view/98625"),

  c("Cristiane Lucena Carneiro", "2023",
    "Review Article: Global Governance in a Complex World",
    "Frontiers in Law, v. 2", "Artigo", "https://lifescienceglobal.com/index.php/FIA/article/view/9323"),

  c("Sérgio R. Vale ; Virginia Parente", "2026",
    "Climate Sensitivity of Electricity Demand in a Tropical Emerging Economy: long-run evidence from Brazil",
    "International Journal of Energy Economics and Policy, v. 16, n. 5", "Artigo", "https://econjournals.com/index.php/ijeep/article/view/24265"),

  c("Sérgio R. Vale ; Larissa Basso", "2026",
    "Voice Without Exit: environmental soft power and the limits of climate governance",
    "In: Routledge Handbook of Power in International Relations. Routledge (aceito)", "Capítulo", ""),

  c("Sérgio R. Vale", "2025",
    "Democracy, economic growth and volatility in Brazil: what is the causality?",
    "Revista Brasileira de Ciência Política, v. 44", "Artigo", ""),

  c("Sérgio R. Vale ; Eduardo Viola", "2023",
    "Impact of economic sanctions on net commodity-producing and net commodity-consuming countries",
    "Revista Brasileira de Política Internacional, v. 66", "Artigo", "https://www.scielo.br/j/rbpi/a/tCGwPLkVsDfKJpzBrnbYHdz/?lang=en"),

  c("Sérgio R. Vale", "2023",
    "Travessia sem fim: economia e política em transformação no mundo e no Brasil",
    "Appris", "Livro", ""),

  c("Moisés S. Marques", "2025",
    "Tarifaço para o Brasil entra em vigor e reforça o 'Gangster Style' da política externa de Trump",
    "The Conversation", "Artigo", ""),

  c("Moisés S. Marques", "2025",
    "Liberal reforms and democracy: revisiting the incremental institutional building of the financial order in Brazil",
    "Congresso Mundial da IPSA, Seul", "Trabalho", ""),

  c("Sérgio R. Vale ; Moisés S. Marques", "2022",
    "Impact of environmental quality indicators on soft power: a few empirical estimates",
    "Journal of Political Power, v. 15", "Artigo", ""),

  c("Maria Tereza A. Sadek ; Rita de Cássia Biason ; Roberto Livianu", "2026",
    "Corrupção no Brasil e no Mundo: transparência, política e análises",
    "Almedina Brasil", "Livro", "https://altabooks.com.br/produto/corrupcao-no-brasil-e-no-mundo/"),

  c("Maria Tereza A. Sadek ; Sérgio R. Vale ; Luciana Yeung", "2026",
    "Courts and Economic Policy Disputes: evidence from the Brazilian Supreme Court",
    "International Review of Law and Economics (em avaliação)", "Artigo", ""),

  c("Maria Tereza A. Sadek", "2025",
    "Poder Judiciário no Brasil",
    "In: Estado de Direito e Três Poderes. Konrad Adenauer Stiftung", "Capítulo", ""),

  c("Maria Tereza A. Sadek ; Fabiana Luci de Oliveira", "2024",
    "Resolução do CNJ se cumpre? A ineficácia da política de cotas raciais no Judiciário",
    "Revista Estudos Institucionais, v. 10, n. 2", "Artigo", ""),

  c("Luciana Yeung", "2025",
    "Judicial Review and Economic Governance: evidence from the Brazilian Supreme Court",
    "International Review of Law and Economics (submetido)", "Artigo", ""),

  c("Luciana Yeung", "2024",
    "O Judiciário Brasileiro: uma análise empírica e econômica",
    "Foco", "Livro", ""),

  c("Kari De Pryck ; Eduardo Viola ; Stefan C. Aykut ; Larissa Basso", "2025",
    "Obstruction in the UNFCCC and the IPCC",
    "In: Climate Obstruction: a global assessment. Oxford University Press", "Capítulo", ""),

  c("Cristina Yumie Aoki Inoue ; Thais Lemos Ribeiro ; Verônica Korber Gonçalves ; Larissa Basso ; Paula Franco Moreira", "2024",
    "Indigenous and traditional communities' ways of knowing and being in planetary justice",
    "Environmental Politics", "Artigo", ""),

  c("Larissa Basso", "2024",
    "The Political Economy of Climate Change Mitigation in Argentina, Brazil and Peru",
    "Iberoamericana – Nordic Journal of Latin American and Caribbean Studies, v. 53, n. 1", "Artigo", ""),

  c("Larissa Basso", "2024",
    "Tracing climate commitment in Brazil and South Africa, 2000–2020",
    "Mural Internacional, v. 15", "Artigo", ""),

  c("Larissa Basso", "2024",
    "Energy transition in Brazil: challenges to achieve the SDG 7",
    "In: The quest for the Sustainable Development Goals. Springer", "Capítulo", ""),

  c("Lourdes Sola ; Sérgio R. Vale ; Paulo C. da S. Flores", "2026",
    "Emerging Middle Classes and Political Discontent in Brazil: rethinking the economic and non-economic determinants of polarization",
    "Working paper — Work-in-Progress 2026, IPSA", "Trabalho", "")
)

pubs <- as.data.frame(
  do.call(rbind, registros),
  stringsAsFactors = FALSE
)
names(pubs) <- c("autores", "ano", "titulo", "veiculo", "tipo", "link")
pubs$ano <- as.integer(pubs$ano)

# --- utilitários ----------------------------------------------------------
# Remove acentos de forma robusta e independente de locale. Faz uma
# substituição por acento com gsub (byte-safe), evitando chartr/iconv que
# dependem do locale e podem falhar ou devolver NA.
sem_acento <- function(x) {
  mapa_ac <- c(
    "á"="a","à"="a","â"="a","ã"="a","ä"="a",
    "é"="e","è"="e","ê"="e","ë"="e",
    "í"="i","ì"="i","î"="i","ï"="i",
    "ó"="o","ò"="o","ô"="o","õ"="o","ö"="o",
    "ú"="u","ù"="u","û"="u","ü"="u",
    "ç"="c","ñ"="n",
    "Á"="A","À"="A","Â"="A","Ã"="A","Ä"="A",
    "É"="E","È"="E","Ê"="E","Ë"="E",
    "Í"="I","Ì"="I","Î"="I","Ï"="I",
    "Ó"="O","Ò"="O","Ô"="O","Õ"="O","Ö"="O",
    "Ú"="U","Ù"="U","Û"="U","Ü"="U",
    "Ç"="C","Ñ"="N"
  )
  for (ac in names(mapa_ac)) {
    x <- gsub(ac, mapa_ac[[ac]], x, fixed = TRUE, useBytes = TRUE)
  }
  # travessões (– —) viram hífen comum antes da limpeza
  x <- gsub("–", "-", x, fixed = TRUE, useBytes = TRUE)
  x <- gsub("—", "-", x, fixed = TRUE, useBytes = TRUE)
  # remove quaisquer bytes/símbolos não-ASCII remanescentes (ex.: °)
  gsub("[^A-Za-z0-9 .,;:_/()-]", "", x, useBytes = TRUE)
}

slugify <- function(ano, autores, titulo) {
  primeiro <- trimws(strsplit(autores, ";", fixed = TRUE)[[1]][1])
  sobren   <- tolower(tail(strsplit(primeiro, "\\s+")[[1]], 1))
  sobren   <- sem_acento(sobren)
  sobren   <- gsub("[^a-z0-9]", "", tolower(sobren))
  t <- sem_acento(tolower(titulo))
  t <- gsub("[^a-z0-9]+", "-", tolower(t))
  t <- gsub("^-|-$", "", t)
  t <- substr(t, 1, 45)
  t <- gsub("^-|-$", "", t)
  sprintf("%d-%s-%s", ano, sobren, t)
}

# escapa aspas para valor YAML entre aspas duplas
yq <- function(s) gsub('"', '\\\\"', s)

# --- gera os itens --------------------------------------------------------
if (dir.exists(itens_dir)) unlink(itens_dir, recursive = TRUE)
dir.create(itens_dir, recursive = TRUE, showWarnings = FALSE)

mapa <- list()  # slug -> link
for (i in seq_len(nrow(pubs))) {
  p <- pubs[i, ]
  autores_vec <- trimws(strsplit(p$autores, ";", fixed = TRUE)[[1]])
  s <- slugify(p$ano, p$autores, p$titulo)
  autores_yaml <- paste(sprintf('"%s"', vapply(autores_vec, yq, "")), collapse = ", ")

  linhas <- c(
    "---",
    sprintf('title: "%s"', yq(p$titulo)),
    sprintf('date: "%d-01-01"', p$ano),
    sprintf("author: [%s]", autores_yaml),
    sprintf('categories: ["%s", "%d"]', p$tipo, p$ano),
    sprintf('description: "%s"', yq(p$veiculo)),
    "---"
  )
  writeLines(linhas, file.path(itens_dir, paste0(s, ".qmd")), useBytes = TRUE)
  if (nzchar(p$link)) mapa[[s]] <- p$link
}

# --- gera o index.qmd -----------------------------------------------------
index_txt <- '---
title: "Publicações"
subtitle: "Produção do grupo de pesquisa"
listing:
  id: pubs
  contents: itens
  type: grid
  grid-columns: 2
  sort: "date desc"
  categories: numbered
  sort-ui: [date, author, title]
  filter-ui: true
  fields: [title, author, description, categories]
  field-display-names:
    description: "Veículo"
  page-size: 60
toc: false
page-layout: full
css: publicacoes.css
include-after-body:
  text: |
    <script src="links.js"></script>
    <script src="publicacoes.js"></script>
---

A produção abaixo reúne artigos, livros, capítulos e trabalhos apresentados
pelos pesquisadores do grupo. Use os filtros por **tipo** e **ano**, a busca,
ou a ordenação para localizar um título.

```{=html}
<div class="pub-legenda">
  <span><i style="background:#1d5b78"></i>Artigo</span>
  <span><i style="background:#12303f"></i>Livro</span>
  <span><i style="background:#3a8fb7"></i>Capítulo</span>
  <span><i style="background:#2f7d5b"></i>Trabalho</span>
</div>
```

::: {#pubs}
:::
'
cat(index_txt, file = file.path(pub_dir, "index.qmd"))

# --- gera o links.js (mapa slug -> URL) -----------------------------------
# JSON simples sem depender de pacotes (usa jsonlite se disponível)
if (length(mapa) == 0L) {
  js <- "window.PUB_LINKS = {};\n"
} else if (requireNamespace("jsonlite", quietly = TRUE)) {
  js <- paste0("window.PUB_LINKS = ",
               jsonlite::toJSON(mapa, auto_unbox = TRUE), ";\n")
} else {
  pares <- vapply(names(mapa), function(k)
    sprintf('"%s":"%s"', k, mapa[[k]]), "")
  js <- paste0("window.PUB_LINKS = {", paste(pares, collapse = ","), "};\n")
}
cat(js, file = file.path(pub_dir, "links.js"))

# --- resumo ---------------------------------------------------------------
message(sprintf("%d publicações geradas em %s", nrow(pubs), itens_dir))
message(sprintf("listing -> %s", file.path(pub_dir, "index.qmd")))
message(sprintf("links externos -> %d", length(mapa)))
message("Pronto. Renderize com: quarto render  (ou o botão Render/Build no RStudio).")
