#!/usr/bin/env bash
# =============================================================================
# GLAPAGOS Repository Bootstrap Script
# =============================================================================
# Initializes the GLAPAGOS repository and publishes it to GitHub.
#
# Prerequisites: git 2.39+, gh 2.40+, python3 3.10+, node 18+, docker 24+
#
# Usage:
#   chmod +x scripts/bootstrap.sh
#   GITHUB_ORG=your-org ./scripts/bootstrap.sh
# =============================================================================

set -euo pipefail

REPO_NAME="${REPO_NAME:-glapagos}"
GITHUB_ORG="${GITHUB_ORG:-glapagos-ai}"
DEFAULT_BRANCH="main"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_command() {
    command -v "$1" &> /dev/null || log_error "Required: '$1' not found."
}

echo ""
echo "============================================================"
echo "  GLAPAGOS Repository Bootstrap"
echo "============================================================"
echo ""

log_info "Checking prerequisites..."
check_command git
check_command gh
check_command python3
check_command node
check_command docker
log_success "All prerequisites met"

log_info "Checking GitHub CLI authentication..."
gh auth status &> /dev/null || gh auth login
log_success "GitHub CLI authenticated"

log_info "Creating GitHub repository..."
echo "Repository: github.com/${GITHUB_ORG}/${REPO_NAME}"
echo "Proceeding in 5 seconds. Press Ctrl+C to abort."
sleep 5

gh repo create "${GITHUB_ORG}/${REPO_NAME}" \
    --public \
    --description "Global Laboratory for AI Progress and Governance: Open Systems" \
    --homepage "https://www.glapagos.com" \
    --source=. \
    --remote=origin \
    --push

log_success "Repository created and pushed"

log_info "Configuring repository settings..."

gh api --method PATCH "repos/${GITHUB_ORG}/${REPO_NAME}" \
    --field has_issues=true \
    --field has_wiki=false \
    --field has_projects=true \
    --field has_discussions=true \
    --field allow_squash_merge=true \
    --field allow_merge_commit=false \
    --field allow_rebase_merge=false \
    --field delete_branch_on_merge=true

gh api --method PUT "repos/${GITHUB_ORG}/${REPO_NAME}/vulnerability-alerts"

log_success "Repository settings configured"

log_info "Setting repository topics..."
gh api --method PUT \
    "repos/${GITHUB_ORG}/${REPO_NAME}/topics" \
    --field names='["artificial-intelligence","latin-america","americas","open-source","ai-governance","multilateral","research","responsible-ai","ai-safety"]'
log_success "Topics set"

log_info "Creating issue labels..."
create_label() {
    gh label create "$1" --color "$2" --description "$3" \
        --repo "${GITHUB_ORG}/${REPO_NAME}" 2>/dev/null || true
}

create_label "bug"                "d73a4a" "Something is not working"
create_label "enhancement"        "a2eeef" "New feature or request"
create_label "governance"         "e4e669" "Governance and policy matters"
create_label "research"           "0075ca" "Research contributions"
create_label "data"               "f9d0c4" "Data contribution or governance"
create_label "security"           "b60205" "Security issue or improvement"
create_label "good-first-issue"   "7057ff" "Good for newcomers"
create_label "help-wanted"        "008672" "Extra attention is needed"
create_label "needs-triage"       "e4e669" "Needs maintainer review"
create_label "translation"        "cfd3d7" "Translation work"
create_label "wg-lang"            "0e8a16" "Working Group: Language"
create_label "wg-safety"          "0e8a16" "Working Group: Safety"
create_label "wg-gov"             "0e8a16" "Working Group: Governance"
create_label "wg-compute"         "0e8a16" "Working Group: Compute"
create_label "wg-data"            "0e8a16" "Working Group: Data"
create_label "wg-civic"           "0e8a16" "Working Group: Civic Technology"
create_label "wg-edu"             "0e8a16" "Working Group: Education"

log_success "Labels created"

log_info "Creating Phase 1 milestone..."
gh api --method POST \
    "repos/${GITHUB_ORG}/${REPO_NAME}/milestones" \
    --field title="Phase 1: Foundation (Day 30)" \
    --field description="Day 1-30 milestones per ROADMAP.md" \
    2>/dev/null || true
log_success "Milestone created"

echo ""
echo "============================================================"
echo "  Bootstrap Complete"
echo "============================================================"
echo ""
echo "  Repository: https://github.com/${GITHUB_ORG}/${REPO_NAME}"
echo "  Platform:   https://www.glapagos.com"
echo "  Research:   https://www.glapagos.ai"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Install development dependencies:"
echo "     make install-dev"
echo ""
echo "  2. Verify CI pipeline:"
echo "     gh run list --repo ${GITHUB_ORG}/${REPO_NAME}"
echo ""
echo "  3. Enable branch protection:"
echo "     gh api --method PUT repos/${GITHUB_ORG}/${REPO_NAME}/branches/main/protection \\"
echo "       --field required_status_checks='{\"strict\":true,\"contexts\":[\"lint\",\"test\",\"docs\",\"security\"]}' \\"
echo "       --field enforce_admins=false \\"
echo "       --field required_pull_request_reviews='{\"required_approving_review_count\":1}' \\"
echo "       --field restrictions=null"
echo ""
echo "  4. Begin institution outreach:"
echo "     See docs/governance/INSTITUTION-ENGAGEMENT.md"
echo ""
