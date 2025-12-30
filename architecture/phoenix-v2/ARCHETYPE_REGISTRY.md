# Archetype Registry (Phoenix v2)

This file defines what "real tools" means per archetype.
The generator must only output commands from the allowed set.

## aws
Allowed command prefix:
- aws

Allowed patterns:
- aws sts get-caller-identity ...
- aws s3 ls
- aws ec2 describe-* ...
- aws iam list-* ...
- aws cloudwatch describe-* ...
- aws lambda list-* ...

Default safety:
- no create/update/delete
- no terraform
- no kubectl unless archetype=kubernetes

## linux
Allowed command prefixes:
- ls, pwd, whoami, id, uname, cat, grep, find, ps, top, df, du, free, systemctl, journalctl

Default safety:
- no rm -rf
- no editing system files
- no sudo unless explicitly scoped

## network
Allowed command prefixes:
- ip, ss, netstat, traceroute, ping, dig, nslookup, curl, wget (read-only), nc (safe mode), arp

Default safety:
- no port scanning unless archetype=security with explicit permission

## security
Allowed command prefixes (safe, training):
- whois, dig, nslookup, curl, openssl s_client (read-only), nmap (ONLY if explicitly allowed + safe targets)

Default safety:
- training targets only
- no exploitation steps
