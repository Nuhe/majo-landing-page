FROM nginx:stable-alpine

COPY index.html privacidad.html booking-config.js logo.jpeg majo.jpeg /usr/share/nginx/html/
