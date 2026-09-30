# Solicitudes de reunión

El archivo [`solicitudes-reunion.json`](solicitudes-reunion.json) es un workflow para importar en n8n. Recibe nombre, email, teléfono y modalidad; valida los datos, avisa a María José y envía al cliente un correo que indica que la solicitud está pendiente. Responde `202 {"status":"pending"}` solo después de que ambos envíos SMTP hayan sido aceptados. Una respuesta SMTP aceptada no garantiza que el mensaje llegue a la bandeja de entrada; hay que probar la entrega real.

## Configuración antes de activar

1. Importar el JSON en n8n y asignar una credencial SMTP a los dos nodos **Send Email**.
2. El remitente temporal es `camilonrodriguez@gmail.com`. Confirmar que la cuenta SMTP permita enviar desde esa dirección. El destino del aviso es `berdaguerfinanzas@gmail.com`, que también figura como dirección de respuesta en el correo al cliente.
3. Publicar el workflow. n8n usa una URL de prueba y otra de producción; para el sitio debe usarse la de producción: `/webhook/plan-paracaidas/reunion`.
4. Servir el sitio y n8n detrás de HTTPS. En el proxy del sitio, dirigir `POST /api/reuniones` al webhook de producción de n8n. Limitar tamaño y frecuencia de las solicitudes; no exponer las credenciales SMTP al navegador.
5. En el VPS, configurar `booking-config.js` con `window.PLAN_PARACAIDAS_BOOKING_API = '/api/reuniones';`. El archivo incluido en el repositorio deja el valor vacío, por lo que el botón permanece oculto en GitHub Pages mientras no exista el endpoint.
6. Probar una solicitud presencial y una virtual con casillas reales; comprobar ambos correos, el `202` y el caso de datos inválidos (`400`). Revisar también que n8n no conserve indefinidamente ejecuciones con datos personales.

Ejemplo de ruta para Nginx, si el contenedor del sitio comparte red Docker con un servicio llamado `n8n`:

```nginx
location = /api/reuniones {
    limit_except POST { deny all; }
    client_max_body_size 8k;
    proxy_pass http://n8n:5678/webhook/plan-paracaidas/reunion;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

El proxy público también debe tener una regla de límite de solicitudes. El webhook no debe quedar como única defensa frente a envíos automatizados. La interfaz de administración de n8n debe mantenerse protegida por separado.

El workflow no almacena una agenda ni asigna horario: deja la coordinación pendiente de respuesta humana. Si más adelante se necesita seguimiento de estados, conviene guardar cada solicitud en una base privada y añadir confirmación o cancelación explícita.
