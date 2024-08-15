---
id: 109
title: 'Instalación de Jenkins con Docker'
date: '2017-12-17T15:15:42+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=109'
permalink: /instalacion-de-jenkins-con-docker/
image: /wp-content/uploads/2017/12/jenkins-docker.png
categories:
    - Contenedores
    - 'Integración y entrega continua'
tags:
    - docker
    - jenkins
    - maven
---

En esta entrada vamos a ver cómo instalar Jenkins utilizando un contenedor Docker.

## ¿Qué es Jenkins?

[Jenkins](https://jenkins-ci.org/) en una herramienta de integración continua que se utiliza para la construcción de software, incluyendo compilación, análisis estático de código, ejecución de pruebas automáticas, empaquetado de la aplicación y despliegue.

Las principales características de Jenkins que lo han hecho tan popular son las siguientes:

- Se trata de un proyecto open source.
- Es fácil de usar y con una curva de aprendizaje relativamente rápida.
- Es adaptable y muy extensible gracias a los miles de plugins existentes.

## ¿Qué es Docker?

[Docker](https://www.docker.com/) es un proyecto open source que permite ejecutar aplicaciones portables y autocontenidas (con todas sus dependencias) mediante contenedores.

Vale, ¿pero qué significa realmente esta definición?

Los contenedores Docker son componentes software estandarizados con un tipo de virtualización muy ligera que, a diferencia de las máquinas virtuales, no necesitan cargar todo el kernel del sistema operativo, sino que comparten el kernel de la máquina anfitriona con otros contenedores y únicamente cargan las librerías que necesitan para ejecutar las aplicaciones.

La gran ventaja de los contenedores Docker es su portabilidad, ya que permiten que las aplicaciones puedan ejecutarse en cualquier máquina con Docker instalado, independientemente del sistema operativo de la máquina anfitriona.

Las aplicaciones que se ejecutan mediante contenedores Docker son autocontenidas, ya que los contenedores incluyen todas las dependencias que la aplicación necesita para su correcta ejecución.

Por todo esto, el uso de contenedores Docker permite crear, probar y desplegar aplicaciones rápidamente.

## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio únicamente necesitáis tener un equipo con Docker instalado. Si no tenéis Docker instalado, podéis seguir las [instrucciones de instalación](https://docs.docker.com/install/) para vuestro sistema operativo en la web oficial de Docker.

A continuación, pasamos a ver los pasos necesarios para instalar Jenkins con un contenedor Docker.

## ¿Qué imagen Docker con Jenkins elegir?

[La imagen oficial de Jenkins en Docker Hub](https://hub.docker.com/_/jenkins/), según la propia documentación de la imagen, está deprecada y nos recomiendan usar la imagen [jenkins/jenkins.](https://hub.docker.com/r/jenkins/jenkins/)

## Ejecución de Jenkins a partir de la imagen jenkins/jenkins

Lo más sencillo para probar Jenkins es ejecutar un contenedor a partir de la imagen jenkins/jenkins. Para ello, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins
```

</div>Una vez arrancado el contenedor, abrimos un navegador web y accedemos a http://localhost:8080 para entrar en la consola de administración de Jenkins.

Nos solicitará una contraseña que podemos encontrar en la salida de la ejecución del contenedor anterior o bien ejecutando los siguientes comandos:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker ps | grep jenkins/jenkins
f687f96f8810    jenkins/jenkins  "/bin/tini -- /usr..." 15 minutes ago   Up 15 minutes   0.0.0.0:8080->8080/tcp, 0.0.0.0:50000->50000/tcp determined_ptolemy
```

</div>Con este comando obtenemos el identificador del contenedor (la primera cadena de caracteres). Para obtener la contraseña ejecutamos el siguiente comando sustituyendo el identificador del contenedor por el que obtengáis en la salida del comando anterior:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker exec -it f687f96f8810 cat /var/jenkins_home/secrets/initialAdminPassword
0aa34fc2581d415d81f9c4e2ee98213c
```

</div>Si queremos que los cambios que realicemos en la configuración de Jenkins persistan incluso tras la destrucción del contenedor, debemos arrancar el contenedor con un volumen. Para ello, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins
```

</div>Esta instalación que acabamos de probar no incluye utilidades como [Maven](https://maven.apache.org/), que permite compilar y empaquetar aplicaciones Java, o cualquiera de los muchos plugins Jenkins disponibles. Cualquier paquete de sistema operativo, utilidad o plugin adicional que necesitemos, tendremos que añadirlo al contenedor manualmente tras ser arrancado. El problema de esto es que, si queremos replicar esta instalación en otra máquina, lo que hemos realizado manualmente no podremos reutilizarlo y deberemos repetir los mismos pasos de configuración manual en la nueva instalación.

La solución para no tener que repetir las configuraciones manuales en cada nueva instalación pasa por construir una imagen Docker con Jenkins a medida, con todo lo que necesitemos, y partiendo de la imagen base jenkins/jenkins que hemos utilizado para probar Jenkins.

## Construcción de nuestra propia imagen con Jenkins

### Dockerfile

Lo primero que tenemos que hacer para construir nuestra propia imagen con Jenkins es escribir el fichero Dockerfile que contendrá las instrucciones para construir nuestra imagen.

<div class="wp-block-syntaxhighlighter-code ">```

FROM jenkins/jenkins

USER root
RUN apt-get -y update && apt-get install -y maven

USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
```

</div>A continuación, explico para que sirven las distintas líneas del fichero Dockerfile:

- En la línea 1 se indica la imagen base de la que se parte para construir la nueva imagen.
- En la línea 4 instalamos Maven utilizando comandos apt-get. Estos comandos deben ejecutarse como usuario root. Indicamos que el usuario de ejecución es root en la línea 3.
- Tras ejecutarse los comandos apt-get, el resto de comandos pueden ejecutarse con el usuario jenkins. Establecemos el nuevo usuario de ejecución en la línea 6.
- En la línea 7 copiamos el fichero plugins.txt en el directorio /usr/share/jenkins/ref/. Este fichero contiene la lista de plugins que queremos que se instalen en Jenkins.
- En la última línea se ejecuta el script install-plugins.sh que toma como entrada la lista de plugins incluidos en el fichero plugins.txt y los instala en Jenkins. Este script viene incluido en la imagen jenkins/jenkins.

### plugins.txt

Como ya he indicado, en el fichero plugins.txt incluimos cada plugin que queremos que se instale en Jenkins. Se incluye un plugin por línea, tal y como puede verse a continuación:

<div class="wp-block-syntaxhighlighter-code ">```

ace-editor
analysis-core
ant
antisamy-markup-formatter
apache-httpcomponents-client-4-api
authentication-tokens
branch-api
build-monitor-plugin
build-pipeline-plugin
checkstyle
cloudbees-folder
conditional-buildstep
copyartifact  
credentials
credentials-binding
deploy
display-url-api
docker-commons
docker-workflow
durable-task
findbugs
git
github
github-api
git-client
git-server
gradle
greenballs
handlebars
jackson2-api
javadoc
jquery
jquery-detached
jsch
junit
mailer
matrix-project
maven-plugin
momentjs
nested-view
parameterized-trigger
pipeline-build-step
pipeline-graph-analysis
pipeline-input-step
pipeline-milestone-step
pipeline-model-api
pipeline-model-declarative-agent
pipeline-model-definition
pipeline-model-extensions
pipeline-rest-api
pipeline-stage-step
pipeline-stage-tags-metadata
pipeline-stage-view
plain-credentials
pmd
run-condition
scm-api
script-security  
ssh-credentials
structs
token-macro
workflow-aggregator
workflow-api
workflow-basic-steps
workflow-cps
workflow-cps-global-lib
workflow-durable-task-step
workflow-job
workflow-multibranch
workflow-scm-step
workflow-step-api
workflow-support
```

</div>### docker-compose.yml

Para facilitar la construcción de la imagen y la ejecución del contenedor Docker escribimos un fichero docker-compose.yml:

<div class="wp-block-syntaxhighlighter-code ">```

version: '2'
services:
  master:
    build: .
    image: aprenderdevops/jenkins:latest
    restart: unless-stopped
    hostname: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home

volumes:
  jenkins_home:
```

</div>Indico a continuación para que sirven las líneas más relevantes de este fichero:

- En la línea 4 indicamos el directorio sobre el que se va a construir la imagen. En este caso, el mismo directorio en el que se encuentra el fichero docker-compose.yml.
- En la línea 5 indicamos el nombre de nuestra imagen. Podéis cambiar aprenderdevops/jenkins:latest por el nombre que le queráis dar a vuestra propia imagen con Jenkins.
- En la línea 6 se establece que se reinicie el contenedor a menos que se detenga explícitamente o el motor de Docker se detenga o reinicie.
- En la línea 7 indicamos el hostname del contenedor.
- En las líneas 9 y 10 se exponen los puertos 8080 y 50000 respectivamente.
- Las líneas de la 12 a la 15 sirven para definir el volumen jenkins\_home. Este volumen se utiliza para que los cambios que realicemos en la configuración de Jenkins persistan incluso tras la destrucción del contenedor.

### Instrucciones

Para construir la imagen ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose build
```

</div>Para arrancar el contenedor con Jenkins ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose up -d
```

</div>Una vez arrancado el contenedor, abrimos un navegador web y accedemos a http://localhost:8080 para entrar en la consola de administración de Jenkins.

Para obtener la contraseña del usuario admin de Jenkins ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker exec -it dockerjenkins_master_1 cat /var/jenkins_home/secrets/initialAdminPassword
```

</div>## Código fuente del laboratorio

Podéis descargar o clonar de GitHub el código fuente completo de este laboratorio de <https://github.com/aprenderdevops/docker-jenkins>.