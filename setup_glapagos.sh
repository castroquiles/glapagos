#!/bin/bash

REPO="castroquiles/glapagos"

echo "=== Setting topics ==="
gh repo edit $REPO \
  --add-topic artificial-intelligence \
  --add-topic ai-governance \
  --add-topic latin-america \
  --add-topic open-source \
  --add-topic multilateral \
  --add-topic policy \
  --add-topic americas \
  --add-topic ai-safety \
  --add-topic international-cooperation \
  --add-topic public-interest-technology

echo "=== Creating labels ==="

# Type
gh label create "type: feature" --color "0075ca" --repo $REPO
gh label create "type: bug" --color "D93F0B" --repo $REPO
gh label create "type: docs" --color "e4e669" --repo $REPO
gh label create "type: research" --color "c5def5" --repo $REPO

# Priority
gh label create "priority: critical" --color "B60205" --repo $REPO
gh label create "priority: high" --color "D93F0B" --repo $REPO
gh label create "priority: medium" --color "E99695" --repo $REPO
gh label create "priority: low" --color "F9D0C4" --repo $REPO

# Domain
gh label create "domain: governance" --color "1D76DB" --repo $REPO
gh label create "domain: policy" --color "0052cc" --repo $REPO
gh label create "domain: platform" --color "5319e7" --repo $REPO
gh label create "domain: community" --color "006b75" --repo $REPO
gh label create "domain: research" --color "0e8a16" --repo $REPO

# Status
gh label create "status: in progress" --color "fbca04" --repo $REPO
gh label create "status: blocked" --color "e11d48" --repo $REPO
gh label create "status: needs review" --color "d4c5f9" --repo $REPO
gh label create "status: good first issue" --color "7057ff" --repo $REPO

echo "=== Creating milestones ==="

gh api repos/$REPO/milestones \
  --method POST \
  --field title="v0.1 — Foundation" \
  --field description="Core repo structure, governance framework draft, public landing presence, and initial contributor onboarding." \
  --field due_on="2025-08-31T00:00:00Z"

gh api repos/$REPO/milestones \
  --method POST \
  --field title="v0.2 — Community Launch" \
  --field description="First public call for contributors, working groups defined, and multilateral stakeholder outreach begins." \
  --field due_on="2025-11-30T00:00:00Z"

echo "=== Done ==="
