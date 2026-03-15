# Stage 1: Export the web build
FROM godot-base:4.6 AS builder

COPY . /game
WORKDIR /game

RUN mkdir -p /output \
    && godot --headless --export-release "Web" /output/index.html

# Stage 2: Serve the static files with BusyBox
FROM busybox:latest

# Create a non-root user
RUN addgroup -g 1001 webgl && \
    adduser -D -u 1001 -G webgl webgl

# Create directory for static files
RUN mkdir -p /home/webgl/www && \
    chown -R webgl:webgl /home/webgl

# Add wasm MIME type and COOP/COEP headers for SharedArrayBuffer support
RUN echo 'application/wasm wasm' >> /etc/mime.types \
    && printf 'H:Cross-Origin-Opener-Policy: same-origin\nH:Cross-Origin-Embedder-Policy: require-corp\n' \
       > /etc/httpd.conf

# Copy built files from builder stage
COPY --from=builder --chown=webgl:webgl /output /home/webgl/www

USER webgl

WORKDIR /home/webgl/www

EXPOSE 8080

CMD ["httpd", "-f", "-v", "-p", "8080", "-h", "/home/webgl/www", "-c", "/etc/httpd.conf"]
