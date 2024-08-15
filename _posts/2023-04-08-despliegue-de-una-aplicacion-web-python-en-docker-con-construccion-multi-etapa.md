---
id: 909
title: 'Despliegue de una aplicación web Python en Docker con construcción multi-etapa'
date: '2023-04-08T13:30:00+02:00'
author: Arturo
layout: post
guid: 'https://aprenderdevops.com/?p=909'
permalink: /despliegue-de-una-aplicacion-web-python-en-docker-con-construccion-multi-etapa/
image: /wp-content/uploads/2019/04/python-docker.png
categories:
    - Contenedores
tags:
    - docker
    - flask
    - python
    - uwsgi
---

En una entrada anterior vimos [cómo desplegar una aplicación web Python en Docker](https://aprenderdevops.com/despliegue-de-una-aplicacion-web-python-en-docker/) y posteriormente añadimos [NGINX como proxy inverso y balanceador de carga](https://aprenderdevops.com/despliegue-de-una-aplicacion-web-python-en-docker-con-nginx-como-proxy-inverso-y-balanceador-de-carga/).

En esta ocasión vamos a mejorar la construcción de la imagen Docker que utilizamos para desplegar la aplicación web Python, y lo haremos utilizando **construcción multi-etapa o multi-stage build.**

## Construcción multi-etapa de imágenes o multi-stage build

La construcción de imágenes en múltiples etapas o construcción multi-stage fue introducida por primera vez en la versión 17.05 de Docker, que se lanzó en mayo de 2017.

La construcción multi-stage consiste en utilizar múltiples etapas en la construcción de una imagen de contenedor. En cada etapa se puede utilizar una imagen base diferente, y se construye una imagen intermedia que contiene un conjunto específico de dependencias o configuraciones. Se pueden copiar selectivamente artefactos de una etapa a otra, dejando atrás todo lo que no se quiera incluir en la imagen final.

El resultado final de la construcción multi-stage es una imagen de contenedor que contiene sólo los componentes necesarios para que la aplicación se ejecute correctamente y no contiene los componentes innecesarios que se utilizaron durante el proceso de construcción.

### Beneficios de la construcción multi-etapa de imágenes o multi-stage build

Algunos de los beneficios de la construcción multi-etapa son:

- Tamaño reducido de la imagen: la construcción multi-stage permite reducir el tamaño final de la imagen de contenedor eliminando los componentes innecesarios utilizados durante el proceso de construcción. Esto puede ser especialmente importante en entornos de producción donde el tamaño de la imagen puede afectar a la velocidad de despliegue de la aplicación.
- Mayor seguridad: al utilizar múltiples etapas para construir una imagen de contenedor, se pueden aplicar diferentes medidas de seguridad en cada etapa, como la eliminación de credenciales de construcción o la reducción de la superficie de ataque.
- Mayor eficiencia: la construcción multi-stage permite la reutilización de capas de imágenes previamente construidas, lo que acelera significativamente el proceso de construcción.
- Mayor flexibilidad: la construcción multi-stage permite la creación de imágenes de contenedor que pueden ser fácilmente personalizadas para diferentes entornos y casos de uso.

## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio, sólo se requiere un equipo con Docker instalado. En caso de no tener Docker instalado, se pueden seguir las [instrucciones de instalación](https://docs.docker.com/install/) correspondientes a vuestro sistema en la web oficial de Docker.

También podéis hacer este laboratorio en [Killercoda](https://killercoda.com/aprenderdevops/scenario/docker-uwsgi-multi-stage).

## Construcción multi-etapa de nuestra imagen

Como ya vimos en la entrada [Despliegue de una aplicación web Python en Docker](https://aprenderdevops.com/despliegue-de-una-aplicacion-web-python-en-docker/), para poder ejecutar nuestra aplicación necesitaremos un servidor de aplicaciones WSGI como uWSGI. Por lo tanto, construiremos una imagen Docker que contenga dicho servidor y nuestra aplicación web Python.

### Dockerfile multi-stage

<div class="wp-block-syntaxhighlighter-code ">```

# Version de Python (solo mayor y menor)
ARG _PYTHON_VERSION=3.11

# Etapa build
FROM python:${_PYTHON_VERSION} AS build
LABEL maintainer="Jose Arturo Fernandez <jarfernandez@aprenderdevops.com>"

# Se instala uWSGI y todas las librerias que necesita la aplicacion
COPY WebApp/requirements.txt requirements.txt
RUN pip install uwsgi && pip install -r requirements.txt
 
# Etapa run
FROM python:${_PYTHON_VERSION}-slim AS run

# Es necesario volver a incluir en esta etapa esta variable
ARG _PYTHON_VERSION

# Puerto HTTP por defecto para uWSGI
ARG UWSGI_HTTP_PORT=8000
ENV UWSGI_HTTP_PORT=$UWSGI_HTTP_PORT

# Aplicacion por defecto para uWSGI
ARG UWSGI_APP=webapp
ENV UWSGI_APP=$UWSGI_APP

# Se instalan dependencias
RUN apt-get update && apt-get install -y libxml2

# Se crea un usuario para arrancar uWSGI
RUN useradd -ms /bin/bash admin
USER admin

# Se copia el contenido de la imagen builder
COPY --from=build /usr/local/lib/python${_PYTHON_VERSION}/site-packages /usr/local/lib/python${_PYTHON_VERSION}/site-packages
COPY --from=build /usr/local/bin/uwsgi /usr/local/bin/uwsgi

# Se copia el contenido de la aplicacion
COPY WebApp /WebApp

# Se copia el fichero con la configuración de uWSGI
COPY uwsgi.ini uwsgi.ini

# Se establece el directorio de trabajo
WORKDIR /WebApp

# Se crea un volumen con el contenido de la aplicacion
VOLUME /WebApp

# Se inicia uWSGI
ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
```

</div>### Instrucciones

Para construir la imagen ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker build -t aprenderdevops/uwsgi .
```

</div>Para arrancar el contenedor ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker run -d -p 8080:8000 --restart unless-stopped -v $(pwd)/WebApp:/WebApp aprenderdevops/uwsgi
```

</div>Una vez arrancado el contenedor, abrimos un navegador web y accedemos a http://localhost:8080. Nos mostrará una página web con el texto “Hello, World!”.

También podéis ver la ejecución de estas instrucciones en el siguiente vídeo:

<script async="" id="asciicast-Rrdgcey2rxoWg5bajYqnXHRC5" src="https://asciinema.org/a/Rrdgcey2rxoWg5bajYqnXHRC5.js"></script>## Código fuente del laboratorio

Podéis encontrar en GitHub el código fuente de este laboratorio en <https://github.com/aprenderdevops/docker-uwsgi>. **Los cambios del Dockerfile para que sea multi-stage están en la rama multi-stage, no en la master.**