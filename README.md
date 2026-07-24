# 🎬 Subs-Generator


[Python Version](https://img.shields.io/badge/python-3.8%2B-blue)
![FFmpeg Required](https://img.shields.io/badge/FFmpeg-Required-red.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)



Un script en Python diseñado para automatizar la generación y traducción de subtítulos a partir de archivos de video de forma local.

## 📋 Requisitos Previos

Para ejecutar este proyecto, es necesario tener instalado **Python 3** y utilizar un entorno virtual (`venv`) para evitar conflictos con las dependencias globales del sistema.

### Dependencias Principales
El script utiliza las siguientes librerías:
* `SpeechRecognition` (Reconocimiento de voz)
* `pydub` (Manipulación de audio)
* `deep-translator` (Traducción de texto)

> **Nota importante:** Para que `pydub` pueda procesar correctamente el audio de archivos de video (como `.mp4`), es muy probable que necesites tener instalado [FFmpeg](https://ffmpeg.org/download.html) en tu sistema y configurado en el PATH.

## 🚀 Instalación y Configuración

1. **Clonar el repositorio (o descargar los archivos):**
   ```bash
   git clone [https://github.com/tu-usuario/subs-generator.git](https://github.com/nerdemma/subs-generator.git)
   cd subs-generator

