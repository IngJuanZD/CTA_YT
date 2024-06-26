#!/bin/bash

# Función para mostrar la ayuda
mostrar_ayuda() {
  echo "Uso: $0 -i ID_CANAL -c NOMBRE_CANAL"
  echo ""
  echo "Opciones:"
  echo "  -i ID_CANAL     ID del canal de YouTube"
  echo "  -c NOMBRE_CANAL Nombre del canal de YouTube"
  echo "  -h              Mostrar esta ayuda"
  exit 1
}

# Función para obtener el número de suscriptores
get_subscribers() {
  local url="https://www.youtube.com/channel/$channel_id"
  local subscribers=$(curl -s "$url" | tr '"' '\n' | grep "suscriptores")

  if [ -z "$subscribers" ]; then
    echo "No se pudo obtener el número de suscriptores."
    exit 1
  fi

  # Procesar para obtener solo el segundo número de suscriptores en caso de duplicados
  subscribers=$(echo "$subscribers" | awk 'NR==2')
  
  echo "$subscribers" | sed 's/:/\\:/g'
}

# Función para extraer IDs de video
extract_video_ids() {
  local url="https://www.youtube.com/@$channel_name/videos"
  local input_file="webpage.txt"
  local output_file="video_ids_filtered.txt"
  
  curl -s "$url" -o "$input_file"
  grep -oP '(?<=href="/watch\?v=)[^"]+' "$input_file" > "$output_file"
  
  grep -o '"videoId":"[^"]*"' "$input_file" |
  cut -d'"' -f4 |
  sort -u |
  tee "$output_file"
  
  echo "Los IDs de los videos han sido guardados en $output_file"
}

# Función para seleccionar IDs de video aleatorios
select_random_videos() {
  local input_file="video_ids_filtered.txt"
  local output_file="youtube_urls.txt"
  
  local selected_ids=$(shuf -n 6 "$input_file")
  
  local youtube_urls=()
  for id in $selected_ids; do
    youtube_urls+=("https://www.youtube.com/watch?v=$id")
  done
  
  printf "%s\n" "${youtube_urls[@]}" > "$output_file"
  
  echo "Se han generado las URLs de YouTube en $output_file"
}

# Función para descargar miniaturas
download_thumbnails() {
  local urls_file="youtube_urls.txt"
  
  if [[ ! -f $urls_file ]]; then
    echo "El archivo $urls_file no existe."
    exit 1
  fi
  
  while IFS= read -r url; do
    yt-dlp --write-thumbnail --skip-download "$url"
  done < "$urls_file"
}

# Función para convertir y limpiar nombres de miniaturas
process_thumbnails() {
  mogrify -format png *.webp
  rm *.webp
  
  > archivos_png.txt
  for archivo in *.png; do
    local nombre_sin_emojis=$(echo "$archivo" | sed 's/[^a-zA-Z0-9 ._-]//g')
    mv "$archivo" "$nombre_sin_emojis"
    local nombre_cortado=$(printf '%-20.20s\n' "$nombre_sin_emojis")
    echo "$nombre_cortado" >> archivos_png.txt
  done
}

# Función para generar el video con texto
generate_video_with_text() {
  local input_file="archivos_png.txt"
  local nSuscriptores=$(get_subscribers)
  
  local video_base="base.mp4"
  local fuente1="YouTubeSansDark-Medium.ttf"
  local fuente2="YouTubeSansDark-Bold.ttf"
  local video_salida="CTA.mp4"
  local posicion_suscriptores="x=180:y=983:fontsize=26:fontcolor=black"
  local posiciones_texto=(
    "x=1534.467:y=203.687:fontsize=29:fontcolor=black"
    "x=1534.467:y=345.138:fontsize=29:fontcolor=black"
    "x=1534.467:y=484.593:fontsize=29:fontcolor=black"
    "x=1534.467:y=632.983:fontsize=29:fontcolor=black"
    "x=1534.467:y=775.578:fontsize=29:fontcolor=black"
    "x=1534.467:y=916.891:fontsize=29:fontcolor=black"
  )
  
  if [[ ! -f "$input_file" ]]; then
    echo "El archivo $input_file no existe."
    exit 1
  fi
  
  local filtros=""
  local indice=0
  while IFS= read -r linea; do
    linea=$(echo "$linea" | xargs)
    if [[ $indice -lt ${#posiciones_texto[@]} ]]; then
      local config_texto=${posiciones_texto[$indice]}
      local drawtext_filtro="drawtext=fontfile=$fuente2:text='$linea':$config_texto"
      filtros="$filtros,$drawtext_filtro"
      indice=$((indice + 1))
    else
      echo "Más líneas en el archivo de las esperadas. Ignorando línea: $linea"
    fi
  done < "$input_file"
  
  filtros="${filtros:1}"  # Eliminar la primera coma
  local comando_ffmpeg="ffmpeg -i $video_base -vf \"$filtros,drawtext=fontfile=$fuente1:text='$nSuscriptores':$posicion_suscriptores\" -codec:a copy $video_salida"
  eval "$comando_ffmpeg"
}

# Función para agregar imágenes al video
add_images_to_video() {
  local video_base="CTA.mp4"
  local imagenes=(*.png)
  local coordenadas=(
    "1286.038:180.566"
    "1286.038:323.664"
    "1286.038:466.763"
    "1286.038:609.861"
    "1286.038:752.960"
    "1286.038:896.110"
  )
  local ancho_especifico=235.126
  local video_salida="$video_base"
  
  for (( i=0; i<${#coordenadas[@]}; i++ )); do
    local coordenada="${coordenadas[$i]}"
    local coordenada_x=$(echo "$coordenada" | cut -d ':' -f 1)
    local coordenada_y=$(echo "$coordenada" | cut -d ':' -f 2)
    local imagen_png="${imagenes[$i]}"
    
    local imagen_info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=noprint_wrappers=1 "$imagen_png")
    local imagen_ancho=$(echo "$imagen_info" | awk -F= '$1=="width"{print $2}')
    local imagen_alto=$(echo "$imagen_info" | awk -F= '$1=="height"{print $2}')
    
    local altura=$(echo "scale=2; $ancho_especifico * $imagen_alto / $imagen_ancho" | bc)
    altura=$(printf "%.0f" "$altura")
    
    video_salida="video_con_imagen_$i.mp4"
    
    ffmpeg -i "$video_base" -i "$imagen_png" -filter_complex \
    "[1:v]scale=$ancho_especifico:$altura [scaled_overlay]; \
    [0:v][scaled_overlay]overlay=$coordenada_x:$coordenada_y:enable='between(t,0,20)'" \
    -c:a copy "$video_salida"
    
    echo "Se ha creado el video con la imagen superpuesta y escalada: $video_salida"
    video_base="$video_salida"
  done
  mv video_con_imagen_5.mp4 CTA_final_bash.mp4
}

# Función principal
main() {
  while getopts "i:c:h" opt; do
    case $opt in
      i) channel_id="$OPTARG" ;;
      c) channel_name="$OPTARG" ;;
      h) mostrar_ayuda ;;
      \?) mostrar_ayuda ;;
    esac
  done
  
  if [[ -z "$channel_id" || -z "$channel_name" ]]; then
    mostrar_ayuda
  fi
  
  get_subscribers
  extract_video_ids
  select_random_videos
  download_thumbnails
  process_thumbnails
  generate_video_with_text
  add_images_to_video
  
  rm *.png *txt
  rm video_con_imagen_*.mp4 CTA.mp4
  
  echo "Proceso completado."
}

main "$@"
