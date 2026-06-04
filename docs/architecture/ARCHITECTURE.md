# GLAPAGOS Technical Architecture

Version 1.0 | Working Document

---

## Design Goals

The architecture satisfies the following constraints derived from the
mission and governance requirements.

Federated, not centralized: No single node controls the system. Any
member institution must be able to run a local instance that interoperates
with the global network without depending on any single infrastructure
provider.

Auditable: Every significant action is logged with sufficient context
for independent review. Logs are tamper-evident.

Multilingual from the ground up: The API, data schemas, documentation,
and interfaces support multiple languages without retrofitting. Language
is a first-class concern.

Modular: Components can be deployed and used independently. A researcher
who only needs the benchmark suite should not need to deploy the full
platform.

Long-lived: The architecture anticipates operation over decades.
Dependencies are chosen for stability. Breaking changes are versioned
and migrated, not dropped.

---

## System Components

### Core Platform Layer

Provides foundational services all other components depend on.

    src/core/
      auth/       Authentication and authorization (OAuth2, API keys, SSO)
      registry/   Module, model, and dataset registry
      audit/      Tamper-evident audit logging
      federation/ Federated instance discovery and communication
      storage/    Abstracted storage interface (local, S3-compatible)
      i18n/       Internationalization utilities

The core layer has no AI-specific dependencies. It is a general platform
for open, federated scientific collaboration.

### API Layer

Exposes platform capabilities over HTTP. Follows REST conventions with
OpenAPI 3.1 specification.

    src/api/
      v1/
        health/     Health and readiness endpoints
        registry/   Module, model, dataset registry endpoints
        research/   Research submission and retrieval
        governance/ Governance record access
        federation/ Inter-instance communication

API versioning is explicit in the URL path. Breaking changes require a
new major version.

### SDK Layer

Language-specific client libraries for interacting with the GLAPAGOS
API and local tools.

    src/sdk/
      python/     Python SDK (primary)
      typescript/ TypeScript SDK

### CLI Layer

Terminal access to all SDK functionality.

    src/cli/
      main.py
      commands/
        registry  Model, dataset, module registry commands
        bench     Benchmark commands
        publish   Publication commands
        config    Configuration management

---

## Data Architecture

### Data Commons

The Data Commons is a governed repository of open datasets. It is not
a centralized database. It is a specification for how datasets are
documented, indexed, and accessed.

Each dataset has:
- A machine-readable manifest (manifest.json)
- A provenance record tracing data origin, collection, and consent
- A governance record with applicable licenses and restrictions
- Integrity checksums for all files

Datasets are stored in contributors' infrastructure and indexed by the
GLAPAGOS registry. This prevents single-point-of-failure and respects
data residency requirements.

### Indigenous Data Protocol

Data originating from or pertaining to Indigenous communities requires:
- Free, prior, and informed consent documented before contribution
- Ongoing benefit-sharing mechanism documented in the manifest
- Community right to withdrawal for future use
- No aggregation with non-consented data

This is an architectural requirement enforced in the contribution
pipeline, not an optional policy.

### Model Registry

Registry entries include:
- Model card following the Americas AI Model Card standard
- Benchmark results from at least one GLAPAGOS benchmark
- License and usage terms
- Known limitations and failure modes
- Dependency manifest (training data, base models, compute)

### Benchmark Suite

Initial benchmark domains:
- AMER-LANG: Multilingual language understanding
- AMER-CULT: Cultural knowledge and representation
- AMER-SAFE: Safety evaluation for hemisphere-specific contexts
- AMER-CIVIC: Civic knowledge and reasoning across jurisdictions

Benchmarks are versioned. Comparisons must reference the same version.

---

## Federation Architecture

GLAPAGOS runs as a network of federated instances. A member institution
can run its own instance that:
- Maintains local copies of relevant registry entries
- Contributes locally hosted datasets and models to the global registry
- Runs benchmarks on local compute
- Participates in governance through the API

The federation protocol is published and open.

---

## Security Architecture

Authentication: OAuth2 with PKCE for human users. API key for machine
clients with rotation requirements. SAML2/OIDC for institutional SSO.
All tokens are short-lived.

Audit Logging: Append-only log with cryptographic chaining. Each entry
includes the hash of the previous entry, making retrospective
modification detectable.

Supply Chain: All dependencies pinned by version and hash. SBOM
generated on every release. Container images are signed.

---

## Deployment

Reference deployment uses infrastructure available from multiple cloud
providers, documented in infrastructure/terraform/. Cloud-provider-
agnostic by design.

Required infrastructure:
- Containerized API and worker services (Docker, Kubernetes)
- Relational database (PostgreSQL 15+)
- Object storage (S3-compatible)
- Reverse proxy and TLS termination

Estimated cost for reference deployment: $500-1500/month depending on
load, or equivalent on institutional on-premises hardware.

Full local development requires only Docker and Docker Compose.
Run `make docker-up` to start all required services.

---

This document is maintained alongside the GLAPAGOS codebase.
Implementation status is tracked in GitHub Issues.
