# Publicar Plan Paracaídas en el VPS de Hostinger

El sitio es estático. `compose.yaml` lo sirve con Nginx y lo conecta al Traefik que ya ocupa los puertos 80 y 443 del VPS. La solicitud de reuniones abre el correo electrónico hasta que se configure su webhook y correo en n8n.

## Dominio y DNS

1. Para `majo-planparacaidas.com`, cambiar el registro `A` de `@` a `187.77.242.243` (IP pública del VPS comprobada el 30/09/2026). El registro `www` puede seguir como `CNAME` hacia `majo-planparacaidas.com`; también sirve un registro `A` a la misma IP. Si hay registros `AAAA`, deben apuntar a una dirección IPv6 funcional del mismo servidor; de lo contrario, quitarlos.
2. Esperar a que ambos nombres resuelvan a `187.77.242.243`. Traefik solicitará el certificado TLS de Let's Encrypt cuando reciba tráfico para esos nombres.

## Instalación

```bash
sudo mkdir -p /opt/majo
sudo chown "$USER:$USER" /opt/majo
git clone https://github.com/Nuhe/majo-landing-page.git /opt/majo/site
cd /opt/majo/site
cp .env.example .env
mkdir -p public
cp index.html privacidad.html booking-config.js logo.jpeg majo.jpeg public/
```

El archivo `.env` ya contiene el dominio de Majo. Después:

```bash
cd /opt/majo/site
docker compose -p majo config
docker compose -p majo up -d --build
docker compose -p majo ps
```

Comprobar `https://majo-planparacaidas.com/` y `https://www.majo-planparacaidas.com/`, además de `/privacidad.html`, `logo.jpeg` y `majo.jpeg`. Si falla HTTPS, mirar `docker logs traefik-traefik-1 --tail 100` y comprobar el DNS de ambos nombres.

## Actualizar la web manualmente

```bash
cd /opt/majo/site
git pull --ff-only
cp index.html privacidad.html booking-config.js logo.jpeg majo.jpeg public/
docker compose -p majo up -d --build
```

## Publicar con el Jenkins existente

El sitio usa `public/` como carpeta servida por Nginx. Jenkins copia allí los archivos del repositorio mediante el [`Jenkinsfile`](Jenkinsfile), con el HTML al final para evitar que cargue recursos aún no copiados. El trabajo busca cambios en `main` aproximadamente cada cinco minutos.

En el VPS, una sola vez, compartir esa carpeta con el contenedor de Jenkins:

```bash
cd /opt/jenkins
python3 - <<'PY'
from pathlib import Path

path = Path('compose.yaml')
content = path.read_text()
existing = '      - /opt/foxops/site/dist:/srv/foxops-dist\n'
additional = '      - /opt/majo/site/public:/srv/majo-public\n'
assert existing in content, 'No encontré el volumen de Fox Ops en el Compose de Jenkins'
if additional not in content:
    path.write_text(content.replace(existing, existing + additional, 1))
PY

jenkins_uid=$(docker compose -p jenkins exec -T jenkins id -u)
jenkins_gid=$(docker compose -p jenkins exec -T jenkins id -g)
chown -R "$jenkins_uid:$jenkins_gid" /opt/majo/site/public
docker compose -p jenkins config --quiet
docker compose -p jenkins up -d
docker compose -p jenkins exec -T jenkins sh -lc 'test -w /srv/majo-public && echo "Carpeta de Majo lista"'
```

En `https://ci.foxops.digital`, crear un trabajo **Pipeline** llamado `majo-deploy`:

- **Definition:** Pipeline script from SCM.
- **SCM:** Git.
- **Repository URL:** `https://github.com/Nuhe/majo-landing-page.git`.
- **Branch:** `*/main`.
- **Script Path:** `Jenkinsfile`.

Guardar y ejecutar **Build Now**. Al terminar en verde, comprobar `https://majo-planparacaidas.com/`. El trabajo de Jenkins publica los cambios posteriores; Docker Compose solo se necesita si cambia la configuración del contenedor.

El repositorio incluye [`n8n/README.md`](n8n/README.md) para activar más adelante el formulario de reuniones. No activar `booking-config.js` hasta que el workflow, SMTP y la ruta `/api/reuniones` funcionen y se haya comprobado la entrega real de los correos.
