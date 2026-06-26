# Platform API

The GLAPAGOS Platform API is a read-only HTTP service that exposes the regional
AI-governance initiatives dataset (`data/initiatives.json`). It is built with
[FastAPI](https://fastapi.tiangolo.com/).

The machine-readable contract lives at
[`openapi.json`](openapi.json) and is regenerated with
`python scripts/export_openapi.py`. When the server is running, interactive docs
are available at `/api/docs` (Swagger UI) and `/api/redoc` (ReDoc).

## Endpoints

| Method | Path | Description |
| ------ | ---- | ----------- |
| `GET` | `/api/health` | Liveness check; returns status and API version. |
| `GET` | `/api/stats` | Aggregate counts by domain, type, and country. |
| `GET` | `/api/initiatives` | List initiatives, optionally filtered. |
| `GET` | `/api/initiatives/{initiative_id}` | Fetch a single initiative by ID. |

### `GET /api/initiatives` filters

All filters are optional query parameters and may be combined:

| Parameter | Description |
| --------- | ----------- |
| `domain` | Filter by initiative domain. |
| `status` | Filter by initiative status. |
| `type` | Filter by initiative type. |
| `country` | ISO 3166-1 alpha-2 country code (case-insensitive). |

Unknown initiative IDs return `404`.
