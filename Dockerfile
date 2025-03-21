# Usamos la imagen oficial PHP 8.2 con Apache como base
FROM php:8.2-apache

# Instalamos dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libbz2-dev \
    libzip-dev \
    libsodium-dev \
    libldap2-dev \
    libcurl4-openssl-dev \
    && apt-get clean

# Instalamos las extensiones de PHP necesarias
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli intl exif ldap opcache zip bz2 sodium curl \
    && docker-php-ext-enable opcache

# Habilitamos el módulo de Apache mod_rewrite para reescritura de URLs
RUN a2enmod rewrite

# Configuración adicional de PHP
RUN echo "session.cookie_httponly = 1" >> /usr/local/etc/php/conf.d/zzz-custom.ini \
    && echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/zzz-custom.ini \
    && echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/zzz-custom.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/zzz-custom.ini

# Copiamos la configuración personalizada de Apache
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Copiar todo el contenido de GLPI a la carpeta de Apache
COPY htmlLoc /var/www/html/

# Establecemos los permisos correctos para las carpetas de GLPI
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Si deseas mover el directorio de archivos fuera de la raíz web, puedes hacerlo aquí:
# RUN mkdir -p /var/www/glpi_data && \
#     chown -R www-data:www-data /var/www/glpi_data

# Exponemos el puerto 80 para que sea accesible
EXPOSE 80

# Ejecutamos Apache en el contenedor
CMD ["apache2-foreground"]