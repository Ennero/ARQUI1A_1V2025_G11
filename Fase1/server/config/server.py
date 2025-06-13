from flask import Flask
from flask_cors import CORS
from werkzeug.exceptions import HTTPException, BadRequest
from controllers.siepa_app_controller import siepa_blueprint

from utils.http_responder import respond_with_success, respond_with_error, respond_with_not_found, respond_with_internal_server_error

class FlaskServer:

    def __init__(self):
        self.app = Flask(__name__)
        CORS(self.app)
        self.register_blueprints()
        self.register_error_handlers()
        self.setup_routes()

    def register_blueprints(self):
        self.app.register_blueprint(siepa_blueprint)

    def setup_routes(self):

        @self.app.route('/')
        def index():
            return "Hello, World!"

    def register_error_handlers(self):
        @self.app.errorhandler(404)
        def not_found_error(error):
            print(f"Resource not found: {error}")
            # return respond_with_not_found("The requested resource was not found.")
            return respond_with_not_found()

        @self.app.errorhandler(BadRequest)
        def handle_bad_request(error):
            print(f"Bad Request: {error}")
            return respond_with_error("Bad request")

        @self.app.errorhandler(HTTPException)
        def handle_http_exception(error):
            print(f"HTTP Exception: {error}")
            return respond_with_error(error.description, error.code)

        @self.app.errorhandler(Exception)
        def handle_exception(error):
            print(f"An unexpected error occurred: {error}")
            return respond_with_internal_server_error(f"Internal server error {error}")

    def run(self):
        # self.app.run(host='0.0.0.0', port=3000, debug=True)
        self.app.run(host='0.0.0.0', port=5000, debug=False)
        return