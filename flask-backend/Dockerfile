ARG TARGETPLATFORM=linux/amd64

# STAGE 1: Builder
FROM --platform=${TARGETPLATFORM} python:3.11-slim AS builder
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# STAGE 2: Runner
FROM --platform=${TARGETPLATFORM} python:3.11-slim
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY . .
RUN useradd -m flaskuser && chown -R flaskuser:flaskuser /app
USER flaskuser
EXPOSE 5000
CMD ["python", "app.py"]
