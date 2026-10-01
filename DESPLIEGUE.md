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
```

El archivo `.env` ya contiene el dominio de Majo. Después:

```bash
cd /opt/majo/site
docker compose -p majo config
docker compose -p majo up -d --build
docker compose -p majo ps
```

Comprobar `https://majo-planparacaidas.com/` y `https://www.majo-planparacaidas.com/`, además de `/privacidad.html`, `logo.jpeg` y `majo.jpeg`. Si falla HTTPS, mirar `docker logs traefik-traefik-1 --tail 100` y comprobar el DNS de ambos nombres.

## Actualizar la web

```bash
cd /opt/majo/site
git pull --ff-only
docker compose -p majo up -d --build
```

El repositorio incluye [`n8n/README.md`](n8n/README.md) para activar más adelante el formulario de reuniones. No activar `booking-config.js` hasta que el workflow, SMTP y la ruta `/api/reuniones` funcionen y se haya comprobado la entrega real de los correos.
