# Use Python Alpine for minimal size with Python support
FROM python:3.12-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk update && apk add --no-cache \    
    bash \
    curl \
    unzip \
# Add any other system dependencies your application needs
    && rm -rf /var/cache/apk/*

# Install Google Cloud SDK (includes gsutil)
RUN curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts \
    && mv /root/google-cloud-sdk /opt/google-cloud-sdk

# Add gcloud and gsutil to PATH
ENV PATH="/opt/google-cloud-sdk/bin:${PATH}"

# # RUN exec -l $SHELL
# RUN pip install --no-cache-dir google-cloud-storage

# Copy shell scripts
COPY setup.sh start.sh ./

# Make scripts executable
RUN chmod +x setup.sh start.sh

# Run setup.sh first, then start.sh
CMD ["bash", "-c", "./setup.sh && ./start.sh"]
