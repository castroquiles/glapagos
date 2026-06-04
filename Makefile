# GLAPAGOS Makefile
# Run `make help` to see all available targets.

SHELL         := /bin/bash
.DEFAULT_GOAL := help

PYTHON        := python3
VENV          := .venv
VENV_PYTHON   := $(VENV)/bin/python
VENV_PIP      := $(VENV)/bin/pip

VERSION       := $(shell cat VERSION 2>/dev/null || echo "0.0.0-dev")
GIT_HASH      := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE    := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

DOCKER_REGISTRY := ghcr.io/glapagos-ai
DOCKER_IMAGE    := $(DOCKER_REGISTRY)/platform
DOCKER_TAG      := $(VERSION)

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ----------------------------------------------------------------------------
# Environment
# ----------------------------------------------------------------------------

.PHONY: venv
venv: ## Create Python virtual environment
	$(PYTHON) -m venv $(VENV)
	$(VENV_PIP) install --upgrade pip

.PHONY: install
install: venv ## Install all dependencies
	$(VENV_PIP) install -r requirements.txt
	npm ci

.PHONY: install-dev
install-dev: install ## Install all dependencies including development tools
	$(VENV_PIP) install -r requirements-dev.txt
	pre-commit install
	pre-commit install --hook-type commit-msg

.PHONY: verify
verify: ## Verify development environment is correctly configured
	@echo "Checking environment..."
	@$(PYTHON) --version
	@node --version
	@docker --version
	@git --version
	@echo "Environment OK"

# ----------------------------------------------------------------------------
# Linting and Formatting
# ----------------------------------------------------------------------------

.PHONY: lint
lint: lint-python lint-node ## Run all linters

.PHONY: lint-python
lint-python: ## Run Python linters
	$(VENV_PYTHON) -m black --check src/ tests/
	$(VENV_PYTHON) -m isort --check-only src/ tests/
	$(VENV_PYTHON) -m flake8 src/ tests/
	$(VENV_PYTHON) -m mypy src/

.PHONY: lint-node
lint-node: ## Run Node.js linters
	npm run lint

.PHONY: format
format: ## Auto-format Python code
	$(VENV_PYTHON) -m black src/ tests/
	$(VENV_PYTHON) -m isort src/ tests/

# ----------------------------------------------------------------------------
# Testing
# ----------------------------------------------------------------------------

.PHONY: test
test: test-unit test-integration ## Run full test suite

.PHONY: test-unit
test-unit: ## Run unit tests
	$(VENV_PYTHON) -m pytest tests/unit/ \
		--cov=src \
		--cov-report=term-missing \
		--cov-fail-under=80 \
		-v

.PHONY: test-integration
test-integration: ## Run integration tests (requires running services)
	$(VENV_PYTHON) -m pytest tests/integration/ -v --timeout=60

.PHONY: test-coverage
test-coverage: ## Run tests with full HTML coverage report
	$(VENV_PYTHON) -m pytest tests/ \
		--cov=src \
		--cov-report=html:coverage_html \
		--cov-report=xml \
		-v
	@echo "Coverage report: coverage_html/index.html"

# ----------------------------------------------------------------------------
# Documentation
# ----------------------------------------------------------------------------

.PHONY: docs
docs: ## Build documentation
	$(VENV_PYTHON) -m mkdocs build --strict

.PHONY: docs-serve
docs-serve: ## Serve documentation at localhost:8001
	$(VENV_PYTHON) -m mkdocs serve --dev-addr 127.0.0.1:8001

.PHONY: docs-deploy
docs-deploy: ## Deploy documentation to GitHub Pages (CI only)
	$(VENV_PYTHON) -m mkdocs gh-deploy --force

# ----------------------------------------------------------------------------
# Docker
# ----------------------------------------------------------------------------

.PHONY: docker-build
docker-build: ## Build Docker images
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg GIT_HASH=$(GIT_HASH) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE):latest \
		-f infrastructure/docker/Dockerfile \
		.

.PHONY: docker-up
docker-up: ## Start local services via Docker Compose
	docker compose -f infrastructure/docker/docker-compose.yml up -d

.PHONY: docker-down
docker-down: ## Stop local services
	docker compose -f infrastructure/docker/docker-compose.yml down

.PHONY: docker-logs
docker-logs: ## View local service logs
	docker compose -f infrastructure/docker/docker-compose.yml logs -f

.PHONY: docker-push
docker-push: ## Push Docker images to registry (CI only)
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

# ----------------------------------------------------------------------------
# Security
# ----------------------------------------------------------------------------

.PHONY: security-scan
security-scan: ## Run security scans
	$(VENV_PYTHON) -m pip_audit -r requirements.txt
	trivy fs . --severity HIGH,CRITICAL

.PHONY: sbom
sbom: ## Generate Software Bill of Materials
	syft . -o spdx-json > sbom.spdx.json
	@echo "SBOM written to sbom.spdx.json"

# ----------------------------------------------------------------------------
# Release
# ----------------------------------------------------------------------------

.PHONY: version
version: ## Display current version
	@cat VERSION

.PHONY: build
build: ## Build Python package
	$(VENV_PYTHON) -m build

.PHONY: release-patch
release-patch: ## Bump patch version and tag (maintainers only)
	@./scripts/bump-version.sh patch

.PHONY: release-minor
release-minor: ## Bump minor version and tag (maintainers only)
	@./scripts/bump-version.sh minor

.PHONY: release-major
release-major: ## Bump major version and tag (maintainers only)
	@./scripts/bump-version.sh major

# ----------------------------------------------------------------------------
# Infrastructure
# ----------------------------------------------------------------------------

.PHONY: tf-init
tf-init: ## Initialize Terraform
	cd infrastructure/terraform && terraform init

.PHONY: tf-plan
tf-plan: ## Plan Terraform changes
	cd infrastructure/terraform && terraform plan

.PHONY: tf-apply
tf-apply: ## Apply Terraform changes (requires confirmation)
	cd infrastructure/terraform && terraform apply

# ----------------------------------------------------------------------------
# Maintenance
# ----------------------------------------------------------------------------

.PHONY: clean
clean: ## Remove build artifacts and caches
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	find . -type d -name '*.egg-info' -delete
	rm -rf .pytest_cache .mypy_cache .coverage coverage_html coverage.xml
	rm -rf dist/ build/ site/

.PHONY: governance-check
governance-check: ## Verify governance documents are internally consistent
	$(VENV_PYTHON) tools/governance_check.py

.PHONY: translation-status
translation-status: ## Show translation coverage across languages
	$(VENV_PYTHON) tools/translation_status.py
