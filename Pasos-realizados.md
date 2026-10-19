# Práctica Docker - Apache en Debian

Autor: Christopher

## 0. Comprobar la instalación de Docker

```powershell
docker --version
docker compose version
docker run hello-world
```

Comprueba que Docker y Docker Compose están instalados y que el motor puede descargar y ejecutar contenedores.

## 1. Documentar los pasos

Este fichero (`Pasos-realizados.md`) recoge todos los pasos realizados, en formato Markdown.

## 2. Descargar la imagen de Debian

```powershell
docker pull debian
docker images
```

Descarga la imagen oficial de Debian desde Docker Hub y comprueba que aparece en la lista.

## 3. Arrancar el contenedor

```powershell
docker run -dit --name mi-apache -p 8080:80 debian
docker ps
```

- `-d`: modo detached (segundo plano)
- `-i`: interactivo
- `-t`: con terminal
- `--name`: nombre del contenedor
- `-p 8080:80`: puerto 8080 del PC redirigido al puerto 80 del contenedor

## 4. Ejecutar una shell bash en el contenedor

```powershell
docker exec -it mi-apache bash
```

El prompt cambia a `root@...`, lo que indica que estamos dentro del contenedor.

## 5. Instalar Apache

Dentro del contenedor:

```bash
apt update
apt install -y apache2
```

## 6. Arrancar el servicio Apache

```bash
service apache2 start
```

## 7. Comprobar desde el navegador

Se abre `http://localhost:8080` y aparece la página "Apache2 Debian Default Page".

## 8. Crear una página HTML nueva

```bash
echo "<h1>Hola, soy Christopher</h1>" > /var/www/html/christopher.html
```

## 9. Acceder desde el navegador

Se abre `http://localhost:8080/christopher.html`.

## 10. Acceder con elinks

```bash
apt install -y elinks
elinks http://localhost/christopher.html
```

Dentro del contenedor se usa el puerto 80. Para salir de elinks: `q`. Después `exit` para salir del contenedor.

## 11. Crear el Dockerfile

Se crea `christopher.html` y un fichero `Dockerfile` que automatiza los pasos anteriores:

```dockerfile
FROM debian:latest

RUN apt-get update && \
    apt-get install -y apache2 elinks && \
    rm -rf /var/lib/apt/lists/*

COPY christopher.html /var/www/html/christopher.html

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
```

- `FROM`: imagen base
- `RUN`: instala Apache y elinks
- `COPY`: copia la página al directorio web de Apache
- `EXPOSE`: documenta el puerto 80
- `CMD`: arranca Apache en primer plano para que el contenedor no se detenga

## 12. Crear la imagen

```powershell
docker build -t apache-christopher-img .
docker images
```

## 13. Ejecutar el contenedor

```powershell
docker run -d --name apache-dockerfile-christopher -p 8081:80 apache-christopher-img
docker ps
```

Se comprueba en `http://localhost:8081/christopher.html`.

## 14. Copiar un archivo local al contenedor

```powershell
docker cp prueba.html apache-dockerfile-christopher:/var/www/html/prueba.html
```

Sintaxis: `docker cp <archivo_local> <contenedor>:<ruta_destino>`. Se comprueba en `http://localhost:8081/prueba.html`.

## 15. Docker Compose con volumen

Se crea la carpeta `web` con `christopher.html` dentro y el fichero `docker-compose.yml`:

```yaml
services:
  apache:
    build: .
    container_name: apache-compose-christopher
    ports:
      - "8082:80"
    volumes:
      - ./web:/var/www/html
```

```powershell
docker compose up -d --build
docker ps
```

Se comprueba en `http://localhost:8082/christopher.html`. Para probar el volumen se modifica `web/christopher.html` y, al recargar el navegador, el cambio aparece sin reconstruir nada.

```powershell
docker compose down
```