#!/usr/bin/env ruby
# frozen_string_literal: true

# Genera las páginas de paginación de los archivos de categoría, etiqueta y
# autor (category/<slug>-pageN.md, tag/<slug>-pageN.md,
# author/<slug>-pageN.md) a partir del número de entradas de cada
# categoría/etiqueta/autor en _posts/*.md y de `paginate` en _config.yml.
#
# La página 1 de cada archivo no la toca este script: la de cada categoría
# vive en category/<slug>.md (escrita a mano, con título y descripción — ver
# categorias.md), la de cada etiqueta en tag/<slug>.md (generada por
# generate_tags.rb) y la de cada autor en author/<slug>.md (generada por
# generate_authors.rb). Este script solo gestiona las páginas 2, 3... que no
# tienen contenido propio, sincronizando category/, tag/ y author/ con el
# estado actual de las entradas: crea las páginas que faltan y borra las que
# sobran (porque una entrada se borró, se le quitó la categoría/etiqueta/
# autor, o bajó el número de entradas por debajo de un múltiplo de
# `paginate`).
#
# El slug de cada etiqueta y de cada autor se calcula igual que en
# generate_tags.rb / generate_authors.rb (Jekyll::Utils.slugify, mode:
# 'latin'); el de cada categoría se lee de _data/categories.yml, la misma
# fuente que usa _layouts/category.html.
#
# Uso:
#   bundle exec ruby scripts/generate_archive_pages.rb
#
# Ver CLAUDE.md para el flujo completo (cuándo ejecutarlo, verificación en
# CI, hook de pre-commit).

require 'jekyll'
require 'yaml'
require 'fileutils'

REPO_ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(REPO_ROOT, '_posts')
CATEGORY_DIR = File.join(REPO_ROOT, 'category')
TAG_DIR = File.join(REPO_ROOT, 'tag')
AUTHOR_DIR = File.join(REPO_ROOT, 'author')
CATEGORIAS_YAML = File.join(REPO_ROOT, '_data', 'categories.yml')
CONFIG_YAML = File.join(REPO_ROOT, '_config.yml')

def front_matter_de(post_path)
  contenido = File.read(post_path)
  partes = contenido.split(/^---\s*$/, 3)
  return {} if partes.length < 3

  YAML.safe_load(partes[1], permitted_classes: [Date, Time]) || {}
end

def yaml_comillas_simples(texto)
  "'#{texto.gsub("'", "''")}'"
end

def total_paginas(total_entradas, por_pagina)
  return 0 if total_entradas.zero?

  (total_entradas + por_pagina - 1) / por_pagina
end

# Sincroniza las páginas 2..N de un directorio (category/ o tag/) con
# `paginas_por_slug` ({ slug => nº de páginas totales }): borra cualquier
# fichero "<slug>-pageN.md" cuyo slug no esté en el mapa o cuyo N supere el
# número de páginas de ese slug, y crea/actualiza el resto usando
# `contenido_pagina.call(slug, numero)`.
def sincronizar_paginas(directorio, paginas_por_slug, contenido_pagina)
  creadas = 0
  borradas = 0

  Dir.glob(File.join(directorio, '*-page*.md')).each do |fichero|
    base = File.basename(fichero, '.md')
    slug, numero = base.match(/\A(.+)-page(\d+)\z/)&.captures
    next unless slug

    numero = numero.to_i
    next if numero.between?(2, paginas_por_slug.fetch(slug, 0))

    File.delete(fichero)
    borradas += 1
    puts "Borrada #{fichero.sub("#{REPO_ROOT}/", '')} (ya no hace falta)"
  end

  paginas_por_slug.each do |slug, paginas|
    (2..paginas).each do |numero|
      ruta = File.join(directorio, "#{slug}-page#{numero}.md")
      contenido = contenido_pagina.call(slug, numero)
      next if File.exist?(ruta) && File.read(ruta) == contenido

      File.write(ruta, contenido)
      creadas += 1
      puts "Generada #{ruta.sub("#{REPO_ROOT}/", '')}"
    end
  end

  [creadas, borradas]
end

config = YAML.safe_load(File.read(CONFIG_YAML))
por_pagina = config.fetch('paginate')

posts = Dir.glob(File.join(POSTS_DIR, '*.md')).map { |f| front_matter_de(f) }

conteo_categorias = Hash.new(0)
conteo_tags = Hash.new(0)
conteo_autores = Hash.new(0)
posts.each do |post|
  Array(post['categories']).each { |categoria| conteo_categorias[categoria] += 1 }
  Array(post['tags']).each { |tag| conteo_tags[tag] += 1 }
  conteo_autores[post['author']] += 1 if post['author']
end

categorias_yaml = YAML.safe_load(File.read(CATEGORIAS_YAML))
slug_de_categoria = categorias_yaml.to_h { |c| [c['nombre'], c['slug']] }
nombre_de_slug_categoria = categorias_yaml.to_h { |c| [c['slug'], c['nombre']] }

conteo_categorias.each_key do |categoria|
  next if slug_de_categoria.key?(categoria)

  warn "aviso: la categoría #{categoria.inspect} no está en _data/categories.yml, se omite su paginación"
end

# Todas las categorías conocidas, no solo las usadas: así una categoría que
# se quede sin entradas también ve borradas sus páginas de paginación.
paginas_por_categoria = slug_de_categoria.to_h do |nombre, slug|
  [slug, total_paginas(conteo_categorias.fetch(nombre, 0), por_pagina)]
end

nombre_de_slug_tag = conteo_tags.keys.to_h { |tag| [Jekyll::Utils.slugify(tag, mode: 'latin'), tag] }
# Incluye también los slugs de páginas de paginación ya existentes en disco,
# por si una etiqueta dejó de usarse del todo: sus páginas deben borrarse
# aunque ya no aparezca en conteo_tags.
Dir.glob(File.join(TAG_DIR, '*-page*.md')).each do |fichero|
  slug = File.basename(fichero, '.md')[/\A(.+)-page\d+\z/, 1]
  nombre_de_slug_tag[slug] ||= nil
end

paginas_por_tag = nombre_de_slug_tag.to_h do |slug, tag|
  total = tag ? conteo_tags.fetch(tag, 0) : 0
  [slug, total_paginas(total, por_pagina)]
end

nombre_de_slug_autor = conteo_autores.keys.to_h { |autor| [Jekyll::Utils.slugify(autor, mode: 'latin'), autor] }
# Igual que con las etiquetas: incluye también los slugs de páginas de
# paginación ya existentes en disco, por si un autor dejó de firmar entradas.
Dir.glob(File.join(AUTHOR_DIR, '*-page*.md')).each do |fichero|
  slug = File.basename(fichero, '.md')[/\A(.+)-page\d+\z/, 1]
  nombre_de_slug_autor[slug] ||= nil
end

paginas_por_autor = nombre_de_slug_autor.to_h do |slug, autor|
  total = autor ? conteo_autores.fetch(autor, 0) : 0
  [slug, total_paginas(total, por_pagina)]
end

creadas_categorias, borradas_categorias = sincronizar_paginas(
  CATEGORY_DIR, paginas_por_categoria, lambda { |slug, numero|
    categoria = nombre_de_slug_categoria.fetch(slug)
    <<~MARKDOWN
      ---
      layout: category
      title: #{yaml_comillas_simples("#{categoria} (página #{numero})")}
      category_name: #{yaml_comillas_simples(categoria)}
      pagina: #{numero}
      permalink: /category/#{slug}/page/#{numero}/
      ---
    MARKDOWN
  }
)

creadas_tags, borradas_tags = sincronizar_paginas(
  TAG_DIR, paginas_por_tag, lambda { |slug, numero|
    tag = nombre_de_slug_tag.fetch(slug)
    <<~MARKDOWN
      ---
      layout: tag
      title: #{yaml_comillas_simples("#{tag} (página #{numero})")}
      tag_name: #{yaml_comillas_simples(tag)}
      pagina: #{numero}
      permalink: /tag/#{slug}/page/#{numero}/
      ---
    MARKDOWN
  }
)

creadas_autores, borradas_autores = sincronizar_paginas(
  AUTHOR_DIR, paginas_por_autor, lambda { |slug, numero|
    autor = nombre_de_slug_autor.fetch(slug)
    <<~MARKDOWN
      ---
      layout: author
      title: #{yaml_comillas_simples("#{autor} (página #{numero})")}
      author_name: #{yaml_comillas_simples(autor)}
      pagina: #{numero}
      permalink: /author/#{slug}/page/#{numero}/
      ---
    MARKDOWN
  }
)

creadas_total = creadas_categorias + creadas_tags + creadas_autores
borradas_total = borradas_categorias + borradas_tags + borradas_autores
puts "#{creadas_total} páginas de paginación creadas o actualizadas · #{borradas_total} borradas"
