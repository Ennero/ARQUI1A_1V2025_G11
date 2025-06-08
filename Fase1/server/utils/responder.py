from flask import Response
import json


def respond_with_success(data = ''):
    
    return Response(
        response=json.dumps(data),
        status=200,
        mimetype='application/json'
    )


def respond_with_error(message = '', details = []):
    response = {
        'message': message,
        'details': details
    }

    return Response(
        response=json.dumps(response),
        status=400,
        mimetype='application/json'
    )

def respond_with_not_found():

    return Response(
        response=json.dumps('Resource not found'),
        status=404,
        mimetype='application/json'
    )

def respond_with_unauthorized():

    return Response(
        response=json.dumps('Your are not allowed -_-'),
        status=401,
        mimetype='application/json'
    )

def respond_with_internal_server_error(msg = 'Internal server error'):
    return Response(
        response=json.dumps(msg),
        status=500,
        mimetype='application/json'
    )