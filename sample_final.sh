#!/bin/bash

# Script finale per estrarre screenshot di alta qualità da un file video,
# usando una catena di filtri avanzati di ffmpeg per migliorare l'immagine.
# Questo metodo è affidabile e non dipende da software esterni.

# --- Variabili ---
INPUT_FILE="DVD1.mp4"
OUTPUT_DIR="screenshots_final"
RATE="1/3"
# Risoluzione orizzontale di output (es. 1280 per 720p, 1920 per 1080p)
TARGET_WIDTH=1280

# --- Controllo File ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Errore: Il file di input '$INPUT_FILE' non è stato trovato."
    exit 1
fi

# --- Logica Principale ---
echo "Rilevamento delle bande nere..."
CROP_VALUES=$(ffmpeg -i "$INPUT_FILE" -t 60 -vf cropdetect -f null - 2>&1 | grep "crop=" | tail -1 | awk '{print $NF}')

if [ -z "$CROP_VALUES" ]; then
    echo "Attenzione: Impossibile rilevare i valori di ritaglio. Procedo senza."
    FILTER_CHAIN_BASE="scale=iw*sar:ih,setsar=1"
else
    echo "Valori di ritaglio rilevati: $CROP_VALUES"
    FILTER_CHAIN_BASE="$CROP_VALUES,scale=iw*sar:ih,setsar=1"
fi

# Crea la directory di output se non esiste.
mkdir -p "$OUTPUT_DIR"

echo "Estrazione e miglioramento degli screenshot con ffmpeg in corso..."
echo "(Questo processo potrebbe essere un po' più lento a causa dei filtri)"

# Costruisce la catena di filtri completa:
# 1. Filtro base: ritaglio e correzione aspect ratio.
# 2. hqdn3d: Denoise di alta qualità.
# 3. unsharp: Aumenta la nitidezza.
# 4. scale: Ingrandisce l'immagine alla larghezza desiderata con l'algoritmo Lanczos.
#    L'altezza (-2) viene calcolata in automatico per mantenere le proporzioni e
#    garantire che sia un numero pari (massima compatibilità).
# 5. fps: Campiona un fotogramma ogni 5 secondi.
FULL_FILTER_CHAIN="${FILTER_CHAIN_BASE},hqdn3d,unsharp,scale=${TARGET_WIDTH}:-2:flags=lanczos,fps=${RATE}"


# Esegue ffmpeg con la catena di filtri avanzata.
ffmpeg -i "$INPUT_FILE" -vf "$FULL_FILTER_CHAIN" -an "$OUTPUT_DIR/final_screenshot_%04d.png"

echo "✅ Fatto! Gli screenshot finali e migliorati sono stati salvati nella directory '$OUTPUT_DIR'."
