// Publicações — realces por tipo e limpeza de links vazios.
// O Quarto renderiza cada card como .quarto-post com .listing-category
// contendo o texto do tipo ("Artigo", "Livro", "Capítulo", "Trabalho").
// Lemos esse texto para pintar a borda-guia e marcamos o card com um
// atributo data-tipo, evitando depender de :has() no CSS.

(function () {
  const CORES = {
    "Artigo":   "#1d5b78", // azul-médio
    "Livro":    "#12303f", // azul-profundo
    "Capítulo": "#3a8fb7", // azul-claro
    "Trabalho": "#2f7d5b", // verde
  };

  function aplicar() {
    const cards = document.querySelectorAll("#listing-pubs .quarto-post, #listing-pubs .card");
    cards.forEach((card) => {
      // tipo = primeira categoria não numérica
      let tipo = null;
      card.querySelectorAll(".listing-category").forEach((c) => {
        const t = c.textContent.trim();
        if (!/^\d{4}$/.test(t) && CORES[t] && !tipo) tipo = t;
      });
      if (tipo) {
        card.style.setProperty("border-left-color", CORES[tipo], "important");
        card.style.setProperty("border-left-width", "5px", "important");
        card.style.setProperty("border-left-style", "solid", "important");
        card.setAttribute("data-tipo", tipo);
      }

      // Sem página individual. O card é envolvido por <a class="quarto-grid-link">
      // (no grid) ou contém <a> internos (na lista), apontando para
      // /publicacoes/itens/<slug>.html. Extraímos <slug> e consultamos
      // window.PUB_LINKS (links.js). Com DOI/URL, o card vira clicável e ganha
      // um botão "Acessar"; sem link, a navegação é removida.
      const LINKS = window.PUB_LINKS || {};
      const wrapper = card.closest("a.quarto-grid-link");
      const ancoras = [];
      if (wrapper) ancoras.push(wrapper);
      card.querySelectorAll("a[href]").forEach((a) => ancoras.push(a));

      let slug = null;
      ancoras.forEach((a) => {
        const m = (a.getAttribute("href") || "").match(/\/itens\/([^\/]+)\.html$/);
        if (m && !slug) slug = m[1];
      });
      const ext = slug && LINKS[slug] ? LINKS[slug] : null;

      ancoras.forEach((a) => {
        const href = a.getAttribute("href") || "";
        if (/\/itens\/[^\/]+\.html$/.test(href)) {
          if (ext) {
            a.setAttribute("href", ext);
            a.setAttribute("target", "_blank");
            a.setAttribute("rel", "noopener");
          } else if (a === wrapper) {
            // desfaz o link-pai preservando o card
            const div = document.createElement("div");
            div.className = a.className;
            while (a.firstChild) div.appendChild(a.firstChild);
            a.replaceWith(div);
          } else {
            const span = document.createElement("span");
            span.className = a.className;
            span.innerHTML = a.innerHTML;
            a.replaceWith(span);
          }
        }
      });

      if (ext) {
        card.classList.add("com-link");
        const body = card.querySelector(".card-body, .body") || card;
        if (!body.querySelector(".pub-acessar")) {
          const link = document.createElement("a");
          link.className = "pub-acessar";
          link.href = ext;
          link.target = "_blank";
          link.rel = "noopener";
          link.textContent = "Acessar";
          body.appendChild(link);
        }
      } else {
        card.classList.add("sem-link");
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", aplicar);
  } else {
    aplicar();
  }
})();
