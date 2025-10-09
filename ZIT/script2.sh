#!/bin/bash

# =======================================================
# Skript pro analýzu obsahu webové stránky
# (Kompatibilní s Bash v3.2)
# =======================================================

# Kontrola, zda byl zadán parametr URL
URL="$1"
if [ -z "$URL" ]; then
    echo "Chyba: Skript vyžaduje zadání URL stránky jako argument."
    echo "Použití: $0 URL_stránky"
    exit 1
fi

# Stažení HTML obsahu do proměnné
# -s: tichý režim
# -L: sleduje přesměrování
# --compressed: umožňuje přijímat komprimovaný obsah (např. seznam.cz)
PAGE_CONTENT=$(curl -s -L --compressed "$URL")

# Kontrola, zda curl vrátil chybu
if [ $? -ne 0 ]; then
    echo "Chyba: Nepodařilo se stáhnout obsah stránky $URL."
    exit 2
fi

# Počet výskytů řetězce "http"
# grep -o: vypíše každý nalezený řetězec na nový řádek
# wc -l: spočítá počet těchto řádků (počet výskytů)
HTTP_COUNT=$(echo "$PAGE_CONTENT" | grep -o "http" | wc -l | tr -d '[:space:]')

# Celkový počet znaků stránky
# wc -m: počítá znaky (ne bajty)
CHAR_COUNT=$(echo "$PAGE_CONTENT" | wc -m | tr -d '[:space:]')

# Počet výskytů tagu "<p>"
P_TAG_COUNT=$(echo "$PAGE_CONTENT" | grep -oiE '<p[^>]*>' | wc -l | tr -d '[:space:]')

# Výstup
echo "================================="
echo "WEB PAGE ANALYSIS"
echo "-----------------"
echo "URL: $URL"
echo "Number of \"http\" occurrences: $HTTP_COUNT"
echo "Total length of page: $CHAR_COUNT characters"
echo "Number of <p> tags: $P_TAG_COUNT"
echo "================================="

exit 0