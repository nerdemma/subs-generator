#!/usr/bin/env python3

import os
import subprocess
import speech_recognition as sr
from pydub import AudioSegment
from deep_translator import GoogleTranslator

def formatear_tiempo(milisegundos):
    # Convierte milisegundos al formato HH:MM:SS
    horas = int(milisegundos / 3600000)
    minutos = int((milisegundos % 3600000) / 60000)
    segundos = int((milisegundos % 60000) / 1000)
    return f"{horas:02d}:{minutos:02d}:{segundos:02d}"



video_file = input("Ingresa el nombre del archivo de video (ej. mi_video.mp4): ")
nombre_base, _ = os.path.splitext(video_file)
audio_file = f"{nombre_base}.wav"
print(f"Extrayendo audio a {audio_file}...")
subprocess.run(["ffmpeg", "-i", video_file, "-vn", "-y", audio_file], check=True)
chunk_length_ms = 10000
archivo_txt = input("Ingresa el nombre del archivo de texto de salida: ")


print("Cargando archivo de audio...")
audio = AudioSegment.from_wav(audio_file)
recognizer = sr.Recognizer()

if not os.path.exists("chunks_temp"):
    os.makedirs("chunks_temp")

print(f"Procesando y generando {archivo_txt}...")


def milisegundos_a_srt(ms):
    horas = ms // 3600000
    ms %= 3600000
    minutos = ms // 60000
    ms %= 60000
    segundos = ms // 1000
    milisegundos = ms % 1000
    return f"{horas:02d}:{minutos:02d}:{segundos:02d},{milisegundos:03d}"


archivo_srt = archivo_txt.replace(".txt", ".srt")

srt_index = 1 
traductor = GoogleTranslator(source='en', target='es')

with open(archivo_srt, "w", encoding="utf-8") as f:
    for i, chunk_start in enumerate(range(0, len(audio), chunk_length_ms)):
        chunk_end = min(chunk_start + chunk_length_ms, len(audio))
        
        
        tiempo_inicio = milisegundos_a_srt(chunk_start)
        tiempo_fin = milisegundos_a_srt(chunk_end)
        
        chunk = audio[chunk_start:chunk_end]
        chunk_path = f"chunks_temp/chunk_{i}.wav"
        chunk.export(chunk_path, format="wav")
        
        with sr.AudioFile(chunk_path) as source:
            audio_data = recognizer.record(source)
            try:
                texto = recognizer.recognize_google(audio_data, language="en-US")
                #texto = recognizer.recognize_google(audio_data, language="es-AR")
               
                texto_traducido = traductor.translate(texto)
                bloque_srt = f"{srt_index}\n{tiempo_inicio} --> {tiempo_fin}\n{texto_traducido.strip()}\n\n"
                
                f.write(bloque_srt)
                print(f"Procesado: [{tiempo_inicio}] -> Ok")
                
                srt_index += 1 
                
            except sr.UnknownValueError:
                # ignorar si hay silencio
                pass
            except sr.RequestError as e:
                print(f"Error de conexión en el tiempo {tiempo_inicio}: {e}")
        
        if os.path.exists(chunk_path):
            os.remove(chunk_path)


try:
    os.rmdir("chunks_temp")
except OSError:
    pass