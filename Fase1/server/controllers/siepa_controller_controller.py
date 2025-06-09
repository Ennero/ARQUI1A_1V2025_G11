from flask import Blueprint, request
from models.siepa_db import SiepaDB
from utils.http_responder import respond_with_success, respond_with_error
from models.app_settings_model import AppSettings
from app import SiepaG11App

siepa_blueprint = Blueprint('siepa_controller', __name__)


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
    data = request.get_json()

    if not data:
        return respond_with_error("Missing JSON body")
    
    mode = data.get('mode')

    if not mode:
        return respond_with_error("Missing mode")
    
    if mode not in ['automatic', 'manual']:
        return respond_with_error("Invalid mode. Must be 'automatic' or 'manual'.")
    
    # Update the app settings
    AppSettings().mode = mode
    
    return respond_with_success({"message": "Settings updated successfully."})

@siepa_blueprint.route('/siepa/devices/<device_name>', methods=['PUT'])
def put_siepa_settings(device_name):
    data = request.get_json()

    if not data:
        return respond_with_error("Missing JSON body")
    
    status = data.get('status')

    if not status:
        return respond_with_error("Missing status")
    
    if status.lower() not in ['on', 'off']:
        return respond_with_error("Invalid status. Must be 'ON' or 'OFF'.")
    
    if device_name not in ['lighting', 'fan', 'buzzer']:
        return respond_with_error("Invalid device. Must be 'lighting', 'fan', or 'buzzer'.")
    
    if device_name == 'lighting':
        SiepaG11App().lighting_device.mode = True if status.lower() == 'on' else False
    elif device_name == 'fan':
        SiepaG11App().fan.mode = True if status.lower() == 'on' else False
    elif device_name == 'buzzer':
        SiepaG11App().buzzer.mode = True if status.lower() == 'on' else False
    
    return respond_with_success({"message": f"Device {device_name} is {status.upper()}."})