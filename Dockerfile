# Verwenden eines offiziellen Python-Basis-Images
FROM python:3.9-slim-buster

# Setzen des Arbeitsverzeichnisses im Container
WORKDIR /app

# Kopieren der requirements.txt-Datei (falls vorhanden)
COPY requirements.txt .

# Installieren der Python-Abhängigkeiten
RUN pip install --no-cache-dir -r requirements.txt

# Kopieren des Anwendungscodes
COPY . .

# Definieren des Ports, auf dem die Anwendung läuft
EXPOSE 8000

# Definieren des Befehls zum Starten der Anwendung
CMD ["python", "app.py"]
