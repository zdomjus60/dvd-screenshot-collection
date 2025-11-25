# DVD Screenshot Collection

Questo repository contiene script per estrarre screenshot da video DVD e per organizzare le collezioni risultanti.

## Contenuto

*   `sample.sh`: Uno script di esempio per l'estrazione di screenshot.
*   `sample_final.sh`: Uno script finale di esempio per l'estrazione di screenshot.

## Prerequisiti

L'unico prerequisito per eseguire questi script è **ffmpeg**. Assicurati che sia installato e accessibile nel tuo sistema. Puoi scaricarlo dal [sito ufficiale di ffmpeg](https://ffmpeg.org/download.html).

## Utilizzo degli Script

Per utilizzare gli script, posiziona il tuo file video `.mp4` nella stessa directory. Gli script sono progettati per essere eseguiti da terminale e rileveranno automaticamente il primo file `.mp4` trovato. **Se sono presenti più file `.mp4`, verrà utilizzato solo il primo rilevato.**

**Esempio:**
```bash
./sample.sh
./sample_final.sh
```

## Consiglio: Convertire un DVD in MP4

I DVD di solito contengono video in formato MPEG-2, spesso all'interno di file `.VOB`. Se hai bisogno di convertire questi file in formato `.mp4` per usarli con questi script, puoi usare `ffmpeg` con un comando simile a questo:

```bash
ffmpeg -i INPUT.VOB -c:v libx264 -c:a aac -strict experimental output.mp4
```

Spesso un film è diviso in più file `.VOB` (es. `VTS_01_1.VOB`, `VTS_01_2.VOB`, ecc.). Potrebbe essere necessario concatenarli prima della conversione. Un modo semplice per farlo su sistemi Linux o macOS è:

```bash
cat VTS_01_*.VOB | ffmpeg -i - -c:v libx264 -c:a aac -strict experimental output.mp4
```

Questo comando unisce tutti i file `VTS_01_*.VOB` e li passa direttamente a `ffmpeg` per la conversione.