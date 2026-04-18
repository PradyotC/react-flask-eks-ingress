# ==========================================
# STAGE 1: Builder
# ==========================================
FROM --platform=linux/amd64 python:3.11-slim AS builder

# Prevent Python from writing pyc files and keep stdout unbuffered
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a virtual environment
RUN python -m venv /opt/venv

# Make sure we use the venv's pip
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies into the venv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ==========================================
# STAGE 2: Runner
# ==========================================
FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

# Copy the completely built venv from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Ensure the runner uses the venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy the application code
COPY . .

# Security Best Practice: Do not run as root!
RUN useradd -m flaskuser && chown -R flaskuser:flaskuser /app
USER flaskuser

EXPOSE 5000
CMD ["python", "app.py"]
