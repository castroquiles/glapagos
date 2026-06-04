# GLAPAGOS Data Governance Policy

Version 1.0 | Working Group: WG-DATA

---

## Purpose

This policy governs all data contributed to the GLAPAGOS Data Commons.
It establishes requirements for provenance documentation, consent,
licensing, quality, and ongoing stewardship.

---

## 1. Contribution Requirements

All datasets contributed to the Data Commons must include:

1.1 Manifest: A machine-readable manifest.json following the schema
at data/schemas/dataset-manifest-v1.json.

1.2 Provenance Record: Documentation of data origin, collection
methodology, collection date range, and the identity of the
collecting organization.

1.3 License: A declared open license compatible with ODbL. Datasets
under incompatible licenses are not accepted.

1.4 Integrity Checksums: SHA-256 checksums for all files, published
in a checksums.txt file accompanying the dataset.

1.5 Quality Documentation: Known limitations, gaps, potential biases,
and recommended use cases.

---

## 2. Indigenous Data Protocol

Data originating from or directly pertaining to Indigenous communities
is governed by an additional protocol that supersedes general
requirements where they conflict.

2.1 Consent Requirement: Free, prior, and informed consent must be
obtained from the relevant community governance body before
contribution. Consent documentation is attached to the manifest.

2.2 Benefit Sharing: A documented mechanism for returning value to
the contributing community must be established before contribution.

2.3 Right of Withdrawal: The contributing community retains the right
to request that their data not be used in future training or research.
Withdrawal applies to future use only; it does not retroactively
affect published research.

2.4 No Aggregation Without Consent: Indigenous language or cultural
data may not be aggregated with other data in ways that would make
re-identification of community members possible.

2.5 Community Governance: Where a community has established data
governance protocols, those protocols take precedence over this
policy for decisions within their scope.

---

## 3. Personal Data

No personal data about identifiable individuals may be contributed
to the Data Commons without:
- Explicit informed consent of the individuals, or
- A documented legal basis in the relevant jurisdiction, or
- Demonstrated anonymization sufficient to prevent re-identification

---

## 4. Data Residency

Contributors may specify data residency requirements. The GLAPAGOS
federation architecture supports localized access controls. Datasets
with residency requirements are indexed globally but accessed only
through designated regional nodes.

---

## 5. Quality Standards

Accepted datasets meet minimum quality standards:
- Documented and consistent encoding (UTF-8 for text)
- Consistent schema within files
- No corrupted or truncated files
- Sufficient documentation for a researcher unfamiliar with the
  collection to use it correctly

---

## 6. Ongoing Stewardship

Contributors are expected to:
- Respond to reported quality issues within 90 days
- Update provenance documentation if source information changes
- Notify the Data Commons if a dataset must be withdrawn

Datasets with unresolved critical quality issues for more than
180 days are subject to delisting pending contributor response.

---

Maintained by WG-DATA. For questions or to report issues with a
dataset, open a GitHub Issue with the label `wg-data`.
