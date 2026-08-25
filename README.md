# aprenderDevOps

Código fuente de [aprenderDevOps](https://aprenderdevops.com), blog en español sobre DevOps (Docker, Ansible, Kubernetes, CI/CD, infraestructura como código...), construido con Jekyll y alojado en GitHub Pages.

El sitio trae tema propio: recrea a mano en Jekyll el aspecto de **Generate Pro** (StudioPress/Genesis Framework, GPL-2.0+), sin `_sass` ni build de CSS.

## Desarrollo local

```bash
bundle install
bundle exec jekyll serve --livereload
```

Abre `http://localhost:4000`.

## Despliegue

Automático vía GitHub Actions (`.github/workflows/jekyll-gh-pages.yml`) en cada push a `main`. No hay entorno de staging: conviene previsualizar en local antes de hacer push.

## Scripts

Tras añadir, editar o borrar una entrada, regenera las páginas de archivo derivadas antes de commitear:

```bash
bundle exec ruby scripts/generar_tags.rb
bundle exec ruby scripts/generar_autores.rb
bundle exec ruby scripts/generar_paginas_archivo.rb
```

Hay un hook de pre-commit que lo automatiza (`git config core.hooksPath hooks`), y CI lo verifica igualmente.
