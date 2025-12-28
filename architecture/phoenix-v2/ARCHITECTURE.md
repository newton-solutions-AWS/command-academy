# Phoenix Protocol v2 — Architecture

## Core Principle
Phoenix v2 validates operator capability, not infrastructure state.

## Allowed Tooling
- AWS CLI only
- Read-only commands
- No fictional tools
- No external repositories

## Validation Model
All lessons validate execution success using behavior-based validation.

## Canonical Archetypes

IDENTITY:
aws sts get-caller-identity --query "Account" --output text

STORAGE:
aws s3 ls

COMPUTE:
aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text

NETWORK:
aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text

OBSERVABILITY:
aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text

## Validation Rule
Expected: "__EMPTY__"
Match: contains

## Transcript Policy
PASS on exit code 0
FAIL on CLI error
