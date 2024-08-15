---
id: 262
title: 'Instalación de SonarQube con Docker'
date: '2018-02-25T17:35:34+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=262'
permalink: /instalacion-de-sonarqube-con-docker/
image: /wp-content/uploads/2018/02/sonarqube-docker.png
categories:
    - 'Aseguramiento de la calidad'
    - Contenedores
    - 'Infraestructura como código'
tags:
    - 'análisis estático de código'
    - docker
    - sonarqube
---

Vamos a ver cómo instalar SonarQube utilizando contenedores Docker.

En esta ocasión nos centraremos únicamente en la instalación de SonarQube. En posteriores entradas veremos cómo integrar SonarQube con otras herramientas DevOps y cómo utilizarlo para analizar la calidad de los desarrollos.

## ¿Qué es SonarQube?

[SonarQube](https://www.sonarqube.org/) (conocido anteriormente como Sonar) es una herramienta open source para evaluar la calidad del código fuente. Utiliza herramientas de análisis estático de código fuente para obtener métricas de calidad del código.

Estas son algunas de las características de SonarQube que hacen que sea una de las soluciones de evaluación de calidad del software más utilizadas:

- Es open source aunque también se puede optar por ediciones comerciales que incluyen soporte dedicado.
- Analizadores de más de 20 lenguajes de programación entre los que se incluyen Java, JavaScript, Python, PHP, C/C++, C# o VB.NET.
- Es fácil de integrar dentro de la cadena de herramientas de DevOps. Esto incluye los sistemas de compilación como [Maven](https://maven.apache.org/), [Gradle](https://gradle.org/) o [Ant](http://ant.apache.org/) y los motores de integración continua como [Jenkins](https://jenkins.io/), [Bamboo](https://es.atlassian.com/software/bamboo), [Travis CI](https://travis-ci.org/) o [Visual Studio Team Foundation Server](https://www.visualstudio.com/es/tfs/).

## Requisitos de instalación de SonarQube

Los requisitos necesarios para poder instalar SonarQube se detallan en el siguiente enlace a la documentación de SonarQube: <https://docs.sonarqube.org/latest/requirements/requirements/>

De entre todos los requisitos detallados en la documentación cabe destacar lo siguiente:

- Es necesario tener instalado Java 11 (Oracle JRE 11 u OpenJDK 11).
- Se necesitan al menos 3 Gb de memoria.
- El espacio en disco necesario depende de la cantidad de código fuente a analizar.
- El almacenamiento debe tener un excelente rendimiento de lectura/escritura.
- Se necesita una base de datos para almacenar la configuración de SonarQube, así como otra información necesaria para el correcto funcionamiento de la solución. Las bases de datos soportadas son PostgreSQL, Microsoft SQL Server, Oracle y MySQL. En nuestro caso vamos a utilizar una base de datos PostgreSQL.

## ¿Qué necesitáis para hacer este laboratorio?

La utilización de contenedores Docker simplifica mucho la instalación de SonarQube. Únicamente se necesita contar con un equipo que tenga Docker instalado. Si no tenéis Docker instalado, podéis seguir las [instrucciones de instalación](https://docs.docker.com/install/) para vuestro sistema operativo en la web oficial de Docker.

A continuación, vamos a ver cómo instalar SonarQube utilizando contenedores Docker.

## ¿Qué imágenes Docker elegir?

Vamos a necesitar dos imágenes Docker: una para el servidor SonarQube y otra para la base de datos, en este caso PostgreSQL. Concretamente, las imágenes que vamos a utilizar son la imagen oficial de SonarQube ([sonarqube](https://hub.docker.com/_/sonarqube/)) y la imagen oficial de PostgreSQL ([postgres](https://hub.docker.com/_/postgres/)).

## Instalación de SonarQube utilizando docker-compose

Para facilitar la instalación de SonarQube en contenedores Docker vamos a utilizar el comando docker-compose.

A continuación, podéis ver el fichero docker-compose.yml que describe cómo se van a ejecutar los contenedores.

<div class="wp-block-syntaxhighlighter-code ">```

version: '2'

services:
  sonarqube:
    image: sonarqube
    ports:
      - "9000:9000"
    networks:
      - sonarnet
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONARQUBE_JDBC_USERNAME=sonar
      - SONARQUBE_JDBC_PASSWORD=sonar
    volumes:
      - sonarqube_conf:/opt/sonarqube/conf
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_bundled-plugins:/opt/sonarqube/lib/bundled-plugins
      
  db:
    image: postgres
    networks:
      - sonarnet
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data
      
networks:
  sonarnet:
    driver: bridge

volumes:
  sonarqube_conf:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_bundled-plugins:
  postgresql:
  postgresql_data:
```

</div>Para arrancar los contenedores ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose up -d
```

</div>## Acceso a la consola de SonarQube

Una vez arrancados los contenedores, abrimos un navegador web y accedemos a http://localhost:9000 para acceder a la consola de SonarQube.

El usuario y la contraseña predeterminados son admin y admin respectivamente. La primera ver que accedamos nos pedirá que cambiemos la contraseña.

<figure class="wp-block-image size-large">[![Instalación de SonarQube con Docker](https://aprenderdevops.com/wp-content/uploads/2021/10/consola-sonarqube-1024x585.png)](https://aprenderdevops.com/wp-content/uploads/2021/10/consola-sonarqube.png)</figure>## Código fuente del laboratorio

Podéis descargar o clonar el código fuente completo de este laboratorio de GitHub de <https://github.com/aprenderdevops/docker-sonarqube>.