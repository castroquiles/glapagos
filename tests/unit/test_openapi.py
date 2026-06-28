"""Tests for the platform API and its committed OpenAPI specification.

These guard issue #13: the platform API must ship a documented, non-drifting
OpenAPI contract at ``docs/api/openapi.json`` and exercise every endpoint.
"""

import json
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from src.api.main import app

SPEC_PATH = Path(__file__).resolve().parents[2] / "docs/api/openapi.json"

EXPECTED_ENDPOINTS = (
    "/api/health",
    "/api/stats",
    "/api/initiatives",
    "/api/initiatives/{initiative_id}",
)


@pytest.fixture(scope="module")
def client() -> TestClient:
    return TestClient(app)


def _committed_spec() -> dict:
    return json.loads(SPEC_PATH.read_text(encoding="utf-8"))


# --- committed OpenAPI artifact --------------------------------------------


def test_committed_spec_exists():
    assert SPEC_PATH.exists(), (
        "docs/api/openapi.json is missing; " "run scripts/export_openapi.py"
    )


def test_committed_spec_matches_app():
    # Normalise the live schema through JSON so the comparison is
    # type-for-type with the committed file. Drift means it is stale.
    live = json.loads(json.dumps(app.openapi()))
    assert (
        _committed_spec() == live
    ), "docs/api/openapi.json is stale; regenerate via export_openapi.py"


def test_spec_documents_all_endpoints():
    paths = _committed_spec()["paths"]
    for endpoint in EXPECTED_ENDPOINTS:
        assert endpoint in paths, f"missing OpenAPI path: {endpoint}"


def test_spec_version_matches_app():
    assert _committed_spec()["info"]["version"] == "0.1.0"


def test_openapi_served_at_runtime(client):
    resp = client.get("/openapi.json")
    assert resp.status_code == 200
    assert resp.json()["info"]["title"] == "GLAPAGOS Platform API"


# --- endpoint behaviour -----------------------------------------------------


def test_health(client):
    resp = client.get("/api/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok", "version": "0.1.0"}


def test_stats(client):
    resp = client.get("/api/stats")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total_initiatives"] >= 0
    assert isinstance(body["by_domain"], dict)
    assert isinstance(body["by_type"], dict)
    assert "data_version" in body


def test_list_initiatives(client):
    resp = client.get("/api/initiatives")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] == len(body["results"])
    assert body["filters"]["domain"] is None


def test_list_initiatives_with_filters(client):
    resp = client.get(
        "/api/initiatives",
        params={
            "domain": "nonexistent-domain",
            "status": "x",
            "type": "y",
            "country": "zz",
        },
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] == 0
    assert body["results"] == []


def test_get_initiative_found(client):
    listing = client.get("/api/initiatives").json()["results"]
    if not listing:
        pytest.skip("no initiatives in dataset")
    first_id = listing[0]["id"]
    resp = client.get(f"/api/initiatives/{first_id}")
    assert resp.status_code == 200
    assert resp.json()["id"] == first_id


def test_get_initiative_not_found(client):
    resp = client.get("/api/initiatives/__does_not_exist__")
    assert resp.status_code == 404
    assert "not found" in resp.json()["detail"].lower()
