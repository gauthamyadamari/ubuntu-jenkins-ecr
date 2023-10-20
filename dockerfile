# Use the latest Ubuntu as the base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade the package lists
RUN apt-get update -y && \
    apt-get upgrade -y

# Install necessary packages
RUN apt-get install -y \
    awscli \
    git \
    curl

# Install Docker
RUN apt-get install -y docker.io

# Install kubectl using curl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm using curl
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    mv /usr/local/bin/helm /usr/bin/helm && \
    rm get_helm.sh

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the entry point to /bin/bash
CMD ["/bin/bash"]






