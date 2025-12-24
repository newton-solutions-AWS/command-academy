export type CertificationThreshold = {
  id: string;
  canon: string;
  required_lessons: number;
  engine_version: string;
  title: string;
};

export const CERTIFICATION_THRESHOLDS: CertificationThreshold[] = [
  {
    id: "phoenix-secure-cloud-operator",
    title: "Phoenix Protocol — Secure Cloud Operator",
    canon: "phoenix-protocol-secure-cloud-operator",
    required_lessons: 8,
    engine_version: "engine-v1"
  },
  {
    id: "sentinel-defensive-operator",
    title: "Sentinel Protocol — Defensive Operations",
    canon: "sentinel-protocol-defensive-operations",
    required_lessons: 5,
    engine_version: "engine-v1"
  },
  {
    id: "vanguard-advanced-architect",
    title: "Vanguard Protocol — Advanced Architecture",
    canon: "vanguard-protocol-advanced-architecture",
    required_lessons: 5,
    engine_version: "engine-v1"
  }
];
