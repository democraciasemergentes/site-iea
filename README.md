# Site do Grupo de Pesquisa EPI — IEA-USP

Site acadêmico do grupo **Economia Política Internacional, Variedades de
Democracia e Descarbonização**, construído com [Quarto](https://quarto.org).

## Estrutura

```
_quarto.yml            → configuração central (menu, tema, rodapé)
index.qmd              → página inicial (hero + destaques)
sobre.qmd              → o grupo e o projeto FAPESP
equipe/index.qmd       → coordenação, integrantes, colaboradores
linhas/index.qmd       → três linhas de pesquisa
publicacoes/
  ├─ index.qmd         → lista gerada automaticamente
  └─ referencias.bib   → adicione publicações aqui (formato BibTeX)
posts/
  ├─ index.qmd         → listagem automática de notícias
  └─ <pasta-do-post>/index.qmd
assets/                → tema (SCSS) e CSS
images/                → logo, favicon, fotos da equipe
```

## Pré-requisitos

- [Quarto](https://quarto.org/docs/get-started/) (1.4 ou superior)
- Opcional: R + RStudio, se quiser embutir gráficos (ex.: redes com `igraph`/`ggraph`)

## Como editar

**Adicionar uma notícia:** duplique uma pasta em `posts/`, edite o cabeçalho
(título, `date`, `categories`) e o texto. Ela aparece sozinha na home e na
página de Notícias.

**Adicionar uma publicação:** cole a entrada BibTeX (exportada do Zotero,
Mendeley ou do pacote R `RefManageR`) em `publicacoes/referencias.bib`.

**Trocar cores/tipografia:** edite `assets/tema.scss`.

**Fotos da equipe:** coloque o arquivo em `images/` e, em `equipe/index.qmd`,
substitua o `<div class="avatar-fallback">XX</div>` por
`<img src="../images/nome.jpg">`.

## Visualizar localmente

```bash
quarto preview
```

## Publicar

- **GitHub Pages:** `quarto publish gh-pages`
- **Netlify:** `quarto publish netlify`
- **Servidor USP:** copie o conteúdo da pasta `_site/` para o servidor web.

## Gráficos em R (opcional)

Renomeie qualquer `.qmd` para conter um bloco de código R, por exemplo:

```` markdown
```{r}
#| echo: false
library(igraph)
# ... seu código de análise de redes gera a figura aqui
```
````

O gráfico é gerado no momento do `quarto render` e embutido na página.
