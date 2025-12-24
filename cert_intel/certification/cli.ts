#!/usr/bin/env ts-node

import { generateTranscript } from "../transcript/generateTranscript";
import { evaluateCertification } from "./evaluateCertification";

const [, , learnerId] = process.argv;

if (!learnerId) {
  console.error("Usage: cert-check <learner_id>");
  process.exit(1);
}

const transcript = generateTranscript(learnerId);
const results = evaluateCertification(transcript);

console.log(JSON.stringify(results, null, 2));

