from flask import Blueprint, request
from config.db import SiepaDB
from utils.http_responder import respond_with_success, respond_with_error
from models.app_settings_model import AppSettings
from models.device_manager import DeviceManager
from config.mongodb import mongodb_connection

siepa_blueprint = Blueprint('siepa_controller', __name__)


@siepa_blueprint.route('/siepa/settings', methods=['GET'])
def get_siepa_settings():
    
    return respond_with_success({
        "humidity": {
            "control": DeviceManager().yellow_led.control,
            "mode": DeviceManager().yellow_led.mode
        },
        "luminosity": {
            "control": DeviceManager().green_led.control,
            "mode": DeviceManager().green_led.mode
        },
        "temperature": {
            "control": DeviceManager().red_led.control,
            "mode": DeviceManager().red_led.mode
        },
        "air_quality": {
            "control": DeviceManager().blue_led.control,
            "mode": DeviceManager().blue_led.mode
        },
        "lighting_device": {
            "control": DeviceManager().lighting_device.control,
            "mode": DeviceManager().lighting_device.mode
        },
        "lighting_device": {
            "control": DeviceManager().lighting_device.control,
            "mode": DeviceManager().lighting_device.mode
        },
        "fan_device": {
            "control": DeviceManager().fan_device.control,
            "mode": DeviceManager().fan_device.mode
        },
        "buzzer_device": {
            "control": DeviceManager().buzzer_device.control,
            "mode": DeviceManager().buzzer_device.mode
        }
    })
    
    

@siepa_blueprint.route('/siepa/devices/control/<device_name>', methods=['PUT'])
def put_siepa_device_control(device_name):
    data = request.get_json()
    print(data)
    if not data:
        return respond_with_error("Missing JSON body")
    
    mode = data.get('mode')

    if not mode:
        return respond_with_error("Missing mode")
    
    if mode not in ['automatic', 'manual']:
        return respond_with_error("Invalid mode. Must be 'automatic' or 'manual'.")
    
    if device_name == 'lighting':
        DeviceManager().lighting_device.control = mode
        DeviceManager().lighting_device.turn_off_device()  
    elif device_name == 'fan':
        DeviceManager().fan_device.control = mode
        DeviceManager().fan_device.turn_off_device()  
    elif device_name == 'buzzer':
        DeviceManager().buzzer_device.control = mode
        DeviceManager().buzzer_device.turn_off_device()
    elif device_name == 'red_led':
        DeviceManager().red_led.control = mode
        DeviceManager().red_led.turn_off_device()
    elif device_name == 'green_led':
        DeviceManager().green_led.control = mode
        DeviceManager().green_led.turn_off_device()
    elif device_name == 'blue_led':
        DeviceManager().blue_led.turn_off_device()
    elif device_name == 'yellow_led':
        DeviceManager().yellow_led.turn_off_device()
    
    return respond_with_success({"message": "Settings updated successfully."})

@siepa_blueprint.route('/siepa/devices/<device_name>', methods=['PUT'])
def put_siepa_device_status(device_name):
    data = request.get_json()
    
    if not data:
        return respond_with_error("Missing JSON body")
    
    status = data.get('status')
    
    # if device_name not in ['lighting', 'fan', 'buzzer', 'red_led', 'green_led', 'blue_led', 'yellow_led', 'display']:
    #     return respond_with_error("Invalid device. Must be 'lighting', 'fan', or 'buzzer', 'red_led', 'blue_led', 'green_led', 'yellow_led', 'display'.")
    
    if device_name == 'lighting':
        if status:
            DeviceManager().lighting_device.turn_on_device()
        else:
            DeviceManager().lighting_device.turn_off_device()
    elif device_name == 'fan':
        if status:
            DeviceManager().fan_device.turn_on_device()
        else:
            DeviceManager().fan_device.turn_off_device()
    elif device_name == 'buzzer':
        if status:
            DeviceManager().buzzer_device.turn_on_device()
        else:
            DeviceManager().buzzer_device.turn_off_device()
    elif device_name == 'red_led':
        if status:
            DeviceManager().red_led.turn_on_device()
        else:
            DeviceManager().red_led.turn_off_device()
    elif device_name == 'green_led':
        if status:
            DeviceManager().green_led.turn_on_device()
        else:
            DeviceManager().green_led.turn_off_device()
    elif device_name == 'blue_led':
        if status:
            DeviceManager().blue_led.turn_on_device()
        else:
            DeviceManager().blue_led.turn_off_device()
    elif device_name == 'yellow_led':
        if status:
            DeviceManager().yellow_led.turn_on_device()
        else:
            DeviceManager().yellow_led.turn_off_device()
    elif device_name == 'display':
        if data.get('show_mode') is not None and data.get('show_mode') in ['readings', 'statistics', 'predictions']:
            DeviceManager().display_lcd.show = data.get('show_mode')
        else:
            return respond_with_error("Invalid display mode. Must be 'readings', 'statistics', or 'predictions'.")
    else:
        return respond_with_error("Invalid device name provided.")
    
    return respond_with_success({"message": f"Device {device_name} is {status}."})


