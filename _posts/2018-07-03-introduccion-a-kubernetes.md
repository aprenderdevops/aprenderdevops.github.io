---
id: 292
title: 'Introducción a Kubernetes'
date: '2018-07-03T23:15:39+02:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=292'
permalink: /introduccion-a-kubernetes/
image: /wp-content/uploads/2018/07/kubernetes.png
categories:
    - Contenedores
tags:
    - kubernetes
---

Kubernetes se ha convertido en el orquestador de [contenedores](https://aprenderdevops.com/category/contenedores/) de facto. En esta entrada vamos a ver algunos conceptos clave de este orquestador.

## ¿Qué es Kubernetes?

Kubernetes, abreviado como k8s, es un orquestador de contenedores de código abierto desarrollado originalmente por Google y donado a la [Cloud Native Computing Foundation](https://www.cncf.io/) (parte de la [Linux Foundation](https://www.linuxfoundation.org/)) que permite automatizar la implementación, el escalado y la administración de aplicaciones en contenedores.

## Conceptos clave de Kubernetes

Para empezar a conocer Kubernetes es necesario tener claros algunos conceptos clave.

### Pods

Un pod es una colección lógica de contenedores y recursos compartidos por esos contenedores que pertenecen a una aplicación. Un pod contiene uno o varios contenedores.

### Labels y selectors

Las etiquetas o labels son pares clave/valor que se asignan a los objetos, por ejemplo, pods, y que se utilizan para especificar atributos de identificación de objetos que sean significativos y relevantes para los usuarios. Cada objeto puede tener un conjunto de etiquetas clave/valor definidas.

Los label selectors permiten identificar y seleccionar subconjuntos de objetos a partir de etiquetas.

Existen dos formas de seleccionar objetos mediante selectors:

- Requisito basado en la igualdad. Filtran claves por igualdad o desigualdad de valores, pudiendo usarse más de una etiqueta. Por ejemplo:  
    ```
    entorno = produccion, capa != frontend
    ```
    
    Identifica los objetos en el entorno de producción que no estén en la capa de frontend. El separador coma actúa como operador AND.
- Requisito basado en conjunto. Filtran claves según un conjunto de valores. Por ejemplo:  
    ```
    environment in (production, qa)<br></br>tier notin (frontend, backend)<br></br>partition<br></br>!partition
    ```
    
    El primer ejemplo selecciona todos los recursos con clave igual a entorno y valor igual a producción o qa. El segundo ejemplo selecciona todos los recursos con clave igual a tier y valores distintos de frontend y backend, y todos los recursos sin etiquetas con la clave tier. El tercer ejemplo selecciona todos los recursos que tengan una etiqueta con clave partition El cuarto ejemplo selecciona todos los recursos que no tengan una etiqueta con clave partition. De manera similar al requisito basado en igualdad, el separador de coma actúa como operador AND.

### Replica sets y controladores de replicación

Tanto los replica sets como los controladores de replicación garantizan que se ejecute un número específico de réplicas de pod en cada momento. Una réplica es una copia exacta de un pod. Los replica sets y controladores de replicación levantan nuevos pods en caso de caídas de los pods en funcionamiento.

El controlador de replicación es el mecanismo original de replicación en Kubernetes, pero está siendo reemplazado por los replica sets. La única diferencia entre un replica set y un controlador de replicación es que el primero admite requisitos de selector basados en conjuntos.

### Servicios

Los servicios son end-points que definen como acceder a las aplicaciones.

### Volúmenes

Un volumen de Kubernetes es esencialmente un directorio accesible por todos los contenedores que se ejecutan en un pod. A diferencia del sistema de ficheros local de los contenedores, los datos en volúmenes se preservan, aunque se reinicie el contenedor. Existen varios tipos de volúmenes dependiendo del tipo de almacenamiento, su contenido y su propósito:

- Locales, es decir, en la misma máquina en la que se ejecutan los contenedores, como **emptyDir** o **hostPath**.
- **nfs** si se montan sobre un sistema de ficheros compartido de tipo NFS (Network File System).
- Específicos según el proveedor de cloud como **awsElasticBlockStore**, **azureDisk**, o **gcePersistentDisk**.
- En sistemas de fichero distribuidos como por ejemplo **glusterfs** o **cephfs**.
- Para propósitos específicos como **secret** o **gitRepo**.

### Deployments

Un deployment define una aplicación como una colección de recursos y referencias. Los deployments contienen pods.

### kubectl

kubectl es la utilidad de línea de comandos que nos permite interactuar con un cluster de Kubernetes y gestionar todos los recursos que hemos estado viendo en esta entrada.

En próximas entradas veremos la arquitectura de Kubernetes y cómo instalarlo.