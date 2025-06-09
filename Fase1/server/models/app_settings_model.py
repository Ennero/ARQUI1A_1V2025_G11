class AppSettings(object):
    
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(AppSettings, cls).__new__(cls)
        return cls.instance
    
    def __init__(self, app_name: str, version: str, debug: bool):
        self._app_name = app_name
        self._version = version
        self._debug = debug
        self._mode = "automatic"

    def __repr__(self):
        return f"AppSettings(app_name={self._app_name}, version={self._version}, debug={self._debug})"
    
    @property
    def mode(self):
        return self._mode
    
    @mode.setter
    def mode(self, value: str):
        if value in ["automatic", "manual"]:
            self._mode = value
        else:
            raise ValueError("Mode must be 'automatic' or 'manual'")
    
