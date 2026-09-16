# Publicar o site no GitHub Pages pelo RStudio

Guia passo a passo, da pasta local ao site no ar. Feito para quem usa RStudio
e ainda não versiona com Git. Ao final, cada atualização vira **um comando**.

---

## Antes de começar (uma vez só)

1. **Conta no GitHub** — crie em https://github.com se ainda não tiver.
2. **Git instalado** — no Terminal do RStudio (aba *Terminal*), digite `git --version`.
   Se der erro, instale em https://git-scm.com/downloads e reabra o RStudio.
3. **Quarto** — confirme com `quarto --version` (precisa ser 1.4 ou superior).
4. **Pacote usethis** (facilita a conexão com o GitHub):
   ```r
   install.packages("usethis")
   ```

---

## Passo 1 — Abrir a pasta como projeto no RStudio

**File → Open Project** (ou *Open Folder*) e aponte para a pasta `site-iea`.
Confirme que o arquivo `_quarto.yml` aparece no painel *Files*.

---

## Passo 2 — Transformar a pasta em repositório Git

No **Console** do RStudio:

```r
usethis::use_git()
```

Ele pergunta se pode fazer o primeiro commit — responda que **sim**. Pode pedir
para reiniciar a sessão; deixe reiniciar. Ao voltar, surge a aba **Git** no
painel superior direito.

---

## Passo 3 — Conectar sua conta do GitHub (uma vez só)

Ainda no Console, crie uma chave de acesso (token) que autoriza o RStudio a
enviar arquivos ao GitHub:

```r
usethis::create_github_token()
```

Isso abre o navegador no GitHub. Dê um nome qualquer ao token, deixe as opções
como vêm, clique em **Generate token** e **copie** o código gerado (começa com
`ghp_...`). De volta ao RStudio:

```r
gitcreds::set_github_pat()
```

Cole o token quando pedido. Pronto — o RStudio agora fala com sua conta.

---

## Passo 4 — Criar o repositório no GitHub e enviar o site

Um comando cria o repositório na sua conta e envia todos os arquivos:

```r
usethis::use_github()
```

Aceite as confirmações. Ao terminar, seu código-fonte já está no GitHub.
(O repositório pode ser público — é o normal para sites — ou privado, se
preferir; o site publicado fica visível de qualquer forma.)

---

## Passo 5 — Publicar no GitHub Pages

Agora o comando que coloca o site no ar. No **Terminal** do RStudio:

```bash
quarto publish gh-pages
```

Na primeira vez ele:
- cria sozinho a branch `gh-pages`,
- renderiza o site,
- envia o resultado ao GitHub,
- e o GitHub Pages se configura automaticamente.

Ao final, o Quarto mostra o endereço do site, algo como:
`https://SEU-USUARIO.github.io/site-iea/`

Aguarde 1–2 minutos e abra o link. Está no ar. 🎉

---

## O dia a dia depois disso

Sempre que quiser atualizar (nova notícia, nova publicação, correção):

1. Edite os arquivos e confira com `quarto::quarto_preview()`.
2. **Salve** o trabalho no histórico. No Console:
   ```r
   # substitui a aba Git; envia as mudanças ao GitHub
   gert::git_add(".")
   gert::git_commit("Descreva a mudança aqui")
   gert::git_push()
   ```
   (Ou use os botões da aba **Git**: marque os arquivos, *Commit*, escreva a
   mensagem, *Push*.)
3. Republique o site:
   ```bash
   quarto publish gh-pages
   ```

O passo 2 guarda o histórico; o passo 3 atualiza o site público.

---

## Quando você comprar o domínio na Hostinger

O site já estará funcionando no endereço `github.io`. Para usar seu domínio
próprio, serão só três ajustes (peça os valores exatos de DNS quando tiver o
nome do domínio):

1. **No painel da Hostinger** (zona de DNS do domínio), aponte os registros
   para os servidores do GitHub Pages.
2. **No projeto**, crie um arquivo chamado `CNAME` (sem extensão) na raiz,
   contendo só o seu domínio, por exemplo:
   ```
   epi-democracia.com.br
   ```
   Adicione também `site-url` no `_quarto.yml` com o mesmo endereço.
3. Rode `quarto publish gh-pages` de novo. O HTTPS é ativado sozinho em
   alguns minutos.

---

## Problemas comuns

- **"Permission denied" ao publicar** → o token do Passo 3 não foi salvo;
  refaça `gitcreds::set_github_pat()`.
- **O site abre sem estilo/menu** → você publicou uma página solta, não o
  projeto. Confira que abriu a pasta com `_quarto.yml` (Passo 1).
- **Mudança não aparece no site** → faltou rodar `quarto publish gh-pages`
  depois de editar, ou o navegador está em cache (Ctrl+Shift+R).
- **Página 404 logo após a primeira publicação** → normal nos primeiros
  minutos; o GitHub ainda está processando. Aguarde e recarregue.
