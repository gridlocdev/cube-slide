# Stage 1: Prepare the WebGL build files
FROM busybox:latest AS builder

# Set working directory
WORKDIR /app

# Copy only the necessary files for the Unity WebGL build
COPY index.html ./
COPY Build/ ./Build/
COPY TemplateData/ ./TemplateData/

# Stage 2: Serve the static files with BusyBox
FROM busybox:latest

# Create a non-root user
RUN addgroup -g 1001 webgl && \
    adduser -D -u 1001 -G webgl webgl

# Create directory for static files
RUN mkdir -p /home/webgl/www && \
    chown -R webgl:webgl /home/webgl

# Copy built files from builder stage
COPY --from=builder --chown=webgl:webgl /app /home/webgl/www

# Switch to non-root user
USER webgl

# Set working directory
WORKDIR /home/webgl/www

# Expose port
EXPOSE 8080

# Start BusyBox httpd server
CMD ["httpd", "-f", "-v", "-p", "8080", "-h", "/home/webgl/www"]
