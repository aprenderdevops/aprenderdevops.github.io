# CLAUDE.md

Este fichero proporciona guía a Claude Code (claude.ai/code) al trabajar con código en este repositorio.

## Qué es esto

El código fuente de [aprenderDevOps](https://aprenderdevops.com), un blog en español sobre DevOps (Docker, Ansible, Kubernetes, CI/CD, infraestructura como código, etc.), alojado en GitHub Pages. En este repositorio no hay herramientas de build locales (no hay `Gemfile`, ni `_layouts`/`_includes`/`_sass`, ni tema declarado en `_config.yml`) — el sitio depende por completo del entorno Jekyll/tema preinstalado de GitHub Pages a través del workflow de despliegue.

## Build / despliegue

No hay una instalación local de Jekyll que ejecutar o probar en este repo. La publicación ocurre exclusivamente mediante GitHub Actions:

- `.github/workflows/jekyll-gh-pages.yml` construye el sitio con `actions/jekyll-build-pages` y lo despliega con `actions/deploy-pages` en cada push a `main`.
- Hacer push a `main` **es** el despliegue. No hay rama de staging ni paso de previsualización — conviene verificar los cambios (front matter, permalinks, sintaxis Liquid) antes de hacer push.

Si necesitas comprobar que un post se renderiza correctamente antes de hacer push, la única forma es ejecutar Jekyll en local con las versiones que GitHub Pages preinstala (no hay `Gemfile.lock` fijado en este repo, así que hay que igualar las versiones actuales del gem `github-pages`/Jekyll) — no existe ningún script en el repo para esto.

## Estructura del contenido

- `_posts/*.md` — entradas del blog, con el patrón de nombre `YYYY-MM-DD-slug.md` (estándar de Jekyll). El contenido se migró desde un sitio WordPress anterior — el front matter aún conserva artefactos de WordPress (`id`, `guid` apuntando a `?p=`) junto a los campos de Jekyll que realmente importan:
  - `permalink: /slug/` — el slug real de la URL (no tiene por qué coincidir con el slug del nombre de fichero).
  - `image: /wp-content/uploads/YYYY/MM/nombre.png` — la imagen destacada del post, siempre bajo `wp-content/uploads/`.
  - `categories:` — una o varias de una taxonomía fija en español (ver más abajo). Las categorías de varias palabras van entre comillas YAML.
  - `tags:` — etiquetas libres, en minúscula, entrecomilladas si tienen varias palabras.
- Páginas `*.md` de nivel superior (`acerca-de.md`, `categorias.md`, `contacto.md`, `recursos.md`) — páginas estáticas con `layout: page`, con el mismo front matter migrado de WordPress que las entradas (`id`, `guid`).
- `wp-content/uploads/YYYY/MM/` — todas las imágenes de las entradas, reflejando la estructura original de la biblioteca de medios de WordPress. Las imágenes de las nuevas entradas deben seguir esta misma convención de ruta `YYYY/MM/` y referenciarse mediante el campo `image:` del front matter.
- `categorias.md` tiene codificada a mano la lista de categorías con sus descripciones y enlaces (`/category/<slug>/`) — al introducir una categoría genuinamente nueva hay que actualizar también esta página, no solo el front matter del post.

### Categorías existentes (usa una o varias de estas; no inventes categorías nuevas sin actualizar `categorias.md`)

`Aseguramiento de la calidad`, `Cloud`, `Contenedores`, `GitOps`, `Infraestructura como código`, `Integración y entrega continua`, `Otros`.

## Convenciones al añadir/editar entradas

- Las entradas nuevas van en `_posts/`, nombradas `YYYY-MM-DD-slug.md`, con `layout: post` y un `permalink: /slug/` explícito.
- Mantén el front matter entre comillas simples cuando el valor contenga tildes, dos puntos o espacios (sigue el estilo existente).
- Como en este repo no hay directorio `_layouts`, `layout: post` / `layout: page` se resuelven desde el tema por defecto de GitHub Pages — no añadas layouts personalizados sin añadir también un tema/`_layouts` propio, o el build se romperá.
- La sintaxis de plantillas Liquid que aparezca literalmente en el cuerpo de un post (por ejemplo, fragmentos de código que muestren `{% raw %}{% ... %}{% endraw %}`) debe envolverse en `{% raw %}...{% endraw %}` para evitar que se rompa el build de Jekyll (ver el historial de commits como precedente).

## Convenciones de commit

Los commits de este repositorio se escriben en español, en tercera persona impersonal con "se" (p. ej. "Se añaden...", "Se corrige...", "Se actualiza..."), en presente, con la primera palabra en mayúscula y sin punto final. Ejemplos reales del historial:

- `Se añaden raw tags para evitar errores de procesamiento de Liquid`
- `Se corrige el post de instalación de GitLab con Ansible`
- `Crear jekyll-gh-pages.yml`

Sigue este mismo estilo (verbo reflexivo + qué cambia) en los mensajes de commit nuevos.
