#!/bin/bash
# Script para iniciar swaync sin tema GTK que interfiera
pkill -f swaync 2>/dev/null
sleep 0.5
GTK_THEME="" swaync > /dev/null 2>&1 &