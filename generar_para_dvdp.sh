#!/bin/bash

# este es un script para generar de manera automatica videos con subtitulos incluidos en formato mpeg compatible con los antiguos dvdplayer ntsc

read -p "nombre de video: " nombre_video
read -p  "nombre del archivo de subtitulos srt:" nombre_subtitulos

[[ "$nombre_video" != *.mp4 ]] && video="${nombre_video}.mp4" || video="$nombre_video"
[[ "$nombre_subtitulos" != *.srt ]] && subtitulo="${nombre_subtitulos}.srt" || subtitulo="$nombre_subtitulos"
salida="${cadena1}_dvd.mpg"


if [[ ! -f "$nombre_video" ]]; then
    echo "Error: No existe el archivo de video '$video'"
    exit 1
fi

if [[ ! -f "$nombre_subtitulo" ]]; then
    echo "Error: No existe el archivo de subtítulos '$subtitulo'"
    exit 1
fi


read -p "¿Deseas proceder? (s/n): " opcion

echo "----------------------------------------"
echo "Video de entrada: $video"
echo "Subtítulos:       $subtitulo"
echo "Video de salida:  $salida"
echo "----------------------------------------"


if [[ "$opcion" =~ ^[Ss]$ ]]; then
    echo ">> Obteniendo duración del video..."
    
    # Obtener duración total en segundos con ffprobe
    duracion=$(ffprobe -v error -show_entries format=duration -of default=noprintwrappers=1:nokey=1 "$nombre_video")
    duracion_sec=${duracion%.*} # Redondear a entero

    if [[ -z "$duracion_sec" || "$duracion_sec" -eq 0 ]]; then
        echo "No se pudo obtener la duración. Ejecutando sin barra..."
        ffmpeg -i "$nombre_video" -vf "subtitles='$nombre_subtitulo'" -target ntsc-dvd "$salida"
    else
        echo ">> Procesando video..."

        # Capturar el tiempo actual de codificación de FFmpeg en tiempo real
        ffmpeg -y -i "$nombre_video" -vf "subtitles='$nombre_subtitulo'" -target ntsc-dvd "$salida" -progress pipe:1 -nostats 2>/dev/null | while read -r line; do
            if [[ "$line" == out_time_ms=* ]]; then
                # Extraer microsegundos y pasar a segundos
                ms=${line#out_time_ms=}
                sec=$((ms / 1000000))
                
                # Calcular porcentaje (0 a 100%)
                porcentaje=$(( (sec * 100) / duracion_sec ))
                [ $porcentaje -gt 100 ] && porcentaje=100

                # Renderizar la barra de texto [██████░░░░░░]
                ancho=20
                llenos=$(( (porcentaje * ancho) / 100 ))
                vacios=$(( ancho - llenos ))

                barra=""
                for ((i=0; i<llenos; i++)); do barra="${barra}█"; done
                for ((i=0; i<vacios; i++)); do barra="${barra}░"; done

                # Imprimir y sobrescribir la misma línea usando '\r'
                printf "\rProgreso: [%s] %3d%%" "$barra" "$porcentaje"
            fi
        done
        echo -e "\n>> ¡Proceso completado con éxito! Archivo: $salida"
    fi
else
    echo ">> Operación cancelada por el usuario."
fi