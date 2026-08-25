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
- Páginas `*.md` de nivel superior (`acerca-de.md`, `categorias.md`, `contacto.md`, `recursos.md`) — páginas estáticas con `layout: page`, con el mismo front matter migrado de WordPress que las entradas (`id`, `guid`).
- `assets/images/YYYY/MM/` — todas las imágenes de las entradas. El `YYYY/MM` es el mes en que la imagen se subió a la antigua biblioteca de medios de WordPress (no necesariamente el mes de publicación del post — por ejemplo, una imagen resubida más tarde queda bajo el mes de la resubida). Se conserva esa subestructura por fecha por coherencia con el histórico, pero el directorio en sí ya no se llama `wp-content/uploads` (nombre de WordPress sin ningún significado funcional en Jekyll: se renombró para dejar de arrastrar la nomenclatura de WordPress). Las imágenes de las entradas nuevas deben seguir esta misma convención `YYYY/MM/` y referenciarse con ruta relativa (`/assets/images/YYYY/MM/nombre.png`), tanto desde el campo `image:` del front matter como desde el cuerpo en Markdown (`![alt](/assets/images/YYYY/MM/nombre.png)`) — nunca con el dominio completo, para que las imágenes se sirvan igual en local (`bundle exec jekyll serve`) que en producción.
- `categorias.md` tiene codificada a mano la lista de categorías con sus descripciones y enlaces (`/category/<slug>/`) — al introducir una categoría genuinamente nueva hay que actualizar también esta página, no solo el front matter del post, además de `_data/categorias.yml` y `category/<slug>.md` (ver más abajo).

### Categorías existentes (usa una o varias de estas; no inventes categorías nuevas sin actualizar `categorias.md`, `_data/categorias.yml` y `category/`)

`Aseguramiento de la calidad`, `Cloud`, `Contenedores`, `GitOps`, `Infraestructura como código`, `Integración y entrega continua`, `Otros`.

Los slugs de categoría **no se derivan** del nombre (el filtro `slugify` de Liquid conserva las tildes salvo en modo `latin`, y ninguno de los dos modos da el slug real de `Integración y entrega continua`, que es `integracion-entrega-continua` — sin la «y» — por precedente histórico del sitio en WordPress). Los 7 slugs están fijados a mano en `_data/categorias.yml`, y de ahí los leen el menú, el pie de cada entrada y las páginas de archivo.

## Tema (Generate Pro portado a Jekyll)

El sitio recrea el tema Generate Pro con layouts e includes propios, sin plugins de Jekyll fuera de la lista permitida por GitHub Pages:

- `_layouts/default.html` — esqueleto común (site-container / header / nav / site-inner / footer); `home.html`, `post.html`, `page.html`, `category.html` y `tag.html` heredan de él.
- `_includes/` — `head.html`, `site-header.html`, `nav-primary.html`, `nav-secondary.html`, `entry.html` (tarjeta reutilizada por `home.html` y `category.html`), `entry-header.html`, `entry-footer.html`, `fecha.html` (formatea fechas en español, ya que Liquid no las localiza).
- `_data/menu.yml` y `_data/categorias.yml` — estructura del menú y mapeo nombre→slug→descripción de categorías.
- `category/<slug>.md` (×7) — páginas de archivo de categoría escritas a mano, con `category_name` en el front matter; `jekyll-archives` no está en la lista de plugins de GitHub Pages.
- `index.html` (en la raíz, no `.md`) — portada paginada vía `jekyll-paginate` (declarado en `plugins:` de `_config.yml`; `github-pages` no lo activa por sí solo). **No le pongas `permalink:` en el front matter**: al ser el propio fichero plantilla que `jekyll-paginate` clona para cada página siguiente, un permalink explícito se hereda en todas las páginas paginadas y todas acaban resolviendo a la misma URL.
- `assets/css/style.css` — el `style.css` de Generate Pro (GPL-2.0+) copiado tal cual, más un bloque de reglas propias al final del fichero: el fondo del body, el logo, `.full-width-content .content` (el único ajuste de anchura, pensado como mando para ampliar la columna de lectura más adelante), el recorte `aspect-ratio`/`object-fit` de las imágenes destacadas (no existen en el repo las variantes `-700x300` que WordPress generaba) y el icono de hamburguesa / flechas de submenú en CSS puro. El tema original apoya esos iconos en la fuente `dashicons` de WordPress, que no está en el repo — cualquier icono nuevo del tema debe evitarla igual.
- `assets/js/responsive-menu.js` — reescritura sin jQuery del menú responsive de Genesis.
- El body siempre lleva `class="custom-background custom-header header-image full-width-content"`: la clase `header-image` es la que convierte el título en el logo (crea la caja que aloja la imagen de fondo del `.site-title` y esconde el texto), no un detalle cosmético.
- No se migraron buscador, comentarios, widgets de sidebar (incluida la suscripción por correo), formulario de contacto ni iconos sociales — eran plugins de WordPress sin equivalente sencillo en Jekyll.
- Las etiquetas sí están enlazadas, a `/tag/<slug>/` — ver la sección siguiente.

## Páginas de etiqueta (tag/)

A diferencia de las categorías (una taxonomía fija de 7, con slugs fijados a mano en `_data/categorias.yml`), las etiquetas son libres y crecen con cada entrada nueva — hoy hay 25 distintas. Por eso no se mantienen a mano: `scripts/generar_tags.rb` las genera a partir de `_posts/*.md`.

- **`scripts/generar_tags.rb`** lee las `tags:` de todas las entradas y sincroniza el directorio `tag/`: crea un `tag/<slug>.md` (con `layout: tag`, `title` y `tag_name`) por cada etiqueta que no lo tenga, y borra los de etiquetas que ya no usa ninguna entrada. El slug lo calcula con `Jekyll::Utils.slugify(etiqueta, mode: 'latin')`. `_includes/entry-footer.html` enlaza cada etiqueta con el filtro Liquid equivalente, `{{ etiqueta | slugify: 'latin' }}` — al ser el mismo método por debajo, el slug que genera el script y el que enlaza la plantilla siempre coinciden sin necesidad de un mapeo a mano como el de categorías. `_layouts/tag.html` es el mismo patrón que `category.html`, indexando `site.tags[page.tag_name]` en vez de `site.categories[...]`.
- **Cuándo ejecutarlo:** después de añadir o editar los `tags:` de cualquier entrada, antes de hacer commit:

  ```bash
  bundle exec ruby scripts/generar_tags.rb
  ```

  Revisa el diff de `tag/` (páginas nuevas o borradas) y commitéalo junto con la entrada.

- **Hook de pre-commit (opcional, ver `hooks/pre-commit`):** automatiza el paso anterior. git no versiona `.git/hooks/`, así que el hook vive en el repo como un fichero más y cada clon debe activarlo una vez:

  ```bash
  git config core.hooksPath hooks
  ```

  A partir de ahí, cualquier commit que toque `_posts/` regenera `tag/` y añade los cambios al propio commit automáticamente. Es solo una comodidad local — si no está activado (por ejemplo, en un clon donde aún no se ha ejecutado ese comando), nada se rompe silenciosamente porque hay una verificación en CI que lo detecta.
- **Verificación en CI:** `.github/workflows/jekyll-gh-pages.yml` vuelve a ejecutar `scripts/generar_tags.rb` en cada push a `main`, antes de construir el sitio, y falla el despliegue si eso cambia algo en `tag/` — es decir, si el commit se hizo sin ejecutar el script (o sin el hook activado). El workflow nunca hace commit ni push de vuelta al repo: solo bloquea el despliegue con un mensaje indicando qué ejecutar en local. Por eso el job de `build` ahora también configura Ruby con `ruby/setup-ruby@v1` y usa `bundle exec` (reutilizando el `Gemfile` del repo, solo para este paso — el build real del sitio lo sigue haciendo `actions/jekyll-build-pages`, que no lo usa).

## Convenciones al añadir/editar entradas

- Las entradas nuevas van en `_posts/`, nombradas `YYYY-MM-DD-slug.md`, con `layout: post` y un `permalink: /slug/` explícito.
- Mantén el front matter entre comillas simples cuando el valor contenga tildes, dos puntos o espacios (sigue el estilo existente).
- La sintaxis de plantillas Liquid que aparezca literalmente en el cuerpo de un post (por ejemplo, fragmentos de código que muestren `{% raw %}{% ... %}{% endraw %}`) debe envolverse en `{% raw %}...{% endraw %}` para evitar que se rompa el build de Jekyll (ver el historial de commits como precedente).

## Convenciones de commit

Los commits de este repositorio se escriben en español, en tercera persona impersonal con "se" (p. ej. "Se añaden...", "Se corrige...", "Se actualiza..."), en presente, con la primera palabra en mayúscula y sin punto final. Ejemplos reales del historial:

- `Se añaden raw tags para evitar errores de procesamiento de Liquid`
- `Se corrige el post de instalación de GitLab con Ansible`
- `Crear jekyll-gh-pages.yml`

Sigue este mismo estilo (verbo reflexivo + qué cambia) en los mensajes de commit nuevos.
