---
id: 101
title: 'Instalación de GitLab con Ansible en una máquina con CentOS 7 provisionada con Vagrant'
date: '2017-12-06T14:45:09+01:00'
author: Arturo
layout: post
guid: 'http://aprenderdevops.com/?p=101'
permalink: /instalacion-gitlab-ansible-una-maquina-centos-7-provisionada-vagrant/
image: /wp-content/uploads/2017/12/gitlab-ansible.png
categories:
    - 'Infraestructura como código'
tags:
    - ansible
    - centos
    - gitlab
    - vagrant
    - virtualbox
---

En esta entrada vamos a ver cómo instalar GitLab CE (Community Edition) en una máquina con sistema operativo CentOS 7 utilizando Ansible. La máquina con CentOS será una máquina virtual que provisionaremos con Vagrant.

## ¿Qué es GitLab?

[GitLab](https://about.gitlab.com/) es un servicio web de control de versiones y desarrollo de software colaborativo basado en [Git](https://git-scm.com/). Además de gestor de repositorios, el servicio ofrece también alojamiento de wikis y un sistema de seguimiento de errores.

Inicialmente GitLab se publicó como un software completamente libre bajo la licencia MIT. Sin embargo, a partir de julio de 2013 el proyecto se dividió en dos versiones distintas: GitLab CE (Community Edition) y GitLab EE (Enterprise Edition). La versión Enterprise cuenta con características que no están disponibles en la versión libre.

## ¿Qué es Ansible?

[Ansible](https://www.ansible.com/) es una herramienta open source desarrollada en [Python](https://www.python.org/) que se utiliza para orquestar y automatizar tareas de provisión, configuración y administración de sistemas. Todas las tareas a automatizar se describen en lenguaje [YAML](https://es.wikipedia.org/wiki/YAML). Esto permite que nuestra infraestructura pueda ser tratada como código y que por ejemplo pueda gestionarse mediante un sistema de control de versiones.

## ¿Qué es Vagrant?

[Vagrant](https://www.vagrantup.com/) es una herramienta open source que permite crear y configurar máquinas virtuales de forma muy sencilla a partir de simples ficheros de configuración.

## ¿Qué necesitáis para hacer este laboratorio?

Para hacer este laboratorio necesitáis tener en un equipo o en un servidor al que tengáis acceso el siguiente software:

- Vagrant.
- [VirtualBox](https://www.virtualbox.org/) u otro software de virtualización compatible con Vagrant.
- Ansible.

A continuación, vamos a ver los pasos necesarios para hacer el laboratorio.

## Provisión de la máquina virtual con CentOS 7 mediante Vagrant

En el directorio en el que vamos a ubicar el Vagrantfile ejecutamos el siguiente comando:

```
$ vagrant init -m centos/7
```

Esto nos genera el siguiente Vagrantfile minimo:

```
Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
end
```

Lo editamos para añadir más configuración. El Vagrantfile definitivo debería ser muy similar al siguiente:

```
Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.boot_timeout = 120
    config.vm.hostname = "gitlab"
    
    config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
        vb.name = "gitlab"
    end
    
    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "provision/install.yml"
        ansible.host_key_checking = false
        ansible.sudo = true
        ansible.tags = ['gitlab']
    end
    
    config.vm.network "private_network", ip: "192.168.107.20"
    config.vm.network "forwarded_port", host: 8080, guest: 80, autocorrect: true
end
```

A continuación, vamos a explicar para qué sirven las líneas más relevantes de este Vagrantfile:

- En la línea 2 se indica que la máquina virtual que vamos a instalar y configurar es una máquina con sistema operativo CentOS 7.
- En las líneas 4 y 9 se especifica el nombre de la máquina, tanto a nivel de sistema operativo (salida del comando hostname) como a nivel de provider de virtualización (en este caso VirtualBox).
- En las líneas 7 y 8 se establecen los recursos de memoria y CPU respectivamente que vamos a asignar a la máquina virtual. Los recursos asignados dependerán en cada caso de los recursos disponibles en el servidor anfitrión.
- De las líneas 12 a la 17 se provisiona mediante un playbook Ansible la instalación y configuración de GitLab. De esta forma se puede ejecutar un playbook desde Vagrant tras la creación de la máquina virtual. Lo veremos más en detalle en los siguientes párrafos.
- En la línea 19 se establece una dirección IP dentro de una red privada.
- En la línea 20 se configura la redirección del puerto 80 (puerto por defecto en el que escucha GitLab) hacia el puerto de la máquina host que decidamos (en este caso 8080 pero podría ser otro puerto que estuviera libre).

## Playbooks Ansible para la instalación de GitLab CE

La estructura de ficheros del proyecto es la siguiente:

```
README.md
Vagrantfile
provision/roles/gitlab/vars/RedHat.yml
provision/roles/gitlab/vars/Debian.yml
provision/roles/gitlab/tasks/main.yml
provision/roles/gitlab/defaults/main.yml
provision/roles/gitlab/templates/gitlab.rb.j2
provision/roles/gitlab/handlers/main.yml
provision/hosts/all
provision/install.yml
```

A continuación, vamos a ir viendo los distintos ficheros del proyecto.

En el subdirectorio provision tendremos los playbooks Ansible que va a ejecutar Vagrant para la instalación de GitLab CE. Más concretamente, tenemos el fichero install.yml, que es el playbook que a su vez invoca al role que instala y configura GitLab CE.

Además de este fichero, tenemos dos subdirectorios:

- hosts, que incluirá el inventario de máquinas en las que se van a ejecutar los playbooks. En este caso sólo contiene una máquina.
- roles, que definen las distintas tareas a ejecutar para la instalación GitLab.

### Inventario

En el fichero all, dentro del directorio hosts, se incluye el inventario de máquinas en las que se va a instalar GitLab. En este caso sólo contiene la máquina virtual creada con Vagrant. Por lo tanto, la dirección IP debe coincidir con la dirección IP privada que hayamos definido en el Vagrantfile.

```
[gitlab]
192.168.107.20
```

### Playbook install.yml

Como ya hemos comentado, el fichero install.yml contiene el playbook invocado desde Vagrant para la instalación y configuración de GitLab. Este fichero, además de indicar el inventario sobre el que se aplicarán las tareas de automatización, relaciona el tag referenciado en el Vagrantfile con el role que se va a ejecutar. En este caso, tanto el tag como el role se llaman gitlab.

```
---
- hosts: all
  
  roles:
    - { role: gitlab, tags: gitlab }
```

En este proyecto tenemos un único role, pero podríamos tener varios, en cuyo caso se incluiría una línea por cada role, y el orden de ejecución de los roles sería secuencial.

El directorio provision/roles/gitlab contiene todo el código del role gitlab. A continuación, vamos a ver los distintos ficheros que contienen este código.

### Variables específicas del sistema operativo

Aunque en este laboratorio estamos instalando GitLab sobre una máquina con sistema operativo CentOS 7, el role gitlab está escrito de tal forma que funciona sobre cualquier sistema operativo Linux, ya sea basado en RedHat, como es el caso de CentOS 7, o en Debian, como podría ser Ubuntu.

Como la URL del repositorio en la que se encuentra el script de instalación es distinta para sistemas basados en RedHat de la URL para sistemas basados en Debian, dentro del directorio provision/roles/gitlab/vars se define un fichero para cada familia de sistema operativo. De esta forma, en cada uno de estos ficheros se define la variable gitlab\_repository\_installation\_script\_url que contendrá la URL correspondiente en cada caso.

Para probarlo con otro sistema operativo, sólo habría que sustituir la cadena [«centos/7»](https://app.vagrantup.com/centos/boxes/7) en la línea 2 del Vagrantfile por otra que haga referencia a otro sistema operativo, por ejemplo [«bento/ubuntu-16.04»](https://app.vagrantup.com/bento/boxes/ubuntu-16.04) o [«debian/jessie64»](https://app.vagrantup.com/debian/boxes/jessie64).

Debian.yml

```
---
gitlab_repository_installation_script_url: https://packages.gitlab.com/install/repositories/gitlab/{{ gitlab_edition }}/script.deb.sh
```

RedHat.yml

```
---
gitlab_repository_installation_script_url: https://packages.gitlab.com/install/repositories/gitlab/{{ gitlab_edition }}/script.rpm.sh
```

Es importante resaltar que en cada fichero, la URL contiene a su vez una variable que hace referencia a la edición de GitLab que vamos a instalar. En este laboratorio vamos a instalar la edición Community Edition.

Para instalar GitLab EE (Enterprise Edition) en lugar de la edición CE, sólo hay que cambiar en el fichero provision/roles/gitlab/defaults/main.yml la línea gitlab\_edition: «gitlab-ce» por gitlab\_edition: «gitlab-ee».

### Variables

El directorio provision/roles/gitlab/defaults contiene un fichero main.yml en el que se definen las distintas variables que se van a utilizar en el código del role, como la URL de acceso a GitLab, la edición que se va a instalar, el directorio que contiene los repositorios Git, y otras muchas variables.

{% raw %}
```
---
# Configuración general
gitlab_external_url: "http://localhost/"
gitlab_git_data_dir: "/var/opt/gitlab/git-data"
gitlab_edition: "gitlab-ce"
gitlab_backup_path: "/var/opt/gitlab/backups"

# Configuración SSL
gitlab_redirect_http_to_https: "false"
gitlab_ssl_certificate: "/etc/gitlab/ssl/gitlab.crt"
gitlab_ssl_certificate_key: "/etc/gitlab/ssl/gitlab.key"

# Configuración de certificados SSL autofirmados
gitlab_create_self_signed_cert: "false"
gitlab_self_signed_cert_subj: "/C=ES/ST=Madrid/L=Madrid/O=IT/CN=gitlab"

# Configuración LDAP
gitlab_ldap_enabled: "false"
gitlab_ldap_host: "example.com"
gitlab_ldap_port: "389"
gitlab_ldap_uid: "sAMAccountName"
gitlab_ldap_method: "plain"
gitlab_ldap_bind_dn: "CN=Username,CN=Users,DC=example,DC=com"
gitlab_ldap_password: "password"
gitlab_ldap_base: "DC=example,DC=com"

# Configuración SMTP
gitlab_smtp_enable: "false"
gitlab_smtp_address: "smtp.server"
gitlab_smtp_port: "465"
gitlab_smtp_user_name: "smtp user"
gitlab_smtp_password: "smtp password"
gitlab_smtp_domain: "example.com"
gitlab_smtp_authentication: "login"
gitlab_smtp_enable_starttls_auto: "true"
gitlab_smtp_tls: "false"
gitlab_smtp_openssl_verify_mode: "none"
gitlab_smtp_ca_path: "/etc/ssl/certs"
gitlab_smtp_ca_file: "/etc/ssl/certs/ca-certificates.crt"

# Autenticación de cliente 2-way SSL
gitlab_nginx_ssl_verify_client: ""
gitlab_nginx_ssl_client_certificate: ""

# Configuraciones opcionales
gitlab_time_zone: "UTC"
gitlab_backup_keep_time: "604800"
gitlab_download_validate_certs: "false"

# Configuración de email
gitlab_email_enabled: "false"
gitlab_email_from: "gitlab@example.com"
gitlab_email_display_name: "Gitlab"
gitlab_email_reply_to: "gitlab@example.com"
```
{% endraw %}

### Tareas del role

El directorio provision/roles/gitlab/tasks contiene un fichero main.yml en el que se detallan las tareas de instalación y configuración de GitLab.

{% raw %}
```
---
- name: Incluir variables específicas del sistema operativo
  include_vars: "{{ ansible_os_family }}.yml"

- name: Comprobar si el archivo de configuración de GitLab ya existe
  stat: path=/etc/gitlab/gitlab.rb
  register: gitlab_config_file

- name: Comprobar si GitLab ya está instalado
  stat: path=/usr/bin/gitlab-ctl
  register: gitlab_file

- name: Instalar dependencias de GitLab
  package: name={{ item }} state=installed
  with_items:
    - openssh-server
    - postfix
    - curl
    - openssl

- name: Descargar el script de instalación del repositorio de GitLab
  get_url:
    url: "{{ gitlab_repository_installation_script_url }}"
    dest: /tmp/gitlab_install_repository.sh
    validate_certs: "{{ gitlab_download_validate_certs }}"
  when: (gitlab_file.stat.exists == false)

- name: Instalar el repositorio de GitLab
  command: bash /tmp/gitlab_install_repository.sh
  when: (gitlab_file.stat.exists == false)

- name: Instalar GitLab
  package: name={{ gitlab_edition }} state=installed
  when: (gitlab_file.stat.exists == false)

- name: Reconfigurar GitLab (primera ejecución)
  command: >
    gitlab-ctl reconfigure
    creates=/var/opt/gitlab/bootstrapped
  failed_when: false

- name: Crear la carpeta de configuración de GitLab SSL
  file:
    path: /etc/gitlab/ssl
    state: directory
    owner: root
    group: root
    mode: 0700
  when: gitlab_create_self_signed_cert

- name: Crear certificado autofirmado
  command: >
    openssl req -new -nodes -x509 -subj "{{ gitlab_self_signed_cert_subj }}" -days 3650 -keyout {{ gitlab_ssl_certificate_key }} -out {{ gitlab_ssl_certificate }} -extensions v3_ca
    creates={{ gitlab_ssl_certificate }}
  when: gitlab_create_self_signed_cert

- name: Copiar el archivo de configuración de GitLab
  template:
    src: gitlab.rb.j2
    dest: /etc/gitlab/gitlab.rb
    owner: root
    group: root
    mode: 0600
  notify: Reiniciar GitLab
```
{% endraw %}

Aunque el código es bastante explicativo, vamos a ver para que sirven algunas de las líneas de este fichero:

- En la línea 3 se incluyen las variables contenidas en el fichero correspondiente a la familia de sistema operativo en el que se ejecuta el playbook Ansible. Para ello, se hace uso de la variable {{ ansible\_os\_family }} que nos indica la familia del sistema operativo en el que se está ejecutando el playbook. Para CentOS 7 el valor de esta variable es «RedHat», por lo que en este caso se cargan las variables contenidas en el fichero RedHat.yml.
- De las líneas 5 a la 11 se comprueba si ya existe el fichero de configuración de GitLab y si GitLab ya está instalado.
- De las líneas 13 a la 19 se instalan los paquetes de sistema operativo necesarios para el correcto funcionamiento de GitLab.
- De las líneas 21 a la 30 se descarga el script de instalación del repositorio de GitLab, lo deja en el directorio /tmp y lo ejecuta para instalar el repositorio.
- En la línea 33 se instala el paquete de GitLab.
- De las líneas 36 a la 40 se reinicia GitLab.
- De las líneas 42 a la 55 se configura el acceso a GitLab mediante certificado SSL autofirmado siempre que la variable gitlab\_create\_self\_signed\_cert sea true.
- De las líneas 57 a la 63 se copia el fichero de configuración de GitLab. Para copiar el fichero de configuración se utiliza una plantilla o template con formato Jinja2 ubicada en provision/roles/gitlab/templates/gitlab.rb.j2. Los valores de esta plantilla son sustituidos por los valores establecidos en las variables del directorio provision/roles/gitlab/defaults.
- Por último, en la línea 64 se solicita el reinicio de GitLab para que se haga efectiva la nueva configuración. Este reinicio se realiza mediante un handler definido en provision/roles/gitlab/handlers/main.yml.

A continuación, podéis ver el código del template y el del handler para el reinicio de GitLab.

### Template gitlab.rb.j2

{% raw %}
```
# URL a través de la cual se accederá a GitLab
external_url "{{ gitlab_external_url }}"

# gitlab.yml
gitlab_rails['time_zone'] = "{{ gitlab_time_zone }}"
gitlab_rails['backup_keep_time'] = {{ gitlab_backup_keep_time }}
gitlab_rails['gitlab_email_enabled'] = {{ gitlab_email_enabled }}
{% if gitlab_email_enabled == "true" %}
gitlab_rails['gitlab_email_from'] = "{{ gitlab_email_from }}"
gitlab_rails['gitlab_email_display_name'] = "{{ gitlab_email_display_name }}"
gitlab_rails['gitlab_email_reply_to'] = "{{ gitlab_email_reply_to }}"
{% endif %}

# Redirección de http a https
nginx['redirect_http_to_https'] = {{ gitlab_redirect_http_to_https }}
nginx['ssl_certificate'] = "{{ gitlab_ssl_certificate }}"
nginx['ssl_certificate_key'] = "{{ gitlab_ssl_certificate_key }}"

# Directorio donde se almacenarán los repositorios de Git
git_data_dirs({"default" => "{{ gitlab_git_data_dir }}"})

# Directorio donde se guardarán las copias de seguridad de Gitlab
gitlab_rails['backup_path'] = "{{ gitlab_backup_path }}"

# Esta configuración está documentada con más detalle en
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/config/gitlab.yml.example#L118
gitlab_rails['ldap_enabled'] = {{ gitlab_ldap_enabled }}
gitlab_rails['ldap_host'] = '{{ gitlab_ldap_host }}'
gitlab_rails['ldap_port'] = {{ gitlab_ldap_port }}
gitlab_rails['ldap_uid'] = '{{ gitlab_ldap_uid }}'
gitlab_rails['ldap_method'] = '{{ gitlab_ldap_method}}' # 'ssl' or 'plain'
gitlab_rails['ldap_bind_dn'] = '{{ gitlab_ldap_bind_dn }}'
gitlab_rails['ldap_password'] = '{{ gitlab_ldap_password }}'
gitlab_rails['ldap_allow_username_or_email_login'] = true
gitlab_rails['ldap_base'] = '{{ gitlab_ldap_base }}'

# GitLab Nginx
## See https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md
{% if gitlab_nginx_listen_port is defined %}
nginx['listen_port'] = "{{ gitlab_nginx_listen_port }}"
{% endif %}
{% if gitlab_nginx_listen_https is defined %}
nginx['listen_https'] = "{{ gitlab_nginx_listen_https }}"
{% endif %}

# Usar smtp en lugar de sendmail/postfix
# Más detalles y ejemplo de configuración en
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/smtp.md
gitlab_rails['smtp_enable'] = {{ gitlab_smtp_enable }}
gitlab_rails['smtp_address'] = '{{ gitlab_smtp_address }}'
gitlab_rails['smtp_port'] = {{ gitlab_smtp_port }}
gitlab_rails['smtp_user_name'] = '{{ gitlab_smtp_user_name }}'
gitlab_rails['smtp_password'] = '{{ gitlab_smtp_password }}'
gitlab_rails['smtp_domain'] = '{{ gitlab_smtp_domain }}'
gitlab_rails['smtp_authentication'] = '{{ gitlab_smtp_authentication }}'
gitlab_rails['smtp_enable_starttls_auto'] = {{ gitlab_smtp_enable_starttls_auto }}
gitlab_rails['smtp_tls'] = {{ gitlab_smtp_tls }}
gitlab_rails['smtp_openssl_verify_mode'] = '{{ gitlab_smtp_openssl_verify_mode }}'
gitlab_rails['smtp_ca_path'] = '{{ gitlab_smtp_ca_path }}'
gitlab_rails['smtp_ca_file'] = '{{ gitlab_smtp_ca_file }}'

# Autenticación de cliente 2-way SSL
{% if gitlab_nginx_ssl_verify_client %}
nginx['ssl_verify_client'] = "{{ gitlab_nginx_ssl_verify_client }}"
{% endif %}
{% if gitlab_nginx_ssl_client_certificate %}
nginx['ssl_client_certificate'] = "{{ gitlab_nginx_ssl_client_certificate }}"
{% endif %}

# Para cambiar otras configuraciones, consultar:
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md#changing-gitlab-yml-settings
```
{% endraw %}

### Handler

```
---
- name: Reiniciar GitLab
  command: gitlab-ctl reconfigure
  register: gitlab_restart
  failed_when: gitlab_restart.rc != 0
```

## Instrucciones

Para crear y arrancar la máquina virtual y lanzar la instalación de GitLab ejecutamos el siguiente comando:

```
$ vagrant up
```

Una vez arrancada la máquina virtual e instalado GitLab, abrimos un navegador web y accedemos a http://localhost:8080 para entrar en la consola de administración de GitLab.

## Código fuente del laboratorio

Podéis descargar o clonar de GitHub el código fuente completo de este laboratorio de <https://github.com/aprenderdevops/ansible-gitlab>.