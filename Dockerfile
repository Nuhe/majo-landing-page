FROM nginx:stable-alpine

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY index.html privacidad.html booking-config.js logo.jpeg majo.jpeg /usr/share/nginx/html/
