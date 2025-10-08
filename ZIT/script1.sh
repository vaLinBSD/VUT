#!/bin/bash

# =======================================================
# Skript pro třídění souborů (kompatibilní s Bash 3.2)
# =======================================================

echo "Spouštím třídění souborů v aktuálním adresáři..."

for filename in *; do
    # Zkontrolujeme, zda se jedná o běžný soubor (-f) a zda to není samotný skript
    if [ -f "$filename" ] && [ "$filename" != "$0" ]; then

        # Extrakce koncovky
        # Získání textu za poslední tečkou
        extension="${filename##*.}"

        # Převod koncovky na malá písmena pro spolehlivé porovnání v 'case'
        ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

        MIME_TYPE="" # Inicializace proměnné

        # Mapování koncovky na MIME typ pomocí 'case'
        case "$ext_lower" in
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
                # Koncovka neodpovídá žádnému podporovanému typu
                MIME_TYPE=""
                ;;
        esac

        # Pokud byl nalezen podporovaný MIME typ, proveď přesun
        if [ -n "$MIME_TYPE" ]; then
            
            # Cílová cesta je definována MIME typem (např. image/jpeg)
            TARGET_PATH="./$MIME_TYPE"

            echo "Nalezen soubor: $filename"
            echo "  -> Typ: $MIME_TYPE"

            # Vytvoření cílové podsložky, pokud neexistuje
            if [ ! -d "$TARGET_PATH" ]; then
                mkdir -p "$TARGET_PATH"
                echo "  -> Vytvořena složka $TARGET_PATH"
            fi

            # Přesunutí souboru
            mv "$filename" "$TARGET_PATH/"
            echo "  -> Soubor přesunut."
        fi
    fi
done

echo "Třídění dokončeno. Nepodporované soubory byly ignorovány."
