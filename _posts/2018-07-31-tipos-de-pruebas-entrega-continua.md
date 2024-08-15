---
id: 331
title: 'Tipos de pruebas en un pipeline de entrega continua'
date: '2018-07-31T08:00:54+02:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=331'
permalink: /tipos-de-pruebas-entrega-continua/
image: /wp-content/uploads/2018/07/tipos-de-pruebas-entrega-continua.png
categories:
    - 'Aseguramiento de la calidad'
    - 'Integración y entrega continua'
tags:
    - pruebas
---

El aseguramiento de la calidad del software debe ser una de las prácticas esenciales dentro de las organizaciones TI de alto rendimiento que [adoptan un enfoque DevOps](https://aprenderdevops.com/razones-para-adoptar-devops/). En esta entrada vamos a ver los distintos tipos de pruebas que se deben incluir en un pipeline de entrega continua.

## Objetivos de las pruebas

El objetivo principal de las pruebas es asegurar y mejorar la calidad del software que se desarrolla y entrega.

Además de este objetivo principal, dentro del pipeline de entrega continua, el objetivo de las pruebas debe ser **identificar builds problemáticos lo antes posible** para mantener ciclos de entrega rápidos, evitar tener que repetir trabajo y obtener feedback lo antes posible. De esta forma se consigue **entregar software de calidad con más frecuencia.**

## Pruebas automáticas

En un pipeline de entrega continua se pueden incluir etapas de pruebas manuales que serán llevadas a cabo por el equipo de QA (aseguramiento de la calidad) o pruebas de aceptación de usuario. Sin embargo, la automatización de las pruebas es la característica clave que permite acelerar los ciclos de entrega y mejorar la calidad. Por lo tanto, se debe automatizar la mayor cantidad posible de pruebas.

Invertir en la automatización de pruebas es costoso al principio, pero una vez que se ha desarrollado una batería de pruebas automáticas la inversión de tiempo y esfuerzo merece la pena, ya que es algo que ayudará a asegurar y mejorar la calidad del software de una manera eficiente a lo largo de la vida útil de ese software.

## Tipos de pruebas

A continuación, vamos a ver los distintos tipos de pruebas que existen y para que sirve cada uno de ellos.

<figure class="wp-block-table">| **Tipo de prueba** | **Para confirmar que** |
|---|---|
| Pruebas unitarias | Las funciones y clases funcionan como se espera bajo una variedad de entradas. |
| Pruebas de integración | Los módulos integrados funcionan en conjunto y junto con la infraestructura, como colas de mensajes y bases de datos. En entornos de microservicios las pruebas de integración de todos los componentes desplegados son cada vez más importantes para asegurar el correcto funcionamiento del software en su conjunto. |
| Prueba de aceptación | Los flujos de usuario clave en la interfaz de usuario funcionan como se espera. |
| Pruebas de carga | La aplicación funciona bien bajo carga de usuario simulada. |
| Pruebas de rendimiento | La aplicación cumple con los requisitos de rendimiento y tiempos de respuesta en escenarios de carga similares a la carga real esperada. |
| Pruebas de simulación | La aplicación funciona en entornos de simulación de dispositivos. Esto es especialmente importante en aplicaciones móviles donde es necesario probar el software en distintos dispositivos móviles emulados. |
| Pruebas de humo | El estado y la integridad de un entorno recién provisionado son válidos. |
| Pruebas de calidad | El código de la aplicación es de alta calidad. Esto se lleva a cabo mediante técnicas como el análisis estático de código que permiten validar el cumplimiento de guías de estilo o la cobertura del código. |

</figure>## Buenas practicas

Estas son algunas buenas prácticas que se deben tener en cuenta a la hora de mantener una batería de pruebas:

- Automatizar tantas pruebas como sea posible.
- Proporcionar una buena cobertura de pruebas, tanto contra los artefactos de código como contra el sistema desplegado.
- Distribuir diferentes tipos de pruebas a lo largo del pipeline de entrega continua. Se recomienda dejar las pruebas más lentas y costosas, como pueden ser las pruebas manuales, para su ejecución en las últimas etapas del pipeline, en entornos cada vez más similares a los de producción.