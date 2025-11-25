#!/bin/bash

# Questo script estrae screenshot da un file video ogni 5 secondi,
# ritagliando le bande nere, correggendo l'aspect ratio per evitare distorsioni,
# e utilizzando un algoritmo di ricampionamento di alta qualità (Lanczos).

# --- Variabili ---
INPUT_FILE="DVD1.mp4"
OUTPUT_DIR="screenshots_hq"
# Frequenza di campionamento: 1 fotogramma ogni 5 secondi.
RATE="1/3"

# --- Controllo File ---
# Verifica se il file di input esiste.
if [ ! -f "$INPUT_FILE" ]; then
    echo "Errore: Il file di input '$INPUT_FILE' non è stato trovato."
    exit 1
fi

# --- Logica Principale ---
echo "Rilevamento delle bande nere per determinare i valori di ritaglio..."

# 1. Usa il filtro 'cropdetect' di ffmpeg per analizzare i primi 60 secondi del video.
CROP_VALUES=$(ffmpeg -i "$INPUT_FILE" -t 60 -vf cropdetect -f null - 2>&1 | grep "crop=" | tail -1 | awk '{print $NF}')

if [ -z "$CROP_VALUES" ]; then
    echo "Attenzione: Impossibile rilevare i valori di ritaglio. Verrà corretta solo la proporzione."
    # Definisce la catena di filtri per la sola correzione dell'aspect ratio e campionamento.
    FILTER_CHAIN="scale=iw*sar:ih,setsar=1,fps=$RATE"
else
    echo "Valori di ritaglio rilevati: $CROP_VALUES"
    # Concatena i filtri: ritaglio, correzione aspect ratio, e infine campionamento.
    FILTER_CHAIN="$CROP_VALUES,scale=iw*sar:ih,setsar=1,fps=$RATE"
fi

# Crea la directory di output se non esiste.
mkdir -p "$OUTPUT_DIR"

echo "Estrazione degli screenshot in alta qualità in corso..."

# 2. Esegue ffmpeg una seconda volta con la catena di filtri completa.
#    -sws_flags lanczos: Specifica l'algoritmo di scaling Lanczos per una qualità superiore.
#    -vf "$FILTER_CHAIN": Applica la catena di filtri video:
#        - crop: Ritaglia le bande nere (se rilevate).
#        - scale=iw*sar:ih,setsar=1: Corregge l'aspect ratio (per video anamorfici).
#          - `scale=iw*sar:ih` ridimensiona l'immagine basandosi sul Sample Aspect Ratio (SAR).
#          - `setsar=1` imposta il nuovo SAR a 1:1 (pixel quadrati), finalizzando la correzione.
#        - fps=$RATE: Estrae un fotogramma ogni 5 secondi.
#    -an: Disabilita l'audio.
#    L'output viene salvato con un nome sequenziale (es. screenshot_hq_0001.png).
ffmpeg -i "$INPUT_FILE" -sws_flags lanczos -vf "$FILTER_CHAIN" -an "$OUTPUT_DIR/screenshot_hq_%04d.png"

echo "Fatto. Gli screenshot in alta qualità sono stati salvati nella directory '$OUTPUT_DIR'."
