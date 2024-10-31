# Use nginx image
FROM nginx:latest

# Copy index.html file from codebuild server to container
COPY ./script/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
