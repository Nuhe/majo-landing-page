# Publicar Plan Paracaídas en el VPS de Hostinger

El sitio es estático. `compose.yaml` lo sirve con Nginx y lo conecta al Traefik que ya ocupa los puertos 80 y 443 del VPS. El formulario de reuniones sigue ofreciendo WhatsApp hasta que se configure su webhook y correo en n8n.

## Dominio y DNS

1. Crear dos registros `A` en la zona DNS del dominio: `@` y `www`, ambos hacia la IP pública del VPS. Si hay registros `AAAA`, deben apuntar a una dirección IPv6 funcional del mismo servidor; de lo contrario, quitarlos.
2. Esperar a que ambos nombres resuelvan a la IP del VPS. Traefik solicitará el certificado TLS de Let's Encrypt cuando reciba tráfico para esos nombres.

## Instalación

```bash
sudo mkdir -p /opt/majo
sudo chown "$USER:$USER" /opt/majo
git clone https://github.com/Nuhe/majo-landing-page.git /opt/majo/site
cd /opt/majo/site
cp .env.example .env
```

Editar `/opt/majo/site/.env` y reemplazar `ejemplo.com.ar` por el dominio comprado, sin `https://` ni `www.`. Después:

```bash
cd /opt/majo/site
docker compose -p majo config
docker compose -p majo up -d --build
docker compose -p majo ps
```

Comprobar `https://DOMINIO/` y `https://www.DOMINIO/`, además de `/privacidad.html`, `logo.jpeg` y `majo.jpeg`. Si falla HTTPS, mirar `docker logs traefik-traefik-1 --tail 100` y comprobar el DNS de ambos nombres.

## Actualizar la web

```bash
cd /opt/majo/site
git pull --ff-only
docker compose -p majo up -d --build
```

El repositorio incluye [`n8n/README.md`](n8n/README.md) para activar más adelante el formulario de reuniones. No activar `booking-config.js` hasta que el workflow, SMTP y la ruta `/api/reuniones` funcionen y se haya comprobado la entrega real de los correos.
