#!/usr/bin/env bash

# =======================================================
# Skript pro monitorování systémových zdrojů
# (Kompatibilní s Bash 3.2, Linux & macOS)
# =======================================================

OS=$(uname -s)
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
CURRENT_USER=$(whoami)

# Dostupnost utility bc
if ! command -v bc > /dev/null 2>&1; then
    echo "Chyba: skript vyžaduje utilitu 'bc' pro desetinnou aritmetiku."
    exit 1
fi

# Doba běhu
UPTIME_STR=$(uptime | grep -oE 'up ([0-9]+ days?, )?[0-9]+:[0-9]+' | sed -E 's/up //g')

# Paměť se liší podle OS
if [ "$OS" = "Linux" ]; then
    MEM_INFO=$(free -k | grep Mem)
    TOTAL_KB=$(echo "$MEM_INFO" | awk '{print $2}' | tr -d '[:space:]')
    USED_KB=$(echo "$MEM_INFO" | awk '{print $3}' | tr -d '[:space:]')
    FREE_KB=$(echo "$MEM_INFO" | awk '{print $4}' | tr -d '[:space:]')

elif [ "$OS" = "Darwin" ]; then
    TOTAL_BYTES=$(sysctl -n hw.memsize)
    TOTAL_KB=$(expr $TOTAL_BYTES / 1024)

    PAGE_SIZE=$(sysctl -n vm.pagesize)
    VM_STATS=$(vm_stat)

    ACTIVE_PAGES=$(echo "$VM_STATS" | grep "Pages active:" | awk '{print $3}' | tr -d '.')
    INACTIVE_PAGES=$(echo "$VM_STATS" | grep "Pages inactive:" | awk '{print $3}' | tr -d '.')
    WIRED_PAGES=$(echo "$VM_STATS" | grep "Pages wired down:" | awk '{print $4}' | tr -d '.')
    FREE_PAGES=$(echo "$VM_STATS" | grep "Pages free:" | awk '{print $3}' | tr -d '.')

    USED_PAGES_TOTAL=$(expr $ACTIVE_PAGES + $INACTIVE_PAGES + $WIRED_PAGES)
    USED_KB=$(expr $USED_PAGES_TOTAL \* $PAGE_SIZE / 1024)
    FREE_KB=$(expr $FREE_PAGES \* $PAGE_SIZE / 1024)
fi

# Převod KB na GB
TOTAL_GB=$(echo "scale=1; $TOTAL_KB / (1024*1024)" | bc)
USED_GB=$(echo "scale=1; $USED_KB / (1024*1024)" | bc)
FREE_GB=$(echo "scale=1; $FREE_KB / (1024*1024)" | bc)

# Zatížení CPU se liší podle OS
if [ "$OS" = "Linux" ]; then
    # Linux: použijeme 'vmstat' pro získání hodnoty idle a pak spočítáme zatížení odečtením od 100%
    VMSTAT_OUTPUT=$(vmstat | tail -n1)
    IDLE_PERCENT=$(echo "$VMSTAT_OUTPUT" | awk '{print $15}') 
    CPU_LOAD=$(expr 100 - "$IDLE_PERCENT")
 
elif [ "$OS" = "Darwin" ]; then
    # macOS: použijeme 'top' pro získání hodnoty idle a pak spočítáme zatížení odečtením od 100%
    TOP_OUTPUT=$(top -l 1 | grep "CPU usage:")
    IDLE_RAW=$(echo "$TOP_OUTPUT" | awk '{print $7}')
    IDLE_PERCENT_FLOAT=$(echo "$IDLE_RAW" | tr -d ',%')
    CPU_LOAD_FLOAT=$(echo "scale=0; 100 - $IDLE_PERCENT_FLOAT" | bc)
    CPU_LOAD=$(echo "$CPU_LOAD_FLOAT" | awk '{print int($1)}')
fi

# Výstup
echo "=============================="
echo "SYSTEM MONITOR"
echo "------------------------------"
echo "User: $CURRENT_USER"
echo "Date: $CURRENT_DATE"
echo "CPU load: $CPU_LOAD %"
echo "RAM: $TOTAL_GB GB total / $USED_GB GB used / $FREE_GB GB free"
echo "Uptime: $UPTIME_STR"
echo "=============================="