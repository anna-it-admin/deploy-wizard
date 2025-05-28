#!/bin/bash

# ------------------------------------------------------------------------------
# Beispielhaftes Start-Skript für Docker Compose Anwendungen
# ------------------------------------------------------------------------------

# Variablen
COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="meine-anwendung" # Optional: Setzen Sie einen spezifischen Projektnamen

# --- Funktionen ---

info() {
  echo -e "\e[1;34m[INFO]\e[0m $1"
}

error() {
  echo -e "\e[1;31m[FEHLER]\e[0m $1"
  exit 1
}

check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Das Kommando '$1' ist nicht installiert."
  fi
}

start_containers() {
  info "Starte die Container..."
  docker-compose -f "$COMPOSE_FILE" up -d
  if [ $? -ne 0 ]; then
    error "Fehler beim Starten der Container."
  fi
  info "Container erfolgreich gestartet."
}

# --- Hauptteil des Skripts ---

info "Starte Docker Compose Umgebung..."

# Überprüfe Voraussetzungen
check_command "docker"
check_command "docker-compose"

# Starte die Container
start_containers

info "Docker Compose Umgebung gestartet."

exit 0
