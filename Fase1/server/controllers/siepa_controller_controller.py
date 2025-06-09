from flask import Blueprint, request
from models.siepa_db import SiepaDB
from utils.http_responder import respond_with_success
from models.app_settings_model import AppSettings

siepa_blueprint = Blueprint('siepa_controller', __name__)

@siepa_blueprint.route('/siepa', methods=['GET'])
def get_siepa_data():
    """
    Endpoint to get the current sensor data.
    """
    # Here you would typically fetch data from your sensors or database
    # For demonstration, we return a static SiepaDB object
    siepa_data = SiepaDB(
        temperature=22.5,
        humidity=45.0,
        pressure=1013.25,
        air_quality=150
    )
    
    return {
        "timestamp": siepa_data.timestamp.isoformat(),
        "temperature": siepa_data.temperature,
        "humidity": siepa_data.humidity,
        "pressure": siepa_data.pressure,
        "air_quality": siepa_data.air_quality
    }, 200

@siepa_blueprint.route('/siepa/settings', methods=['GET'])
def get_siepa_settings():
    
    return respond_with_success({
        "app_name": AppSettings().app_name,
        "version": AppSettings().version,
        "debug": AppSettings().debug,
        "mode": AppSettings().mode
    })

@siepa_blueprint.route('/siepa/settings', methods=['PUT'])
def put_siepa_settings():
    
    return respond_with_success({"message": "Settings updated successfully."})