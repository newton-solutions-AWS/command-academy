#!/usr/bin/env ts-node

import { generateTranscript } from "../transcript/generateTranscript";
import { evaluateCertification } from "./evaluateCertification";

const [, , learnerId] = process.argv;

if (!learnerId) {
  console.error("Usage: cli.ts <learnerId>");
  process.exit(1);
}

const transcript = generateTranscript(learnerId);
const result = evaluateCertification(transcript);

console.log(JSON.stringify(result, null, 2));