"""Validate source structure without claiming boot or runtime success."""
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent.parent
files = [p for directory in ('auto', 'scripts', 'config') for p in (root / directory).rglob('*') if p.is_file()]
for path in files:
    data = path.read_bytes()
    assert not data.startswith(b'\xef\xbb\xbf'), f'BOM: {path}'
    assert b'\r\n' not in data, f'CRLF: {path}'
    if path.suffix in ('.xml', '.svg'):
        ET.fromstring(data)

packages = (root / 'config/package-lists/desktop.list.chroot').read_text().splitlines()
assert len(packages) == len(set(packages)), 'Duplicate packages'
assert not {'openssh-server', 'xrdp', 'telnetd'} & set(packages)
for required in ('calamares-settings-debian', 'firefox-esr', 'kolourpaint', 'pipewire-audio', 'network-manager', 'xfce4'):
    assert required in packages, required

panel = ET.parse(root / 'config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml')
ids = panel.findall(".//property[@name='plugin-ids']/value")
plugins = panel.find("./property[@name='plugins']")
assert plugins is not None
assert {f"plugin-{p.attrib['value']}" for p in ids} == {p.attrib['name'] for p in plugins}

try:
    import yaml
except ImportError:
    print('YAML: não verificado (instale python3-yaml no host Linux).')
else:
    for path in (root / 'config/includes.chroot/etc/calamares').rglob('*'):
        if path.suffix in ('.conf', '.desc'):
            assert isinstance(yaml.safe_load(path.read_text()), dict), path
print(f'{len(files)} arquivos verificados; XML/SVG, codificação, pacotes e painel válidos.')
