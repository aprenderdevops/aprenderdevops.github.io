---
id: 382
title: 'Arquitectura de Kubernetes'
date: '2018-12-22T01:45:31+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=382'
permalink: /arquitectura-de-kubernetes/
image: /wp-content/uploads/2018/07/kubernetes.png
categories:
    - Contenedores
tags:
    - kubernetes
---

Tras la entrada [Introducción a Kubernetes](https://aprenderdevops.com/introduccion-a-kubernetes/), en la que conocimos este orquestador de contenedores y vimos algunos conceptos clave, vamos a ver su arquitectura, identificando los distintos componentes en los que está organizado y su relación entre ellos.

## Nodos

<div class="wp-block-image"><figure class="aligncenter">[![Arquitectura de Kubernetes](http://aprenderdevops.com/wp-content/uploads/2018/12/arquitectura-kubernetes-1.png)](http://aprenderdevops.com/wp-content/uploads/2018/12/arquitectura-kubernetes-1.png)</figure></div>Los nodos en Kubernetes son las máquinas que componen el clúster Kubernetes. Estas máquinas pueden ser físicas o virtuales, y estar desplegadas on premise o en la nube. A su vez los nodos pueden ser nodos master o nodos worker.

### Nodos master

Los nodos master son los responsables de gestionar el clúster Kubernetes. Estos nodos toman decisiones globales sobre el clúster, como el reparto de trabajo entre los nodos worker, y detectan y dan respuesta a distintos eventos del clúster, como puede ser el inicio de nuevos pods cuando el número de replicas es inferior al configurado para un controlador de replicación.

En un clúster Kubernetes puede haber un único nodo master o varios si queremos tener redundancia para asegurar una mayor disponibilidad del clúster. Si hay varios nodos master, el número de nodos master tiene que ser siempre impar para que sea posible establecer quórum. Esto es así porque en cada nodo master se ejecuta un nodo de la base de datos distribuida etcd y todos los componentes master de Kubernetes restantes (API, administrador del controlador/controller y scheduler). Un clúster etcd necesita alcanzar una mayoría de nodos, un quórum, para acordar las actualizaciones del estado del clúster, y esto sólo se puede asegurar si el número de nodos es impar.

### Nodos worker

Los nodos worker, también denominados simplemente nodos, son los responsables de ejecutar las aplicaciones en pods. Como ya vimos en la entrada [Introducción a Kubernetes](https://aprenderdevops.com/introduccion-a-kubernetes/), un pod es una colección lógica de contenedores y recursos compartidos por esos contenedores que pertenecen a una aplicación.

Como curiosidad, indicar que en la documentación de las primeras versiones de Kubernetes los nodos worker se denominaban minions.

Cada nodo worker puede ejecutar múltiples pods. Es muy recomendable tener varios nodos worker si queremos asegurar la disponibilidad de las aplicaciones desplegadas en el clúster Kubernetes.

## Componentes de un nodo master

<div class="wp-block-image"><figure class="aligncenter">[![Arquitectura de Kubernetes](http://aprenderdevops.com/wp-content/uploads/2018/12/arquitectura-kubernetes-2.png)](http://aprenderdevops.com/wp-content/uploads/2018/12/arquitectura-kubernetes-2.png)</figure></div>Los distintos componentes de un nodo master se pueden ejecutar en cualquier máquina del clúster, sin embargo, por simplicidad, las secuencias de comandos de configuración inician normalmente todos los componentes del nodo master en la misma máquina. Además, en esa máquina no se ejecutan contenedores de usuario.Estos componentes de un nodo master se detallan a continuación.

### API server

Es el componente que expone la API de Kubernetes. Es, por lo tanto, el punto de entrada para todos los comandos REST utilizados para controlar el clúster. Procesa las solicitudes REST, las valida y ejecuta.

### Scheduler

Este componente observa los pods recién creados que no tienen un nodo asignado y selecciona un nodo para que se ejecuten. El scheduler tiene en cuenta los recursos disponibles en cada nodo del clúster, así como los recursos necesarios para que se ejecute un determinado servicio. Con esta información decide dónde desplegar cada pod dentro del clúster.

### Controller-manager

Este componente ejecuta los controladores. Un controlador usa el API server para observar el estado compartido del clúster y realiza cambios correctivos en el estado actual para cambiarlo al estado deseado.

Un ejemplo de controlador es el controlador de replicación, que se ocupa de mantener la cantidad correcta de pods en el clúster. El usuario configura el factor de replicación, y es responsabilidad del controlador de replicación volver a crear un pod caído o eliminar uno que se haya programado de más.

Desde un punto de vista lógico, cada controlador es un proceso separado, pero para reducir la complejidad, todos los controladores se compilan en un único binario y se ejecutan en un solo proceso.

Estos son los controladores incluidos:

- Controlador de nodo: responsable de monitorizar el estado de los nodos y responder cuando uno se cae desplegando los pods afectados en los nodos restantes disponibles.
- Controlador de replicación: responsable de mantener el número correcto de pods.
- Controlador de endpoints: responsable de asegurar la conexión entre servicios y pods.
- Controladores service acount y token: crean cuentas predeterminadas y tokens de acceso a la API para nuevos espacios de nombres.

### etcd

[etcd](https://coreos.com/etcd/) es un almacén de datos clave valor simple, distribuido y consistente. Se utiliza para almacenar la configuración compartida del clúster y para el descubrimiento de servicios. Permite de una forma confiable notificar al resto de nodos del clúster los cambios de configuración en un nodo determinado.

Algunos ejemplos de datos almacenados por Kubernetes en etcd son los trabajos que se programan, crean y despliegan, estado y detalles de los pods, espacios de nombre o información de replicación.

## Componentes de un nodo worker

<div class="wp-block-image"><figure class="aligncenter">[![Arquitectura de Kubernetes](http://aprenderdevops.com/wp-content/uploads/2018/12/arquitectura-kubernetes-3.png)](http://aprenderdevops.com/wp-content/uploads/2018/12/arquitectura-kubernetes-3.png)</figure></div>Cada nodo worker ejecuta los siguientes componentes que se detallan a continuación.

### kubelet

kubelet es el servicio, dentro de cada nodo worker, responsable de comunicarse con el nodo master. Obtiene la configuración de los pods del API server y garantiza que los contenedores descritos en dicha configuración estén arriba y funcionando correctamente. También se comunica con etcd para obtener información de los servicios y registrar los detalles de los nuevos servicios creados.

### kube-proxy

kube-proxy actúa como proxy de red y balanceador de carga enrutando el tráfico hacia el contenedor correcto en función de la dirección IP y el número de puerto indicados en cada petición.

### Runtime de contenedores

El runtime de contenedores es el software responsable de ejecutar los contenedores de los pods. Para ello, se encarga de descargar las imágenes necesarias y de arrancar los contenedores.

Kubernetes admite varios runtimes de contenedores: [Docker](https://www.docker.com/), [rkt](https://coreos.com/rkt/), [runc](https://github.com/opencontainers/runc) y cualquier implementación de la especificación de runtime [OCI (Open Container Initiative)](https://www.opencontainers.org/).

### Pods

Como ya comentamos, las aplicaciones se ejecutan mediante pods. Un pod es una colección lógica de contenedores más los recursos compartidos por esos contenedores.

En próximas entradas veremos cómo instalar Kubernetes y algunos ejemplos de configuración de aplicaciones en este orquestador de contenedores.