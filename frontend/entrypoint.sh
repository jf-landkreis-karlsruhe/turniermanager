#!/bin/sh

# Create directory if it doesn't exist
mkdir -p /usr/share/nginx/html/assets/assets/textfiles

# Write token to file
echo "$BACKEND_URL" > /usr/share/nginx/html/assets/assets/textfiles/backend-url.txt

# Start nginx in foreground
nginx -g 'daemon off;'
