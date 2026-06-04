from geonode.settings import *

try:
    with open("/opt/geonode-custom/settings_additions.py", encoding="utf-8") as f:
        exec(f.read())
except FileNotFoundError:
    pass
