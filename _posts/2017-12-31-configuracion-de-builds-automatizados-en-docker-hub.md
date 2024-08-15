---
id: 129
title: 'Configuración de builds automatizados en Docker Hub'
date: '2017-12-31T10:00:17+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=129'
permalink: /configuracion-de-builds-automatizados-en-docker-hub/
image: /wp-content/uploads/2017/12/builds-dockerhub.png
categories:
    - Contenedores
    - 'Integración y entrega continua'
tags:
    - 'builds automatizados'
    - docker
    - 'docker hub'
    - github
---

En esta entrada os cuento cómo configurar builds automatizados en Docker Hub.

 Esto os permitirá que las imágenes Docker se construyan automáticamente cada vez que hagáis un cambio en el código fuente utilizado para construir la imagen y subáis ese cambio al repositorio de [GitHub](https://github.com/) o de [Bitbucket](https://bitbucket.org/) que estéis utilizando para alojar ese código.

## ¿Qué es Docker Hub?

[Docker Hub](https://hub.docker.com/) es el registro online de imágenes Docker proporcionado por [Docker Inc.](https://www.docker.com/company), la compañía que está detrás del desarrollo de [Docker](https://www.docker.com/).

Docker Hub proporciona repositorios gratuitos para imágenes públicas, o bien se puede pagar para disponer de repositorios privados.

## Subir imágenes a Docker Hub

Si queréis subir vuestras imágenes Docker a Docker Hub, lo primero que tenéis que hacer es crearos una cuenta en <https://hub.docker.com>.

Una vez que dispongáis de una cuenta, subir una imagen Docker a Docker Hub es tan sencillo como ejecutar un comando docker push similar al siguiente:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker push aprenderdevops/jenkins:latest
```

</div>En este caso estoy subiendo la imagen con Jenkins que construí en la entrada [Instalación de Jenkins con Docker](https://aprenderdevops.com/instalacion-de-jenkins-con-docker/).

En vuestro caso, sólo tendréis que cambiar el nombre de la cuenta aprenderdevops por el de vuestra cuenta de Docker Hub, y el nombre del repositorio de imágenes, en este caso jenkins, por el nombre que le queráis dar a vuestra imagen.

Además, tenéis la opción de indicar la etiqueta o tag de la imagen. En el ejemplo he utilizado latest, que convencionalmente se suele utilizar para hacer referencia a la última imagen construida, y por lo tanto la más actual.

Una vez subida la imagen Docker a Docker Hub, esta estará disponible públicamente y cualquiera podrá descargarla para que esté disponible localmente. Para ello, únicamente tendrá que ejecutar un comando docker pull similar al siguiente:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker pull aprenderdevops/jenkins
Using default tag: latest
latest: Pulling from aprenderdevops/jenkins
Digest: sha256:8627663a01a0ca10a2067244e8cdf9baae91538570f6c5b4e578e06ca0a7cc41
Status: Image is up to date for aprenderdevops/jenkins:latest
```

</div>## Configurar builds automatizados en Docker Hub

Si accedéis al sitio web de Docker Hub, encontraréis vuestro repositorio en una URL similar a <https://hub.docker.com/r/aprenderdevops/jenkins/>.

Iniciando sesión en Docker Hub podréis realizar algunas tareas de administración como establecer una descripción para el repositorio, establecer otros usuarios como colaboradores o configurar webhooks.

Para que vuestras imágenes Docker se actualicen cada vez que vuestro código fuente cambie, podéis configurar en Docker Hub los builds automatizados. Esto hará que cada vez que subáis a GitHub o Bitbucket cambios en el código fuente, Docker Hub construya de forma totalmente automática una nueva versión de la imagen Docker y la guarde en vuestro repositorio de Docker Hub.

Los builds automatizados se configuran en el interfaz web de Docker Hub. Si habéis iniciado sesión en Docker Hub, veréis un menú desplegable en la parte superior de la pantalla con el nombre “Create”. En este menú debéis seleccionar la opción “Create Automated Build”, lo que os dirigirá a una nueva pantalla en la que deberéis enlazar vuestra cuenta de Docker Hub con una cuenta de GitHub o de Bitbucket.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-1.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-1.png)</figure></div>### Enlazar cuentas

En la nueva pantalla debéis pulsar en el botón “Link Accounts”.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-2.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-2.png)</figure></div>El siguiente paso será elegir qué tipo de repositorio queréis enlazar con la cuenta de Docker Hub. Las opciones son GitHub o Bitbucket. En mi caso he elegido GitHub.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-3.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-3.png)</figure></div>En el caso de GitHub, os pedirá que elijáis el tipo de acceso que vais a permitir desde Docker Hub a vuestra cuenta de GitHub. Lo más sencillo es elegir la opción recomendada (acceso de lectura y escritura a repositorios públicos y privados).

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-4.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-4.png)</figure></div>Una vez seleccionado el tipo de acceso, os solicitará que accedáis a la cuenta de GitHub que queréis enlazar.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-5.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-5.png)</figure></div>Una vez logados, debéis autorizar a Docker Hub el acceso a vuestra cuenta de GitHub pulsando en el botón “Authorize docker”.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-6.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-6.png)</figure></div>Si todo ha ido bien, os mostrará una pantalla similar a la siguiente, en la que se muestran las cuentas enlazadas con Docker Hub.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-7.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-7.png)</figure></div>### Configurar builds automatizados

Una vez enlazada la cuenta de Docker Hub con la cuenta de GitHub, podéis configurar builds automatizados. Para ello, volvéis a pulsar en el menú desplegable “Create” y seleccionáis la opción “Create Automated Build”, lo que os dirigirá a una nueva pantalla en la que ya os aparecerá la cuenta de GitHub que tenéis enlazada.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-1.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-1.png)</figure></div>En la nueva pantalla debéis elegir la opción de GitHub.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-8.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-8.png)</figure></div>Al seleccionar la opción de GitHub os dirigirá a una nueva pantalla en la que debéis seleccionar el repositorio de GitHub que contiene el código fuente, principalmente el Dockerfile, que se utilizará para construir la imagen Docker.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-9.png)](http://aprenderdevops.com/wp-content/uploads/2017/12/builds-dockerhub-9.png)</figure></div>Una vez seleccionado el repositorio de GitHub con el código fuente de la imagen, el último paso es crear el build automatizado en una pantalla similar a la siguiente.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-10.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-10.png)</figure></div>En esta pantalla tendréis que incluir una breve descripción del build automatizado.

La configuración por defecto asigna a la imagen la etiqueta latest si el build es disparado por un cambio realizado en la rama master del repositorio de GitHub. Adicionalmente, si el build es disparado por un cambio en otra rama del repositorio de GitHub distinta de la rama master, asignará a la imagen una etiqueta que tendrá el mismo nombre que la rama modificada.

Para crear el build automatizado, lo único que queda por hacer es pulsar el botón “Create” en la parte inferior derecha de la pantalla.

### Probar los builds automatizados

Una vez configurado el build automatizado, cualquier cambio que subáis al repositorio de GitHub desencadenará de forma automática la construcción de una nueva versión de la imagen en Docker Hub, tal y como puede verse en la siguiente imagen.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-11.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-11.png)</figure></div>Para conocer los detalles de un build concreto, tanto si ha sido satisfactorio como si ha fallado por algún error, sólo tenéis que pulsar sobre él. Esto os abrirá una nueva pantalla como la siguiente, en la que podréis ver el fichero README del repositorio de GitHub, el fichero Dockerfile y los logs del build.

<div class="wp-block-image"><figure class="aligncenter">[![Configuración de builds automatizados en Docker Hub](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-12.png)](http://aprenderdevops.com/wp-content/uploads/2018/02/builds-dockerhub-12.png)</figure></div>A partir de ahora, cada vez que hagáis un cambio en el código fuente y lo subáis al repositorio de GitHub se desencadenará en Docker Hub la construcción de una nueva versión de la imagen Docker.