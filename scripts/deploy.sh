Bash

#!/bin/bash

# ------------------------------------------------------------------------------
# Beispielhaftes Deploy-Skript für Docker Compose Anwendungen
# ------------------------------------------------------------------------------

# Variablen
COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="meine-anwendung" # Optional: Setzen Sie einen spezifischen Projektnamen
BACKUP_DIR="./backup"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# --- Funktionen ---

info() {
  echo -e "\e[1;34m[INFO]\e[0m $1"
}

warn() {
  echo -e "\e[1;33m[WARNUNG]\e[0m $1"
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

backup_volumes() {
  info "Sichere Volumes..."
  mkdir -p "$BACKUP_DIR"
  for volume in $(docker volume ls -q --filter driver=local); do
    volume_name=$(docker volume inspect "$volume" --format '{{.Name}}')
    backup_path="$BACKUP_DIR/${volume_name}_${TIMESTAMP}.tar.gz"
    info "Sichere Volume '$volume_name' nach '$backup_path'"
    docker run --rm -v "$volume:/data" alpine tar czvf "$backup_path" -C /data .
    if [ $? -ne 0 ]; then
      warn "Fehler beim Sichern des Volumes '$volume_name'."
    fi
  done
  info "Sicherung der Volumes abgeschlossen."
}

stop_and_remove_containers() {
  info "Stoppe und entferne bestehende Container..."
  docker-compose -f "$COMPOSE_FILE" down
  if [ $? -ne 0 ]; then
    warn "Fehler beim Herunterfahren der Container."
  fi
}

pull_latest_images() {
  info "Ziehe die neuesten Images..."
  docker-compose -f "$COMPOSE_FILE" pull
  if [ $? -ne 0 ]; then
    warn "Fehler beim Ziehen der Images."
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

info "Starte Deployment..."

# Überprüfe Voraussetzungen
check_command "docker"
check_command "docker-compose"

# Optional: Sichern Sie bestehende Volumes
read -p "Möchten Sie die bestehenden Docker Volumes sichern? (j/N): " -n 1 -r
echo    # Zeileumbruch nach der Eingabe
if [[ "$REPLY" =~ ^[Jj]$ ]]; then
  backup_volumes
fi

# Stoppe und entferne die aktuellen Container
stop_and_remove_containers

# Ziehe die neuesten Images vom Docker Hub
pull_latest_images

# Starte die neuen Container
start_containers

info "Deployment abgeschlossen."

exit 0
