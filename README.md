# CAT YouTube

Este script te ayuda a genera un video que Call To Action para agregar en tus video de YouTube usando un video base y el script se encarga de personalizar el video con información de tu canal de YouTube muy básica.

Espero después modificar el script con lo restante en la Nota



## Instalación

Para lograr un uso satisfactorio de este script se requieres la instalación de los siguientes paquetes.

Recuerda que este script está escrito en bash, así que necesitas un entorno compatible con bash.


### Requisitos
1. **curl**: Para realizar solicitudes HTTP y descargar contenido desde las URLs de YouTube.

```sh
sudo apt-get install curl
```

2. **grep**: Utilizado para buscar y filtrar texto dentro de archivos.

```sh
sudo apt-get install grep
```

3. **awk**: Para manipular y procesar texto.
```sh
sudo apt-get install gawk
```
4.  **shuf**: Para seleccionar elementos aleatorios de una lista.
```sh
sudo apt-get install coreutils
```

5. **yt-dlp**: Una herramienta para descargar videos de YouTube (similar a youtube-dl).
```sh
sudo apt-get install yt-dlp
```
6. **imagemagick**: Utilizado para convertir imágenes de formato webp a png.
```sh
sudo apt-get install imagemagick
```
7. **ffmpeg**: Para procesar y editar videos.
```sh
sudo apt-get install ffmpeg
```
8. **bc**: Una calculadora de precisión arbitraria, utilizada para cálculos en el script.
```sh
sudo apt-get install bc
```
9. **fontconfig**: Necesario si necesitas utilizar fuentes específicas con ffmpeg.
```sh
sudo apt-get install fontconfig
```

Podias usar tambien este comando para hacer todo lo anteriror.

```sh
sudo apt-get update && sudo apt-get install -y curl grep gawk coreutils yt-dlp imagemagick ffmpeg bc fontconfig
```

## Como usar
Asegúrate de que todas estas herramientas están instaladas y actualizadas en tu sistema para evitar problemas de compatibilidad y errores de ejecución.

También es posible que necesites configurar permisos de ejecución para tu script. Puedes hacerlo con:

```sh
chmod +x full.sh
```
Ver ayuda

```sh
./full.sh  -h
```

Ejecuta el comando de la siguiente manera
```sh
./full.sh -u https://www.youtube.com/@USER
```
*El nombre del canal es como aparece en la url cambia el @USER por el canal deseado*

### **Ejemplo**
```sh
./full.sh -u https://www.youtube.com/@chepecarlo  
```


## Nota
Lamento no modificar la personalización completa para cada canal pero espero próximamente hacerlo.
Este mini proyecto solo estaba pensado para el canal de [ChepeCarlos](https://www.youtube.com/@chepecarlo) por eso es que el video base ya incluye la foto de perfil del canal y su nombre, pero de igual manera que se agrega lo de mas se podría modificar para obtener la información restante para personalizar por completo.

## Nota 2
Hay un error en el video base esta mal escrito el nombre del canal en un video proxima corrección 