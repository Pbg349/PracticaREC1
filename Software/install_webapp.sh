# Descargamos y desplegamos Moodle:
# Pagina oficial moodle y terminar de hacerlo: w
## Creamos un directorio para la Web-App y le asignamos permisos:
## Dar permiso a usuario y grupo:
sudo mkdir -p /var/www/plataforma/moodledata
sudo chown apache: /var/www/plataforma
sudo chmod 770 /var/www/moodledata

## Cambiamos permisos para que Apache escriba en webroot:

chmod 770 /var/www/html
chgrp apache /var/www/html
chcon -t httpd_sys_rw_content_t /var/www/html


## Descarga y desplegue de Moodle: