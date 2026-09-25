# =============================================================================
# gerar_eventos.R
# Gera as páginas da seção Eventos a partir de duas planilhas:
#   dados/eventos_iea.csv      -> eventos/iea/<slug>/index.qmd   (uma página por seminário)
#   dados/participacoes.csv    -> eventos/participacoes/itens/<slug>.qmd (só alimentam a lista)
#
# Uso (com o .Rproj aberto no RStudio):  source("gerar_eventos.R")
# Só usa R base. Rode sempre que editar as planilhas; depois, quarto render / push.
# =============================================================================

# Aspas simples de YAML: apóstrofos são duplicados
yq <- function(x) paste0("'", gsub("'", "''", x, fixed = TRUE), "'")

# Divide "A; B; C" em vetor, descartando vazios
dividir <- function(x) {
  if (is.na(x) || !nzchar(trimws(x))) return(character(0))
  trimws(strsplit(x, ";", fixed = TRUE)[[1]])
}

# Lista YAML em linha: [a, b, c]
yaml_lista <- function(v) paste0("[", paste(vapply(v, yq, ""), collapse = ", "), "]")

# Extrai o ID de vídeo do YouTube (youtu.be/ID, watch?v=ID, /live/ID)
youtube_id <- function(url) {
  padroes <- c("youtu\\.be/([A-Za-z0-9_-]{11})",
               "[?&]v=([A-Za-z0-9_-]{11})",
               "/live/([A-Za-z0-9_-]{11})")
  for (p in padroes) {
    m <- regmatches(url, regexec(p, url))[[1]]
    if (length(m) == 2) return(m[2])
  }
  NA_character_
}

# Junta nomes em português: "A", "A e B", "A, B e C"
juntar <- function(v) {
  n <- length(v)
  if (n == 0) return("")
  if (n == 1) return(v)
  paste(paste(v[-n], collapse = ", "), "e", v[n])
}

# Remove a filiação entre parênteses: "Fulano (USP)" -> "Fulano"
so_nomes <- function(v) trimws(sub("\\s*\\(.*\\)$", "", v))

ler <- function(caminho) {
  # readLines + text= funciona mesmo quando a sessão não está em locale UTF-8
  linhas <- readLines(caminho, encoding = "UTF-8", warn = FALSE)
  read.csv(text = linhas, stringsAsFactors = FALSE, encoding = "UTF-8",
           na.strings = character(0))
}

escrever <- function(linhas, caminho) {
  dir.create(dirname(caminho), recursive = TRUE, showWarnings = FALSE)
  con <- file(caminho, open = "w", encoding = "UTF-8")
  writeLines(linhas, con)
  close(con)
}

# -----------------------------------------------------------------------------
# 1. Seminários no IEA
# -----------------------------------------------------------------------------
iea <- ler("dados/eventos_iea.csv")
unlink(list.dirs("eventos/iea", recursive = FALSE), recursive = TRUE)

papeis <- c(abertura = "Abertura", expositores = "Exposição",
            debatedores = "Debate", moderacao = "Moderação")

for (i in seq_len(nrow(iea))) {
  e   <- iea[i, ]
  vid <- youtube_id(e$url_video)
  expo <- dividir(e$expositores)

  # Nomes exibidos no card: expositores + debatedores, no máximo 4
  nomes <- so_nomes(c(expo, dividir(e$debatedores)))
  if (length(nomes) > 4) nomes <- c(nomes[1:3], "outros")
  resumo <- paste0("Com ", juntar(nomes), ".")

  yaml <- c(
    "---",
    paste0("title: ", yq(e$titulo)),
    paste0("date: ", e$data),
    paste0("description: ", yq(resumo)),
    paste0("categories: ", yaml_lista(dividir(e$temas))),
    if (!is.na(vid)) paste0("image: ", yq(sprintf("https://img.youtube.com/vi/%s/hqdefault.jpg", vid))),
    paste0("horario: ", yq(e$horario)),
    paste0("participantes: ", yq(juntar(nomes))),
    paste0("video: ", yq(e$url_video)),
    paste0("pagina-iea: ", yq(e$url_iea)),
    "title-block-banner: false",
    "language:",
    "  title-block-published: 'Realizado em'",
    "css: ../../eventos.css",
    "---",
    ""
  )

  # Ficha: data, horário e cada papel com seus nomes
  ficha <- c('```{=html}', '<dl class="evento-ficha">')
  quando <- format(as.Date(e$data), "%d/%m/%Y")
  if (nzchar(e$horario)) quando <- paste0(quando, ", ", e$horario)
  ficha <- c(ficha, sprintf("<dt>Quando</dt><dd>%s</dd>", quando),
                    "<dt>Onde</dt><dd>Instituto de Estudos Avançados da USP</dd>")
  for (campo in names(papeis)) {
    pessoas <- dividir(e[[campo]])
    if (length(pessoas)) {
      ficha <- c(ficha, sprintf("<dt>%s</dt><dd>%s</dd>", papeis[[campo]],
                                paste(pessoas, collapse = "<br>")))
    }
  }
  ficha <- c(ficha, "</dl>", '```', "")

  corpo <- c(
    if (!is.na(vid)) c(sprintf("{{< video https://www.youtube.com/embed/%s >}}", vid), ""),
    ficha,
    '```{=html}',
    '<p class="evento-acoes">',
    sprintf('<a class="btn-evento" href="%s">Página do evento no IEA</a>', e$url_iea),
    sprintf('<a class="btn-evento secundario" href="%s">Assistir no YouTube</a>', e$url_video),
    '<a class="btn-evento secundario" href="../">Todos os seminários</a>',
    '</p>',
    '```'
  )

  escrever(c(yaml, corpo), file.path("eventos/iea", e$slug, "index.qmd"))
}
message(nrow(iea), " seminários do IEA gerados.")

# -----------------------------------------------------------------------------
# 2. Congressos e participações (itens sem página própria)
# -----------------------------------------------------------------------------
part <- ler("dados/participacoes.csv")
unlink("eventos/participacoes/itens", recursive = TRUE)

for (i in seq_len(nrow(part))) {
  p <- part[i, ]
  membros <- dividir(p$membros)
  yaml <- c(
    "---",
    paste0("title: ", yq(p$titulo)),
    paste0("date: ", p$data),
    paste0("quando: ", yq(p$quando)),
    paste0("status: ", yq(p$status)),
    paste0("local: ", yq(p$local)),
    paste0("tipo: ", yq(p$tipo)),
    paste0("categories: ", yaml_lista(p$tipo)),
    paste0("membros: ", yq(juntar(membros))),
    paste0("description: ", yq(p$detalhe)),
    "---",
    "",
    # o corpo repete os nomes para a busca da listagem encontrá-los
    juntar(membros), "", p$detalhe
  )
  escrever(yaml, file.path("eventos/participacoes/itens", paste0(p$slug, ".qmd")))
}
message(nrow(part), " participações geradas.")
