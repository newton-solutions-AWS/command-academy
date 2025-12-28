// cert_intel/intake/lib/phoenixArchetypes.ts

export type PhoenixV2Archetype =
  | "identity"
  | "storage"
  | "compute"
  | "iam"
  | "network"
  | "observe"
  | "serverless"
  | "security";

export function resolvePhoenixV2Archetype(
  lessonNumber: number
): PhoenixV2Archetype {
  const cycle: PhoenixV2Archetype[] = [
    "identity",    // STS / whoami
    "storage",     // S3
    "compute",     // EC2
    "iam",         // IAM visibility
    "network",     // VPC
    "observe",     // CloudWatch
    "serverless",  // Lambda
    "security",    // SGs / policies
  ];

  return cycle[(lessonNumber - 1) % cycle.length];
}