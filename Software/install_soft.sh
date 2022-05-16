#!/bin/bash
set -x 
## Actualizamos paquetes del equipo:

sudo yum list updates -y
sudo yum update -y

# Instalación Apache HTTP Server:

## Actualizamos el paquete httpd local de Apache:

sudo yum update httpd -y

## Instalamos Apache:

sudo yum install httpd -y

## Iniciamos el servicio de Apache:

sudo systemctl start httpd

## Habilitamos su ejecución cada vez que el sistema arranque:

sudo systemctl enable httpd

## Creamos la estructura de directorios necesaria:

sudo mkdir -p /var/www/practica1iaw.ddns.net/public_html/

## Asignamos permisos:

sudo chown -R apache. /var/www/
sudo chmod -R 755 /var/www/$DNS

## Añadimos línea IncludeOptional:

echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf

## Creamos los archivos .conf:

sudo mkdir /etc/httpd/sites-available
sudo mkdir /etc/httpd/sites-enabled

## Configuramos el host virtual:

## -Archivo sites-Available:
cd /etc/httpd/sites-available/
echo "
<VirtualHost *:80>
ServerAdmin practica-1@practica1iaw.ddns.net
ServerName www.practica1iaw.ddns.net
ServerAlias practica1iaw.ddns.net
DocumentRoot /var/www/practica1iaw.ddns.net/public_html
ErrorLog /var/www/practica1iaw.ddns.net/error.log
CustomLog /var/www/practica1iaw.ddns.net/access.log combined
</Virtualhost>" >> practica1iaw.ddns.net.conf

## -Creamos enlace simbólico sobre sites-enabled:
ln -s /etc/httpd/sites-available/$DNS.conf /etc/httpd/sites-enabled/$DNS.conf

## Reiniciamos Apache2:

sudo systemctl restart httpd.service



# Instalación PostgreSQL:

## Antes de instalar configuramos el repositorio:

sudo yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

## Actualizamos repositorios:

sudo yum update -y

## Instalamos PostgreSQL:

sudo yum -y install postgresql14-server

## Iniciamos el servicio y habilitamos su inicio junto al arranque del sistema:

sudo systemctl start postgresql-14

sudo systemctl enable postgresql-14

## Configuramos PostgreSQL para que el acceso desde la red sea mediante usuario y contraseña:

sudo sed 's/scram-sha-256/md5/' /var/lib/pgsql/14/data/pg_hba.conf

## Configuramos las direcciones de escucha de PostgreSQL:

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/14/data/postgresql.conf
sudo sed -i 's/#port = 5432/port = 5432/' /var/lib/pgsql/14/data/postgresql.conf

## Recargamos la configuración de PostgreSQL:

sudo systemctl reload postgresql-14

## Creamos un usuario de la base de datos:

sudo -u postgres psql <<< "CREATE USER usupractica1 ENCRYPTED PASSWORD 'practica1pass';"
<<< "CREATE DATABASE practica1 OWNER usupractica1;"
<<< "GRANT ALL PRIVILEGES ON DATABASE practica1 TO usupractica1;"
\q


# Instalamos phpPgAdmin:

##Instalamos y configuramos los repositorios EPEL y Remi:

sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y


## Instalamos PHP y extensiones necesarias para phpPgAdmin:

sudo yum install php php-pgsql php-mbstring -y

## Instalamos las Yum Utils y habilitamos el repositorio para php 7.2:

sudo yum install yum-utils -y
sudo yum-config-manager --enable remi-php72

## Actualizamos los paquetes de PHP:

sudo yum update -y

## Instalamos el paquete phpPgAdmin:

sudo yum install phpPgAdmin -y

## Lo configuramos como accesible desde el exterior sustituyendo los siguientes parámetros:

## -Del archivo phpPgAdmin.conf:

sudo sed -i 's/Require local/Require all granted/' /etc/httpd/conf.d/phpPgAdmin.conf
sudo sed -i 's/Deny from all/Allow from all/' /etc/httpd/conf.d/phpPgAdmin.conf

## -Del archivo config.inc.php:

sudo sed -i 's/$conf['servers'][0]['host'] = '';/$conf['servers'][0]['host'] = 'localhost';/' /etc/phpPgAdmin/config.inc.php
sudo sed -i 's/$conf['owned_only'] = false;/$conf['owned_only'] = true;/' /etc/phpPgAdmin/config.inc.php

## Recargamos los servicios de PostgreSQL y httpd:

sudo systemctl start postgresql-14.service
sudo systemctl reload httpd.service



# Herramientas Adicionales (AWStats, Certbot, htaccess...):

## Actualizamos la lista de repositorios:

sudo yum repolist -y

## Instalamos mod_perl (necesario para trabajar con Awstats):

sudo yum install mod_perl -y

## Instalamos AWStats:

sudo yum --enablerepo=epel install awstats -y 

## Modificamos el archivo de configuración de Awstats y permitimos la conexión desde cualquier IP:

sed -i 's/Require local/Require host 0.0.0.0/' /etc/httpd/conf.d/awstats.conf
sed -i 's/from 127.0.0.1/from 0.0.0.0/' /etc/httpd/conf.d/awstats.conf

## Copiamos el archivo de configuración cambiándole el nombre por nuestro dominio:

sudo cp /etc/awstats/awstats.localhost.localdomain.conf /etc/awstats/awstats.$DNS.conf

## Editamos los siguientes valores en el archivo:
## Revisar ruta archivos log apache 
sed -i 's/LogFile="/var/log/httpd/access_log"/LogFile="/var/log/httpd/practica1iaw.ddns.net-access_log"/' /etc/awstats/awstats.$DNS.conf
sed -i 's/SiteDomain="localhost.localdomain"/SiteDomain="practica1iaw.ddns.net"/' /etc/awstats/awstats.$DNS.conf
sed -i 's/HostAliases="localhost 127.0.0.1"/HostAliases="practica1iaw.net www.practica1iaw.ddns.net"/' /etc/awstats/awstats.practica1iaw.ddns.net.conf

## Actualizamos los archivos de registro:

perl /usr/share/awstats/wwwroot/cgi-bin/awstats.pl -config=practica1iaw.ddns.net -update

## Programamos Cron para actualizar registros:

0 2 * * * /usr/bin/perl /usr/share/awstats/wwwroot/cgi-bin/awstats.pl -config=practica1iaw.ddns.net -update >> /etc/crontab
sudo systemctl start crond.service
sudo systemctl enable crond.service

## Instalación Certbot:

## Instalamos los paquetes necesarios:

sudo yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional 
sudo yum install certbot python2-certbot-apache mod_ssl -y

## Instalamos Certbot:

sudo yum install certbot -y 

## Ejecutamos Certbot para conseguir el certificado:
## Automatizar respuestas a certbot:
sudo certbot --apache -d practica1iaw.ddns.net 

## Reiniciamos apache:

sudo service httpd restart


## Directorios con htaccess:

## Editamos el archivo /etc/httpd/conf/httpd.conf:

sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

## Creamos un directorio al que pondremos clave con htaccess:

sudo mkdir /var/www/html/prueba1

## Instalamos los paquetes necesarios para proteger el directorio con clave y reiniciamos el servicio:

sudo yum install mod_auth_shadow -y
sudo systemctl restart httpd

## Creamos un archivo htaccess dentro del directorio:

sudo echo "AuthName 'descargas'
AuthShadow on
AuthBasicAuthoritative off
AuthType Basic
AuthUserFile /dev/null
require valid-user" >> /var/www/html/prueba1/.htaccess
