# Base stage with dependencies
FROM python:3.11-slim AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Set the application directory
WORKDIR /usr/local/app

# Install dependencies
COPY vote/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Dev stage
FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
COPY vote/ ./vote/
WORKDIR /usr/local/app/vote
CMD ["python", "app.py"]

# Final production stage
FROM base AS final

# Copy the application code
COPY vote/ ./vote/

# Set the working directory to the application folder
WORKDIR /usr/local/app/vote

# Expose port 80
EXPOSE 80

# Start the application with gunicorn
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
