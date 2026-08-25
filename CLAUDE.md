# CLAUDE.md

Este fichero proporciona guía a Claude Code (claude.ai/code) al trabajar con código en este repositorio.

## Qué es esto

El código fuente de [aprenderDevOps](https://aprenderdevops.com), un blog en español sobre DevOps (Docker, Ansible, Kubernetes, CI/CD, infraestructura como código, etc.), alojado en GitHub Pages. El repositorio trae tema propio: `_layouts`/`_includes`/`_data` recrean en Jekyll el aspecto de **Generate Pro** (tema de StudioPress sobre Genesis Framework, GPL-2.0+) que usaba el sitio en su día como WordPress, portado a mano — no hay `_sass` ni build de CSS, `assets/css/style.css` es el `style.css` original del tema más un puñado de reglas propias al final del fichero. El `Gemfile` del repo es solo para previsualizar en local; el despliegue real no lo usa (ver más abajo).

## Build / despliegue

La publicación ocurre exclusivamente mediante GitHub Actions:

- `.github/workflows/jekyll-gh-pages.yml` construye el sitio con `actions/jekyll-build-pages` y lo despliega con `actions/deploy-pages` en cada push a `main`. Esta acción trae su propio entorno `github-pages` preinstalado — **no usa el `Gemfile` del repo ni Bundler**.
- Hacer push a `main` **es** el despliegue. No hay rama de staging ni paso de previsualización — conviene verificar los cambios (front matter, permalinks, sintaxis Liquid) antes de hacer push.

Para comprobar que un post se renderiza correctamente antes de hacer push, usa el `Gemfile` del repo (fija el gem `github-pages`, igualando la versión de Jekyll y plugins que usa GitHub Pages en producción):

```bash
bundle install
bundle exec jekyll serve --livereload
```

y abre `http://localhost:4000`. Revisa de vez en cuando que `Gemfile.lock` siga igualando la versión de `github-pages` que usa producción (`bundle update github-pages`), ya que GitHub Pages actualiza esa versión de forma independiente a este repo.

## Estructura del contenido

- `_posts/*.md` — entradas del blog, con el patrón de nombre `YYYY-MM-DD-slug.md` (estándar de Jekyll). El contenido se migró desde un sitio WordPress anterior — el front matter aún conserva artefactos de WordPress (`id`, `guid` apuntando a `?p=`) junto a los campos de Jekyll que realmente importan:
  - `permalink: /slug/` — el slug real de la URL (no tiene por qué coincidir con el slug del nombre de fichero).
  - `image: /assets/images/YYYY/MM/nombre.png` — la imagen destacada del post, con ruta relativa (nunca `https://aprenderdevops.com/...`).
  - `categories:` — una o varias de una taxonomía fija en español (ver más abajo). Las categorías de varias palabras van entre comillas YAML.
  - `tags:` — etiquetas libres, en minúscula, entrecomilladas si tienen varias palabras.
  - `author:` — nombre del autor, texto libre (hoy siempre `Arturo`); enlaza a `/author/<slug>/` (ver «Páginas de autor» más abajo).
- Páginas `*.md` de nivel superior (`acerca-de.md`, `categorias.md`, `contacto.md`, `recursos.md`) — páginas estáticas con `layout: page`, con el mismo front matter migrado de WordPress que las entradas (`id`, `guid`).
- `assets/images/YYYY/MM/` — todas las imágenes de las entradas. El `YYYY/MM` es el mes en que la imagen se subió a la antigua biblioteca de medios de WordPress (no necesariamente el mes de publicación del post — por ejemplo, una imagen resubida más tarde queda bajo el mes de la resubida). Se conserva esa subestructura por fecha por coherencia con el histórico, pero el directorio en sí ya no se llama `wp-content/uploads` (nombre de WordPress sin ningún significado funcional en Jekyll: se renombró para dejar de arrastrar la nomenclatura de WordPress). Las imágenes de las entradas nuevas deben seguir esta misma convención `YYYY/MM/` y referenciarse con ruta relativa (`/assets/images/YYYY/MM/nombre.png`), tanto desde el campo `image:` del front matter como desde el cuerpo en Markdown (`![alt](/assets/images/YYYY/MM/nombre.png)`) — nunca con el dominio completo, para que las imágenes se sirvan igual en local (`bundle exec jekyll serve`) que en producción.
- `categorias.md` tiene codificada a mano la lista de categorías con sus descripciones y enlaces (`/category/<slug>/`) — al introducir una categoría genuinamente nueva hay que actualizar también esta página, no solo el front matter del post, además de `_data/categorias.yml` y `category/<slug>.md` (ver más abajo).

### Categorías existentes (usa una o varias de estas; no inventes categorías nuevas sin actualizar `categorias.md`, `_data/categorias.yml` y `category/`)

`Aseguramiento de la calidad`, `Cloud`, `Contenedores`, `GitOps`, `Infraestructura como código`, `Integración y entrega continua`, `Otros`.

Los slugs de categoría **no se derivan** del nombre (el filtro `slugify` de Liquid conserva las tildes salvo en modo `latin`, y ninguno de los dos modos da el slug real de `Integración y entrega continua`, que es `integracion-entrega-continua` — sin la «y» — por precedente histórico del sitio en WordPress). Los 7 slugs están fijados a mano en `_data/categorias.yml`, y de ahí los leen el menú, el pie de cada entrada y las páginas de archivo.

## Tema (Generate Pro portado a Jekyll)

El sitio recrea el tema Generate Pro con layouts e includes propios, sin plugins de Jekyll fuera de la lista permitida por GitHub Pages:

- `_layouts/default.html` — esqueleto común (site-container / header / nav / site-inner / footer); `home.html`, `post.html`, `page.html`, `category.html`, `tag.html` y `author.html` heredan de él.
- `_includes/` — `head.html`, `site-header.html`, `nav-primary.html`, `nav-secondary.html`, `entry.html` (tarjeta reutilizada por `home.html`, `category.html`, `tag.html` y `author.html`), `entry-header.html` (incluye el enlace del autor a `/author/<slug>/`), `entry-footer.html`, `fecha.html` (formatea fechas en español, ya que Liquid no las localiza), `archivo-paginacion.html` (paginación compartida por categoría/etiqueta/autor).
- `_data/menu.yml` y `_data/categorias.yml` — estructura del menú y mapeo nombre→slug→descripción de categorías.
- `category/<slug>.md` (×7) — página 1 de cada archivo de categoría, escrita a mano, con `category_name` en el front matter; `jekyll-archives` no está en la lista de plugins de GitHub Pages. Las páginas 2, 3... de cada categoría (cuando hay más entradas que `paginate`) se generan aparte — ver «Paginación de los archivos de categoría, etiqueta y autor» más abajo.
- `index.html` (en la raíz, no `.md`) — portada paginada vía `jekyll-paginate` (declarado en `plugins:` de `_config.yml`; `github-pages` no lo activa por sí solo). **No le pongas `permalink:` en el front matter**: al ser el propio fichero plantilla que `jekyll-paginate` clona para cada página siguiente, un permalink explícito se hereda en todas las páginas paginadas y todas acaban resolviendo a la misma URL.
- `assets/css/style.css` — el `style.css` de Generate Pro (GPL-2.0+) copiado tal cual, más un bloque de reglas propias al final del fichero: el fondo del body, el logo, el ancho compartido de cabecera y contenido (`.full-width-content .content` y `.site-header .wrap`/`.nav-primary .wrap`, ambos a 900px), el recorte `aspect-ratio`/`object-fit` de las imágenes destacadas (no existen en el repo las variantes `-700x300` que WordPress generaba), el centrado de esa misma imagen (`.entry-content .entry-image`, que pisa el `margin` de sangrado a la izquierda del tema original, pensado para un layout con texto envolvente que este port no usa) y el icono de hamburguesa / flechas de submenú en CSS puro. El tema original apoya esos iconos en la fuente `dashicons` de WordPress, que no está en el repo — cualquier icono nuevo del tema debe evitarla igual.
- `assets/js/responsive-menu.js` — reescritura sin jQuery del menú responsive de Genesis.
- El body siempre lleva `class="custom-background custom-header header-image full-width-content"`: la clase `header-image` es la que convierte el título en el logo (crea la caja que aloja la imagen de fondo del `.site-title` y esconde el texto), no un detalle cosmético.
- No se migraron buscador, comentarios, widgets de sidebar (incluida la suscripción por correo), formulario de contacto ni iconos sociales — eran plugins de WordPress sin equivalente sencillo en Jekyll.
- Las etiquetas y el autor sí están enlazados, a `/tag/<slug>/` y `/author/<slug>/` respectivamente (a diferencia del WordPress original, donde el autor no enlazaba a ningún archivo) — ver las dos secciones siguientes.

## Páginas de etiqueta (tag/)

A diferencia de las categorías (una taxonomía fija de 7, con slugs fijados a mano en `_data/categorias.yml`), las etiquetas son libres y crecen con cada entrada nueva — hoy hay 25 distintas. Por eso no se mantienen a mano: `scripts/generar_tags.rb` las genera a partir de `_posts/*.md`.

- **`scripts/generar_tags.rb`** lee las `tags:` de todas las entradas y sincroniza el directorio `tag/`: crea un `tag/<slug>.md` (con `layout: tag`, `title` y `tag_name`) por cada etiqueta que no lo tenga, y borra los de etiquetas que ya no usa ninguna entrada. El slug lo calcula con `Jekyll::Utils.slugify(etiqueta, mode: 'latin')`. `_includes/entry-footer.html` enlaza cada etiqueta con el filtro Liquid equivalente, `{{ etiqueta | slugify: 'latin' }}` — al ser el mismo método por debajo, el slug que genera el script y el que enlaza la plantilla siempre coinciden sin necesidad de un mapeo a mano como el de categorías. `_layouts/tag.html` es el mismo patrón que `category.html`, indexando `site.tags[page.tag_name]` en vez de `site.categories[...]`.

## Páginas de autor (author/)

A diferencia de WordPress (donde el nombre del autor bajo cada entrada no enlaza a ningún archivo en este sitio), aquí el autor sí tiene una página de archivo, con el mismo enfoque que las etiquetas: `author:` en el front matter de cada entrada es texto libre (hoy solo hay un autor, `Arturo`, pero nada impide añadir más en el futuro), así que tampoco se mantiene a mano.

- **`scripts/generar_autores.rb`** lee el `author:` de todas las entradas y sincroniza el directorio `author/`: crea un `author/<slug>.md` (con `layout: author`, `title` y `author_name`) por cada autor que no lo tenga, y borra los de autores que ya no firman ninguna entrada. El slug lo calcula con `Jekyll::Utils.slugify(autor, mode: 'latin')` — igual que las etiquetas, lo que además de resolver acentos garantiza minúsculas (`Arturo` → `arturo`). `_includes/entry-header.html` enlaza el nombre del autor con el filtro Liquid equivalente, `{{ post.author | slugify: 'latin' }}`. `_layouts/author.html` sigue el mismo patrón que `category.html`/`tag.html`, pero filtrando `site.posts` con `where: "author", page.author_name` en vez de indexar `site.categories[...]`/`site.tags[...]`, porque Jekyll no expone un `site.authors` para campos de front matter arbitrarios (solo lo hace para `categories`/`tags`).

## Paginación de los archivos de categoría, etiqueta y autor

`jekyll-paginate` (el único plugin de paginación permitido por GitHub Pages) solo sabe paginar la portada (`index.html`, sobre `site.posts`); no tiene forma de paginar `site.categories[...]`, `site.tags[...]` ni una lista filtrada por autor por separado. Para que un archivo de categoría, etiqueta o autor con más de `paginate` entradas (3, ver `_config.yml`) no las muestre todas en una sola página, la paginación de `category/`, `tag/` y `author/` se resuelve a mano, con páginas físicas adicionales generadas por script:

- **`scripts/generar_paginas_archivo.rb`** cuenta las entradas de cada categoría, etiqueta y autor en `_posts/*.md` y sincroniza `category/<slug>-pageN.md`, `tag/<slug>-pageN.md` y `author/<slug>-pageN.md` (N = 2, 3...) con `permalink: /category/<slug>/page/N/`, `/tag/<slug>/page/N/` y `/author/<slug>/page/N/` respectivamente: crea las que faltan y borra las que sobran (entrada borrada, categoría/etiqueta/autor quitado de una entrada, o el total ya no llega a otro múltiplo de `paginate`). La página 1 de cada archivo no la toca este script — sigue siendo `category/<slug>.md` (escrita a mano), `tag/<slug>.md` (generada por `generar_tags.rb`) o `author/<slug>.md` (generada por `generar_autores.rb`).
- **`_layouts/category.html`, `_layouts/tag.html` y `_layouts/author.html`** trocean su lista de entradas (`site.categories[page.category_name]`, `site.tags[page.tag_name]` o `site.posts | where: "author", page.author_name`) con los filtros Liquid `slice`/`divided_by` según `page.pagina` (ausente = página 1) y `site.paginate`, sin necesitar el número total de páginas en el front matter. `_includes/archivo-paginacion.html` (mismo patrón visual que la paginación de `home.html`, misma clase CSS `archive-pagination pagination`) calcula los enlaces «anterior/siguiente» y el listado de páginas a partir de una `base` (`/category/<slug>`, `/tag/<slug>` o `/author/<slug>`, sin barra final) que cada layout calcula: para categoría, buscando el slug en `site.data.categorias`; para etiqueta y autor, con `slugify: 'latin'` sobre `page.tag_name`/`page.author_name`.
- **Cuándo ejecutarlo:** después de añadir, editar o borrar entradas (cambia el `tags:`/`categories:`/`author:` de cualquiera, o el número total de entradas de una categoría/etiqueta/autor), antes de hacer commit:

  ```bash
  bundle exec ruby scripts/generar_tags.rb
  bundle exec ruby scripts/generar_autores.rb
  bundle exec ruby scripts/generar_paginas_archivo.rb
  ```

  Revisa el diff de `tag/`, `author/` y `category/` (páginas nuevas o borradas) y commitéalo junto con la entrada.

- **Hook de pre-commit (opcional, ver `hooks/pre-commit`):** automatiza el paso anterior. git no versiona `.git/hooks/`, así que el hook vive en el repo como un fichero más y cada clon debe activarlo una vez:

  ```bash
  git config core.hooksPath hooks
  ```

  A partir de ahí, cualquier commit que toque `_posts/` regenera `tag/`, `author/` y las páginas de paginación de `category/`/`tag/`/`author/`, y añade los cambios al propio commit automáticamente. Es solo una comodidad local — si no está activado (por ejemplo, en un clon donde aún no se ha ejecutado ese comando), nada se rompe silenciosamente porque hay una verificación en CI que lo detecta.
- **Verificación en CI:** `.github/workflows/jekyll-gh-pages.yml` vuelve a ejecutar los tres scripts en cada push a `main`, antes de construir el sitio, y falla el despliegue si eso cambia algo en `tag/`, `author/` o `category/` — es decir, si el commit se hizo sin ejecutarlos (o sin el hook activado). El workflow nunca hace commit ni push de vuelta al repo: solo bloquea el despliegue con un mensaje indicando qué ejecutar en local. Por eso el job de `build` ahora también configura Ruby con `ruby/setup-ruby@v1` y usa `bundle exec` (reutilizando el `Gemfile` del repo, solo para este paso — el build real del sitio lo sigue haciendo `actions/jekyll-build-pages`, que no lo usa).

## Convenciones al añadir/editar entradas

- Las entradas nuevas van en `_posts/`, nombradas `YYYY-MM-DD-slug.md`, con `layout: post` y un `permalink: /slug/` explícito.
- Mantén el front matter entre comillas simples cuando el valor contenga tildes, dos puntos o espacios (sigue el estilo existente).
- La sintaxis de plantillas Liquid que aparezca literalmente en el cuerpo de un post (por ejemplo, fragmentos de código que muestren `{% raw %}{% ... %}{% endraw %}`) debe envolverse en `{% raw %}...{% endraw %}` para evitar que se rompa el build de Jekyll (ver el historial de commits como precedente).

## Convenciones de commit

Los commits de este repositorio se escriben en español, en tercera persona impersonal con "se" (p. ej. "Se añaden...", "Se corrige...", "Se actualiza..."), en presente, con la primera palabra en mayúscula y sin punto final. Son de una sola línea, sin cuerpo adicional. Ejemplos reales del historial:

- `Se añaden raw tags para evitar errores de procesamiento de Liquid`
- `Se corrige el post de instalación de GitLab con Ansible`
- `Crear jekyll-gh-pages.yml`

Sigue este mismo estilo (verbo reflexivo + qué cambia) en los mensajes de commit nuevos.
