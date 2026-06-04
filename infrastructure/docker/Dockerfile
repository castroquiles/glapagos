# GLAPAGOS Platform Dockerfile
# Multi-stage build for production-grade image

# Stage 1: Dependencies
FROM python:3.11-slim AS dependencies

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Production image
FROM python:3.11-slim AS production

ARG VERSION=unknown
ARG GIT_HASH=unknown
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="GLAPAGOS Platform"
LABEL org.opencontainers.image.description="Global Laboratory for AI Progress and Governance: Open Systems"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${GIT_HASH}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.source="https://github.com/glapagos-ai/glapagos"
LABEL org.opencontainers.image.licenses="Apache-2.0"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 glapagos && \
    useradd --uid 1001 --gid glapagos --shell /bin/bash --create-home glapagos

WORKDIR /app

COPY --from=dependencies /root/.local /home/glapagos/.local
COPY --chown=glapagos:glapagos src/ ./src/
COPY --chown=glapagos:glapagos VERSION .

ENV PATH=/home/glapagos/.local/bin:$PATH
ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV GLAPAGOS_VERSION=${VERSION}

USER glapagos

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python3 -c "import httpx; httpx.get('http://localhost:8000/health').raise_for_status()"

CMD ["python3", "-m", "uvicorn", "src.api.main:app", \
     "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
