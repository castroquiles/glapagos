# Contributing to GLAPAGOS

This document covers the technical and procedural requirements for
contributing to GLAPAGOS across all domains: code, research, governance,
documentation, data, and education.

---

## Before You Contribute

Read in this order:
1. README.md: What GLAPAGOS is and what it is not
2. MANIFESTO.md: The principles underlying all decisions
3. CODE_OF_CONDUCT.md: Behavioral standards for this community
4. This document

For any contribution taking more than a few hours, open a GitHub Issue
first. This prevents duplicate effort and confirms alignment with current
priorities.

---

## Development Environment Setup

All commands are for Linux or macOS. Windows users should use WSL2.

    # 1. Clone the repository
    git clone https://github.com/glapagos-ai/glapagos.git
    cd glapagos

    # 2. Verify system requirements
    python3 --version    # Requires 3.10 or later
    node --version       # Requires 18 or later
    docker --version     # Requires 24 or later

    # 3. Create Python virtual environment
    python3 -m venv .venv
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    pip install -r requirements-dev.txt

    # 4. Install Node.js dependencies
    npm install

    # 5. Configure pre-commit hooks
    pre-commit install
    pre-commit install --hook-type commit-msg

    # 6. Copy environment template
    cp .env.example .env

    # 7. Verify setup
    make verify

---

## Makefile Commands

    make help              List all available commands
    make verify            Verify development environment
    make test              Run full test suite
    make test-unit         Run unit tests only
    make test-integration  Run integration tests
    make lint              Run all linters
    make format            Auto-format code
    make docs              Build documentation locally
    make docs-serve        Serve documentation at localhost:8001
    make docker-build      Build Docker images
    make docker-up         Start local services
    make docker-down       Stop local services
    make clean             Remove build artifacts

---

## Code Contributions

All code contributions must:
- Pass the full test suite (make test)
- Pass all linters (make lint)
- Have test coverage for new functionality (minimum 80% for new modules)
- Be documented in docstrings (numpy-style for Python, JSDoc for TS)
- Not introduce new dependencies without prior Issue approval

Branching:

    git checkout main
    git pull origin main
    git checkout -b feat/your-feature-name

    # Make changes, then commit
    git commit -m "feat(module-name): short description"

    # Push and open PR
    git push origin feat/your-feature-name
    gh pr create --title "feat(module-name): description"

Commit Message Format (Conventional Commits):

    type(scope): description

Valid types:  feat, fix, docs, style, refactor, test, chore, security
Valid scopes: core, api, sdk, cli, docs, infra, governance, data, edu

Pull Request Requirements:
- Linked to an open Issue
- All automated checks passing
- At least one review from a relevant CODEOWNERS designee
- Governance document PRs require two reviews

---

## Research Contributions

For datasets:
1. Open an Issue using the data-contribution template
2. Provide complete provenance documentation
3. Complete the Data Governance Checklist at data/standards/CHECKLIST.md
4. Indigenous data requires the Indigenous Data Protocol
5. Submit via pull request to data/

For benchmarks:
1. Open an Issue using the benchmark-contribution template
2. Include complete methodology description
3. Provide baseline results on at least two publicly available models
4. Submit via pull request to data/benchmarks/

---

## Documentation Contributions

All documentation follows the structure in docs/DOCUMENTATION-STANDARDS.md.
Translation contributions go to i18n/[language-code]/.

---

## Governance Contributions

Changes to CONSTITUTION.md, GOVERNANCE.md, CHARTER.md, or CITIZENSHIP.md
require:
- A GitHub Issue opened at least 14 days before submitting a PR
- Clear rationale for the proposed change
- Two reviews from Working Group leads or maintainers
- Comment period of minimum 7 days (Tier 3), 30 days (Tier 2),
  60 days (Tier 1)

---

## Code Review Standards

Reviewers:
- Review for correctness, not style (linters handle style)
- Provide specific, actionable feedback
- Respond within 5 business days of assignment
- Approve only when genuinely satisfied

Authors:
- Respond to all review comments
- Do not merge until all blocking comments are resolved

---

## Reporting Security Issues

Do not open a public GitHub Issue for security vulnerabilities.
See SECURITY.md for the responsible disclosure process.

---

## Getting Help

GitHub Discussions: Technical questions and architecture discussions
Issue Tracker: Bug reports, feature requests, contribution proposals
Working Group meetings: See community/councils/ for schedules
Primary platform: https://www.glapagos.com
