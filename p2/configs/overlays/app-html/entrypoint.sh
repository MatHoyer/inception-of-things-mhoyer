#!/bin/sh
KERNEL="$(uname -s) ($(uname -r) $(uname -m))"
sed -e "s|__APP_NAME__|${APP_NAME}|g" \
    -e "s|__KERNEL__|${KERNEL}|g" \
    -e "s|__POD_NAME__|${POD_NAME}|g" \
    /etc/app/index.html > /usr/share/nginx/html/index.html
cp /etc/app/index.css /usr/share/nginx/html/index.css
exec nginx -g 'daemon off;'
