 app.py
from flask import Flask, jsonify, request

app = Flask(__name__)

# Ein einfaches In-Memory-Array zur Speicherung von "Services"
# In einer echten Anwendung würden Sie hier eine Datenbank verwenden
services = [
    {"id": 1, "name": "Webserver Hosting", "status": "active", "version": "1.0"},
    {"id": 2, "name": "Datenbank-Service", "status": "inactive", "version": "1.2"},
    {"id": 3, "name": "Caching-Service", "status": "active", "version": "0.9"}
]

# Zähler für die nächste Service-ID
next_service_id = len(services) + 1

@app.route('/')
def home():
    """
    Begrüßungsnachricht für die API-Basis-URL.
    """
    return jsonify({"message": "Willkommen zur Services API! Verwenden Sie /services für die Service-Liste."})

@app.route('/services', methods=['GET'])
def get_services():
    """
    Gibt eine Liste aller verfügbaren Services zurück.
    """
    return jsonify(services)

@app.route('/services/<int:service_id>', methods=['GET'])
def get_service(service_id):
    """
    Gibt Details zu einem spezifischen Service anhand seiner ID zurück.
    Gibt 404 zurück, wenn der Service nicht gefunden wird.
    """
    service = next((s for s in services if s['id'] == service_id), None)
    if service:
        return jsonify(service)
    return jsonify({"message": "Service nicht gefunden"}), 404

@app.route('/services', methods=['POST'])
def add_service():
    """
    Fügt einen neuen Service hinzu.
    Erwartet JSON-Daten mit 'name', 'status' und 'version'.
    """
    global next_service_id
    if not request.json or not 'name' in request.json:
        return jsonify({"message": "Ungültige Anfrage: 'name' ist erforderlich"}), 400

    new_service = {
        'id': next_service_id,
        'name': request.json['name'],
        'status': request.json.get('status', 'pending'), # Standardwert 'pending'
        'version': request.json.get('version', '1.0') # Standardwert '1.0'
    }
    services.append(new_service)
    next_service_id += 1
    return jsonify(new_service), 201 # 201 Created

@app.route('/services/<int:service_id>', methods=['PUT'])
def update_service(service_id):
    """
    Aktualisiert einen bestehenden Service anhand seiner ID.
    Erwartet JSON-Daten mit den zu aktualisierenden Feldern.
    """
    service = next((s for s in services if s['id'] == service_id), None)
    if not service:
        return jsonify({"message": "Service nicht gefunden"}), 404

    if not request.json:
        return jsonify({"message": "Ungültige Anfrage: Keine JSON-Daten bereitgestellt"}), 400

    service['name'] = request.json.get('name', service['name'])
    service['status'] = request.json.get('status', service['status'])
    service['version'] = request.json.get('version', service['version'])

    return jsonify(service)

@app.route('/services/<int:service_id>', methods=['DELETE'])
def delete_service(service_id):
    """
    Löscht einen Service anhand seiner ID.
    """
    global services
    original_len = len(services)
    services = [s for s in services if s['id'] != service_id]
    if len(services) < original_len:
        return jsonify({"message": "Service erfolgreich gelöscht"}), 200
    return jsonify({"message": "Service nicht gefunden"}), 404

if __name__ == '__main__':
    # Startet die Flask-Anwendung.
    # Für die Produktion würden Sie einen WSGI-Server wie Gunicorn verwenden.
    app.run(debug=True, host='0.0.0.0', port=5000)
