# Introduction

This is a set of build files including a Dockerfile to build a container image for nginx and php-fpm based on [Alpine Linux](https://github.com/gliderlabs/docker-alpine) to keep the size of the container small, and inspired by the work done by [Ric Harvey](https://github.com/ngineered/nginx-php-fpm). The container can also use environment variables to configure your web application using the templating detailed in the special features section.

## Git repository
The source files for this project can be found here: https://github.com/kabudu/nginx-php-fpm

If you have any improvements please submit a pull request.

## Docker hub repository

The Docker hub build can be found here: https://registry.hub.docker.com/u/boxedcode/nginx-php-fpm/

## Nginx versions
* Stable Version: **1.8.0**
* Latest = **1.8.0**

## Installation

Pull the image from the docker index rather than downloading the git repo. This prevents you having to build the image on every docker host.

docker pull boxedcode/nginx-php-fpm:latest

To pull the Stable Version:

docker pull boxedcode/nginx-php-fpm:stable

## Run the container

To simply run the container:

    sudo docker run --name nginx -p 8080:80 -d boxedcode/nginx-php-fpm

You can then browse to http://<docker_host>:8080 to view the default index.php file.

## Volumes

### Website directory

If you want to link to your web site directory on the docker host to the container run:

    sudo docker run --name nginx -p 8080:80 -v /your_code_directory:/usr/share/nginx/html -d boxedcode/nginx-php-fpm
    
### Logging

If you want to manage your log files on your docker host, you can link to the nginx log directory in the container by running:

    sudo docker run --name nginx -p 8080:80 -v /your_log_directory:/var/log/nginx -d boxedcode/nginx-php-fpm

### SSL

For SSL enabled sites, create a folder on your docker host containing your SSL certificate and key file, and link it to the SSL directory on the container by running:

    sudo docker run --name nginx -p 8080:80 -v /your_ssl_config_directory:/etc/nginx/ssl -d boxedcode/nginx-php-fpm
    
## Special Features
 
### Templating
 
This container will automatically configure your web application if you template your code. For example, if you want to link to an external MySQL DB you can pass variables directly to the container that will be automatically configured by the container.

Example:

    sudo docker run -e 'MYSQL_HOST=host.x.y.z' -e 'MYSQL_USER=username' -e 'MYSQL_PASS=password' -p 8080:80 -d boxedcode/nginx-php-fpm
    
This will expose the following variables that can be used to template your code.

    MYSQL_HOST=host.x.y.z
    MYSQL_USER=username
    MYSQL_PASS=password
        
To use these variables in a template, do the following in your file:
  
    <?php
    database_host = $$_MYSQL_HOST_$$;
    database_user = $$_MYSQL_USER_$$;
    database_pass = $$_MYSQL_PASS_$$
    ...
    ?>
        
### Skip Templating
        
In order to speed up install time if templating is not required and you have a lot of files in your web root that you don't wish to be scanned, simply include the flag below: -e TEMPLATE_NGINX_HTML=0
 
### Display Errors
 
If you want to display PHP errors on screen for debugging use this feature: -e ERRORS=1

### Template Anything

Yes **ANYTHING**, any variable exposed by the -e flag lets you template your config files. This means you can add redis, mariaDB, memcache or anything you want to your application very easily.