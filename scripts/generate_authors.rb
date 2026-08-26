#!/usr/bin/env ruby
# frozen_string_literal: true

# Genera las páginas de archivo de autor (author/<slug>.md) a partir del
# campo `author:` de _posts/*.md. Sincroniza el directorio author/ con el
# estado actual de las entradas: crea las páginas que faltan y borra las de
# autores que ya no firman ninguna entrada.
#
# El slug de cada autor se calcula con Jekyll::Utils.slugify(mode: 'latin'),
# el mismo método que usa scripts/generate_tags.rb para las etiquetas — así
# el nombre queda siempre en minúsculas y sin tildes (p. ej. "Arturo" ->
# "arturo"), y el slug que genera este script y el que enlaza
# _includes/entry-header.html (con el filtro Liquid `slugify: 'latin'')
# siempre coinciden, sin necesidad de un mapeo a mano.
#
# Uso:
#   bundle exec ruby scripts/generate_authors.rb
#
# Ver CLAUDE.md para el flujo completo (cuándo ejecutarlo, verificación en
# CI, hook de pre-commit).

require 'jekyll'
require 'yaml'
require 'fileutils'

REPO_ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(REPO_ROOT, '_posts')
AUTHORS_DIR = File.join(REPO_ROOT, 'author')

def front_matter_de(post_path)
  contenido = File.read(post_path)
  partes = contenido.split(/^---\s*$/, 3)
  return {} if partes.length < 3

  YAML.safe_load(partes[1], permitted_classes: [Date, Time]) || {}
end

def yaml_comillas_simples(texto)
  "'#{texto.gsub("'", "''")}'"
end

autores = Dir.glob(File.join(POSTS_DIR, '*.md')).filter_map { |f| front_matter_de(f)['author'] }.uniq.sort

FileUtils.mkdir_p(AUTHORS_DIR)

esperados = autores.to_h { |autor| [Jekyll::Utils.slugify(autor, mode: 'latin'), autor] }

borradas = 0
Dir.glob(File.join(AUTHORS_DIR, '*.md')).each do |fichero|
  slug = File.basename(fichero, '.md')
  next if slug.match?(/-page\d+\z/) || esperados.key?(slug)

  File.delete(fichero)
  borradas += 1
  puts "Borrada author/#{slug}.md (el autor ya no firma ninguna entrada)"
end

creadas = 0
esperados.each do |slug, autor|
  ruta = File.join(AUTHORS_DIR, "#{slug}.md")
  contenido = <<~MARKDOWN
    ---
    layout: author
    title: #{yaml_comillas_simples(autor)}
    author_name: #{yaml_comillas_simples(autor)}
    permalink: /author/#{slug}/
    ---
  MARKDOWN

  next if File.exist?(ruta) && File.read(ruta) == contenido

  File.write(ruta, contenido)
  creadas += 1
  puts "Generada author/#{slug}.md"
end

puts "#{esperados.size} autores · #{creadas} páginas creadas o actualizadas · #{borradas} borradas"
