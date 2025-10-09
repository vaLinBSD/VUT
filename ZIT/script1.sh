#!/bin/bash

# =======================================================
# Skript pro třídění souborů do adresářů podle MIME typu
# (kompatibilní s Bash v3.2)
# =======================================================

echo "Spouštím třídění souborů v aktuálním adresáři..."

for FILE in *; do
    # Zkontrolujeme, zda se jedná o běžný soubor (-f) a zda to není tento skript
    if [ -f "$FILE" ] && [ "$FILE" != "$0" ]; then

        # Získání koncovky a převod na malá písmena pro spolehlivé porovnání v 'case'
        EXT=$(echo "${FILE##*.}" | tr '[:upper:]' '[:lower:]')

        case "$EXT" in
            doc)
                MIME_TYPE="application/msword"
                ;;
            html)
                MIME_TYPE="text/html"
                ;;
            zip)
                MIME_TYPE="application/zip"
                ;;
            pdf)
                MIME_TYPE="application/pdf"
                ;;
            jpg|jpeg)
                MIME_TYPE="image/jpeg"
                ;;
            *)
                # Koncovka neodpovídá žádnému MIME typu ze seznamu
                MIME_TYPE=""
                ;;
        esac

        # Pokud byl nalezen podporovaný MIME typ, proveď přesun
        if [ -n "$MIME_TYPE" ]; then
            
            # Vytvoření cílové podsložky, pokud neexistuje
            if [ ! -d "$MIME_TYPE" ]; then
                mkdir -p "$MIME_TYPE"
            fi

            # Přesunutí souboru
            mv "$FILE" "$MIME_TYPE/"
            echo "Soubor '$FILE' přesunut do složky '$MIME_TYPE/'"
        fi
    fi
done

echo "...třídění dokončeno."
