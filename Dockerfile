# Use official NGINX image
FROM nginx:latest

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static HTML file to serve
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
