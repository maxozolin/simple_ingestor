# Use Alpine Linux for minimal size
FROM alpine:latest

# Set working directory
WORKDIR /app

# Install any system dependencies if needed
RUN apk update && apk add --no-cache \
    # Add any system dependencies your application needs
    && rm -rf /var/cache/apk/*
    
# Copy shell scripts
COPY setup.sh start.sh ./

# Make scripts executable
RUN chmod +x setup.sh start.sh

# Run setup.sh first, then start.sh
CMD ["sh", "-c", "./setup.sh && ./start.sh"]
