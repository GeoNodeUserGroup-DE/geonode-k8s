# Overlay for existing GeoNode settings

from pathlib import Path
from geonode.settings import *

settings_additions = Path("/opt/geonode-custom/settings_additions.py")

if settings_additions.exists():
    exec(settings_additions.read_text(encoding="utf-8"))
