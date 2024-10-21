FROM bitnami/matomo:latest

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint to the shell script
ENTRYPOINT ["/entrypoint.sh"]
