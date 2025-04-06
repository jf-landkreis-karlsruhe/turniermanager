#!/bin/sh

rm /usr/share/nginx/html/apiBaseApi.js
echo "BASE_API_URL = 'http://$BACKEND_URL';" > /usr/share/nginx/html/apiBaseApi.js

# Start nginx in foreground
nginx -g 'daemon off;'
