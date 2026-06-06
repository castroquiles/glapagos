"""
GLAPAGOS - Regional AI Governance Policy Dashboard
FastAPI backend serving data from the data/ directory.

Run:
    uvicorn main:app --reload --port 8000
"""

import json
import logging
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

logging.basicConfig(level=logging.INFO, format="%(levelname)s  %(name)s  %(message)s")
log = logging.getLogger("glapagos")

BASE_DIR    = Path(__file__).parent
DATA_DIR    = BASE_DIR / "data"
FRONTEND_DIR = BASE_DIR / "frontend"

app = FastAPI(
    title="GLAPAGOS Dashboard API",
    description="Regional AI Governance Policy Dashboard — Western Hemisphere",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_json(path: Path) -> dict:
    if not path.exists():
        log.error("Data file not found: %s", path)
        raise HTTPException(status_code=404, detail=f"Data file not found: {path.name}")
    with open(path, encoding="utf-8") as f:
        return json.load(f)


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/api/health", tags=["meta"])
def health() -> dict:
    return {"status": "ok", "platform": "GLAPAGOS", "version": "0.1.0"}


@app.get("/api/policies", tags=["data"])
def get_policies() -> dict:
    """Returns all records from data/standards/regional_policies.json."""
    return load_json(DATA_DIR / "standards" / "regional_policies.json")


@app.get("/api/policies/{policy_id}", tags=["data"])
def get_policy(policy_id: str) -> dict:
    """Returns a single policy record by ID (e.g. POL-001)."""
    data = load_json(DATA_DIR / "standards" / "regional_policies.json")
    for record in data.get("policies", []):
        if record["id"].upper() == policy_id.upper():
            return record
    raise HTTPException(status_code=404, detail=f"No policy found with id: {policy_id}")


@app.get("/api/benchmarks", tags=["data"])
def get_benchmarks() -> dict:
    """Returns domain benchmark scores from data/benchmarks/domain_scores.json."""
    return load_json(DATA_DIR / "benchmarks" / "domain_scores.json")


@app.get("/api/schemas", tags=["meta"])
def get_schemas() -> dict:
    """Returns schema definitions from data/schemas/governance_schema.json."""
    return load_json(DATA_DIR / "schemas" / "governance_schema.json")


@app.get("/api/summary", tags=["data"])
def get_summary() -> dict:
    """
    Returns aggregate statistics computed at request time from the data files.
    No caching — values always reflect current file contents.
    """
    policies_data   = load_json(DATA_DIR / "standards" / "regional_policies.json")
    benchmarks_data = load_json(DATA_DIR / "benchmarks" / "domain_scores.json")

    policies = policies_data.get("policies", [])
    domains  = benchmarks_data.get("domains", [])
    total    = len(policies)

    avg_compliance = round(
        sum(p["compliance_score"] for p in policies) / total, 1
    ) if total else 0

    avg_hemisphere = round(
        sum(d["hemisphere_score"] for d in domains) / len(domains), 1
    ) if domains else 0

    return {
        "total_countries": total,
        "status_breakdown": {
            "Active":      sum(1 for p in policies if p["status"] == "Active"),
            "In Progress": sum(1 for p in policies if p["status"] == "In Progress"),
            "Draft":       sum(1 for p in policies if p["status"] == "Draft"),
            "None":        sum(1 for p in policies if p["status"] == "None"),
        },
        "avg_compliance_score":       avg_compliance,
        "high_risk_countries":        sum(1 for p in policies if p["risk_tier"] == "High"),
        "open_source_committed":      sum(1 for p in policies if p.get("open_source_commitment")),
        "multilateral_participants":  sum(1 for p in policies if p.get("multilateral_participation")),
        "avg_hemisphere_domain_score": avg_hemisphere,
        "top_domains_by_score": sorted(
            [
                {
                    "name":  d["name"],
                    "score": d["hemisphere_score"],
                    "trend": d["trend"],
                }
                for d in domains
            ],
            key=lambda x: x["score"],
            reverse=True,
        )[:3],
    }


# ---------------------------------------------------------------------------
# Static frontend
# ---------------------------------------------------------------------------

app.mount("/static", StaticFiles(directory=str(FRONTEND_DIR)), name="static")


@app.get("/", include_in_schema=False)
def root() -> FileResponse:
    index = FRONTEND_DIR / "index.html"
    if not index.exists():
        raise HTTPException(status_code=404, detail="Frontend not built. Place index.html in frontend/")
    return FileResponse(str(index))


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import uvicorn
    log.info("Starting GLAPAGOS Dashboard")
    log.info("Frontend : http://localhost:8000/")
    log.info("API docs : http://localhost:8000/docs")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
