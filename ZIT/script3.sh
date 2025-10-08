#!/bin/bash

# =======================================================
# MONITOROVÁNÍ SYSTÉMU (Kompatibilní s Bash 3.2, Linux & macOS)
# =======================================================

# Zjištění operačního systému
OS=$(uname -s)

# Potvrzení dostupnosti bc
if ! command -v bc > /dev/null 2>&1; then
    echo "Chyba: Skript vyžaduje utilitu 'bc' pro desetinnou aritmetiku."
    exit 1
fi

# =======================================================
# 1. Standardní informace (univerzální)
# =======================================================

CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
CURRENT_USER=$(whoami)

# UPTIME - opraveno parsování sed pro vyšší kompatibilitu
UPTIME_STR_RAW=$(uptime | sed 's/^.*up //; s/user[s]*.*//; s/load average.*//')
UPTIME_STR=$(echo "$UPTIME_STR_RAW" | tr -d ',' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')


# =======================================================
# 2. Získání informací o paměti (OS-specific)
# =======================================================

TOTAL_KB=0
USED_KB=0
FREE_KB=0

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
if [ "$TOTAL_KB" -gt 0 ]; then
    TOTAL_GB=$(echo "scale=1; $TOTAL_KB / (1024*1024)" | bc)
    USED_GB=$(echo "scale=1; $USED_KB / (1024*1024)" | bc)
    FREE_GB=$(echo "scale=1; $FREE_KB / (1024*1024)" | bc)
else
    TOTAL_GB="N/A"
    USED_GB="N/A"
    FREE_GB="N/A"
fi


# =======================================================
# 3. Získání zatížení CPU (OS-specific)
# =======================================================

CPU_LOAD="N/A"

if [ "$OS" = "Linux" ]; then
    # Linux: Průměr Idle z druhého vzorku vmstat
    VMSTAT_OUTPUT=$(vmstat 1 2 | tail -1)
    IDLE_PERCENT=$(echo "$VMSTAT_OUTPUT" | awk '{print $15}') 
    
    if [ -n "$IDLE_PERCENT" ] && expr "$IDLE_PERCENT" + 1 >/dev/null 2>&1; then
        CPU_LOAD=$(expr 100 - "$IDLE_PERCENT")
    fi

elif [ "$OS" = "Darwin" ]; then
    # macOS: Používáme 'top' pro získání Idle procenta
    TOP_OUTPUT=$(top -l 1 | grep "CPU usage:")
    
    IDLE_RAW=$(echo "$TOP_OUTPUT" | awk '{print $7}')
    IDLE_PERCENT_FLOAT=$(echo "$IDLE_RAW" | tr -d ',%')

    if [ -n "$IDLE_PERCENT_FLOAT" ]; then
        CPU_LOAD_FLOAT=$(echo "scale=0; 100 - $IDLE_PERCENT_FLOAT" | bc)
        CPU_LOAD=$(echo "$CPU_LOAD_FLOAT" | awk '{print int($1)}')
    fi
fi


# =======================================================
# 4. Tisk výstupu
# =======================================================

echo "=============================="
echo "SYSTEM MONITOR"
echo "------------------------------"
echo "User: $CURRENT_USER"
echo "Date: $CURRENT_DATE"
echo "CPU load: $CPU_LOAD %"
echo "RAM: $TOTAL_GB GB total / $USED_GB GB used / $FREE_GB GB free"
echo "Uptime: $UPTIME_STR"
echo "=============================="
