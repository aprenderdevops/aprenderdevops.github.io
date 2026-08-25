---
id: 181
title: 'Instalación de Nexus 3 en CentOS 7'
date: '2018-01-13T22:45:43+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=181'
permalink: /instalacion-de-nexus-3-en-centos-7/
image: /assets/images/2018/01/instalacion-nexus.png
categories:
    - 'Integración y entrega continua'
tags:
    - centos
    - nexus
    - 'repositorios de binarios'
---

En esta entrada vamos a ver cómo instalar [Sonatype Nexus Repository OSS 3](https://www.sonatype.com/nexus-repository-oss) en Linux, concretamente en CentOS 7.

## ¿Qué es Sonatype Nexus Repository?

Sonatype Nexus Repository es un gestor de repositorios de componentes binarios de software (artefactos, paquetes, …). Un gestor de repositorios de binarios es una herramienta software diseñada para optimizar la descarga y el almacenamiento de archivos binarios utilizados y producidos en el desarrollo de software.

Un gestor de repositorios de binarios es una pieza esencial dentro de una arquitectura de integración y entrega continua de software.

Otros gestores de repositorios de binarios son:

- [Apache Archiva](https://archiva.apache.org/)
- [JFrog Artifactory](https://jfrog.com/artifactory/)
- [Inedo ProGet](https://inedo.com/proget)
- [MyGet](https://www.myget.org/)
- [Pulp](https://pulpproject.org/)

En el caso de Sonatype Nexus Repository contamos con una versión gratuita ([Nexus Repository OSS](https://www.sonatype.com/nexus-repository-oss)) y otra de pago ([Nexus Repository Pro](https://www.sonatype.com/nexus-repository-sonatype)) que cuenta con más funcionalidades que la versión gratuita y con soporte enterprise.

Sonatype Nexus Repository OSS 3 puede gestionar los siguientes formatos:

- Bower
- **Docker (podemos utilizar Nexus Repository OSS 3 como registro privado de imágenes Docker)**
- Git LFS
- Maven
- npm
- NuGet
- PyPI
- Ruby Gems
- Yum Proxy

## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio únicamente necesitáis tener un equipo con CentOS 7, aunque seguramente funcione también en un equipo con Red Hat Enterprise Linux 7.

Si no tenéis una máquina con CentOS 7, podéis crear una máquina virtual utilizando [Vagrant](https://www.vagrantup.com/), tal y como vimos en la entrada [Instalación de GitLab con Ansible en una máquina con CentOS 7 provisionada con Vagrant](https://aprenderdevops.com/instalacion-gitlab-ansible-una-maquina-centos-7-provisionada-vagrant#vagrant-centos7).

A continuación, vamos a ver los pasos necesarios para instalar Sonatype Nexus Repository OSS 3 en CentOS 7.

## Instalación de Nexus 3 en CentOS 7

Para instalar Nexus 3, accedemos a la máquina CentOS 7 y realizamos los pasos que se indican a continuación.

### Instalación de los paquetes necesarios

Actualizamos los paquetes del sistema.

```console
$ sudo yum update -y
```

Instalamos el paquete wget, necesario para poder descargar el fichero de instalación de Nexus.

```console
$ sudo yum install wget -y
```

### Instalación de Oracle Java 8

Para instalar Oracle Java 8, lo primero que tenemos que hacer es descargar el fichero RPM de instalación.

```console
$ wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http://www.oracle.com/oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-x64.rpm"
```

Una vez descargado el fichero RPM, procedemos a la instalación mediante el comando yum localinstall.

```console
$ sudo yum localinstall jdk-8u152-linux-x64.rpm -y
```

Una vez instalado Oracle Java 8, borramos el fichero RPM.

```console
$ rm jdk-8u152-linux-x64.rpm
```

### Instalación de Nexus 3

Cambiamos al directorio /opt.

```console
$ cd /opt
```

Descargamos la última versión de Sonatype Nexus Repository OSS 3.

```console
$ sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
```

Descomprimimos el fichero descargado.

```console
$ sudo tar xvf latest-unix.tar.gz
```

Una vez descomprimido el fichero de instalación, podemos borrarlo para liberar espacio en disco.

```console
$ sudo rm latest-unix.tar.gz
```

Establecemos un enlace simbólico al directorio de instalación de Nexus.

```console
$ sudo ln -s nexus-3.* nexus
```

### Configuración para que Nexus se ejecute con un usuario distinto de root

Por motivos de seguridad, no se recomienda ejecutar Nexus con usuario root. Creamos un usuario específico para ejecutar Nexus.

```console
$ sudo adduser nexus
```

Cambiamos el propietario de los ficheros de instalación de Nexus al nuevo usuario que hemos creado.

```bash
sudo chown -R nexus:nexus nexus* sonatype-work
```

Editamos el fichero de configuración /opt/nexus/bin/nexus.rc, descomentamos el parámetro run\_as\_user y le ponemos como valor el nombre del nuevo usuario que hemos creado para ejecutar Nexus.

```bash
run_as_user="nexus"
```

### Configuración para ejecutar Nexus como servicio

Para poder ejecutar Nexus como servicio Linux seguimos los siguientes pasos.

Creamos un enlace simbólico para el script de servicio nexus en la carpeta /etc/init.d.

```console
$ sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus
```

Ejecutamos los siguientes comandos para añadir el servicio nexus al arranque.

```console
$ sudo chkconfig --add nexus
$ sudo chkconfig --levels 345 nexus on
```

## Inicio del servicio de Nexus

Para iniciar el servicio de Nexus, ejecutamos el siguiente comando.

```console
$ sudo service nexus start
```

Este comando iniciará el servicio nexus en el puerto 8081.

## Acceso a la consola de Nexus

Para entrar en la consola de Nexus, abrimos un navegador web y accedemos a http://localhost:8081.

[![Consola Nexus Repository OSS 3](/assets/images/2018/01/consola-nexus.png)](/assets/images/2018/01/consola-nexus.png)
{: .aligncenter}

Para iniciar sesión en la consola, lo que nos permitirá administrar Nexus 3, pulsamos en «Sign in» en la esquina superior derecha de la pantalla. Podemos utilizar el usuario y la contraseña predeterminados, que son admin y admin123 respectivamente.