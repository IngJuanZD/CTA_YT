#!/bin/bash

# URL del canal de YouTube
CHANNEL_URL="https://www.youtube.com/@chepecarlo"

# Archivo temporal para almacenar el HTML
TEMP_HTML="temp_page.html"

# Descargar el HTML de la página del canal
curl -s -o "$TEMP_HTML" "$CHANNEL_URL"

# Extraer la URL de la imagen de la meta etiqueta 'link rel="image_src"'
IMAGE_URL=$(grep -oP '(?<=<link rel="image_src" href=")[^"]*' "$TEMP_HTML")

# Nombre del archivo de salida
OUTPUT_FILE="imagen_descargada.png"

# Descargar la imagen
if [ -n "$IMAGE_URL" ]; then
  curl -s -o "$OUTPUT_FILE" "$IMAGE_URL"
  if [ $? -eq 0 ]; then
    echo "Imagen descargada exitosamente y guardada como $OUTPUT_FILE"
  else
    echo "Error al descargar la imagen"
  fi
else
  echo "No se encontró la URL de la imagen en el HTML"
fi

# Limpiar archivo temporal
rm "$TEMP_HTML"

