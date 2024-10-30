# Use the official NGINX image as the base image
FROM https:latest

# Install git to clone the repository
# RUN yum update && yum install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository and copy the index.html to NGINX's default location
# RUN mkdir /tmp/jh-kubernetes
# RUN git clone https://github.com/jan2274/jh-kubernetes.git /tmp/jh-kubernetes

# Copy the index.html from the cloned repository to the NGINX HTML directory
COPY ./script/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
