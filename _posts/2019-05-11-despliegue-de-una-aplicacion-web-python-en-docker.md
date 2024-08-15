---
id: 419
title: 'Despliegue de una aplicación web Python en Docker'
date: '2019-05-11T00:30:23+02:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=419'
permalink: /despliegue-de-una-aplicacion-web-python-en-docker/
image: /wp-content/uploads/2019/04/python-docker.png
categories:
    - Contenedores
tags:
    - docker
    - flask
    - python
    - uwsgi
---

En esta entrada vamos a ver cómo desplegar una aplicación web desarrollada en Python, en este caso usando el framework Flask, dentro de un contenedor Docker con un servidor uWSGI.

## Aplicación web Python “Hola mundo”

La aplicación web Python que vamos a utilizar es extremadamente sencilla. Se trata de la típica aplicación “Hola mundo” que en este caso está desarrollada con [Flask](http://flask.pocoo.org/).

El funcionamiento sería exactamente el mismo si la aplicación fuera más compleja o en lugar de Flask se hubiera utilizado otro framework, como [Django](https://www.djangoproject.com/), para su desarrollo.

### webapp.py

<div class="wp-block-syntaxhighlighter-code ">```

from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    return "Hello World!"


if __name__ == "__main___":
    app.run()
```

</div>## ¿Qué es WSGI?

WSGI (Web Server Gateway Interface) es un protocolo para que los servidores web como Nginx, lighttpd o Cherokee envíen peticiones a aplicaciones web desarrolladas en Python.

Para poder ejecutar una aplicación WSGI lo primero que se necesita es un servidor WSGI. WSGI es tanto un protocolo como un servidor de aplicaciones. El servidor de aplicaciones puede servir a los protocolos WSGI, FastCGI y HTTP.

## El servidor uWSGI

Existen varios [servidores WSGI](http://flask.pocoo.org/docs/1.0/deploying/wsgi-standalone/#deploying-wsgi-standalone﻿) como Gunicorn, [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/), Gevento o Twisted Web. Para este laboratorio he optado por uWSGI.

uWSGI es un servidor de aplicaciones escrito en C, rápido y muy configurable.

## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio únicamente necesitáis tener un equipo con Docker instalado. Si no tenéis Docker instalado, podéis seguir las [instrucciones de instalación](https://docs.docker.com/install/) para vuestro sistema operativo en la web oficial de Docker.

## Construcción de nuestra imagen con uWSGI

Como ya hemos comentado, para poder ejecutar nuestra aplicación web Python necesitaremos un servidor de aplicaciones WSGI como uWSGI. Por lo tanto, lo que vamos a hacer es construir una imagen Docker que contenga el servidor uWSGI y ejecutar nuestra aplicación web Python en él.

### Dockerfile

<div class="wp-block-syntaxhighlighter-code ">```

FROM python:3.7.3
LABEL maintainer="Jose Arturo Fernandez <jarfernandez@aprenderdevops.com>"

# Se instala uWSGI y todas las librerias que necesita la aplicacion
COPY WebApp/requirements.txt requirements.txt
RUN pip install uwsgi && pip install -r requirements.txt

# Puerto HTTP por defecto para uWSGI
ARG UWSGI_HTTP_PORT=8000
ENV UWSGI_HTTP_PORT=$UWSGI_HTTP_PORT

# Aplicacion por defecto para uWSGI
ARG UWSGI_APP=webapp
ENV UWSGI_APP=$UWSGI_APP

# Se crea un usuario para arrancar uWSGI
RUN useradd -ms /bin/bash admin
USER admin

# Se copia el contenido de la aplicacion
COPY WebApp /WebApp

# Se copia el fichero con la configuración de uWSGI
COPY uwsgi.ini uwsgi.ini

# Se establece el directorio de trabajo
WORKDIR /WebApp

# Se crea un volume con el contenido de la aplicacion
VOLUME /WebApp

# Se inicia uWSGI
ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
```

</div>A continuación, explico las distintas líneas del Dockerfile:

- En la línea 1 se indica la imagen base de la que se parte para construir la nueva imagen. En este caso partimos de la imagen oficial de Python en su versión 3.7.3.
- En la línea 5 se copia el fichero requirements.txt que contiene las librerías Python necesarias para ejecutar la aplicación.
- En la línea 6 se instala el servidor uWSGI y las librerías incluidas en el fichero requirements.txt. Para la instalación se utiliza pip. pip es un sistema de gestión de paquetes utilizado para instalar y administrar paquetes software escritos en Python.
- En la línea 9 se define la variable UWSGI\_HTTP\_PORT. Esta variable puede ser modificada al hacer docker build con el flag –build-arg. Esta variable contendrá el puerto HTTP por defecto en el que escucha el servidor uWSGI.
- En la línea 10 se define la variable de entorno UWSGI\_HTTP\_PORT que será igual al valor de la variable definida en la línea 9.
- En las líneas 13 y 14 hacemos lo mismo que en las líneas 9 y 10, pero en este caso para la variable de entornos UWSGI\_APP. Esta variable contendrá el nombre del fichero Python en el que se declara la aplicación que ejecutará el servidor uWSGI.
- En la línea 17 se crea el usuario admin.
- En la línea 18 se cambia la ejecución del proceso uwsgi al usuario admin, ya que puede ejecutarse sin privilegios, lo que proporciona mayor seguridad.
- En la línea 21 se copia el contenido de la aplicación.
- En la línea 24 se copia el fichero de configuración del servidor uWSGI.
- En la línea 27 se establece el directorio de trabajo que será el directorio en el que se encuentra la aplicación (/WebApp).
- En la línea 30 se crea un volumen para compartir el contenido de la aplicación desde el host al contenedor. De esta forma, si se modifica el código fuente de la aplicación en el host, los cambios se harán efectivos también dentro del directorio WebApp del contenedor. Para que el servidor uWSGI los refleje será necesario reiniciar el contenedor con docker restart.
- En la línea 33 se inicia el servidor uWSGI. Se pasa como parámetro el fichero con la configuración que previamente se ha copiado en la línea 24.

### requirements.txt

<div class="wp-block-syntaxhighlighter-code ">```

Click==7.0
Flask==1.1.1
itsdangerous==1.1.0
Jinja2==2.10.1
MarkupSafe==1.1.1
Werkzeug==0.15.5
```

</div>El fichero requirements.txt contiene las librerías Python necesarias para ejecutar la aplicación. Este fichero se obtiene con el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ pip freeze > requirements.txt
```

</div>### uwsgi.ini

<div class="wp-block-syntaxhighlighter-code nums:true">```

[uwsgi]
http = 0.0.0.0:$(UWSGI_HTTP_PORT)
module = $(UWSGI_APP):app
```

</div>El fichero uwsgi.ini contiene la configuración del servidor uWSGI.

En la línea 2 se indica la dirección IP y el puerto en el que el servidor uWSGI escuchará peticiones HTTP. La dirección establecida a 0.0.0.0 hará que se escuche por todas las interfaces de red.

En el caso del puerto, se especifica que se obtenga el valor de la variable de entorno UWSGI\_HTTP\_PORT. Si esta variable no se establece en la ejecución del contenedor con el flag –env o -e se le asignará el valor por defecto (8000).

El valor por defecto del puerto se puede cambiar al construir la imagen con docker build especificando otro valor. Por ejemplo, si queremos que el valor por defecto del puerto para la imagen sea el 9000, ejecutaremos el siguiente comando para construir la imagen:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker build --build-arg UWSGI_HTTP_PORT=9000 -t aprenderdevops/uwsgi .
```

</div>Esta configuración se define en las líneas 9 y 10 del Dockerfile.

En la línea 3 se especifica el módulo a ejecutar por el servidor uWSGI. Se especifica que se obtenga el valor de la variable de entorno UWSGI\_APP. Si esta variable no se establece en la ejecución del contenedor con el flag –env o -e se le asignará el valor por defecto (webapp).

Al igual que en el caso del puerto, el valor por defecto del módulo se puede cambiar al construir la imagen con docker build especificando otro valor mediante el flag –build-arg. Esta configuración se define en las líneas 13 y 14 del Dockerfile.

La utilización de variables de entorno que se pasan al fichero de configuración del servidor uWSGI nos proporciona mucha flexibilidad a la hora de utilizar el contenedor, ya que se puede iniciar el servidor uWSGI en el puerto que deseemos, siempre que no esté ya ocupado, y lo que es más importante, se puede cambiar el nombre del fichero Python en el que se declara la aplicación que ejecutará el servidor uWSGI.

### Instrucciones

Para construir la imagen ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker build -t aprenderdevops/uwsgi .
```

</div>Para arrancar el contenedor ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker run -d -p 8080:8000 --restart unless-stopped -v $(pwd)/WebApp:/WebApp aprenderdevops/uwsgi
```

</div>Con el flag -p indicamos que se rediriga el puerto 8000 del contenedor (puerto por defecto en el que escucha el servidor uWSGI) al puerto 8080 de nuestra máquina. Si el puerto 8080 estuviera ocupado por otro proceso habría que cambiarlo por otro.

Una vez arrancado el contenedor, abrimos un navegador web y accedemos a http://localhost:8080. Nos debería abrir una página web con el texto “Hello World!”.

## Código fuente del laboratorio

Podéis descargar o clonar de GitHub el código fuente de este laboratorio de <https://github.com/aprenderdevops/docker-uwsgi>.