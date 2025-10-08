#!/bin/bash

# =======================================================
# Analýza obsahu webové stránky (Kompatibilní s Bash 3.2)
# Použití: ./analyza_webu.sh <URL>
# =======================================================

# Kontrola, zda byl zadán parametr URL
URL="$1"

if [ -z "$URL" ]; then
    echo "Chyba: Skript vyžaduje jeden argument (URL stránky)."
    echo "Použití: $0 https://adresa.cz"
    exit 1
fi

# Stažení obsahu webové stránky
# Používáme curl -s (silent mode) pro stažení HTML obsahu do proměnné.
# Pro velké stránky by se z hlediska paměti OS hodilo použít dočasný soubor,
# ale pro standardní webové stránky je proměnná dostačující a rychlejší.
PAGE_CONTENT=$(curl -s "$URL")

# Kontrola, zda curl vrátil chybu
if [ $? -ne 0 ]; then
    echo "Chyba: Nepodařilo se stáhnout obsah stránky $URL."
    exit 2
fi

# Analýza textu
# Počet výskytů řetězce "http"
# grep -o: vypíše každý nalezený řetězec na nový řádek
# wc -l: spočítá počet těchto řádků (tedy počet výskytů)
HTTP_COUNT=$(echo "$PAGE_CONTENT" | grep -o "http" | wc -l | tr -d '[:space:]')

# Celkový počet znaků stránky
# wc -m: počítá znaky (ne bajty), výstup očistíme od prázdných znaků pomocí tr
CHAR_COUNT=$(echo "$PAGE_CONTENT" | wc -m | tr -d '[:space:]')

# Počet výskytů tagu "<p>"
# Hledáme striktně "<p>" (předpokládáme přesný match, neřešíme atributy jako <p class="...">)
P_TAG_COUNT=$(echo "$PAGE_CONTENT" | grep -o "<p>" | wc -l | tr -d '[:space:]')

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