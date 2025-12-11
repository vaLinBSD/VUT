#!/usr/bin/env bash

# =======================================================
# Skript pro analýzu obsahu webové stránky
# (Kompatibilní s Bash v3.2)
# =======================================================

# Kontrola, zda byl zadán parametr URL
if [ $# -ne 1 ]; then
    echo "Chyba: skript vyžaduje zadání URL stránky"
    echo "Použití: $0 URL_stránky"
    exit 1
fi
URL="$1"

# Stažení HTML obsahu do proměnné
# -s: tichý režim
# -L: sleduje přesměrování
# --compressed: umožňuje přijímat komprimovaný obsah (např. seznam.cz)
PAGE_CONTENT=$(curl -s -L --compressed "$URL")

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