# Nginx Static Site / Reverse Proxy Dockerfile

FROM nginx:alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom config
COPY nginx.conf /etc/nginx/conf.d/

# Copy static files (for static sites)
COPY html/ /usr/share/nginx/html/

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
