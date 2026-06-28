"""
GLAPAGOS Platform API
v0.1.0

Regional AI governance initiatives dashboard backend.
Serves structured data from data/initiatives.json.

Endpoints:
  GET /api/health
  GET /api/stats
  GET /api/initiatives
  GET /api/initiatives/{initiative_id}
"""

import json
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException, Query  # type: ignore
from fastapi.middleware.cors import CORSMiddleware  # type: ignore
from fastapi.staticfiles import StaticFiles  # type: ignore

BASE_DIR = Path(__file__).resolve().parent.parent.parent
DATA_FILE = BASE_DIR / "data" / "initiatives.json"
STATIC_DIR = BASE_DIR / "src" / "dashboard"

app = FastAPI(
    title="GLAPAGOS Platform API",
    description="Regional AI governance across the Western Hemisphere.",
    version="0.1.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)


def load_data() -> dict:
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


@app.get("/api/health")
def health() -> dict:
    return {"status": "ok", "version": "0.1.0"}


@app.get("/api/stats")
def stats() -> dict:
    data = load_data()
    initiatives = data["initiatives"]

    domains: dict = {}
    types: dict = {}
    countries: set = set()

    for item in initiatives:
        domains[item["domain"]] = domains.get(item["domain"], 0) + 1
        types[item["type"]] = types.get(item["type"], 0) + 1
        for c in item["countries"]:
            countries.add(c)

    return {
        "total_initiatives": len(initiatives),
        "countries_covered": len(countries),
        "by_domain": domains,
        "by_type": types,
        "data_version": data["version"],
        "last_updated": data["updated"],
    }


@app.get("/api/initiatives")
def list_initiatives(
    domain: Optional[str] = Query(None, description="Filter by domain"),
    status: Optional[str] = Query(None, description="Filter by status"),
    type: Optional[str] = Query(None, description="Filter by type"),
    country: Optional[str] = Query(
        None,
        description="ISO 3166-1 alpha-2 country code",
    ),
) -> dict:
    data = load_data()
    results = data["initiatives"]

    if domain:
        results = [r for r in results if r["domain"] == domain]
    if status:
        results = [r for r in results if r["status"] == status]
    if type:
        results = [r for r in results if r["type"] == type]
    if country:
        results = [r for r in results if country.upper() in r["countries"]]

    return {
        "total": len(results),
        "filters": {
            "domain": domain,
            "status": status,
            "type": type,
            "country": country,
        },
        "results": results,
    }


@app.get("/api/initiatives/{initiative_id}")
def get_initiative(initiative_id: str) -> dict:
    data = load_data()
    for item in data["initiatives"]:
        if item["id"] == initiative_id:
            return item
    raise HTTPException(
        status_code=404,
        detail=f"Initiative '{initiative_id}' not found.",
    )


app.mount(
    "/",
    StaticFiles(directory=str(STATIC_DIR), html=True),
    name="static",
)
