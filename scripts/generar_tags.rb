#!/usr/bin/env ruby
# frozen_string_literal: true

# Genera las páginas de archivo de etiqueta (tag/<slug>.md) a partir de las
# etiquetas usadas en _posts/*.md. Sincroniza el directorio tag/ con el
# estado actual de las entradas: crea las páginas que faltan y borra las de
# etiquetas que ya no usa ninguna entrada.
#
# El slug de cada etiqueta se calcula con Jekyll::Utils.slugify(mode: 'latin'),
# el mismo método que usa el filtro Liquid `slugify: 'latin'` que
# _includes/entry-footer.html usa para enlazar cada etiqueta — así el slug
# que genera este script y el que calcula la plantilla en tiempo de build
# siempre coinciden, sin necesidad de mantener un mapeo a mano (a diferencia
# de _data/categorias.yml, que sí lo necesita por la excepción de
# "integracion-entrega-continua"; las etiquetas no tienen ninguna excepción
# de ese tipo).
#
# Uso:
#   bundle exec ruby scripts/generar_tags.rb
#
# Ver CLAUDE.md para el flujo completo (cuándo ejecutarlo, verificación en
# CI, hook de pre-commit).

require 'jekyll'
require 'yaml'
require 'fileutils'

REPO_ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(REPO_ROOT, '_posts')
TAGS_DIR = File.join(REPO_ROOT, 'tag')

def etiquetas_de(post_path)
  contenido = File.read(post_path)
  partes = contenido.split(/^---\s*$/, 3)
  return [] if partes.length < 3

  front_matter = YAML.safe_load(partes[1], permitted_classes: [Date, Time]) || {}
  Array(front_matter['tags'])
end

def yaml_comillas_simples(texto)
  "'#{texto.gsub("'", "''")}'"
end

etiquetas = Dir.glob(File.join(POSTS_DIR, '*.md')).flat_map { |f| etiquetas_de(f) }.uniq.sort

FileUtils.mkdir_p(TAGS_DIR)

esperados = etiquetas.to_h { |etiqueta| [Jekyll::Utils.slugify(etiqueta, mode: 'latin'), etiqueta] }

borradas = 0
Dir.glob(File.join(TAGS_DIR, '*.md')).each do |fichero|
  slug = File.basename(fichero, '.md')
  next if slug.match?(/-page\d+\z/) || esperados.key?(slug)

  File.delete(fichero)
  borradas += 1
  puts "Borrada tag/#{slug}.md (la etiqueta ya no se usa en ninguna entrada)"
end

creadas = 0
esperados.each do |slug, etiqueta|
  ruta = File.join(TAGS_DIR, "#{slug}.md")
  contenido = <<~MARKDOWN
    ---
    layout: tag
    title: #{yaml_comillas_simples(etiqueta)}
    tag_name: #{yaml_comillas_simples(etiqueta)}
    permalink: /tag/#{slug}/
    ---
  MARKDOWN

  next if File.exist?(ruta) && File.read(ruta) == contenido

  File.write(ruta, contenido)
  creadas += 1
  puts "Generada tag/#{slug}.md"
end

puts "#{esperados.size} etiquetas · #{creadas} páginas creadas o actualizadas · #{borradas} borradas"
