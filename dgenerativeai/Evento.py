import json
import uuid
import requests
from datetime import datetime
from promptflow import tool


# The inputs section will change based on the arguments of the tool function, after you save the code
# Adding type to arguments and return value will help the system show the types properly
# Please update the function name/signature per need
@tool
def my_python_tool(input1: str) -> str:
    # Configuración del Event Grid
    EVENT_GRID_TOPIC_ENDPOINT = ""  # Cambia por tu endpoint
    EVENT_GRID_TOPIC_KEY = ""  # Clave del topic

    # Encabezados para autenticación
    HEADERS = {
        "Content-Type": "application/json",
        "aeg-sas-key": EVENT_GRID_TOPIC_KEY,
    }

    # Evento de ejemplo
    event = [{
        "id": str(uuid.uuid4()),
        "eventType": "MiEvento.TipoEjemplo",
        "subject": "mi/sujeto/de/prueba",
        "eventTime": datetime.utcnow().isoformat(),
        "data": {
            "mensaje": "¡Hola desde Python!",
            "valor": 42
        },
        "dataVersion": "1.0"
    }]

    # Enviar el evento a Event Grid
    response = requests.post(EVENT_GRID_TOPIC_ENDPOINT, headers=HEADERS, data=json.dumps(event))

    # Verificar la respuesta
    if response.status_code == 200 or response.status_code == 202:
        print("Evento enviado con éxito")
    else:
        print(f"Error al enviar evento: {response.status_code} - {response.text}")
