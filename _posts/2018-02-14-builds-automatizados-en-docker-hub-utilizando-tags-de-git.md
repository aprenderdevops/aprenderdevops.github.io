---
id: 228
title: 'Configuración de builds automatizados en Docker Hub utilizando tags de Git'
date: '2018-02-14T07:30:58+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=228'
permalink: /builds-automatizados-en-docker-hub-utilizando-tags-de-git/
image: /wp-content/uploads/2017/12/builds-dockerhub.png
categories:
    - Contenedores
    - 'Integración y entrega continua'
tags:
    - 'builds automatizados'
    - docker
    - 'docker hub'
    - 'git tag'
    - github
---

En esta entrada vamos a ver cómo configurar builds automatizados en Docker Hub para que estos se desencadenen a partir del etiquetado de un commit en GitHub.

En la entrada [Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/configuracion-de-builds-automatizados-en-docker-hub/) vimos cómo configurar un repositorio [Docker Hub](https://hub.docker.com/) ([aprenderdevops/jenkins](https://hub.docker.com/r/aprenderdevops/jenkins/)) para enlazarlo con un repositorio de código [GitHub](https://github.com/) ([aprenderdevops/docker-jenkins](https://github.com/aprenderdevops/docker-jenkins)), de forma que cualquier actualización del código fuente en el repositorio GitHub desencadene automáticamente en Docker Hub la construcción de una nueva versión de la imagen Docker.

Con esta configuración, cualquier actualización de código en la rama master del repositorio GitHub desencadenará la construcción de una nueva imagen Docker etiquetada con el tag latest.

Además, cualquier actualización en otra rama del repositorio GitHub distinta de la rama master desencadenará la construcción de una nueva imagen Docker etiquetada con el nombre de la rama de GitHub.

Esta última configuración es útil si tenemos una o más líneas de desarrollo paralelas a la línea principal (rama master) y queremos que se construyan imágenes Docker etiquetadas con el nombre de cada rama, de forma que sea muy sencillo identificar a que código fuente corresponde cada imagen en función de su etiqueta asignada. Las modificaciones en GitHub en cualquiera de las ramas desencadenarán la construcción de la imagen correspondiente, de forma que se puede ir evolucionando la funcionalidad de cualquiera de las ramas en paralelo al resto de ramas y de la rama principal.

## Utilidad de los tags de Git

El problema de las ramas de Git es que no sirven para identificar una versión concreta y estática del código. Para conseguir esto, lo mejor es utilizar tags (o etiquetas) de Git.

Un tag es una cadena arbitraria que apunta a un commit específico de un repositorio Git. Se trata, por lo tanto, de algo estático, ya que el código puede seguir evolucionando, pero el tag siempre apuntará a un determinado punto de la historia del código. La principal utilidad de los tags es identificar las distintas versiones o releases del código.

Podéis encontrar información sobre el uso de tags en Git en el siguiente enlace: <https://git-scm.com/book/es/v2/Fundamentos-de-Git-Etiquetado>

Cuando tenemos builds automatizados en Docker Hub, la utilización de tags Git resulta de gran utilidad para identificar las distintas versiones de las imágenes Docker que se van construyendo.

Vamos a ver cómo configurar en Docker Hub esta característica.

## Configuración de builds automatizados en Docker Hub utilizando tags de Git

Lo primero que tenemos que hacer es logarnos en Docker Hub y acceder a la configuración de los builds (opción Build Settings) del repositorio en el que queremos configurar builds automatizados utilizando tags de Git.

Una vez en la pantalla Build Settings nos aparecerá una configuración similar a la de la siguiente pantalla.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub utilizando tags de Git](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-1-1024x639.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-1.png)</figure></div>En esta configuración, si previamente ya habíamos configurado los builds automatizados, tendremos una línea para la rama master y otra línea para cualquier rama distinta de la rama master. Lo que tenemos que hacer ahora es pulsar en el símbolo más de color verde y añadir una línea de tipo Tag. Para esta nueva línea podemos dejar los valores por defecto. De esta forma, cualquier tag creado en el repositorio GitHub desencadenará un build cuya imagen Docker resultante será etiquetada con el mismo tag que se ha creado en GitHub.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub utilizando tags de Git](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-2-1024x699.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-2.png)</figure></div>## Actualización del código en GitHub y etiquetado con un tag

Para probar que esta nueva configuración de builds automatizados funciona correctamente, vamos a hacer una modificación en la rama master del código de nuestro proyecto de [instalación de Jenkins con Docker](http://aprenderdevops.com/instalacion-de-jenkins-con-docker/). También vamos a etiquetar ese código con el comando git tag. Por último, lo vamos a subir al repositorio GitHub ([aprenderdevops/docker-jenkins](https://github.com/aprenderdevops/docker-jenkins)) mediante el comando git push.

Todo esto, debería desencadenar la construcción de dos imágenes Docker, una correspondiente a la rama master y que se etiquetará con el tag latest, y otra correspondiente al tag de Git que hayamos subido a GitHub y que se etiquetará con ese mismo tag. Ambas imágenes serán totalmente idénticas, cambiando únicamente la etiqueta que tienen asignada.

Vamos a ver en detalle los pasos de esta modificación en el código del proyecto de [instalación de Jenkins con Docker](http://aprenderdevops.com/instalacion-de-jenkins-con-docker/).

### Instalación de un plugin adicional en Jenkins

La modificación que vamos a hacer es muy sencilla. Consistirá en añadir un nuevo plugin Jenkins a nuestra imagen Docker. El plugin que he elegido es [Blue Ocean](https://jenkins.io/projects/blueocean/) (identificado como [blueocean](https://plugins.jenkins.io/blueocean)). Este plugin realiza un completo rediseño del interfaz de usuario de Jenkins.

Para añadir un nuevo plugin Jenkins a la imagen Docker únicamente tenemos que incluir el identificador del plugin, en este caso blueocean, en el fichero plugins.txt. Os recuerdo que este fichero contiene todos los plugins de Jenkins que queremos incluir en nuestra imagen Docker. Se trata de un fichero en formato texto que incluye un identificador de plugin por línea. Añadiendo el identificador blueocean en el fichero plugins.txt se instalará el plugin Blue Ocean y todos los plugins de los que éste dependa para su correcto funcionamiento.

### Asignación de un tag para versionar la imagen Docker

Una vez realizada la modificación en el código de nuestro proyecto, hacemos un commit de los cambios de nuestro código y le asignamos un tag. Esto lo hacemos ejecutando los comandos que detallo a continuación:

<div class="wp-block-syntaxhighlighter-code ">```

$ git add plugins.txt
$ git commit -m "Se añade el plugin blueocean en plugins.txt"
[master c38387a] Se añade el plugin blueocean en plugins.txt
1 file changed, 2 insertions(+), 1 deletion(-)
$ git tag 1.5 -m "Versión 1.5. Se añade el plugin Blue Ocean."
```

</div>En mi caso he etiquetado esta versión como la 1.5.

Podemos obtener información sobre un determinado tag ejecutando un comando git show como el siguiente:

<div class="wp-block-syntaxhighlighter-code ">```

$ git show 1.5
tag 1.5
Tagger: aprenderdevops <jarfernandez@aprenderdevops.com>
Date:   Sun Feb 11 14:44:19 2018 +0100

Versión 1.5. Se añade el plugin Blue Ocean.

commit 14287aafa95734a3e6fc4d8f5bceb1f73c33340d (HEAD -> master, tag: 1.5, origin/master, origin/HEAD)
Author: aprenderdevops <jarfernandez@aprenderdevops.com>
Date:   Sun Feb 11 14:43:51 2018 +0100

    Se añade el plugin blueocean en plugins.txt

diff --git a/plugins.txt b/plugins.txt
index 30ac56c..1b3b57c 100644
--- a/plugins.txt
+++ b/plugins.txt
@@ -5,6 +5,7 @@ antisamy-markup-formatter
 apache-httpcomponents-client-4-api
 authentication-tokens
 branch-api
+blueocean
 build-monitor-plugin
 build-pipeline-plugin
 checkstyle
@@ -69,4 +70,4 @@ workflow-job
 workflow-multibranch
 workflow-scm-step
 workflow-step-api
-workflow-support
\ No newline at end of file
+workflow-support
```

</div>Por último, para actualizar estos cambios en GitHub ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ git push origin master --tag
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 489 bytes | 489.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/aprenderdevops/docker-jenkins.git
   c6c882b..14287aa  master -> master
 * [new tag]         1.5 -> 1.5

```

</div>En el repositorio de GitHub tendremos una nueva release etiquetada con el tag 1.5.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub utilizando tags de Git](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-3-1024x456.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-3.png)</figure></div>Estos cambios en GitHub desencadenarán dos builds en Docker Hub, uno etiquetado como latest y otro como 1.5.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub utilizando tags de Git](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-4-1024x590.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-4.png)</figure></div>Pasados unos minutos ambas imágenes estarán disponibles en Docker Hub y podremos usarlas para ejecutar Jenkins con el plugin Blue Ocean.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub utilizando tags de Git](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-5-1024x390.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-5.png)</figure></div>### Arranque del contenedor con la nueva imagen Docker

Para comprobar que todo ha ido bien, descargamos a local la nueva imagen Docker construida. Para ello, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker pull aprenderdevops/jenkins
```

</div>Una vez descargada la nueva imagen Docker, arrancamos el contenedor ejecutando el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose up -d
Creating volume "dockerjenkins_jenkins_home" with default driver
Creating dockerjenkins_master_1 ... done
```

</div>Una vez arrancado el contenedor, abrimos un navegador y accedemos a http://localhost:8080 para entrar en la consola de administración de Jenkins.

Para obtener la contraseña del usuario admin de Jenkins ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker exec -it dockerjenkins_master_1 cat /var/jenkins_home/secrets/initialAdminPassword
```

</div>Si todo ha ido bien, en la parte izquierda de la consola de Jenkins se mostrará el icono de acceso a la interfaz Blue Ocean.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub utilizando tags de Git](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-6-1024x625.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-tags-6.png)</figure></div>## Código fuente del laboratorio

Podéis descargar o clonar de GitHub el código fuente completo de este laboratorio de <https://github.com/aprenderdevops/docker-jenkins>.