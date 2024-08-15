---
id: 816
title: 'Despliegue de una aplicación web Python en Docker con NGINX como proxy inverso y balanceador de carga'
date: '2023-03-06T01:15:18+01:00'
author: Arturo
layout: post
guid: 'https://aprenderdevops.com/?p=816'
permalink: /despliegue-de-una-aplicacion-web-python-en-docker-con-nginx-como-proxy-inverso-y-balanceador-de-carga/
image: /wp-content/uploads/2023/03/python-docker-nginx-1.png
categories:
    - Contenedores
tags:
    - docker
    - flask
    - nginx
    - python
    - uwsgi
---

En una entrada anterior vimos cómo [desplegar una aplicación web Python en Docker](https://aprenderdevops.com/despliegue-de-una-aplicacion-web-python-en-docker/). En esta ocasión vamos a desplegar la misma aplicación, con una modificación mínima, pero por delante levantaremos un contenedor con [NGINX](https://www.nginx.com/) que hará de proxy inverso y balanceador de carga.

Un proxy inverso es un servidor que actúa como intermediario entre los clientes y los servidores web, y que se utiliza para proteger y optimizar el acceso a los servidores.

Cuando un cliente se conecta a un servidor a través de un proxy inverso, la petición del cliente se enruta primero al proxy inverso, que la reenvía al servidor de destino correspondiente. De esta manera, el proxy inverso puede realizar funciones de filtrado, balanceo de carga, caché, encriptación y autenticación de manera transparente para el cliente y el servidor.

Un balanceador de carga es un componente que distribuye el tráfico entrante entre varios servidores con el objetivo de mejorar el rendimiento, la disponibilidad y la escalabilidad de los sistemas y las aplicaciones.

En lugar de tener un solo servidor que maneje todas las peticiones, un balanceador de carga reparte la carga de trabajo entre varios servidores, de modo que cada uno de ellos procesa una parte del tráfico y se evita la sobrecarga de un solo servidor. Además, si uno de los servidores falla, el balanceador de carga puede redirigir las peticiones a otro servidor disponible, lo que aumenta la disponibilidad y la tolerancia a fallos del sistema.

En este laboratorio levantaremos un contenedor con la [imagen oficial de NGINX](https://hub.docker.com/_/nginx) que balanceará el tráfico entre dos contenedores [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/).

<figure class="wp-block-image size-full">![](https://aprenderdevops.com/wp-content/uploads/2023/03/python-docker-nginx-2.png)</figure>## Aplicación web Python “Hola mundo”

Vamos a utilizar la misma aplicación web Python desarrollada con [Flask](http://flask.pocoo.org/) que utilizamos en la primera entrada, pero con una pequeña modificación que muestra desde que servidor uWSGI se está dando respuesta a la petición realizada desde el cliente.

### webapp.py

<div class="wp-block-syntaxhighlighter-code ">```

from flask import Flask
import socket

app = Flask(__name__)


@app.route("/")
def hello():
    return f"""
    
    <html>
    <head>
      <title>Hello, World!</title>
    </head>
    <body>
      <h1>Hello, World! This is {socket.gethostname()}.</h1>
    </body>
    </html>
    """


if __name__ == "__main__":
    app.run()
```

</div>## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio únicamente necesitáis tener un equipo con Docker instalado. Si no tenéis Docker instalado, podéis seguir las [instrucciones de instalación](https://docs.docker.com/install/) para vuestro sistema operativo en la web oficial de Docker.

También podéis hacer este laboratorio en [Killercoda](https://killercoda.com/aprenderdevops/scenario/docker-uwsgi-nginx).

## Construcción de nuestra imagen con uWSGI

Al igual que en la primera entrada, para poder ejecutar nuestra aplicación web Python necesitaremos un servidor de aplicaciones WSGI como uWSGI. Construiremos una imagen Docker que contendrá el servidor uWSGI y nuestra aplicación web Python.

### Dockerfile

<div class="wp-block-syntaxhighlighter-code ">```

FROM python:3.11.2
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

# Se crea un volumen con el contenido de la aplicacion
VOLUME /WebApp

# Se inicia uWSGI
ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
```

</div>### requirements.txt

<div class="wp-block-syntaxhighlighter-code ">```

Click==8.1.3
Flask==2.2.3
itsdangerous==2.1.2
Jinja2==3.1.2
MarkupSafe==2.1.2
Werkzeug==2.2.3
```

</div>El fichero requirements.txt contiene las librerías Python necesarias para ejecutar la aplicación. Este fichero se obtiene con el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ pip freeze > requirements.txt
```

</div>### uwsgi.ini

<div class="wp-block-syntaxhighlighter-code ">```

[uwsgi]
http = 0.0.0.0:$(UWSGI_HTTP_PORT)
module = $(UWSGI_APP):app
```

</div>El fichero uwsgi.ini contiene la configuración del servidor uWSGI.

## Utilización de Docker Compose

Para facilitar la construcción de la imagen con el servidor uWSGI que contiene nuestra aplicación, y para crear, arrancar, parar y eliminar los contenedores que vamos a utilizar en el despliegue de la misma, utilizaremos Docker Compose.

### docker-compose.yml

<div class="wp-block-syntaxhighlighter-code ">```

version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    hostname: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    ports:
      - 80:80
    restart: unless-stopped

  uwsgi-1:
    build: .
    image: aprenderdevops/uwsgi:latest
    container_name: uwsgi-1
    hostname: uwsgi-1
    volumes:
      - ./WebApp:/WebApp
    restart: unless-stopped

  uwsgi-2:
    image: aprenderdevops/uwsgi:latest
    container_name: uwsgi-2
    hostname: uwsgi-2
    volumes:
      - ./WebApp:/WebApp
    restart: unless-stopped
```

</div>A continuación, paso a explicar el código de este fichero docker-compose.yml:

- De las líneas 4 a la 12 se describe el servicio nginx.
- En la línea 5 se indica el repositorio y el tag de la imagen de NGINX que se va a utilizar.
- En las líneas 6 y 7 indicamos el nombre y el hostname del contenedor NGINX. En ambos casos es nginx.
- En la línea 9 se mapea el volumen que contendrá el fichero de configuración de NGINX (nginx.conf).
- En la línea 11 se mapea el puerto 80, que es el puerto en el que escuchará NGINX.
- En la línea 12 indicamos que el contenedor se reiniciará siempre, salvo que lo paremos.
- De las líneas 14 a la 21 se describe el servicio del primer servidor uWSGI.
- En la línea 15 se indica que el Dockerfile que define como se construirá la imagen del servidor uWSGI se encuentra en el directorio actual, es decir, en el mismo directorio en el que se encuentra el fichero docker-compose.yml.
- En la línea 16 se indica el repositorio y el tag de la imagen del servidor uWSGI.
- En las líneas 17 y 18 indicamos el nombre del contenedor y el hostname del primer servidor uWSGI. En ambos casos es uwsgi-1.
- En la línea 20 se mapea el volumen que contendrá nuestra aplicación web Python.
- En la línea 21 indicamos que el contenedor se reiniciará siempre, salvo que lo paremos.
- De las líneas 23 a la 29 se describe el servicio del segundo servidor uWSGI. La configuración es idéntica a la del primero a excepción del nombre del contenedor y del hostname, que en este caso es uwsgi-2. Tampoco hay configuración para la construcción de la imagen, ya que es la misma para ambos servidores uWSGI, por lo que sólo es necesario construirla una vez.

## Configuración de NGINX

Para que nuestro contenedor NGINX funcione como proxy inverso y balanceador de carga necesitamos pasarle el fichero de configuración nginx.conf.

### nginx.conf

<div class="wp-block-syntaxhighlighter-code ">```

user nginx;
worker_processes 1;

error_log /var/log/nginx/error.log warn;
pid       /var/run/nginx.pid;

events {
  worker_connections 1024;
}

http {
  sendfile    on;
  tcp_nopush  on;
  tcp_nodelay on;

  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host $server_name;

  upstream uwsgi {
    server uwsgi-1:8000;
    server uwsgi-2:8000;
  }

  server {
    listen 80;

    location / {
      proxy_pass     http://uwsgi;
      proxy_redirect off;
    }
  }
}
```

</div>A continuación, explico en detalle esta configuración:

- En la línea 1 se especifica el usuario bajo el cual se ejecutará el proceso de NGINX.
- En la línea 2 se especifica el número de procesos que se utilizarán para manejar las peticiones. En este caso, se utiliza sólo un proceso.
- En la línea 4 se establece la ubicación del fichero de log de errores de NGINX y el nivel de registro de errores que se registrarán en el fichero.
- En la línea 5 se especifica la ubicación del fichero de identificación de proceso (PID) de NGINX.
- De las líneas 7 a la 9 se definen las opciones de eventos de NGINX. En este caso, se establece el número máximo de conexiones que un worker puede manejar al mismo tiempo.
- De las líneas 12 a la 14 se incluyen las opciones de envío de ficheros (sendfile) para enviar ficheros estáticos, la desactivación de la agrupación de TCP (tcp\_nopush) y la desactivación de la demora de TCP (tcp\_nodelay) para mejorar la velocidad de transferencia de ficheros.
- De las líneas 16 a la 19 se establecen las cabeceras HTTP que se enviarán al servidor proxy. Estas cabeceras incluyen la dirección IP real del cliente (X-Real-IP), la dirección IP del cliente detrás del proxy (X-Forwarded-For), el nombre del servidor proxy (X-Forwarded-Host) y el nombre del host original (Host).
- De las líneas 21 a la 24 se define el grupo de servidores que se utilizarán como destino de las peticiones entrantes. En este caso, se especifican los dos contenedores uWSGI uwsgi-1 y uwsgi-2 en el puerto 8000.
- De las líneas 26 a la 33 se define el servidor virtual y la ubicación de las peticiones entrantes. En este caso, todas las peticiones entrantes se manejarán mediante el servidor virtual que escucha en el puerto 80. La ubicación de la petición se establece en la raíz (/), lo que significa que cualquier petición entrante se pasará al grupo de servidores definido en la sección upstream utilizando la directiva proxy\_pass. La directiva proxy\_redirect off desactiva la redirección automática de URLs en las respuestas del servidor proxy.

## Instrucciones

Para construir la imagen del servidor uWSGI, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose build
```

</div>Una vez construida la imagen del servidor uWSGI, ya podemos arrancar ambos servidores uWSGI y el servidor NGINX mediante el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose up -d
```

</div>Para verificar que todos los contenedores están arrancados, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose ps
NAME                IMAGE                         COMMAND                  SERVICE             CREATED             STATUS              PORTS
nginx               nginx:latest                  "/docker-entrypoint.…"   nginx               2 minutes ago       Up 2 minutes        0.0.0.0:80->80/tcp
uwsgi-1             aprenderdevops/uwsgi:latest   "uwsgi --ini /uwsgi.…"   uwsgi-1             2 minutes ago       Up 2 minutes
uwsgi-2             aprenderdevops/uwsgi:latest   "uwsgi --ini /uwsgi.…"   uwsgi-2             2 minutes ago       Up 2 minutes
```

</div>Para ver los logs, utilizamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose logs -f
```

</div>Por último, vamos a comprobar que todo está funcionando correctamente. Para ello, abrimos un navegador y accedemos a http://localhost. Esto nos deberá mostrar el mensaje «Hello, World! This is uwsgi-1.» o «Hello, World! This is uwsgi-2.».

Si refrescamos la petición en el navegador nos devolverá el mismo mensaje, pero si en la petición anterior la respuesta nos la había proporcionado el servidor uwsgi-1 en esta ocasión la respuesta nos la dará uwsgi-2, y viceversa. Esto verificará que el contenedor NGINX está balanceando correctamente las peticiones entre ambos contenedores uWSGI.

Podéis ver la ejecución de estas instrucciones en el siguiente vídeo:

<script async="" id="asciicast-zAT3BEouW0ZgSX285CmNPLUkp" src="https://asciinema.org/a/zAT3BEouW0ZgSX285CmNPLUkp.js"></script>## Código fuente del laboratorio

Tenéis el código fuente de este laboratorio en <https://github.com/aprenderdevops/docker-uwsgi-nginx>.

</body></html>