# MyProject - Dockerized PHP & MySQL Application

## Overview

This guide will walk you through setting up a simple Dockerized PHP & MySQL application using `docker-compose` and `nginx`.

### Project Structure

```
myproject/
│── docker-compose.yml
│── nginx/
│   └── default.conf
│── php/
│   └── Dockerfile
│── www/
│   └── index.php
│── static-nginx/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── index.html
```

## Prerequisites

Ensure you have the following installed on your system:

- Docker
- Docker Compose

## Configuration Details

### 1. `docker-compose.yml`

This file defines the services for our application.

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx_server
    restart: always
    ports:
      - "8080:80"
    volumes:
      - ./www:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
      - mysql
    networks:
      - app_network

  php:
    build: ./php
    container_name: php_fpm
    restart: always
    volumes:
      - ./www:/var/www/html
    networks:
      - app_network

  mysql:
    image: mysql:latest
    container_name: mysql_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: mydatabase
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - app_network

  static-nginx:
    build: ./static-nginx
    container_name: static_nginx
    restart: always
    ports:
      - "8081:80"
    networks:
      - app_network

volumes:
  mysql_data:

networks:
  app_network:
```

### Explanation:

- **nginx**: Acts as the web server, serving PHP files via FastCGI.
- **php**: A container running PHP-FPM to execute PHP scripts.
- **mysql**: A MySQL database container.
- **static-nginx**: A separate Nginx server serving static HTML content.
- **Volumes**: Persist MySQL data even if the container is restarted.
- **Networks**: Ensures communication between services.

### 2. `php/Dockerfile`

This file defines how the PHP container is built.

```dockerfile
FROM php:8.2-fpm

# Install required PHP extensions  
RUN docker-php-ext-install pdo pdo_mysql mysqli
```

### Explanation:

- Uses `php:8.2-fpm` as the base image.
- Installs necessary PHP extensions (`pdo`, `pdo_mysql`, `mysqli`).

### 3. `nginx/default.conf`

This file configures the Nginx web server.

```nginx
server {
    listen 80;
    server_name localhost;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

### 4. `www/index.php`

A basic PHP script to test MySQL connectivity.

```php
<?php
$servername = "mysql";
$username = "user";
$password = "password";
$dbname = "mydatabase";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to MySQL!";
?>
```

### 5. `static-nginx/Dockerfile`

This file defines a separate Nginx container serving static HTML content.

```dockerfile
# Use official NGINX image
FROM nginx:latest

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static HTML file to serve
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
```

### 6. `static-nginx/nginx.conf`

Nginx configuration for serving static HTML files.

```nginx
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```

### 7. `static-nginx/index.html`

A fun static webpage that plays a rickroll video.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Never Gonna Give You Up</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            background-color: #000;
            color: white;
        }
        h1 {
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <h1>You've Been Rickrolled!</h1>
    <iframe width="560" height="315" 
        src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1&loop=1" 
        frameborder="0" allow="autoplay; encrypted-media" allowfullscreen>
    </iframe>
</body>
</html>
```

## Accessing the MySQL Database

You can access the MySQL database using the following methods:

### 1. Using MySQL CLI
Run the following command to connect to the MySQL container:
```sh
docker exec -it mysql_db mysql -uuser -ppassword mydatabase
```

### 2. Using MySQL Workbench or Any Database Client
- Host: `localhost`
- Port: `3306`
- Username: `user`
- Password: `password`
- Database: `mydatabase`

## Running the Application

1. Navigate to the project directory:
   ```sh
   cd myproject
   ```
2. Build and start the containers:
   ```sh
   docker-compose up -d
   ```
3. Access the PHP application:
   ```
   http://localhost:8080
   ```
4. Access the static page:
   ```
   http://localhost:8081
   ```
5. To stop the containers:
   ```sh
   docker-compose down
   ```

## Conclusion

This setup provides a functional PHP & MySQL environment, along with a separate Nginx container serving static content. Feel free to extend this further!

---

For any issues or improvements, feel free to contribute or raise an issue!

