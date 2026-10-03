# Solicitudes de reunión

El archivo [`solicitudes-reunion.json`](solicitudes-reunion.json) es un workflow para importar en n8n. Recibe nombre, email, teléfono y modalidad; valida los datos, avisa a María José y envía al cliente un correo que indica que la solicitud está pendiente. Responde `202 {"status":"pending"}` solo después de que ambos envíos SMTP hayan sido aceptados. Una respuesta SMTP aceptada no garantiza que el mensaje llegue a la bandeja de entrada; hay que probar la entrega real.

## Configuración antes de activar

1. Importar el JSON en n8n y asignar una credencial SMTP a los dos nodos **Send Email**.
2. El remitente temporal es `camilonrodriguez@gmail.com`. Confirmar que la cuenta SMTP permita enviar desde esa dirección. El destino del aviso es `berdaguerfinanzas@gmail.com`, que también figura como dirección de respuesta en el correo al cliente.
3. Publicar el workflow. n8n usa una URL de prueba y otra de producción; para el sitio debe usarse la de producción: `/webhook/plan-paracaidas/reunion`.
4. En el VPS, actualizar el sitio y reconstruir su contenedor para instalar la ruta `POST /api/reuniones` definida en [`nginx/default.conf`](../nginx/default.conf). La configuración limita el cuerpo a 8 KB y las solicitudes a 10 por minuto, con una ráfaga de 5. La página sigue usando el correo hasta completar las pruebas.

   ```bash
   cd /opt/majo/site
   git pull --ff-only
   docker compose -p majo up -d --build
   docker network connect majo_booking n8n
   ```

   Si `docker network connect` indica que `n8n` ya está conectado, se puede continuar. Si n8n se recrea con Docker Compose, agregarle la red externa `majo_booking` en su propio archivo Compose para que conserve esa conexión. No publicar el puerto 5678 hacia Internet.

5. Comprobar que el sitio todavía carga y que los datos inválidos llegan al workflow sin enviar correos:

   ```bash
   curl -I https://majo-planparacaidas.com/
   curl -i -X POST https://majo-planparacaidas.com/api/reuniones \
     -H 'Content-Type: application/json' --data '{}'
   ```

   Con el workflow activo, el segundo comando debe responder `400 {"error":"invalid_request"}`. Un `404` indica que el workflow no está activo o que la ruta no llega a n8n; un `502` indica que falta la conexión entre contenedores o que n8n no responde.

6. Probar una solicitud presencial y una virtual con casillas reales; comprobar ambos correos, el `202` y el caso de datos inválidos (`400`). Revisar también que n8n no conserve indefinidamente ejecuciones con datos personales.

7. Solo entonces configurar `booking-config.js` con `window.PLAN_PARACAIDAS_BOOKING_API = '/api/reuniones';` y publicar el cambio con Jenkins. Con el valor vacío, «Agendar una reunión» sigue abriendo el correo electrónico.

La interfaz de administración de n8n debe mantenerse protegida por separado. La ruta pública solo debe exponer el webhook necesario.

El workflow no almacena una agenda ni asigna horario: deja la coordinación pendiente de respuesta humana. Si más adelante se necesita seguimiento de estados, conviene guardar cada solicitud en una base privada y añadir confirmación o cancelación explícita.
