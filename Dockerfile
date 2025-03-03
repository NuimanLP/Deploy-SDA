# Use the official Nginx image as base
FROM nginx:alpine

# Copy the React build files to the Nginx web root
COPY build/ /usr/share/nginx/html/

# Copy a custom Nginx configuration for React routing (SPA)
RUN mkdir -p /etc/nginx/conf.d
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

