---
id: 574
title: 'Instalación del stack Elastic con Docker'
date: '2021-11-15T00:25:00+01:00'
author: Arturo
layout: post
guid: 'https://aprenderdevops.com/?p=574'
permalink: /instalacion-del-stack-elastic-con-docker/
image: /wp-content/uploads/2021/11/elastic-docker-1.png
categories:
    - Contenedores
tags:
    - docker
    - elastic
---

En esta entrada vamos a ver cómo instalar el [stack Elastic](https://www.elastic.co/es/elastic-stack/) utilizando contenedores Docker. Para ello, vamos a preparar un fichero Docker compose que cree y arranque los contenedores necesarios para el funcionamiento del stack.

Es importante destacar que en un entorno de producción no se instala todo el stack en un único host. Además, se suelen instalar varios nodos de Logstash, y en cuanto a Elasticsearch, este se suele instalar como un cluster con al menos tres nodos.

Antes de empezar a instalar el stack vamos a ver primero qué es Elastic, qué componentes tiene y para que se suele utilizar.

## ¿Qué es el stack Elastic?

El stack Elastic es el nuevo nombre de lo que anteriormente se conocía como stack ELK, y que está formado por los proyectos open source Elasticsearch, Logstash y Kibana.

En 2015 se añadieron al stack los Beats, que son un conjunto de agentes ligeros que se instalan en los distintos sistemas y envían datos a Elasticsearch, ya sea directamente o a través de Logstash.

El stack Elastic recolecta logs y eventos de los sistemas y aplicaciones, los formatea y almacena en forma de datos que pueden ser buscados y leídos en tiempo real por otras aplicaciones, y los representa de forma visual en cuadros de mando.

## Componentes del stack Elastic

A continuación, vamos a conocer un poco más de cada uno de los componentes del stack:

- Elasticsearch es donde se almacenan los datos. Además, es un motor de búsqueda open source, distribuido, RESTful basado en JSON, fácil de usar, escalable y flexible.
- Logstash es un pipeline de procesamiento de datos del lado del servidor que ingesta datos de una multitud de fuentes simultáneamente, los transforma y luego los envía a Elasticsearch.
- Kibana permite visualizar los datos en cuadros de mando.

## Casos de uso

Ya sabemos que es, que hace y cuales son los componentes del stack Elastic, pero realmente ¿para qué se utiliza?

Los casos de uso del stack Elastic son la búsqueda de datos en tiempo real, la observabilidad de sistemas y aplicaciones mediante la analítica de logs y métricas, o el análisis de seguridad mediante el módulo de SIEM integrado en Kibana.

## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio únicamente necesitáis tener un equipo con Docker instalado. Si no tenéis Docker instalado, podéis seguir las [instrucciones de instalación](https://docs.docker.com/install/) en la web oficial de Docker para vuestro sistema operativo.

Vamos a ver los pasos necesarios para instalar el stack Elastic utilizando contenedores Docker.

## ¿Qué imágenes Docker elegir?

El registro Docker de Elastic (<https://www.docker.elastic.co/>) contiene las imágenes de todos los productos del stack.

## Instalación del stack Elastic utilizando docker-compose

Para la instalación del stack Elastic, vamos a utilizar docker-compose. A continuación, podemos ver el fichero docker-compose.yml que utilizaremos.

<div class="wp-block-syntaxhighlighter-code ">```

version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.2
    container_name: elasticsearch
    ports:
      - 9200:9200
      - 9300:9300
    environment:
      cluster.name: elasticsearch-cluster
      node.name: elasticsearch
      bootstrap.memory_lock: true
      ES_JAVA_OPTS: "-Xms512m -Xmx512m"
      discovery.type: single-node
    volumes:
      - ./elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - ./elasticsearch/data:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1

  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.2
    container_name: logstash
    ports:
      - 5044:5044
      - 5000:5000
      - 9600:9600
    environment:
      LS_JAVA_OPTS: "-Xmx256m -Xms256m"
    volumes:
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml
      - ./logstash/pipeline/logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.2
    container_name: kibana
    ports:
      - 5601:5601
    volumes:
      - ./kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml
    depends_on:
      - elasticsearch
```

</div>A continuación, paso a explicar el código de este fichero docker-compose:

- De las líneas 4 a la 22 se describe el servicio elasticsearch.
- En la línea 5 se indica el repositorio y el tag de la imagen de Elasticsearch que se va a utilizar. Como se puede ver, vamos a obtener las imágenes del registro Docker de Elastic.
- En la línea 6 indicamos que nombre va a tener el contenedor de Elasticsearch. En este caso elasticsearch.
- De las líneas 7 a la 9 mapeamos los puertos que utiliza Elasticsearch. Concretamente los puertos 9200 y 9300.
- De las líneas 10 a la 15 se establecen las variables de entorno que tendrá el contenedor del servicio elasticsearch, como el nombre del cluster, el nombre del nodo o la memoria heap con la que se levantará el proceso Java con el que se ejecuta Elasticsearch.
- En la línea 13 se habilita el bloqueo del espacio de direcciones del proceso en la RAM para evitar que la memoria heap de Elasticsearch pase a la memoria swap. Esto se hace para mejorar la estabilidad y el rendimiento del nodo.
- En la línea 15 se indica que el cluster tendrá un único nodo.
- De las líneas 16 a la 18 se mapean los volúmenes del contenedor eleasticsearch.
- En la línea 17 se mapea el volumen que contendrá el fichero de configuración de Elasticsearch (elasticsearch.yml).
- En la línea 18 se mapea el volumen que contendrá los datos de Elasticsearch, de tal forma que, si se reinicia el contenedor, los datos persistirán en el volumen y volverán a ser accesibles a través de una nueva instancia del contenedor.
- De las líneas 19 a la 22 se utiliza ulimit para deshabilitar la memoria swap. Ulimit permite controla la cantidad máxima de recursos del sistema que se pueden asignar a los procesos en ejecución.
- De las líneas 24 a la 37 se describe el servicio logstash.
- En la línea 25 se indica el repositorio y el tag de la imagen de Logstash que se va a utilizar.
- En la línea 26 se indica qué nombre va a tener el contenedor de Logstash.
- De las líneas 27 a la 30 mapeamos los puertos que utiliza Logstash.
- En la línea 32 se establece la variable de entorno en la que se indica con cuanta memoria heap se levantará el proceso Java con el que se ejecuta Logstash.
- De las líneas 33 a la 35 se mapean los volúmenes del contenedor logstash.
- En la línea 34 se mapea el volumen que contendrá el fichero de configuración de Logstash (logstash.yml).
- En la línea 35 se mapea el volumen que contendrá la configuración del pipeline de procesamiento de datos que va a llevar a cabo Logstash (logstash.conf).
- En las líneas 36 y 37 se establece una dependencia del servicio logstash respecto al servicio elasticsearch, de forma que se arranque el servicio elasticsearch antes que el servicio logstash. Esto tiene que ser así porque Logstash necesita conectarse a Elasticsearch para empezar a reenviarle los eventos que procesa, por lo que ha de estar iniciado Elasticsearch para que se pueda establecer esta conexión.
- De las líneas 39 a la 47 se describe el servicio kibana.
- En la línea 40 se indica el repositorio y el tag de la imagen de Kibana que se va a utilizar.
- En la línea 41 se indica qué nombre va a tener el contenedor de Kibana.
- En las líneas 42 y 43 mapeamos los puertos que utiliza Kibana. En este caso únicamente el puerto 5601.
- En las líneas 44 y 45 se mapea el volumen que contendrá el fichero de configuración de Kibana (kibana.yml).
- En las líneas 46 y 47 se establece una dependencia del servicio kibana respecto al servicio elasticsearch, de forma que se arranque el servicio elasticsearch antes que el servicio kibana. Esto es así porque Kibana se conecta a Elasticsearch para poder mostrar los datos almacenados en Elasticsearch, por lo que, al igual que pasaba con Logstash, ha de estar iniciado Elasticsearch para que se pueda establecer la conexión.

En el caso de la configuración de Kibana, cabe destacar que se pueden utilizar tanto variables de entorno como pares clave valor en el fichero de configuración kibana.yml. En el caso de que se utilicen variables de entorno, los nombres de estas variables son los mismos que los de las propiedades del fichero kibana.yml a las que sustituyen, pero con mayúsculas y caracteres punto (.) en lugar de subrayados (\_).

Podéis consultar esto con más detalle en el siguiente enlace de la documentación de Elastic: <https://www.elastic.co/guide/en/kibana/current/docker.html#environment-variable-config>

### Instrucciones

Para arrancar los contenedores del stack Elastic, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose up -d
```

</div>Para verificar que los tres contenedores se están ejecutando correctamente, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose ps
NAME                COMMAND                  SERVICE             STATUS              PORTS
elasticsearch       "/bin/tini -- /usr/l…"   elasticsearch       running             0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp
kibana              "/bin/tini -- /usr/l…"   kibana              running             0.0.0.0:5601->5601/tcp
logstash            "/usr/local/bin/dock…"   logstash            running             0.0.0.0:5000->5000/tcp, 0.0.0.0:5044->5044/tcp, 0.0.0.0:9600->9600/tcp
```

</div>Para visualizar los logs, ejecutamos el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker-compose logs -f
```

</div>## Comprobación del funcionamiento del stack Elastic

Una vez arrancados los tres contenedores del stack Elastic, para comprobar si el stack está funcionando correctamente, podemos seguir las instrucciones que se detallan a continuación.

### Elasticsearch

Abrimos un navegador y accedemos a http://localhost:9200. Deberíamos ver una salida similar a la mostrada en la siguiente captura de pantalla.

<figure class="wp-block-image size-full">[![Instalación del stack Elastic con Docker](https://aprenderdevops.com/wp-content/uploads/2021/11/elastic-docker-2.png)](https://aprenderdevops.com/wp-content/uploads/2021/11/elastic-docker-2.png)</figure>### Logstash

A continuación, se muestra el fichero <meta charset="utf-8"></meta>[logstash/pipeline/logstash.conf](https://github.com/aprenderdevops/docker-elastic/blob/main/logstash/pipeline/logstash.conf), que contiene la <meta charset="utf-8"></meta>configuración del pipeline que <meta charset="utf-8"></meta>nos va a permitir comprobar el funcionamiento <meta charset="utf-8"></meta>de Logstash.

<div class="wp-block-syntaxhighlighter-code ">```

input {
  heartbeat {
    message => "ok"
    interval => 5
    type => "heartbeat"
  }
}

output {
  if [type] == "heartbeat" {
    elasticsearch {
      hosts => "elasticsearch:9200"
      index => "heartbeat"
    }
  }
  stdout {
    codec => "rubydebug"
  }
}
```

</div>Con esta configuración se genera cada 5 segundos un evento mediante el [plugin heartbeat](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-heartbeat.html).

En este ejemplo no hemos incluido ningún [filter](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html), por lo que, con los eventos generados no se va a realizar ningún tipo de procesamiento o transformación.

En la sección output se configura la salida de los eventos para su envío al índice <meta charset="utf-8"></meta>heartbeat de Elasticsearch cuando estos hayan sido generados por el plugin heartbeat. También se envían todos los eventos por la salida estándar mediante el [plugin stdout](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-stdout.html) utilizando el formato definido por el [códec rubydebug](https://www.elastic.co/guide/en/logstash/current/plugins-codecs-rubydebug.html).

Para comprobar que los eventos de tipo heartbeat se están generando cada 5 segundos y se están enviando a la salida estándar, se puede ejecutar el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ docker logs logstash -n21 -f
{
          "host" => "18ff4068ddbb",
      "@version" => "1",
    "@timestamp" => 2021-11-11T00:10:11.934Z,
          "type" => "heartbeat",
       "message" => "ok"
}
{
          "host" => "18ff4068ddbb",
      "@version" => "1",
    "@timestamp" => 2021-11-11T00:10:16.935Z,
          "type" => "heartbeat",
       "message" => "ok"
}
{
          "host" => "18ff4068ddbb",
      "@version" => "1",
    "@timestamp" => 2021-11-11T00:10:21.935Z,
          "type" => "heartbeat",
       "message" => "ok"
}
```

</div>La salida de este comando deberá mostrar cada 5 segundos un nuevo evento de tipo heartbeat.

Para comprobar que los eventos también se están enviado a Elasticsearch, se puede ejecutar el siguiente comando:

<div class="wp-block-syntaxhighlighter-code ">```

$ curl -XGET "http://localhost:9200/heartbeat/_search?pretty=true" -H 'Content-Type: application/json' -d'{"size": 1}'
{
  "took" : 693,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 148,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "heartbeat",
        "_type" : "_doc",
        "_id" : "3NEq_HwB8PSqowAaUkI_",
        "_score" : 1.0,
        "_source" : {
          "type" : "heartbeat",
          "message" : "ok",
          "host" : "e66d07ee3402",
          "@timestamp" : "2021-11-07T20:50:04.374Z",
          "@version" : "1"
        }
      }
    ]
  }
}
```

</div>La salida de este comando deberá mostrar el primer evento de tipo heartbeat generado.

### Kibana

Para comprobar el correcto funcionamiento de Kibana, abrimos un navegador y accedemos a http://localhost:5601. Esto debería abrir la consola de Kibana, tal y como se muestra en la siguiente captura de pantalla.

<figure class="wp-block-image size-large">[![Instalación del stack Elastic con Docker](https://aprenderdevops.com/wp-content/uploads/2021/11/elastic-docker-3-1024x788.png)](https://aprenderdevops.com/wp-content/uploads/2021/11/elastic-docker-3.png)</figure>## Código fuente del laboratorio

Podéis descargar o clonar el código fuente completo de este laboratorio de GitHub de <https://github.com/aprenderdevops/docker-elastic>.