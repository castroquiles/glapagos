# Security Policy

## Supported Versions

| Version             | Supported                               |
|---------------------|-----------------------------------------|
| main branch         | Yes                                     |
| Latest release tag  | Yes                                     |
| Previous major      | Yes, for 12 months after supersession   |
| Older releases      | No                                      |

---

## Reporting a Vulnerability

Do not open a public GitHub Issue for security vulnerabilities.
Public disclosure before a fix is available can expose users to risk.

### Responsible Disclosure Process

1. Email your report to: security@glapagos.com
2. Encrypt using the GLAPAGOS Security PGP key published at
   https://www.glapagos.com/security
3. Include in your report:
   - Description of the vulnerability
   - Steps to reproduce
   - Your assessment of potential impact
   - Any suggested mitigations
4. You will receive acknowledgment within 48 hours
5. Estimated fix timeline provided within 7 days
6. Coordinated disclosure timeline agreed with reporter

### Our Commitments

- Acknowledgment within 48 hours
- No legal action against researchers following this policy
- Credit in security advisory unless reporter prefers anonymity
- Fix as rapidly as resources permit
- Notification when fix is deployed

### Disclosure Timeline

We aim to disclose within 90 days of report receipt. If a fix requires
longer, we communicate transparently about the reason and expected date.

---

## Security Architecture

Least Privilege: All components operate with minimum required permissions.

Defense in Depth: Security controls exist at multiple layers. No single
control failure should compromise the system.

Open Security: Security mechanisms are documented and auditable. We do
not rely on security through obscurity.

Supply Chain Integrity: All dependencies are pinned by version and hash,
verified on each build. The Software Bill of Materials (SBOM) is
published with each release.

Regular Auditing: An independent security audit is conducted annually.
Findings are published.

---

## Infrastructure Security

For deployments of GLAPAGOS infrastructure, consult:
- infrastructure/SECURITY-HARDENING.md
- infrastructure/terraform/ for reference infrastructure
- docs/architecture/THREAT-MODEL.md for the platform threat model

---

## Data Security

Data contributed to the GLAPAGOS Data Commons is subject to:
- Integrity verification on contribution (checksums published)
- Access logging
- The Data Governance Policy at data/standards/DATA-GOVERNANCE.md

Personal data handling follows the Privacy Policy at
docs/legal/PRIVACY-POLICY.md.
