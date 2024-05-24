# Use an official Nginx runtime as a parent image
FROM nginx:latest

# Copy your custom Nginx configuration file (if needed)
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]